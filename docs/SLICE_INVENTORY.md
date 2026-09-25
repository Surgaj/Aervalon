# Inventário técnico — continuação da Bíblia V0.1

Base inspecionada: `fa46fdee`, branch `visual-rebuild-v2`, PR #2.
Não houve reinício nem troca dos assets raster aprovados.

| Pilar do vertical slice | Estado na base | Arquitetura / próxima lacuna |
| --- | --- | --- |
| Movimento, ponte, colisões e profundidade | Funcional | CharacterBody2D, mundo com Y-sort e bases físicas; testes reais de movimento |
| Exploração | Área única, baú, floresta | Faltam descobertas além do tesouro |
| Combate | Direção, alcance, cooldown, dano, reação, IA de lobos | Falta esquiva e padrões de boss |
| NPCs e missão | Mara aceita/conclui; Borin trabalha; Nilo vende | Rotinas limitadas; sem sistema de horários |
| XP e nível | Funcional | Dados em `rpg_state.gd`; aumentos moderados |
| Loot | Sacos no chão; coleta próxima com teste de parede | Pele, presa e moedas |
| Inventário e equipamento | Funcional, mobile, arma/armadura | Não há todos os slots futuros nem troca visual da roupa |
| Comércio | Duas lojas, compra/venda e atributos reais | Sem economia regional ou crafting |
| Morte/respawn | Funcional, sem apagar progresso | Lobos também reaparecem |
| Persistência | JSON versionado / localStorage na Web | Adicionar campos opcionais, manter saves V1 |
| Coleta do mundo | Ausente | Primeira lacuna: plantas, recuperação e prática de herbalismo |
| Dungeon / boss | Ausentes | Precisam de cenário separado e padrões; não simular conclusão com decoração |
| Começo de The Below | Apenas rumor provisório | Primeira descoberta ambiental, sem revelar respostas |
| Web/mobile | Export Godot + Playwright | Validado em Chromium emulado; iPhone físico ainda necessário |

## Incremento escolhido

1. Esquiva curta com cooldown, colisão preservada e janela de proteção pequena.
2. Coleta contextual de plantas, item utilizável/vendável, prática de herbalismo
   e regeneração persistente dos pontos. Nada de menu de profissão gigantesco.
3. Descoberta no poço existente: um eco sob Eryndor, reação visível e memória
   persistente. Pista, não entrada jogável ou explicação da civilização antiga.
4. Testes de regressão, controles de toque, save antigo e export Web.

## Próxima etapa após este incremento

Pequena dungeon com entrada no mundo, saída segura, arena legível e boss de
padrões aprendíveis, construída com assets separados de qualidade equivalente.
Depois: som, animações específicas e consequência visual regional. Criação de
raças/classes, continente, crafting amplo e multiplayer continuam futuros.
