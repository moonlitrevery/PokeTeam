-- scripts/init.sql
USE poke_db;

-- 1. USERS table
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(150) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. POKEMON table (everything in one table)
CREATE TABLE pokemon (
    id INT PRIMARY KEY, -- PokeAPI ID
    name VARCHAR(100) NOT NULL,
    height INT,
    weight INT,
    base_experience INT,
    types JSON, -- Store types as JSON array ['fire', 'flying']
    abilities JSON, -- Store abilities as JSON array
    sprite_front_default VARCHAR(255),
    sprite_front_shiny VARCHAR(255),
    sprite_official_artwork VARCHAR(255),
    stats JSON, -- Store base stats as JSON
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. USER_POKEDEX table (user progress)
CREATE TABLE user_pokedex (
    user_id INT NOT NULL,
    pokemon_id INT NOT NULL,
    status ENUM('seen', 'caught') DEFAULT 'seen',
    is_favorite BOOLEAN DEFAULT FALSE,
    custom_nickname VARCHAR(100),
    notes TEXT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, pokemon_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (pokemon_id) REFERENCES pokemon(id) ON DELETE CASCADE
);

-- 4. USER_TEAMS table
CREATE TABLE user_teams (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    team_name VARCHAR(100) NOT NULL,
    pokemon_ids JSON, -- Store team as [1, 4, 7, 25, ...]
    is_active BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_teams_user_id (user_id)
);

-- 5. USER_BADGES table (conquistas/emblemas do usuário)
CREATE TABLE user_badges (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    badge_name VARCHAR(100) NOT NULL,
    badge_type VARCHAR(50),
    description TEXT,
    earned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_badges_user_id (user_id)
);
