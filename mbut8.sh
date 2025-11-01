#!/bin/bash

REMOTE_PATH="/var/www/pterodactyl/app/Http/Controllers/Api/Client/Servers/ServerController.php"
TIMESTAMP=$(date -u +"%Y-%m-%d-%H-%M-%S")
BACKUP_PATH="${REMOTE_PATH}.bak_${TIMESTAMP}"

echo "🚀 Mengaktifkan Cyber Defense Layer: ServerController Protection by Than..."

if [ -f "$REMOTE_PATH" ]; then
  mv "$REMOTE_PATH" "$BACKUP_PATH"
  echo "📦 File lama diamankan di $BACKUP_PATH"
fi

mkdir -p "$(dirname "$REMOTE_PATH")"
chmod 755 "$(dirname "$REMOTE_PATH")"

cat > "$REMOTE_PATH" << 'EOF'
<?php
/**
 * ─────────────────────────────────────────────────────────────
 * ⚔️  Cyber Defense Layer: ServerController Access Enforcement
 * Author  : Than
 * Version : Secure Build v1.0
 * Date    : $(date +"%Y-%m-%d %H:%M:%S")
 *
 * Description:
 *   This controller is hardened under Than’s Zero-Trust Policy.
 *   Every access is validated — only the rightful server owner 
 *   or root administrator (User ID 1) can interact with data.
 *
 *   “Access is not a right — it’s a verified privilege.” — Than
 * ─────────────────────────────────────────────────────────────
 */

namespace Pterodactyl\Http\Controllers\Api\Client\Servers;

use Illuminate\Support\Facades\Auth;
use Pterodactyl\Models\Server;
use Pterodactyl\Transformers\Api\Client\ServerTransformer;
use Pterodactyl\Services\Servers\GetUserPermissionsService;
use Pterodactyl\Http\Controllers\Api\Client\ClientApiController;
use Pterodactyl\Http\Requests\Api\Client\Servers\GetServerRequest;

class ServerController extends ClientApiController
{
    public function __construct(private GetUserPermissionsService \$permissionsService)
    {
        parent::__construct();
    }

    /**
     * 🧠 Secure Endpoint: Enforces ownership validation.
     */
    public function index(GetServerRequest \$request, Server \$server): array
    {
        \$authUser = Auth::user();

        // 🛡️ Zero Trust Enforcement
        if (\$authUser->id !== 1 && (int) \$server->owner_id !== (int) \$authUser->id) {
            abort(403, '🚫 Access Denied — This server is not registered under your authorization.');
        }

        return \$this->fractal->item(\$server)
            ->transformWith(\$this->getTransformer(ServerTransformer::class))
            ->addMeta([
                'is_server_owner' => \$request->user()->id === \$server->owner_id,
                'user_permissions' => \$this->permissionsService->handle(\$server, \$request->user()),
            ])
            ->toArray();
    }
}
EOF

chmod 644 "$REMOTE_PATH"

echo "✅ ServerController berhasil diamankan dengan Cyber Defense Layer by Than."
echo "📂 Lokasi file: $REMOTE_PATH"
echo "🗂️ Backup file lama: $BACKUP_PATH"
echo "🔒 Mode keamanan aktif: Hanya Admin (ID 1) dan pemilik server yang memiliki izin akses."
echo "🧠 Kebijakan: Zero Trust Access Verification diterapkan secara menyeluruh."