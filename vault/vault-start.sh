#!/usr/bin/env bash
set -e

VAULT=${VAULT:-vault}

vault server -config=/vault/config/config.hcl &  # lance Vault
VAULT_PID=$!

sh /vault/vault-init.sh

wait $VAULT_PID  # garder Vault comme PID1
