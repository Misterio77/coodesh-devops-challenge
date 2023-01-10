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

echo "Buscando nameserver delegation sets..." >&2
list_result="$(aws --output json route53 list-reusable-delegation-sets)"
delegation_set="$(jq '.DelegationSets[0]' <<< "$list_result")"

if [ "$delegation_set" = "null" ]; then
    echo "" >&2
    echo "Nenhum encontrado. Criando..." >&2
    create_result="$(aws --output json route53 create-reusable-delegation-set --caller-reference $(date -Iminutes))"
    delegation_set="$(jq '.DelegationSet' <<< "$create_result")"
    echo "Sucesso." >&2
fi
echo "" >&2

echo "Seu delegation set ID, configure ele na pipeline: " >&2
jq -r '.Id' <<< "$delegation_set" | cut -d '/' -f3
echo ""
echo "Seus nameservers, configure eles na registrar: " >&2
jq -r '.NameServers | join("\n")' <<< "$delegation_set"
