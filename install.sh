#!/usr/bin/env bash
set -e

ENV_EXAMPLE=".env.example"
ENV_FILE=".env"

# --------------------------------------------------
# Kontroller
# --------------------------------------------------
if [ ! -f "$ENV_EXAMPLE" ]; then
  echo "❌ $ENV_EXAMPLE bulunamadı."
  exit 1
fi

if [ ! -f "$ENV_FILE" ]; then
  cp "$ENV_EXAMPLE" "$ENV_FILE"
  echo "✅ $ENV_EXAMPLE → $ENV_FILE kopyalandı"
else
  echo "ℹ️  $ENV_FILE mevcut, güncellenecek"
fi

# --------------------------------------------------
# Yardımcı Fonksiyonlar
# --------------------------------------------------
gen_password() {
  openssl rand -base64 24 | tr -dc 'A-Za-z0-9' | head -c 20
}

gen_encryption_key() {
  openssl rand -hex 16
}

set_env() {
  local key="$1"
  local value="$2"

  if grep -q "^${key}=" "$ENV_FILE"; then
    sed -i "s|^${key}=.*|${key}=${value}|" "$ENV_FILE"
  else
    echo "${key}=${value}" >> "$ENV_FILE"
  fi
}

set_env_once() {
  local key="$1"
  local value="$2"

  local current
  current=$(grep "^${key}=" "$ENV_FILE" 2>/dev/null | cut -d'=' -f2-)

  if [ -z "$current" ]; then
    set_env "$key" "$value"
  fi
}

# --------------------------------------------------
# Kullanıcıdan Gerekli Bilgiler
# --------------------------------------------------
read -rp "HOPPSCOTCH_SERVER_HOSTNAME (örn: hoppscotch.example.com): " HOPPSCOTCH_SERVER_HOSTNAME

# --------------------------------------------------
# .env Güncelle — Hostname
# --------------------------------------------------
set_env HOPPSCOTCH_SERVER_HOSTNAME "$HOPPSCOTCH_SERVER_HOSTNAME"

# --------------------------------------------------
# .env Güncelle — Secret'lar (mevcut değerlere dokunma)
# --------------------------------------------------
set_env_once DATABASE_PASSWORD   "$(gen_password)"
set_env_once DATA_ENCRYPTION_KEY "$(gen_encryption_key)"

DATABASE_PASSWORD=$(grep "^DATABASE_PASSWORD=" "$ENV_FILE" | cut -d'=' -f2-)

# --------------------------------------------------
# Sonuçları Göster
# --------------------------------------------------
echo
echo "==============================================="
echo "✅ Hoppscotch .env başarıyla hazırlandı"
echo "-----------------------------------------------"
echo "🌐 Hostname      : $HOPPSCOTCH_SERVER_HOSTNAME"
echo "🔑 DB Şifresi    : $DATABASE_PASSWORD"
echo "-----------------------------------------------"
echo "⚠️  Şifreyi güvenli bir yerde saklayın!"
echo "==============================================="
