# DevOps Challenge

## Introdução

Este é um desafio para testar seus conhecimentos de DevOps;

O objetivo é avaliar a sua forma de estruturação e autonomia em decisões para construir algo escalável utilizando o provedor de Cloud sugerido na vaga aplicada.

### Antes de começar

- Prepare o projeto para ser disponibilizado no Github, copiando o conteúdo deste repositório para o seu (ou utilize o fork do projeto e aponte para o Github). Confirme que a visibilidade do projeto é pública (não esqueça de colocar no readme a referência a este challenge);
- O projeto deve utilizar um Provedor de Cloud especificado na sua Vaga (caso esteja se candidatando). Por exempo: AWS, Azure, Google Cloud e entre outras;
- Considere como deadline 5 dias a partir do início do desafio. Caso tenha sido convidado a realizar o teste e não seja possível concluir dentro deste período, avise a pessoa que o convidou para receber instruções sobre o que fazer.
- Documentar todo o processo de investigação para o desenvolvimento da atividade (README.md no seu repositório); os resultados destas tarefas são tão importantes do que o seu processo de pensamento e decisões à medida que as completa, por isso tente documentar e apresentar os seus hipóteses e decisões na medida do possível.

## **Parte 1 - Build**

A sua tarefa consiste em configurar o build para o projeto de [Calculadora](https://github.com/ahfarmer/calculator).

1. Adicionar o projeto como um Git Submodule no seu repositório
2. Seguir os passos para iniciar o projeto segundo a versão especifica do Node.js
3. Testar o projeto se está disponível localmente
4. Utilizar os comandos para gerar o Build do Projeto: `npm run build`

## **Part 2 – Deploy**

Configurar a infra-estrutura no Proveedor de Cloud escolhido para disponibilizar o Projeto Online, você pode criar as configurações com a seguinte opção:

- Ansible
- Terraform

O projeto deverá ser adicionado em um Storage onde ficará disponível a URL para acessar a Calculador Online, os arquivos que vem ser subidos ao Storage estão na pasta (`build`)
que será gerado ao rodar o comando de build. 

As opções mais comuns de Storage do mercado são:

- S3
- Google Cloud Storage
- Azure Storage

## Extras

Além do desafio proposto temos alguns diferenciais:

**Diferencial 1 -** Desenhar o fluxo de CI/CD do projeto entregue nas etapas anteriores;

**Diferencial 2 -** Configurar o fluxo do CI/CD com o fluxo de criação do sistema de Storage usando Infra as Code;

**Diferencial 3 -** Configurar os conceitos de modules para re-aproveitar o código do Infra as Code


## Readme do Repositório

- Deve conter o título do projeto
- Uma descrição de uma frase
- Como instalar e usar o projeto (instruções)
- Não esqueça o [.gitignore](https://www.toptal.com/developers/gitignore)

## Finalização

Avisar sobre a finalização e enviar para correção em: [https://coodesh.com/review-challenge](https://coodesh.com/review-challenge)
Após essa etapa será marcado a apresentação/correção do projeto.

## Instruções para a Apresentação:

1. Será necessário compartilhar a tela durante a vídeo chamada;
2. Deixe todos os projetos de solução previamente abertos em seu computador antes de iniciar a chamada;
3. Deixe os ambientes configurados e prontos para rodar;
4. Prepara-se pois você será questionado sobre cada etapa e decisão do Challenge;
5. Prepare uma lista de perguntas, dúvidas, sugestões de melhorias e feedbacks (caso tenha).

## Suporte

Use a [nossa comunidade](https://discord.com/invite/rdXbEvjsWu) para tirar dúvidas sobre o processo ou envie uma mensagem diretamente a um especialista no chat da plataforma.
