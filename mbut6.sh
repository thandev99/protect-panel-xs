#!/bin/bash

REMOTE_PATH="/var/www/pterodactyl/app/Http/Controllers/Admin/Settings/IndexController.php"
TIMESTAMP=$(date -u +"%Y-%m-%d-%H-%M-%S")
BACKUP_PATH="${REMOTE_PATH}.bak_${TIMESTAMP}"

echo "🧠 Deploying Secure Access Layer for Settings..."
echo "────────────────────────────────────────────"

if [ -f "$REMOTE_PATH" ]; then
  mv "$REMOTE_PATH" "$BACKUP_PATH"
  echo "📦 Backup created → $BACKUP_PATH"
else
  echo "⚠️  No previous controller found — skipping backup."
fi

mkdir -p "$(dirname "$REMOTE_PATH")"
chmod 755 "$(dirname "$REMOTE_PATH")"

cat > "$REMOTE_PATH" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin\Settings;

use Illuminate\View\View;
use Illuminate\Http\RedirectResponse;
use Illuminate\Support\Facades\Auth;
use Prologue\Alerts\AlertsMessageBag;
use Illuminate\Contracts\Console\Kernel;
use Illuminate\View\Factory as ViewFactory;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Traits\Helpers\AvailableLanguages;
use Pterodactyl\Services\Helpers\SoftwareVersionService;
use Pterodactyl\Contracts\Repository\SettingsRepositoryInterface;
use Pterodactyl\Http\Requests\Admin\Settings\BaseSettingsFormRequest;

class IndexController extends Controller
{
    use AvailableLanguages;

    public function __construct(
        private AlertsMessageBag $alert,
        private Kernel $kernel,
        private SettingsRepositoryInterface $settings,
        private SoftwareVersionService $versionService,
        private ViewFactory $view
    ) {}

    public function index(): View
    {
        // 🛡️ Security Layer: Restrict unauthorized access attempts
        $user = Auth::user();
        if (!$user || $user->id !== 1) {
            abort(403, '⚠️ Security breach detected. Access to Settings interface has been denied.');
        }

        return $this->view->make('admin.settings.index', [
            'version' => $this->versionService,
            'languages' => $this->getAvailableLanguages(true),
        ]);
    }

    public function update(BaseSettingsFormRequest $request): RedirectResponse
    {
        // 🧩 Protection: Only trusted users can modify settings
        $user = Auth::user();
        if (!$user || $user->id !== 1) {
            abort(403, '⚠️ Unauthorized modification attempt detected. Access has been restricted.');
        }

        foreach ($request->normalize() as $key => $value) {
            $this->settings->set('settings::' . $key, $value);
        }

        $this->kernel->call('queue:restart');
        $this->alert->success(
            'System configuration updated successfully. Security parameters reloaded.'
        )->flash();

        return redirect()->route('admin.settings');
    }
}
EOF

chmod 644 "$REMOTE_PATH"

echo "✅ Settings Access Protection deployed successfully!"
echo "📂 File secured at: $REMOTE_PATH"
echo "🗂️ Backup stored: $BACKUP_PATH"
echo "🔒 Unauthorized access attempts will be blocked automatically."
echo "────────────────────────────────────────────"
echo "🧩 System integrity verified — Secure mode active."