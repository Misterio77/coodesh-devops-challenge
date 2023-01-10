# Observações

Observações e problemas que tive durante o processo.

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

O output é apenas assets estáticos, então não faz sentido dockerizar. Existe
quem use docker como build tool (abusando de volumes pra acessar output); eu
não gosto dessa prática.

De resto, não tem muito segredo. `npm run build` e servir esses assets em
qualquer servidor HTTP.

## Parte 2 (deploy)

Decidi fazer o deploy na AWS via Terraform. A melhor forma, até onde sei, de
servir assets estáticos é S3 + CloudFront (provê SSL termination e distrui
globalmente os assets).

Fiz a infra completa usando terraform. Incluindo zone no Route53 e
provisionamento de SSL pelo Let's Encrypt.

Existe, no entanto, dois problemas:

### Registrar o DNS zone e certificado ao mesmo tempo

Mudanças no DNS, especialmente nameservers, demoram pra propagar. Você só sabe
os nameservers DEPOIS de criar a DNS zone. Mesmo que você abra o console
rapidamente durante o apply para ver os nameservers atribuídos, a aplicação
provavelmente eventualmente falhará pois não conseguirá provisionar o SSL antes
do timeout.

### Estado do terraform

O uso do terraform é inviável sem persistir/sincronizar state. Não dá para
trabalhar confortavelmente com mais de uma pessoa, e caso o state se perca
entre execuções, teremos recursos duplicados e perdidos!

É complicado e desajeitado persistir um arquivo de estado (que não seja público
e não expire) entre execuções no github actions. Os artefatos claramente são
feitos para builds, não estado mutável cheio de secrets.

O jeito mais fácil de resolver isso é usando o terraform cloud. Além de
sincronizar estado, ele também permite remote apply (isto é, o apply acontece
lá, com os secrets de lá). Optei por não fazer isso pra evitar adicionar mais
complexidade e SaaS a uma implantação que deveria ser simples e reusável.

### Solução

Decidi usar um S3 para persistir o estado do terraform. Apenas vantagens,
certo? Dá pra acessar o estado com as mesmas credenciais da AWS, fica tudo na
mesma nuvem... Então é só mandar o terraform criar o bucket e referenciar ele?
Errado. O terraform [não permite usar
variáveis](https://github.com/hashicorp/terraform/issues/13022) nessa
configuração, tornando esse uso extremamente desajeitado. Minha teoria é que a
hashicorp não faz questão de melhorar a usabilidade dos backends alternativos,
já que querem vender o SaaS.

Minha solução para ambos os problemas é relativamente simples: provisionar
imperativamente a DNS zone, e mostrar os namesevers antes de criar o resto da
infra; e um S3 para o estado do terraform. Podemos especificar as variáveis de
backend como argumentos no `terraform init`, e podemos importar para o
terraform recursos previamente criados... Vê onde estou chegando?

O script é um pouquinho chato de montar (especialmente pois bash não é
exatamente bom com error handling), mas funciona bem. Ele:
- pede um domínio (por argumento ou prompteia);
- vê se existe uma zone com ele, criando se nescessário;
- vê se existe um bucket cujo nome é derivado do domínio, criando se nescessário;
- inicializa o terraform com o bucket como backend;
- importa os dois para o estado do terraform (permitindo que ele gerencie seus
  ciclos de vida depois);
- exibe os nameservers que o usuário precisa para configurar o domínio.

E é isto! Com os nameservers em mão, basta configurar o domínio e (depois que o
DNS propague), executar `terraform apply`. Assim temos um setup do terraform
que não trava na execução e não depende de nada além da AWS.

# Considerações

## Alternativas

- Ao invés de criar o DNS zone imperativamente, é possível criar um _Delegation
    Set_, um conjunto de nameservers que pode ser referenciado ao criar zones.
    Isso permite que você saiba os nameservers antes de criá-la. Eu usei a
    estratégia de criar os delegation sets imperativamente, mas, depois que
    tive que criar também um S3, não oferece muita vantagem sobre criar
    imperativamente a zona propriamente dita.

- Eu pensei em usar o terraform cloud, mas não fiquei satisfeito ao escrever os
    passos explicando que teríamos que configurar dois SaaS diferentes para
    fazer um deploy tão simples como este.

- Em um deploy desses, faz mais sentido usar algo como o github pages. É
    extremamente simples e bastava dar push nos assets numa branch e é isto.
    Mas daí como que eu iria mostrar que sei terraform? Haha.

## Feedback sobre o desafio

Não sei se esse desafio era mais pra desenvolvedores júniores ou coisa do tipo,
mas eu acho que seria muito mais interessante pedir o empacotamento e
implantação de uma aplicação full stack. Precisamos de, no mínimo, uma
aplicação serverside para justificar o uso de compute, contêineres, e
possivelmente orquestração.
