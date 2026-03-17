-- ============================================================
-- PokeTeam - Exemplos DML (INSERT, UPDATE, DELETE)
-- Para comprovar transações no trabalho final de Banco de Dados
-- Execute no MySQL (Workbench, DBeaver, etc.) e use prints como comprovação
-- ============================================================
USE poke_db;

-- ------------------------------------------------------------
-- 1. INSERT - Inserção de dados
-- ------------------------------------------------------------

-- 1.1 INSERT em users (usuário)
INSERT INTO users (username, email, password_hash)
VALUES ('TreinadorJoão', 'joao@poketeam.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/X4.G2icGmT5pQK.6u');
-- Comprovação: SELECT * FROM users WHERE email = 'joao@poketeam.com';

-- 1.2 INSERT em pokemon (um Pokémon para testes)
INSERT INTO pokemon (id, name, height, weight, base_experience, types, abilities, sprite_front_default, stats, created_at)
VALUES (999, 'pikachu-teste', 4, 60, 112, '["electric"]', '["static", "lightning-rod"]', 'https://example.com/sprite.png', '[{"name":"hp","value":35},{"name":"attack","value":55}]', NOW());
-- Comprovação: SELECT * FROM pokemon WHERE id = 999;

-- 1.3 INSERT em user_teams (time do usuário)
-- Assumindo que o usuário inserido acima tem id = 1 (ou use LAST_INSERT_ID())
INSERT INTO user_teams (user_id, team_name, pokemon_ids, is_active)
VALUES (1, 'Time Inicial', '[1, 4, 7]', TRUE);
-- Comprovação: SELECT * FROM user_teams WHERE user_id = 1;

-- 1.4 INSERT em user_pokedex (progresso do usuário)
INSERT INTO user_pokedex (user_id, pokemon_id, status, is_favorite, custom_nickname)
VALUES (1, 999, 'caught', TRUE, 'Meu Pikachu');
-- Comprovação: SELECT * FROM user_pokedex WHERE user_id = 1 AND pokemon_id = 999;

-- 1.5 INSERT em user_badges (emblema do usuário)
INSERT INTO user_badges (user_id, badge_name, badge_type, description)
VALUES (1, 'Primeiro Time', 'time', 'Criou o primeiro time no PokeTeam');
-- Comprovação: SELECT * FROM user_badges WHERE user_id = 1;


-- ------------------------------------------------------------
-- 2. UPDATE - Atualização de dados
-- ------------------------------------------------------------

-- 2.1 UPDATE em users (alterar email)
UPDATE users SET email = 'joao.novo@poketeam.com' WHERE id = 1;
-- Comprovação: SELECT id, username, email FROM users WHERE id = 1;

-- 2.2 UPDATE em user_teams (alterar nome do time e desativar)
UPDATE user_teams SET team_name = 'Time Kanto Atualizado', is_active = FALSE WHERE id = 1;
-- Comprovação: SELECT * FROM user_teams WHERE id = 1;

-- 2.3 UPDATE em user_pokedex (alterar status e apelido)
UPDATE user_pokedex SET status = 'seen', custom_nickname = NULL, notes = 'Liberado' WHERE user_id = 1 AND pokemon_id = 999;
-- Comprovação: SELECT * FROM user_pokedex WHERE user_id = 1 AND pokemon_id = 999;

-- 2.4 UPDATE em user_badges (alterar descrição)
UPDATE user_badges SET description = 'Conquista: criou o primeiro time' WHERE id = 1;
-- Comprovação: SELECT * FROM user_badges WHERE id = 1;


-- ------------------------------------------------------------
-- 3. DELETE - Remoção de dados
-- ------------------------------------------------------------

-- 3.1 DELETE em user_badges (remover um emblema)
DELETE FROM user_badges WHERE id = 1;
-- Comprovação: SELECT * FROM user_badges; (registro removido)

-- 3.2 DELETE em user_pokedex (remover registro da pokédex)
DELETE FROM user_pokedex WHERE user_id = 1 AND pokemon_id = 999;
-- Comprovação: SELECT * FROM user_pokedex WHERE user_id = 1;

-- 3.3 DELETE em user_teams (remover um time)
DELETE FROM user_teams WHERE id = 1;
-- Comprovação: SELECT * FROM user_teams;

-- 3.4 DELETE em pokemon (remover Pokémon de teste)
DELETE FROM pokemon WHERE id = 999;
-- Comprovação: SELECT * FROM pokemon WHERE id = 999;

-- 3.5 DELETE em users (remove usuário; CASCADE remove user_teams e user_pokedex e user_badges)
DELETE FROM users WHERE id = 1;
-- Comprovação: SELECT * FROM users; (e tabelas relacionadas vazias para esse user)
