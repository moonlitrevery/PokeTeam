# Diagrama Entidade-Relacionamento (ER)

## Modelo Conceitual Visual

```
┌─────────────────────────────────────────────────────────────────────┐
│                         POKETEAM DATABASE                            │
└─────────────────────────────────────────────────────────────────────┘

┌──────────────────┐
│     USERS        │
├──────────────────┤
│ PK  id           │
│     username     │──┐
│     email        │  │
│     password_hash│  │
│     created_at   │  │
└──────────────────┘  │
                      │
                      │ 1
                      │
                      │ owns
                      │
                      │ N
                      ↓
           ┌──────────────────┐
           │   USER_TEAMS     │
           ├──────────────────┤
           │ PK  id           │
           │ FK  user_id      │
           │     team_name    │
           │     pokemon_ids  │ (JSON Array: [1, 4, 7, 25])
           │     is_active    │
           │     created_at   │
           └──────────────────┘


┌──────────────────┐
│     USERS        │
├──────────────────┤
│ PK  id           │──┐
│     username     │  │
│     email        │  │ 1
│     password_hash│  │
│     created_at   │  │ tracks
└──────────────────┘  │
                      │ N
                      ↓
           ┌──────────────────┐         ┌──────────────────┐
           │  USER_POKEDEX    │    N:1  │     POKEMON      │
           ├──────────────────┤ ───────→├──────────────────┤
           │ PK  user_id      │         │ PK  id           │
           │ PK  pokemon_id   │         │     name         │
           │     status       │         │     height       │
           │     is_favorite  │         │     weight       │
           │custom_nickname   │         │base_experience   │
           │     notes        │         │     types (JSON) │
           │     updated_at   │         │abilities (JSON)  │
           └──────────────────┘         │     sprites      │
                                        │     stats (JSON) │
                                        │     created_at   │
                                        └──────────────────┘


┌──────────────────┐
│     USERS        │
├──────────────────┤
│ PK  id           │──┐
│     username     │  │ 1
│     email        │  │ earns
│     password_hash│  │ N
│     created_at   │  │
└──────────────────┘  │
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

## Relacionamentos

### 1. USERS → USER_TEAMS (1:N)
- Um usuário pode ter múltiplos times
- Um time pertence a apenas um usuário
- **Tipo**: One-to-Many
- **Chave Estrangeira**: `user_teams.user_id` → `users.id`
- **Deleção**: CASCADE (deletar usuário remove seus times)

### 2. USERS → USER_POKEDEX (1:N)
- Um usuário pode ter múltiplos registros na pokédex
- Cada registro pertence a um único usuário
- **Tipo**: One-to-Many
- **Chave Estrangeira**: `user_pokedex.user_id` → `users.id`
- **Deleção**: CASCADE

### 3. POKEMON → USER_POKEDEX (1:N)
- Um pokémon pode estar na pokédex de múltiplos usuários
- Cada registro rastreia um pokémon específico
- **Tipo**: One-to-Many
- **Chave Estrangeira**: `user_pokedex.pokemon_id` → `pokemon.id`
- **Deleção**: CASCADE

### 4. USER_TEAMS → POKEMON (Implícito via JSON)
- Um time contém até 6 pokémons (armazenados como JSON array)
- Não há foreign key física, mas lógica de negócio valida existência
- **Tipo**: Many-to-Many (via JSON)
- **Validação**: Feita na camada de Service

### 5. USERS → USER_BADGES (1:N)
- Um usuário pode ter múltiplos emblemas/conquistas
- Cada emblema pertence a um único usuário
- **Tipo**: One-to-Many
- **Chave Estrangeira**: `user_badges.user_id` → `users.id`
- **Deleção**: CASCADE (deletar usuário remove seus emblemas)

## Cardinalidades

```
USERS (1) ─────< USER_TEAMS (N)
USERS (1) ─────< USER_POKEDEX (N)
USERS (1) ─────< USER_BADGES (N)
POKEMON (1) ───< USER_POKEDEX (N)
USER_TEAMS (*) ─────< POKEMON (*) [via JSON]
```

## Constraints e Regras de Negócio

### USERS
- ✅ `username` UNIQUE
- ✅ `email` UNIQUE
- ✅ `password_hash` NOT NULL (min 6 caracteres no Service)

### POKEMON
- ✅ `id` é o mesmo ID da PokeAPI
- ✅ `name` indexed para buscas rápidas
- ✅ `types`, `abilities`, `stats` armazenados como JSON

### USER_POKEDEX
- ✅ Chave primária composta: (user_id, pokemon_id)
- ✅ `status` ENUM('seen', 'caught')
- ✅ Não permite duplicatas (mesmo usuário + mesmo pokémon)

### USER_TEAMS
- ✅ `pokemon_ids` JSON array com máximo 6 elementos
- ✅ Validação de duplicatas no Service
- ✅ Um usuário pode ter múltiplos times

### USER_BADGES
- ✅ `user_id` FK para users com ON DELETE CASCADE
- ✅ Emblemas/conquistas por usuário (ex.: "Primeiro time", "10 Pokémon capturados")

## Índices para Performance

```sql
-- Índices criados para otimizar queries frequentes
CREATE INDEX idx_email ON users(email);
CREATE INDEX idx_name ON pokemon(name);
CREATE INDEX idx_teams_user_id ON user_teams(user_id);
CREATE INDEX idx_badges_user_id ON user_badges(user_id);
```

## Normalização

O banco está na **3ª Forma Normal (3NF)**:

1. ✅ **1NF**: Todos os atributos são atômicos (exceto JSON, que é tratado como tipo)
2. ✅ **2NF**: Não há dependências parciais
3. ✅ **3NF**: Não há dependências transitivas

**Nota**: O uso de JSON para `types`, `abilities`, `stats`, e `pokemon_ids` é uma decisão de design para:
- Flexibilidade (PokeAPI pode ter dados variáveis)
- Performance (evita joins excessivos)
- Simplicidade (menos tabelas para manter)
