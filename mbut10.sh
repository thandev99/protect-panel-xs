#!/bin/bash

TARGET_FILE="/var/www/pterodactyl/resources/views/templates/base/core.blade.php"
BACKUP_FILE="${TARGET_FILE}.bak_$(date -u +"%Y-%m-%d-%H-%M-%S")"

echo "🚀 Mengganti isi $TARGET_FILE..."

# Backup dulu file lama
if [ -f "$TARGET_FILE" ]; then
  cp "$TARGET_FILE" "$BACKUP_FILE"
  echo "📦 Backup file lama dibuat di $BACKUP_FILE"
fi

cat > "$TARGET_FILE" << 'EOF'
@extends('templates/wrapper', [
    'css' => ['body' => 'bg-neutral-800'],
])

@section('container')
    <div id="modal-portal"></div>
    <div id="app"></div>

    <script>
      document.addEventListener("DOMContentLoaded", () => {
        const username = @json(auth()->user()->name ?? 'User');

        const message = document.createElement("div");
        message.innerText = `🛰 Connection Verified — Welcome ${username}\n🔒 Than Security Protocol Active`;
        Object.assign(message.style, {
          position: "fixed",
          bottom: "20px",
          right: "20px",
          background: "rgba(0,0,0,0.8)",
          color: "#fff",
          padding: "10px 15px",
          borderRadius: "8px",
          fontFamily: "monospace",
          fontSize: "14px",
          boxShadow: "0 0 10px rgba(0,0,0,0.3)",
          zIndex: "9999",
          whiteSpace: "pre-line",
          opacity: "1",
          transition: "opacity 1s ease"
        });

        document.body.appendChild(message);
        setTimeout(() => message.style.opacity = "0", 4000);
        setTimeout(() => message.remove(), 5000);
      });
    </script>
@endsection
EOF

echo "✅ Isi $TARGET_FILE sudah diganti dengan konten baru."