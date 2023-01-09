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
