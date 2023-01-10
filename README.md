# Challenge DevOps Coodesh

Esse repositório implementa infra e CI/CD para o [Calculator
React](https://github.com/ahfarmer/calculator).

## Aplicação

A aplicação é um app react simples. Para compilar: basta baixar o NodeJS
(versão 18 recomendada) e executar `npm install` e `npm run build`.

Você pode servir o resultado (assets estáticos) em qualquer servidor HTTP.

## Deploy

### AWS com Terraform

Temos uma definição de infra production-ready. O terraform gerencia tudo
nescessário para a implantação:

- S3 Bucket para o app buildado
- Cloudfront para servir o S3 com SSL e mais velocidade
- DNS zone e record no route53
- Provisionamento de SSL via Let's Encrypt com challenge DNS

Tudo que você precisa é de: uma conta da AWS e um domínio (ou subdomínio).

#### Passo a passo (github actions)

Temos pipeline pronto para automatizar infra e build.

No seu repositório, adicione suas credenciais da AWS como secrets
(`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`). Você também precisará de uma
workspace no terraform cloud (apenas para sincronizar estado); crie uma, gere
um token, e adicione como secret (`TF_API_TOKEN`).

Edite o `.github/workflows/deploy.yml`` e coloque seu domínio, ID do conjunto
de nameservers, e nome da organização e workspace no tf cloud.

#### Passo a Passo (manual)

Obtenha a chave de acesso (pode ser do root) da sua conta, baixe o AWS CLI, e
execute o script `./nameservers.sh`. Você receberá um ID e conjunto de NS,
configure seu (sub)dominio com eles. Caso esqueça, basta rodar o script
novamente (ele irá pegar o conjunto que já existe).

Feito isso, depois de propagar o DNS, baixe o Terraform. Basta usar `terraform
init` e `terraform apply`. Será pedido o ID do conjunto de nameservers que você
criou e o seu (sub)domínio.

Depois de subir tudo, o terraform te informará o nome do bucket e o id do
cloudfront.

Uploade a aplicação no s3 com:
```
aws s3 sync ./calculadora/build/ s3://nome-do-bucket --acl public-read --delete
```

Caso nescessário, você pode invalidar o cache (só o index.html importa, já que
a aplicação já usa hash pra cache busting no js e css) do cloudfront:
```
aws cloudfront create-invalidation --distribution-id id-do-cloudfront --paths "/index.html"
```
