# Sete raças, tela inicial e exclusão

## Jogável

- Valen, Sylari, Kharum, Ruun, Nym, Thalass e Pipri selecionáveis na criação.
- Identidades, facções, origens e sprites próprios; movimento, ataque, reação e
  morte usam o controlador existente. Kharum possui ordem lateral de atlas
  corrigida no adaptador. Escala corporal varia sem alterar alcance/colisão.
- Todos usam Guardião nesta versão e visitam Eryndor. Não existem ainda sete
  regiões natais jogáveis, habilidades raciais ou novas classes.
- Até oito perfis; V1 existente continua válido. Raça pertence ao perfil;
  inventário e progresso continuam isolados.
- A cena inicial não instancia o mapa, NPCs, lobos ou HUD. A vila é carregada
  somente após selecionar Entrar em Eryndor. A ficha retorna à tela inicial.
- Exclusão pede confirmação com nome, bloqueia outras ações durante o aviso,
  permite cancelar e preserva todos os demais perfis. Falha de gravação desfaz
  a exclusão em memória. Excluir o último grava um roster vazio; a migração
  legada não é reexecutada. O backup V1 original permanece intocado.

## Arte e limites

As seis raças novas possuem roupa inicial própria. Equipamentos alteram atributos
normalmente e nunca trocam a raça. Variantes visuais de armadura para essas seis
raças ainda precisam ser produzidas; Valen mantém linho/couro/ferro aprovados.
Um visual por raça, sem personalização de rosto/gênero neste incremento.
O fundo pintado é exclusivo do menu; o mundo mantém sprites e colisões separados.
Prompts completos: assets/aervalon/races_v4/PROVENANCE.md.

## Validação

Testes cobrem identidade das sete raças, movimento e animações, restauração,
exclusão confirmada, falha de gravação, último perfil e ausência de atores da
vila na tela inicial. Navegador cobre seleção racial, Nym em jogo, cancelamento,
exclusão de um entre dois perfis, sobrevivência do outro, exclusão do último e
reload sem ressuscitar o backup. Capturas desktop/mobile são revisadas.
