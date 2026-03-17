-- Migração: adiciona a tabela user_badges (5ª tabela) em bancos já existentes
-- Execute apenas se o banco foi criado antes da inclusão desta tabela no init.sql
USE poke_db;

CREATE TABLE IF NOT EXISTS user_badges (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    badge_name VARCHAR(100) NOT NULL,
    badge_type VARCHAR(50),
    description TEXT,
    earned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_badges_user_id (user_id)
);
