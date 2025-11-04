# ===========================================
# Policy : frontend.hcl
# Objectif : accès lecture seule pour le frontend
# ===========================================

# Autoriser la lecture uniquement des secrets du frontend
path "secret/data/frontend/*" {
  capabilities = ["read"]
}

# Autoriser la liste des clés (utile si le service énumère ses secrets)
path "secret/metadata/frontend/*" {
  capabilities = ["list"]
}
