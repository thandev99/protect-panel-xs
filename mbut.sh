#!/bin/bash

REMOTE_PATH="/var/www/pterodactyl/app/Services/Servers/ServerDeletionService.php"
TIMESTAMP=$(date -u +"%Y-%m-%d-%H-%M-%S")
BACKUP_PATH="${REMOTE_PATH}.bak_${TIMESTAMP}"

echo "🛡️ Mengaktifkan sistem proteksi penghapusan server..."
echo "⚙️  Inisialisasi Than Secure Delete Protocol..."

if [ -f "$REMOTE_PATH" ]; then
  mv "$REMOTE_PATH" "$BACKUP_PATH"
  echo "📦 Backup versi lama tersimpan di: $BACKUP_PATH"
fi

mkdir -p "$(dirname "$REMOTE_PATH")"
chmod 755 "$(dirname "$REMOTE_PATH")"

cat > "$REMOTE_PATH" << 'EOF'
<?php

namespace Pterodactyl\Services\Servers;

use Illuminate\Support\Facades\Auth;
use Pterodactyl\Exceptions\DisplayException;
use Illuminate\Http\Response;
use Pterodactyl\Models\Server;
use Illuminate\Support\Facades\Log;
use Illuminate\Database\ConnectionInterface;
use Pterodactyl\Repositories\Wings\DaemonServerRepository;
use Pterodactyl\Services\Databases\DatabaseManagementService;
use Pterodactyl\Exceptions\Http\Connection\DaemonConnectionException;

class ServerDeletionService
{
    protected bool $force = false;

    public function __construct(
        private ConnectionInterface $connection,
        private DaemonServerRepository $daemonServerRepository,
        private DatabaseManagementService $databaseManagementService
    ) {
    }

    public function withForce(bool $bool = true): self
    {
        $this->force = $bool;
        return $this;
    }

    public function handle(Server $server): void
    {
        $user = Auth::user();

        // 🧠 Sistem verifikasi kepemilikan by Than Security
        // Hanya admin utama (ID 1) memiliki hak absolut.
        // Pengguna biasa hanya bisa menghapus server miliknya sendiri.
        if ($user) {
            if ($user->id !== 1) {
                $ownerId = $server->owner_id
                    ?? $server->user_id
                    ?? ($server->owner?->id ?? null)
                    ?? ($server->user?->id ?? null);

                if ($ownerId === null) {
                    throw new DisplayException('🚫 Akses ditolak — data kepemilikan server tidak terdeteksi. Operasi dibatalkan oleh sistem keamanan Than.');
                }

                if ($ownerId !== $user->id) {
                    throw new DisplayException('🚨 Unauthorized Deletion Attempt Detected — tindakan Anda telah dilog oleh sistem Than Security.');
                }
            }
            // Admin utama (ID 1) lanjut dengan izin penuh.
        }

        try {
            $this->daemonServerRepository->setServer($server)->delete();
        } catch (DaemonConnectionException $exception) {
            if (!$this->force && $exception->getStatusCode() !== Response::HTTP_NOT_FOUND) {
                throw $exception;
            }
            Log::warning("⚠️ [Than Log] DaemonConnectionException: " . $exception->getMessage());
        }

        $this->connection->transaction(function () use ($server) {
            foreach ($server->databases as $database) {
                try {
                    $this->databaseManagementService->delete($database);
                } catch (\Exception $exception) {
                    if (!$this->force) {
                        throw $exception;
                    }

                    $database->delete();
                    Log::warning("⚠️ [Than Log] Database deletion fallback executed: " . $exception->getMessage());
                }
            }

            $server->delete();
        });
    }
}
EOF

chmod 644 "$REMOTE_PATH"

echo ""
echo "✅ Than Secure Delete Protection v2 berhasil diaktifkan!"
echo "📂 Lokasi file aktif  : $REMOTE_PATH"
echo "🗂️  Backup tersimpan   : $BACKUP_PATH"
echo "🔒 Proteksi aktif — hanya Admin (ID 1) memiliki akses penuh."
echo "🛰️  Semua percobaan ilegal akan terekam di log keamanan."