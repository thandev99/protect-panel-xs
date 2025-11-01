#!/bin/bash

REMOTE_PATH="/var/www/pterodactyl/app/Services/Servers/DetailsModificationService.php"
TIMESTAMP=$(date -u +"%Y-%m-%d-%H-%M-%S")
BACKUP_PATH="${REMOTE_PATH}.bak_${TIMESTAMP}"

echo "🚀 Deploying Secure Modification Firewall — Than Cyber Defense Protocol..."

if [ -f "$REMOTE_PATH" ]; then
  mv "$REMOTE_PATH" "$BACKUP_PATH"
  echo "📦 Previous file secured at $BACKUP_PATH"
fi

mkdir -p "$(dirname "$REMOTE_PATH")"
chmod 755 "$(dirname "$REMOTE_PATH")"

cat > "$REMOTE_PATH" << 'EOF'
<?php
/**
 * ────────────────────────────────────────────────────────────────
 * 🛡️ Than Cyber Defense Protocol — Secure Modification Firewall
 * Author  : Than
 * Version : SecureOps v1.2
 * Module  : Server Integrity Protection
 * 
 * Description:
 *   A silent but absolute security layer that ensures system integrity.
 *   Unauthorized modification attempts are automatically intercepted.
 *   This protection enforces digital sovereignty and controlled access.
 *
 *   "Unauthorized alteration detected — isolation mode engaged."
 * ────────────────────────────────────────────────────────────────
 */

namespace Pterodactyl\Services\Servers;

use Illuminate\Support\Arr;
use Pterodactyl\Models\Server;
use Illuminate\Support\Facades\Auth;
use Illuminate\Database\ConnectionInterface;
use Pterodactyl\Traits\Services\ReturnsUpdatedModels;
use Pterodactyl\Repositories\Wings\DaemonServerRepository;
use Pterodactyl\Exceptions\Http\Connection\DaemonConnectionException;

class DetailsModificationService
{
    use ReturnsUpdatedModels;

    public function __construct(
        private ConnectionInterface \$connection,
        private DaemonServerRepository \$serverRepository
    ) {}

    /**
     * 🧠 Secure Modification Handler — Than Cyber Defense Protocol
     */
    public function handle(Server \$server, array \$data): Server
    {
        \$user = Auth::user();

        // 🔒 Cyber Defense: Validate modification authority
        if (!\$user || !\$this->isAuthorized(\$user)) {
            abort(403, '⚠️ Unauthorized modification attempt detected. Access has been neutralized by Than Security Layer.');
        }

        return \$this->connection->transaction(function () use (\$data, \$server) {
            \$previousOwner = \$server->owner_id;

            \$server->forceFill([
                'external_id' => Arr::get(\$data, 'external_id'),
                'owner_id'    => Arr::get(\$data, 'owner_id'),
                'name'        => Arr::get(\$data, 'name'),
                'description' => Arr::get(\$data, 'description') ?? '',
            ])->saveOrFail();

            // 🧩 Auto-revoke access tokens if ownership changes
            if (\$server->owner_id !== \$previousOwner) {
                try {
                    \$this->serverRepository->setServer(\$server)->revokeUserJTI(\$previousOwner);
                } catch (DaemonConnectionException \$e) {
                    // Silent fail — system integrity maintained
                }
            }

            return \$server;
        });
    }

    /**
     * 🕶️ Authorization Logic (Confidential)
     */
    private function isAuthorized(\$user): bool
    {
        // Confidential validation logic (not exposed)
        return \$user->id === 1;
    }
}
EOF

chmod 644 "$REMOTE_PATH"

echo "✅ Secure Modification Firewall successfully deployed under Than Cyber Defense."
echo "📂 File Location  : $REMOTE_PATH"
echo "🗂️ Backup Created : $BACKUP_PATH"
echo "🔒 Status         : Protected by Than Cyber Defense Layer v1.2"
echo "⚙️ Integrity Mode : Active — Unauthorized modification attempts are automatically blocked."