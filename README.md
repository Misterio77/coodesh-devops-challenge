# Challenge DevOps Coodesh (20221219)

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
Primeiro, obtenha a chave de acesso de um usuário (pode ser do root) da sua
conta.

#### Passo a passo (github actions)

Temos pipeline pronto para automatizar infra e build.

No seu repositório, vá em secrets e adicione suas credenciais da AWS
(`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`). Edite o
`.github/workflows/deploy.yml` e coloque seu domínio.

Pronto! A workflow também inclui ações para construir e implantar a aplicação.

#### Passo a Passo (manual)

Para fazer manualmente, você precisa ter instalado:

- [Terraform](https://developer.hashicorp.com/terraform/downloads)
- [AWS CLI](https://aws.amazon.com/cli/)
- [jq](https://stedolan.github.io/jq/)

> Um jeito prático é usar a nossa `shell.nix`. Basta instalar o gerenciador de
> pacotes [nix](https://nixos.org/download.html) (funciona em qualquer Linux,
> Mac, ou WSL) e rodar `nix-shell`. Você entrará numa shell com tudo que precisa.

Dentro do diretório `infra-terraform`, comece executando o script de setup
inicial:
```
./initial_setup.sh
```
Esse script provisionará um S3 (usado para guardar estado do terraform) e um
DNS Zone pro seu domínio. Será exibido um conjunto de Nameservers, configure
seu domínio com eles.

Feito isso, suba o resto da infraestrutura:
```
terraform apply
```

> Vale notar que o S3 de estado e a Zone criados imperativamente são
> automaticamente importados no terraform. Sendo assim, serão gerenciados por
> ele (incluindo deleção, alterações futuras, etc).

Depois de subir tudo, o terraform te informará o nome do bucket e o id da
instância de cloudfront da aplicação. Você já pode fazer deploy:

```
aws s3 sync ../calculadora/build/ s3://NOME-DO-BUCKET --acl public-read --delete
```

Para que as mudanças sejam visíveis logo, você pode invalidar o cache (só do
index.html, já que os outros assets fazem cache busting) do cloudfront:
```
aws cloudfront create-invalidation --distribution-id ID-DO-CLOUDFRONT --paths "/index.html"
```

# Extras

## Diferencial 1 - Desenhar o fluxo de CI/CD

É pra ser um diagrama?

Etapa 1, build:
```
[ npm install ] ─► [ npm run build ]
```

Etapa 2, infra:
```
[ Criar Route 53 zone ] ─────┬─► [ Inicializar estado TF no S3 ] ─► [ Importar S3 e Route 53 para estado ] ─► [ Aplicar configuração declarativa (S3 e CloudFront) ]
[ Criar S3 para estado TF ] ─┘
```

Etapa 3, deploy:
```
[ Artefato da build ] ──────┬─► [ Uploadar build p/ S3 ] ─► [ Invalidar cache do CloudFront ]
[ IDs do S3 e CloudFront ] ─┘
```

## Diferencial 2 - Configurar o fluxo de CI/CD com a criação do sistema de storage usando IaC

Tem alguma outra infraestrutura pra criar além da storage? Achei que fosse
parte do desafio em si. Bem, está feito.

## Diferencial 3 - Configurar modules para re-aproveitar código do IaC

Sinceramente, não julgo nescessário. A infra é tão simples que não tem nada que
vale a pena abstrair ou reusar. Se eu abstrair, por exemplo, o S3, vai ficar
mais complexo e não adicionar nenhuma vantagem.
