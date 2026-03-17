# PROJETO FINAL – PRÁTICA EM BANCO DE DADOS  
## 1º semestre de 2026

---

**Disciplina:** Prática em Banco de Dados  
**Semestre:** 5º  
**Professor:** Me. Henrique Pachioni Martins  

**Projeto:** PokeTeam – Banco de Dados Relacional  

**Integrantes do grupo:**
- Jean Victor Yoshida Lima
- João Pedro Cabrera Rodrigues Penna
- João Vitor Gozzo Bruschi
- Nícolas Justo Melão

---

Bauru, 2026.

---

\newpage

# 1. Modelagem do banco de dados

O banco **PokeTeam** possui **5 tabelas relacionadas**: `users`, `pokemon`, `user_pokedex`, `user_teams` e `user_badges`.

## 1.1 Diagrama Entidade-Relacionamento

```
┌─────────────────────────────────────────────────────────────────────┐
│                         POKETEAM DATABASE                            │
└─────────────────────────────────────────────────────────────────────┘

┌──────────────────┐
│     USERS        │
├──────────────────┤
│ PK  id           │
│     username     │──┐
│     email        │  │ 1 owns N
│     password_hash│  │
│     created_at   │  ↓
└──────────────────┘  ┌──────────────────┐
           ┌──────────│   USER_TEAMS     │
           │          ├──────────────────┤
           │          │ PK  id           │
           │          │ FK  user_id      │
           │          │     team_name    │
           │          │     pokemon_ids  │ (JSON)
           │          │     is_active    │
           │          │     created_at   │
           │          └──────────────────┘
           │
           │ 1 tracks N     ┌──────────────────┐    N  ┌──────────────────┐
           └──────────────→│  USER_POKEDEX    │──1───→│     POKEMON      │
                           ├──────────────────┤       ├──────────────────┤
                           │ PK  user_id      │       │ PK  id           │
                           │ PK  pokemon_id   │       │     name         │
                           │     status       │       │     height       │
                           │     is_favorite  │       │     types (JSON)  │
                           │     notes        │       │     stats (JSON)  │
                           └──────────────────┘       └──────────────────┘
           │
           │ 1 earns N
           ↓
┌──────────────────┐
│   USER_BADGES    │
├──────────────────┤
│ PK  id           │
│ FK  user_id      │
│     badge_name   │
│     badge_type   │
│     description  │
│     earned_at    │
└──────────────────┘
```

## 1.2 Relacionamentos

| Relacionamento | Tipo | Descrição |
|----------------|------|-----------|
| USERS → USER_TEAMS | 1:N | Um usuário possui vários times. FK: `user_teams.user_id` → `users.id` |
| USERS → USER_POKEDEX | 1:N | Um usuário tem vários registros na pokédex. FK: `user_pokedex.user_id` → `users.id` |
| USERS → USER_BADGES | 1:N | Um usuário pode ter vários emblemas. FK: `user_badges.user_id` → `users.id` |
| POKEMON → USER_POKEDEX | 1:N | Um Pokémon pode estar na pokédex de vários usuários. FK: `user_pokedex.pokemon_id` → `pokemon.id` |
| USER_TEAMS ↔ POKEMON | N:N (via JSON) | Times armazenam até 6 IDs de Pokémon em `pokemon_ids` (JSON). Validação na aplicação. |

Todas as FKs usam **ON DELETE CASCADE** onde aplicável (ex.: ao excluir um usuário, seus times, registros na pokédex e emblemas são removidos).

---

\newpage

# 2. Comandos SQL – DML (INSERT, UPDATE, DELETE)

Os comandos abaixo comprovam o funcionamento das transações DML. Podem ser executados no MySQL (Workbench, DBeaver, linha de comando) e os resultados podem ser comprovados com prints da ferramenta.

## 2.1 INSERT – Inserção de dados

```sql
USE poke_db;

-- Inserir usuário
INSERT INTO users (username, email, password_hash)
VALUES ('TreinadorJoão', 'joao@poketeam.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/X4.G2icGmT5pQK.6u');

-- Inserir Pokémon (exemplo)
INSERT INTO pokemon (id, name, height, weight, base_experience, types, abilities, sprite_front_default, stats, created_at)
VALUES (999, 'pikachu-teste', 4, 60, 112, '["electric"]', '["static"]', 'https://example.com/sprite.png', '[{"name":"hp","value":35}]', NOW());

-- Inserir time (user_id = 1)
INSERT INTO user_teams (user_id, team_name, pokemon_ids, is_active)
VALUES (1, 'Time Inicial', '[1, 4, 7]', TRUE);

-- Inserir progresso na pokédex
INSERT INTO user_pokedex (user_id, pokemon_id, status, is_favorite, custom_nickname)
VALUES (1, 999, 'caught', TRUE, 'Meu Pikachu');

-- Inserir emblema
INSERT INTO user_badges (user_id, badge_name, badge_type, description)
VALUES (1, 'Primeiro Time', 'time', 'Criou o primeiro time no PokeTeam');
```

**Comprovação:** Executar `SELECT * FROM users;`, `SELECT * FROM user_teams;`, etc., e anexar print no PDF se solicitado.

---

## 2.2 UPDATE – Atualização de dados

```sql
USE poke_db;

-- Atualizar email do usuário
UPDATE users SET email = 'joao.novo@poketeam.com' WHERE id = 1;

-- Atualizar nome e status do time
UPDATE user_teams SET team_name = 'Time Kanto Atualizado', is_active = FALSE WHERE id = 1;

-- Atualizar status na pokédex
UPDATE user_pokedex SET status = 'seen', custom_nickname = NULL, notes = 'Liberado' WHERE user_id = 1 AND pokemon_id = 999;

-- Atualizar descrição do emblema
UPDATE user_badges SET description = 'Conquista: criou o primeiro time' WHERE id = 1;
```

**Comprovação:** Executar `SELECT` nas tabelas alteradas antes e depois do UPDATE e anexar prints.

---

## 2.3 DELETE – Remoção de dados

```sql
USE poke_db;

-- Remover um emblema
DELETE FROM user_badges WHERE id = 1;

-- Remover registro da pokédex
DELETE FROM user_pokedex WHERE user_id = 1 AND pokemon_id = 999;

-- Remover um time
DELETE FROM user_teams WHERE id = 1;

-- Remover Pokémon de teste
DELETE FROM pokemon WHERE id = 999;

-- Remover usuário (CASCADE remove dados em user_teams, user_pokedex, user_badges)
DELETE FROM users WHERE id = 1;
```

**Comprovação:** Executar `SELECT * FROM users;` (e demais tabelas) após os DELETEs e anexar print mostrando que os registros foram removidos.

---

**Observação:** O script completo com todos os exemplos em sequência (INSERT → UPDATE → DELETE) está em `scripts/exemplos_dml.sql` no repositório do projeto.
