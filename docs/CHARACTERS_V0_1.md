# Personagens — primeiro incremento jogável

Direção aprovada: cada raça terá origem própria; classe determina armas e estilo
 de combate; equipamentos mudam aparência e podem possuir efeitos especiais.
As afinidades raciais e especializações da Bíblia continuam referência. Oitava
raça e revelações de The Below permanecem mistérios.

## Implementado neste incremento

- Seleção e criação de até seis personagens nomeados.
- Primeiro conjunto jogável: Valen / Guardião, início em Eryndor, Elden.
- Roupa básica de linho, espada gasta, sem armadura inicial.
- Cada perfil possui suas próprias moedas, missão, inventário, equipamento,
  XP, prática de coleta e descobertas.
- Aba Personagem na mochila com retrato de corpo inteiro, arma, armadura,
  atributos, retirada de armadura e retorno à seleção.
- Linho, couro e ferro possuem animações de corpo inteiro diferentes.
- Borin vende couro e ferro; atributos continuam afetando o combate real.
- Nilo usa arte própria e organiza frutas; não compartilha o sprite de Eldric.
- Lia e Tomás caminham por percursos definidos na vila, pausam e possuem falas.
  Usam colisões do mundo, não bloqueiam o jogador e param durante menus.
- O mapa mantém suas dimensões atuais. A próxima expansão proposta conecta
  Eryndor às estradas e fazendas de Elden; outros países não estão implementados.

## Persistência

`aervalon.characters.v1` / `user://aervalon_characters_v1.json` armazena perfis e
seleção. Dados de gameplay mantêm o formato V1 existente dentro de cada perfil.
O save antigo é copiado uma única vez para o perfil legado, sem excluir nem
reescrever `aervalon.eryndor.v1` / `eryndor_rpg_v1.json`.

Dados de seleção inválidos bloqueiam escrita, preservando o original. Operações
que falham ao salvar não confirmam criação ou troca de perfil. Não há exclusão
de personagens nesta etapa. Entrar sempre coloca o personagem em Eryndor,
com vida cheia, como a base anterior.

## Limites explícitos

- Outras raças, classes e prólogos ainda não são selecionáveis.
- Aparência facial/cabelo/corpo ainda fixa; não há personalização cosmética.
- Apenas slots de arma e armadura estão funcionais.
- Roupas são variações completas da folha de animação, não camadas modulares.
- Espadas ainda compartilham a forma desenhada; trocar arma já muda atributos,
  mas não há efeitos míticos nem habilidades específicas da arma nesta entrega.
- Arcanista (cajado/grimório), Rastreador (arco/rifle/pet) e demais identidades
  aprovadas serão desenvolvidos incrementalmente, sem opções falsas no menu.
- Países, continente, dungeon e boss não foram acrescentados neste incremento.

## Validação

Testes nativos cobrem migração, isolamento, seleção, nomes, releitura e aparência
por equipamento, além da regressão completa do slice. Browser cobre criação por
UI, troca de personagens, migração Web e painel mobile. Emulação Chromium não
substitui validação em iPhone físico, especialmente teclado virtual Safari.
