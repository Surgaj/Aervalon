# Inventário técnico — Aervalon

Base desta continuação: `fd7f5612`, branch `visual-rebuild-v2`, PR #2.
Preservados mapa raster, sprites separados, Y-sort, colisões e saves.

| Sistema | Implementado | Próxima lacuna |
| --- | --- | --- |
| Mundo | Eryndor, ponte, floresta e arredores de Elden (2920×1450); moradores em rotas e animais | Regiões raciais e conteúdo regional mais profundo |
| Personagens | Tela inicial independente; sete raças; dez classes; oito perfis; exclusão confirmada; migração de saves | Personalização, prólogos raciais e arte das armas nas mãos |
| Combate | Ataque, esquiva, poderes iniciais, cooldown, dano, colisões, morte/respawn, lobos | Boss com padrões; pets; especializações |
| Progressão | XP, nível, drops físicos, moedas e missão de Mara | Mais histórias regionais e recompensas especiais |
| Equipamento | Inventário, arma/armadura, atributos reais; roupas Valen em linho/couro/ferro | Aparências de equipamento para as outras raças |
| Comércio | Borin e Nilo, compra/venda; proteção contra compra sem saldo | Economia regional e crafting |
| Exploração | Plantas, cura, venda, prática de herbalismo e regrowth; descoberta no poço | Dungeon e entrada jogável de The Below |
| Persistência | Saves individuais locais; inventário, equipamento, progressão, descobertas | Nenhuma infraestrutura multiplayer nesta fase |
| Web/mobile | Godot Web e Chromium com controles reais; preview imutável | Validação em iPhone físico |

## Incremento: identidade das armas

- Flechas, energia arcana e tiros são Sprite2D independentes em movimento.
- A arma equipada define o tipo de projétil e o alcance. Espadas continuam corpo a corpo.
- Colisão varrida impede atravessar paredes; cada disparo atinge um inimigo e termina.
- Menus pausam projéteis; morte os remove; tiros perdidos expiram.
- Assistência de mira limitada ao cone frontal e a alvos visíveis.
- Cada classe encontra melhoria compatível na ferraria; ícones distinguem as famílias.
- Não foram substituídos sprites do mundo nem simulada uma dungeon com decoração.

Limite visual: a animação corporal de ataque ainda utiliza as folhas atuais; armas nas
mãos, pets, especializações e efeitos raros/míticos próprios exigem uma próxima etapa.
Os ícones e pequenos projéteis SVG foram desenhados em código; não usam arte externa.
