# Aervalon — continuidade

Leia `docs/BIBLIA_VISAO_V0_1.md` antes de decisões de lore, arquitetura,
gameplay ou arte. É a direção fornecida pelo criador, não uma promessa de
funcionalidades já implementadas. Consulte `docs/SLICE_INVENTORY.md` para o estado.

- Preserve a base raster aprovada: sprites separados, Y-sort, colisões e gameplay.
- Não recomece, não troque a engine, não converta o mapa em imagem de fundo.
- Trabalhe incrementalmente em `visual-rebuild-v2`; não faça merge para main.
- Mantenha saves existentes compatíveis e previews Web imutáveis separados da versão estável.
- Não implemente todo o continente, classes ou infraestrutura multiplayer de uma vez.
- Diferencie cânone do usuário, propostas de conteúdo e sistemas realmente jogáveis.
- Para mudanças de gameplay: execute testes Godot, exporte Web e valide controles/mobile
  no navegador. Informe limitações reais (emulação não equivale a iPhone físico).
