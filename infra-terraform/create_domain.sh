#!/usr/bin/env bash

set -euo pipefail

if ! command -v jq > /dev/null; then
    echo "Esse script requer o jq" >&2
    exit 1
fi
if ! command -v aws > /dev/null; then
    echo "Esse script requer a AWS CLI" >&2
    exit 1
fi

if ! aws sts get-caller-identity &> /dev/null; then
    echo "Você não está autenticado na AWS CLI. Configure ela agora:" >&2
    if ! aws configure; then
        exit 2
    fi
fi

if [ -n "${1-}" ]; then
    domain="$1"
else
    read -p "Digite o domínio a ser registrado: " domain
    if [ -z "${domain:-}" ]; then
        exit 3
    fi
fi

output="$(aws --output json route53 create-hosted-zone --name $domain --caller-reference "$(date -Iseconds)")"

echo "O ID da zone (configure na action):" >&2
echo "$output" | jq -r '.HostedZone.Id' | cut -d '/' -f3
echo ""
echo "Os nameservers do domínio (configure no registrar):" >&2
echo "$output" | jq -r '.DelegationSet.NameServers | join("\n")'
