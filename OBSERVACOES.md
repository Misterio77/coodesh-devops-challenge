# Observações

Observações e problemas que passei no processo.

## Parte 1 (Build)

- A versão do node com o qual esse app foi empacotado é muito muito antiga.
    - Lock File version é 1, indicativo do Node 14
    - Tão antiga que eu tenho erro com SSL se eu usar Node 17+
        - Isso é corrigível passando `NODE_OPTIONS=--openssl-legacy-provider`
    - Usando o [nix](https://nixos.org), é muito fácil trocar entre as versões,
      então constatei que funciona sem alterações no Node 14.
    - Acho usar o Node 14 ou OpenSSL legado péssimas idéias, então resolvi
      atualizar para funcionar com o 18.
      - Um simples `npm audit --force` resolveu.

- O output é apenas assets estáticos, então não faz sentido dockerizar. Existe
    quem use docker como build tool (abusando de volumes pra acessar output);
    eu não gosto dessa prática.

## Parte 2 (deploy)

Decidi fazer o deploy na AWS via Terraform. A melhor forma, até onde sei, de
servir assets estáticos é S3 + CloudFront (SSL termination, CDN, etc).

Fiz a infra completa incluindo zone no Route53 e provisionamento de SSL pelo
Let's Encrypt.

Existe um problema comum de se adicionar o domínio pelo terraform pois DNS
demora pra propagar, causando erros ao gerar o certificado até que propague.
Pra resolver isso, eu fiz um script que gera um nameserver delegation set, isto
é, obtém o conjunto de nameservers antes de subir a infra. Depois disso, basta
passar esse ID para o terraform pra garantir que o zone suba com esses
nameservers.

O jeito mais fácil de automatizar deploy com terraform é usando o remote apply
do terraform cloud, mas optei por não fazer isso pra evitar que seja
obrigatório usar ele. Contudo, o terraform é inviável de usar sem
persistir/sincronizar state, então, no caso da pipeline, fiz rodar com o tf
cloud (apenas para sincronizar estado, sem remote run).

Numa situação de produção, eu preferiria usar o terraform cloud.
