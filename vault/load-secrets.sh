#!/usr/bin/env sh
set -e

# ==================================================
# 🚀 Script : load-secrets.sh
# Objectif : Injecter les secrets applicatifs dans Vault
# ==================================================

# Adresse Vault (par défaut)
export VAULT_ADDR=${VAULT_ADDR:-http://127.0.0.1:8200}
export VAULT_TOKEN=${VAULT_TOKEN:-$(cat /vault/root.tokenttt 2>/dev/null)}

if [ -z "$VAULT_TOKEN" ]; then
  echo "❌ Aucun token Vault détecté (VAULT_TOKEN non défini)."
  exit 1
fi

echo "🔐 Injection des secrets dans Vault @ $VAULT_ADDR"
SECRET_PATH="secret"

# Vérifier que le moteur KV est bien monté
MOUNTED=$(vault secrets list -format=json | grep "\"$SECRET_PATH/\"" || true)
if [ -z "$MOUNTED" ]; then
  echo "🛠 Activation du moteur KV v2 sur '$SECRET_PATH'..."
  vault secrets enable -path="$SECRET_PATH" -version=2 kv
else
  echo "ℹ️ Moteur KV '$SECRET_PATH' déjà activé."
fi

echo ""
echo "💾 Injection des secrets applicatifs..."

# ================
# 🔐 AUTH SERVICE
# ================

vault kv put secret/authservice \
  JWT_SECRET="jwt_value" \
  DATABASE_URL="file:/app/data/database.sqlite" \
  HASH_SALT="hash_salt_value" \
  SESSION_SECRET="session_secret_value" \
  VAULT_TOKEN="vault_token_value"

vault policy write authservice /vault/policies/authservice.hcl

echo "🛠 Création du rôle AppRole pour authservice..."
vault write auth/approle/role/authservice \
  secret_id_ttl=0 \
  token_num_uses=0 \
  token_ttl=1h \
  token_max_ttl=4h \
  policies="authservice"

# Récupérer le ROLE_ID et SECRET_ID pour le conteneur
ROLE_ID=$(vault read -field=role_id auth/approle/role/authservice/role-id)
SECRET_ID=$(vault write -f -field=secret_id auth/approle/role/authservice/secret-id)

echo "✅ AppRole authservice créé."
echo "ROLE_ID=$ROLE_ID"
echo "SECRET_ID=$SECRET_ID"



# ================
# 🚪 API GATEWAY
# ================
vault kv put secret/api-gateway \
  AUTH_SERVICE_URL="http://authservice:4000" \
  API_KEY_INTERNAL="internal_api_key_value" \
  JWT_PUBLIC_KEY="jwt_public_value" \
  JWT_PRIVATE_KEY="jwt_private_value"

vault policy write api-gateway /vault/policies/api-gateway.hcl

echo "🛠 Création du rôle AppRole pour api-gateway..."
vault write auth/approle/role/api-gateway \
  secret_id_ttl=0 \
  token_num_uses=0 \
  token_ttl=1h \
  token_max_ttl=4h \
  policies="api-gateway"

# Récupérer le ROLE_ID et SECRET_ID pour le conteneur
ROLE_ID=$(vault read -field=role_id auth/approle/role/api-gateway/role-id)
SECRET_ID=$(vault write -f -field=secret_id auth/approle/role/api-gateway/secret-id)

echo "✅ AppRole api-gateway créé."
echo "ROLE_ID=$ROLE_ID"
echo "SECRET_ID=$SECRET_ID"


# ================
# 💾 DB WRITER
# ================
vault kv put secret/dbwriter \
  DATABASE_URL="file:/app/data/database.sqlite" \
  VAULT_TOKEN="vault_token_value"

vault policy write dbwriter /vault/policies/dbwriter.hcl

echo "🛠 Création du rôle AppRole pour dbwriter..."
vault write auth/approle/role/dbwriter \
  secret_id_ttl=0 \
  token_num_uses=0 \
  token_ttl=1h \
  token_max_ttl=4h \
  policies="dbwriter"

# Récupérer le ROLE_ID et SECRET_ID pour le conteneur
ROLE_ID=$(vault read -field=role_id auth/approle/role/dbwriter/role-id)
SECRET_ID=$(vault write -f -field=secret_id auth/approle/role/dbwriter/secret-id)

echo "✅ AppRole dbwriter créé."
echo "ROLE_ID=$ROLE_ID"
echo "SECRET_ID=$SECRET_ID"


# ================
# 🧱 VAULT
# ================
vault kv put secret/vault \
  VAULT_ROOT_TOKEN="vault_root_token_value" \
  VAULT_UNSEAL_KEYS="vault_unseal_keys_value"

vault policy write vault /vault/policies/vault.hcl

echo "🛠 Création du rôle AppRole pour vault..."
vault write auth/approle/role/vault \
  secret_id_ttl=0 \
  token_num_uses=0 \
  token_ttl=1h \
  token_max_ttl=4h \
  policies="vault"

# Récupérer le ROLE_ID et SECRET_ID pour le conteneur
ROLE_ID=$(vault read -field=role_id auth/approle/role/vault/role-id)
SECRET_ID=$(vault write -f -field=secret_id auth/approle/role/vault/secret-id)

echo "✅ AppRole vault créé."
echo "ROLE_ID=$ROLE_ID"
echo "SECRET_ID=$SECRET_ID"

# ================
# ⛓️ BLOCKCHAIN
# ================
vault kv put secret/blockchain \
  BLOCKCHAIN_PRIVATE_KEY="private_key_value" \
  BLOCKCHAIN_RPC_URL="rpc_url_value" \
  BLOCKCHAIN_NETWORK_ID="blockchain_network_id_value"

vault policy write blockchain /vault/policies/blockchain.hcl

echo "🛠 Création du rôle AppRole pour blockchain..."
vault write auth/approle/role/blockchain \
  secret_id_ttl=0 \
  token_num_uses=0 \
  token_ttl=1h \
  token_max_ttl=4h \
  policies="blockchain"

# Récupérer le ROLE_ID et SECRET_ID pour le conteneur
ROLE_ID=$(vault read -field=role_id auth/approle/role/blockchain/role-id)
SECRET_ID=$(vault write -f -field=secret_id auth/approle/role/blockchain/secret-id)

echo "✅ AppRole blockchain créé."
echo "ROLE_ID=$ROLE_ID"
echo "SECRET_ID=$SECRET_ID"

# ================
# 🛡️ WAF
# ================
vault kv put secret/waf \
  SSL_CERT="PEM_content" \
  SSL_KEY="PEM_content" \
  MODSECURITY_SECRET_KEY="secret_modsec_key"

vault policy write waf /vault/policies/waf.hcl

echo "🛠 Création du rôle AppRole pour waf..."
vault write auth/approle/role/waf \
  secret_id_ttl=0 \
  token_num_uses=0 \
  token_ttl=1h \
  token_max_ttl=4h \
  policies="waf"

# Récupérer le ROLE_ID et SECRET_ID pour le conteneur
ROLE_ID=$(vault read -field=role_id auth/approle/role/waf/role-id)
SECRET_ID=$(vault write -f -field=secret_id auth/approle/role/waf/secret-id)

echo "✅ AppRole waf créé."
echo "ROLE_ID=$ROLE_ID"
echo "SECRET_ID=$SECRET_ID"

# ================
# 🌐 FRONTEND
# ================
vault kv put secret/frontend \
  API_BASE_URL="url_value" \
  PUBLIC_KEY="PEM_content"

vault policy write frontend /vault/policies/frontend.hcl

echo "🛠 Création du rôle AppRole pour frontend..."
vault write auth/approle/role/frontend \
  secret_id_ttl=0 \
  token_num_uses=0 \
  token_ttl=1h \
  token_max_ttl=4h \
  policies="frontend"

# Récupérer le ROLE_ID et SECRET_ID pour le conteneur
ROLE_ID=$(vault read -field=role_id auth/approle/role/frontend/role-id)
SECRET_ID=$(vault write -f -field=secret_id auth/approle/role/frontend/secret-id)

echo "✅ AppRole frontend créé."
echo "ROLE_ID=$ROLE_ID"
echo "SECRET_ID=$SECRET_ID"


echo ""
echo "✅ Tous les secrets ont été chargés avec succès dans Vault."
