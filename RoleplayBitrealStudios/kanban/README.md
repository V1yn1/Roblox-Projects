# Kanban — RoleplayBitrealStudios

Quadro Kanban interativo do projeto, em um único arquivo HTML. **Não precisa de servidor nem internet** — é só abrir.

## Como usar
Dê duplo clique em `index.html` (ou arraste para o navegador).

## Recursos
- **Salva automático**: tudo fica no `localStorage` do navegador. Fechou e abriu de novo, continua lá.
- **Arrastar e soltar**: mova cards entre colunas e reordene; arraste o cabeçalho para reordenar colunas.
- **Cards completos**: título, descrição, prioridade (baixa/média/alta), arquivo de referência e etiquetas — de tipo/técnico (Bug, Feature, Polish, Client, Server, DataStore, UI/UX) e de domínio RP estilo cidade FiveM (Economia, Emprego, Veículo, Polícia, Saúde/EMS, Crime, Inventário, Imóvel, Telefone, Social/RP, Admin).
- **Quadro já populado** com o escopo de uma cidade RP estilo GTA V / FiveM (economia, empregos, veículos, polícia, EMS, inventário, imóveis, telefone, crime, social e admin), adaptado ao projeto Roblox/Rojo.
- **Colunas editáveis**: clique no título para renomear; menu `⋯` para trocar cor, limpar ou excluir.
- **Busca** instantânea no topo.
- **Exportar / Importar JSON**: faça backup ou compartilhe o quadro (ex.: comitar o `.json` no git para o time).
- **Reset**: restaura as tarefas iniciais derivadas da análise do projeto.

## Atalhos
- `N` — novo card
- `Ctrl/Cmd + Enter` — salvar card aberto
- `Esc` — fechar janela

## Persistência e backup
O estado vive no navegador (chave `rbs_kanban_v1`). Para versionar no git, use **Exportar** e salve o `kanban-rbs.json` no repositório; para restaurar em outra máquina, use **Importar**.
