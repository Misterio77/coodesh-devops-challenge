#!/usr/bin/env bash

set -euo pipefail

export AWS_REGION="us-east-1"

if ! command -v aws > /dev/null; then
    echo "Esse script requer a AWS CLI" >&2
    exit 1
fi

if ! command -v aws > /dev/null; then
    echo "Esse script requer o jq" >&2
    exit 1
fi

if ! aws sts get-caller-identity > /dev/null;  then
    echo "Você não está autenticado na AWS. Configure agora:" >&2
    if ! aws configure; then
        exit 2
    fi
fi

if [ -n "${1:-}" ]; then
    domain="$1"
else
    read -p "Digite o domínio (sem trailing dot): " domain
    echo "" >&2
    if [ -z "${domain:-}" ]; then
        exit 3
    fi
fi

caller_reference="$(date -Iminutes)"
bucket_name="$(echo "$domain" | tr '.' '-')-tfstate"


zones="$(aws route53 list-hosted-zones)"
zone="$(echo "$zones" | jq -r --arg domain "$domain" '.HostedZones | map(select(.Name == "\($domain).")) | .[0]')"
if [ -z "${zone:-}" ]; then
    zone="$(aws route53 create-hosted-zone --name "$domain" --caller-reference "$caller_reference" | jq -r '.HostedZone')"
fi
zone_id="$(echo "$zone" | jq -er '.Id' | cut -d '/' -f3)"

buckets="$(aws s3api list-buckets)"
bucket="$(echo "$buckets" | jq -r --arg name "$bucket_name" '.Buckets[] | select(.Name == $name)')"
if [ -z "${bucket:-}" ]; then
    bucket="$(aws s3api create-bucket --bucket "$bucket_name")"
fi
bucket_name="$(echo "$bucket" | jq -er '.Name')"

terraform init -backend-config "bucket=$bucket_name"
terraform import -var "domain=$domain" aws_route53_zone.main "$zone_id"
terraform import -var "domain=$domain" aws_s3_bucket.tfstate "$bucket_name"
