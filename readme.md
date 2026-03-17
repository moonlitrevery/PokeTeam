# 📘 PokeTeam — Documentação do Projeto

O **PokeTeam** é um projeto full-stack que integra um frontend em **Astro** com um backend em **Node.js**, utilizando a **PokeAPI** como fonte de dados.
Ele permite visualizar detalhes da Pokédex, criar times personalizados de Pokémon e gerenciar usuários de forma interativa.

Este documento descreve em detalhes o domínio do problema, a arquitetura do banco de dados, a estrutura do código e instruções completas de execução.

---

## 📋 Índice

1. [Domínio do Problema](#-domínio-do-problema)
2. [Modelo de Banco de Dados](#-modelo-de-banco-de-dados)
3. [Arquitetura do Código](#-arquitetura-do-código)
4. [Estrutura do Repositório](#-estrutura-do-repositório)
5. [Pré-requisitos](#-pré-requisitos)
6. [Instalação](#-instalação-de-dependências)
7. [Execução do Projeto](#-executando-o-projeto)
8. [Exemplos de Consultas SQL](#-exemplos-de-consultas-sql)
9. [Testes](#-testes)
10. [Build de Produção](#-build-de-produção)

---

## 🎯 Domínio do Problema

### **Contexto**

O universo Pokémon apresenta um vasto conjunto de criaturas com características únicas (tipos, habilidades, estatísticas). Jogadores e fãs frequentemente desejam:

- **Explorar a Pokédex completa** com informações detalhadas
- **Criar e gerenciar times estratégicos** (limitados a 6 Pokémon)
- **Acompanhar seu progresso** (Pokémon vistos/capturados)
- **Compartilhar e comparar times** com outros treinadores

### **Problema**

Não existe uma plataforma centralizada que integre:

1. **Consulta eficiente** à base de dados completa de Pokémon
2. **Sistema de autenticação** para múltiplos usuários
3. **Gerenciamento de times personalizados** com validações de negócio
4. **Tracking individual** de progresso na Pokédex
5. **Interface moderna e responsiva** para desktop e mobile

### **Solução Proposta**

O **PokeTeam** resolve esses problemas através de:

- **Backend RESTful** com Node.js + Express + MySQL
- **Frontend moderno** com Astro e JavaScript vanilla
- **Arquitetura em camadas** (MVC) para separação de responsabilidades
- **Integração com PokeAPI** para dados atualizados
- **Validações robustas** de negócio e segurança
- **Sistema de cache** e otimização de consultas

---

## 🗄️ Modelo de Banco de Dados

### **Modelo Conceitual**

O sistema é composto por **5 entidades principais** (requisito do projeto acadêmico de Banco de Dados):

```
USERS (Usuários)
  ├─ Atributos: id, username, email, password_hash, created_at
  └─ Relacionamentos: 1:N com USER_POKEDEX, USER_TEAMS e USER_BADGES

POKEMON (Pokémon)
  ├─ Atributos: id, name, height, weight, base_experience, types, abilities, sprites, stats
  └─ Relacionamentos: 1:N com USER_POKEDEX

USER_POKEDEX (Progresso do Usuário)
  ├─ Atributos: user_id, pokemon_id, status, is_favorite, custom_nickname, notes
  └─ Relacionamentos: N:1 com USERS e POKEMON

USER_TEAMS (Times de Pokémon)
  ├─ Atributos: id, user_id, team_name, pokemon_ids, is_active, created_at
  └─ Relacionamentos: N:1 com USERS

USER_BADGES (Emblemas/Conquistas do Usuário)
  ├─ Atributos: id, user_id, badge_name, badge_type, description, earned_at
  └─ Relacionamentos: N:1 com USERS
```

### **Modelo Lógico (MySQL)**

```sql
-- Tabela de usuários
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(150) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_email (email)
);

-- Tabela de pokémons (dados da PokeAPI)
CREATE TABLE pokemon (
    id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    height INT,
    weight INT,
    base_experience INT,
    types JSON,
    abilities JSON,
    sprite_front_default VARCHAR(255),
    sprite_front_shiny VARCHAR(255),
    sprite_official_artwork VARCHAR(255),
    stats JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_name (name)
);

-- Tabela de progresso do usuário na pokédex
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

-- Tabela de times do usuário
CREATE TABLE user_teams (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    team_name VARCHAR(100) NOT NULL,
    pokemon_ids JSON,
    is_active BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_teams_user_id (user_id)
);

-- Tabela de emblemas/conquistas do usuário
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
```

### **Decisões de Design**

1. **Uso de JSON para dados complexos**: Types, abilities, stats e pokemon_ids são armazenados como JSON para flexibilidade e facilidade de manutenção
2. **Chave primária composta em user_pokedex**: Garante que um usuário não pode ter duplicatas do mesmo Pokémon
3. **ON DELETE CASCADE**: Quando um usuário é deletado, seus dados relacionados são automaticamente removidos
4. **Índices estratégicos**: Email e name são indexados para otimizar buscas frequentes
5. **ENUM para status**: Limita valores possíveis e garante integridade dos dados

### **Diagrama ER Completo**

Para visualizar o diagrama entidade-relacionamento completo com todos os relacionamentos e cardinalidades, consulte:

📊 **[docs/ER_DIAGRAM.md](docs/ER_DIAGRAM.md)**

### **Entrega – Projeto Final (Prática em Banco de Dados)**

Para a entrega em PDF no Connect (capa, modelagem e SQL DML), use o documento:

📄 **[docs/ENTREGA_PROJETO_FINAL_BD.md](docs/ENTREGA_PROJETO_FINAL_BD.md)** — preencha os nomes dos integrantes e exporte para PDF. Os exemplos DML completos estão em **scripts/exemplos_dml.sql**.

---

## 🏛️ Arquitetura do Código

### **Padrão de Arquitetura: MVC (Model-View-Controller)**

O backend segue uma arquitetura em camadas que separa responsabilidades:

```
Cliente (Frontend)
       │
       ↓ HTTP Request
       │
   [ROUTES] ───────────────── Define endpoints e middlewares
       │
       ↓
       │
 [CONTROLLERS] ────────────── Recebe requisições, valida e retorna respostas
       │
       ↓
       │
  [SERVICES] ──────────────── Lógica de negócio e validações
       │
       ↓
       │
   [MODELS] ───────────────── Interação direta com o banco de dados
       │
       ↓
       │
   Database (MySQL)
```

### **Responsabilidades de Cada Camada**

#### **1. Routes (`/backend/src/routes/`)**

**Função**: Definir endpoints HTTP e aplicar middlewares

```javascript
// Exemplo: routes/users.js
router.post("/users/register", UserController.create);
router.post("/users/login", UserController.login);
router.get("/users/:id", UserController.findById);
```

**Responsabilidades**:
- Mapear URLs para controllers
- Aplicar rate limiting e autenticação
- Logging de requisições

#### **2. Controllers (`/backend/src/controllers/`)**

**Função**: Processar requisições HTTP e formatar respostas

```javascript
// Exemplo: UserController.js
async create(req, res) {
  try {
    const user = await UserService.createUser(req.body);
    res.status(201).json({ success: true, data: user });
  } catch (error) {
    res.status(400).json({ success: false, error: error.message });
  }
}
```

**Responsabilidades**:
- Extrair dados da requisição (body, params, query)
- Chamar o Service apropriado
- Formatar resposta (success/error)
- Definir status HTTP correto

#### **3. Services (`/backend/src/services/`)**

**Função**: Implementar regras de negócio e validações

```javascript
// Exemplo: UserService.js
async createUser(userData) {
  // Validações de negócio
  if (userData.password.length < 6) {
    throw new Error("Senha deve ter pelo menos 6 caracteres");
  }
  
  // Verifica duplicatas
  const existingUser = await UserModel.findByEmail(userData.email);
  if (existingUser) {
    throw new Error("É já cadastrado");
  }
  
  // Hash de senha
  const password_hash = await bcrypt.hash(userData.password, 12);
  
  return await UserModel.create({ ...userData, password_hash });
}
```

**Responsabilidades**:
- Validações de negócio complexas
- Criptografia de senhas
- Orquestração de múltiplos models
- Transformação de dados

#### **4. Models (`/backend/src/models/`)**

**Função**: Comunicar diretamente com o banco de dados

```javascript
// Exemplo: UserModel.js
async create(userData) {
  const sql = `INSERT INTO users (username, email, password_hash) VALUES (?, ?, ?)`;
  const [result] = await db.query(sql, [
    userData.username,
    userData.email,
    userData.password_hash
  ]);
  return this.findById(result.insertId);
}
```

**Responsabilidades**:
- Queries SQL (SELECT, INSERT, UPDATE, DELETE)
- Tratar resultados do banco
- NÃO contém regras de negócio

#### **5. Middleware (`/backend/src/middleware/`)**

**Função**: Processar requisições antes de chegarem aos controllers

- **`security.js`**: CORS, Helmet, sanitização de inputs
- **`rateLimit.js`**: Limitação de requisições por IP
- **`auth.js`**: Autenticação e autorização
- **`validation.js`**: Validações de schemas com Joi

### **Frontend - Arquitetura Astro**

```
frontend/
  ├─ src/
  │   ├─ pages/           # Páginas (roteamento automático)
  │   │   ├─ index.astro      # Página inicial
  │   │   ├─ login.astro      # Login de usuário
  │   │   ├─ register.astro   # Registro de usuário
  │   │   ├─ pokedex.astro    # Busca de Pokémon (com autocomplete)
  │   │   └─ team-builder.astro # Criação de times
  │   │
  │   ├─ layouts/         # Layouts reutilizáveis
  │   │   └─ BaseLayout.astro # Layout base com header/footer
  │   │
  │   ├─ components/      # Componentes reutilizáveis
  │   │   └─ Footer.astro
  │   │
  │   ├─ lib/             # Utlitários e helpers
  │   │   └─ api.js          # Configuração de API
  │   │
  │   └─ styles/          # CSS global
  │       └─ theme.css       # Tema visual do projeto
  │
  └─ astro.config.mjs  # Configuração do Astro
```

---

## 📱 Estrutura do Repositório

```
PokeTeam/
 ├─ backend/
 │   ├─ src/
 │   │   ├─ controllers/      # Controllers (UserController, PokemonController, TeamController)
 │   │   ├─ services/         # Services (UserService, PokemonService, TeamService)
 │   │   ├─ models/           # Models (UserModel, PokemonModel, TeamModel)
 │   │   ├─ routes/           # Routes (users, pokemons, teams)
 │   │   ├─ middleware/       # Middlewares (security, rateLimit, auth, validation)
 │   │   ├─ db/               # Conexão com banco
 │   │   ├─ __tests__/        # Testes unitários
 │   │   ├─ app.js            # Configuração do Express
 │   │   └─ server.js         # Inicialização do servidor
 │   │
 │   ├─ package.json
 │   ├─ .env.example
 │   └─ Dockerfile
 │
 ├─ frontend/
 │   ├─ src/               # Código-fonte
 │   ├─ public/            # Assets estáticos
 │   ├─ package.json
 │   ├─ astro.config.mjs
 │   └─ Dockerfile
 │
 ├─ scripts/
 │   └─ init.sql          # Script de criação do banco
 │
 ├─ docker-compose.yml
 ├─ README.md
 └─ LICENSE
```

---

## 🧱 Arquitetura do Projeto

### **Frontend (Astro)**

* Framework: **Astro**
* Linguagem: **JavaScript**
* Responsável pela interface de usuário e consumo dos dados retornados pelo backend.

### **Backend (Node.js)**

* Plataforma: **Node.js**
* Utiliza Express.js como framework da API
* Atua como:

  * Proxy para obter dados da PokeAPI
  * Camada para abstrair e tratar informações
  * API própria para servir dados ao frontend

### **Integrações**

* API externa utilizada: **PokeAPI ([https://pokeapi.co](https://pokeapi.co))**

### **Infraestrutura**

* Suporte nativo a **Docker** via `docker-compose.yml`
  → Permite levantar frontend + backend juntos e criar o database vázio com um único comando.

---

## ⚡️ Pré-requisitos

Antes de instalar o projeto, você precisará de:

| Tecnologia         | Versão Recomendada |
| ------------------ | ------------------ |
| **Node.js**        | 18+                |
| **npm**            | 9+                 |
| **MySQL**          | 8.0+ (se local)    |
| **Docker**         | opcional           |
| **Docker Compose** | opcional           |

---

## 🔧 Configuração de Ambiente

### **Variáveis de Ambiente - Backend**

Crie um arquivo `.env` na pasta `backend/` baseado no `.env.example`:

```bash
cd backend
cp .env.example .env
```

**Conteúdo do `.env`**:

```env
# Database Configuration
MYSQL_HOST=localhost          # Use 'db' se estiver usando Docker
MYSQL_PORT=3069               # Porta do MySQL no host
MYSQL_USER=root
MYSQL_PASSWORD=root
MYSQL_DATABASE=poke_db

# Server Configuration
PORT=3067                     # Porta do backend
NODE_ENV=development          # development | production

# JWT Secret (opcional - para autenticação futura)
JWT_SECRET=seu_jwt_secret_aqui
```

### **Variáveis de Ambiente - Frontend**

O frontend usa variáveis públicas no Astro:

```env
PUBLIC_API_URL=http://localhost:3067
```

Essas são configuradas automaticamente no `docker-compose.yml` ou podem ser definidas diretamente no arquivo `frontend/src/lib/api.js`.

### **Configuração do Docker**

O `docker-compose.yml` já está pré-configurado com:

- **Backend**: Porta 3067
- **Frontend**: Porta 4321
- **MySQL**: Porta 3069 (host) → 3306 (container)

Não é necessário criar `.env` ao usar Docker.

---

## 📦 Instalação de Dependências

O projeto possui duas etapas de instalação:

### 🔹 1. Backend

```bash
cd backend
npm install
```

### 🔹 2. Frontend

```bash
cd frontend
npm install
```

---

## 🚀 Executando o Projeto

Você pode rodar o PokeTeam de duas maneiras: **com Docker** ou **localmente**.

---

# ▶️ Método 1 — Executar com Docker (Recomendado)

Executa **frontend + backend** automaticamente.

### 1. Build & Start:

```bash
docker compose up -d --build
```

### 2. Acessar o Projeto:

* Frontend: [http://localhost:4321](http://localhost:4321)
* Backend: [http://localhost:3067](http://localhost:3067) (ou porta configurada)

### 3. Encerrar:

```bash
docker compose down
```

---

# ▶️ Método 2 — Executar Manualmente (Sem Docker)

### 🔹 Iniciar o backend

```bash
cd backend
npm run dev
```

### 🔹 Iniciar o frontend

```bash
cd frontend
npm run dev
```

### Depois, acesse:

* Frontend: [http://localhost:4321](http://localhost:4321)
* Backend: [http://localhost:3067](http://localhost:3067)

---

## 🏗️ Build de Produção

### 🔹 Backend (Node.js)

Normalmente o backend não requer build, apenas instalação:

```bash
cd backend
npm install
npm start
```

### 🔹 Frontend (Astro)

Gerar build otimizado:

```bash
cd frontend
npm run build
```

Saída gerada em:

```
frontend/dist/
```

Visualizar o build:

```bash
npm run preview
```

---

## 🧪 Scripts Úteis

### Backend

| Comando       | Função                      |
| ------------- | --------------------------- |
| `npm run dev` | Inicia modo desenvolvimento |
| `npm start`   | Inicia modo produção        |

### Frontend

| Comando           | Função                      |
| ----------------- | --------------------------- |
| `npm run dev`     | Ambiente de desenvolvimento |
| `npm run build`   | Gera build estático         |
| `npm run preview` | Visualiza build             |

---

## 🔌 Endpoints da API

O backend expõe uma API RESTful nas seguintes rotas:

### **Usuários** (`/users`)

| Método | Endpoint            | Descrição                      | Body/Params                                   |
| ------ | ------------------- | -------------------------------- | --------------------------------------------- |
| POST   | `/users/register`   | Registrar novo usuário          | `{ username, email, password }`               |
| POST   | `/users/login`      | Fazer login                      | `{ email, password }`                         |
| GET    | `/users`            | Listar todos os usuários        | -                                             |
| GET    | `/users/:id`        | Buscar usuário por ID            | `id` (param)                                  |
| PUT    | `/users/:id`        | Atualizar dados do usuário      | `id` (param) + `{ username?, email?, password? }` |
| DELETE | `/users/:id`        | Deletar usuário                 | `id` (param)                                  |

### **Pokémon** (`/pokemon`)

| Método | Endpoint            | Descrição                      | Query Params                                  |
| ------ | ------------------- | -------------------------------- | --------------------------------------------- |
| GET    | `/pokemon`          | Listar Pokémon (paginado)       | `?limit=50&offset=0`                          |
| GET    | `/pokemon/:id`      | Buscar Pokémon por ID            | `id` (param)                                  |
| GET    | `/pokemon/search`   | Buscar Pokémon por nome          | `?name=pikachu`                               |

### **Times** (`/teams`)

| Método | Endpoint                  | Descrição                      | Body/Params                                   |
| ------ | ------------------------- | -------------------------------- | --------------------------------------------- |
| POST   | `/teams/create`           | Criar novo time                  | `{ user_id, team_name, pokemon_ids[] }`       |
| GET    | `/teams`                  | Listar todos os times            | -                                             |
| GET    | `/teams/:id`              | Buscar time por ID               | `id` (param)                                  |
| PUT    | `/teams/:id/add-pokemon`  | Adicionar Pokémon ao time        | `id` (param) + `{ pokemon_id }`               |
| PUT    | `/teams/:id/remove-pokemon` | Remover Pokémon do time        | `id` (param) + `{ pokemon_id }`               |
| DELETE | `/teams/:id`              | Deletar time                     | `id` (param)                                  |

### **Saúde da API** (`/health`)

| Método | Endpoint  | Descrição            |
| ------ | --------- | ---------------------- |
| GET    | `/health` | Verificar status da API |

**Exemplo de resposta**:
```json
{
  "success": true,
  "message": "API está funcionando",
  "timestamp": "2025-01-16T20:00:00.000Z"
}
```

### **Padrão de Respostas**

Todas as respostas seguem o formato:

**Sucesso**:
```json
{
  "success": true,
  "data": { /* dados */ },
  "message": "Operação bem-sucedida"
}
```

**Erro**:
```json
{
  "success": false,
  "error": "Mensagem de erro"
}
```

### **Segurança e Limitações**

- **Rate Limiting**:
  - Login/Register: 5 requisições por 15 minutos
  - Criação de times: 10 requisições por hora
  - Endpoints gerais: 100 requisições por 15 minutos

- **CORS**: Configurado para aceitar requisições de `localhost:4321`

- **Sanitização**: Todos os inputs são sanitizados contra XSS

- **Helmet**: Headers de segurança HTTP configurados

---

## 📊 Exemplos de Consultas SQL

### **Scripts SQL de Criação**

O arquivo `/scripts/init.sql` contém todos os scripts necessários para criar o banco de dados.
Ele é executado automaticamente quando o Docker é iniciado.

### **Consultas Implementadas no Sistema**

#### **1. Buscar Usuário por Email (Login)**

```sql
SELECT id, username, email, password_hash 
FROM users 
WHERE email = 'ash@example.com';
```

**Resultado**:
```
+----+----------+------------------+--------------------------------------------------------------+
| id | username | email            | password_hash                                                |
+----+----------+------------------+--------------------------------------------------------------+
|  1 | AshK     | ash@example.com  | $2b$12$XyZ... (hash bcrypt)                                      |
+----+----------+------------------+--------------------------------------------------------------+
```

**Uso no código**: `UserModel.findByEmail()` - Validação de login

---

#### **2. Criar Novo Usuário**

```sql
INSERT INTO users (username, email, password_hash) 
VALUES ('Misty', 'misty@example.com', '$2b$12$abc...');
```

**Resultado**:
```
Query OK, 1 row affected (0.05 sec)
insertId: 2
```

**Uso no código**: `UserModel.create()` - Registro de novo usuário

---

#### **3. Buscar Pokémon por Nome (com LIKE)**

```sql
SELECT * FROM pokemon 
WHERE name LIKE '%char%'
LIMIT 10;
```

**Resultado**:
```
+----+-----------+--------+--------+----------------+-------------------------+
| id | name      | height | weight | base_experience| types                   |
+----+-----------+--------+--------+----------------+-------------------------+
|  4 | charmander|     6  |   85   |      62        | ["fire"]                |
|  5 | charmeleon|    11  |  190   |     142        | ["fire"]                |
|  6 | charizard |    17  |  905   |     267        | ["fire", "flying"]      |
+----+-----------+--------+--------+----------------+-------------------------+
```

**Uso no código**: `PokemonModel.searchByName()` - Busca na Pokédex

---

#### **4. Listar Times de um Usuário**

```sql
SELECT id, team_name, pokemon_ids, is_active, created_at
FROM user_teams
WHERE user_id = 1
ORDER BY created_at DESC;
```

**Resultado**:
```
+----+-----------------+------------------------+-----------+---------------------+
| id | team_name       | pokemon_ids            | is_active | created_at          |
+----+-----------------+------------------------+-----------+---------------------+
|  1 | Kanto Starters  | [1, 4, 7]              |     1     | 2025-01-15 10:30:00 |
|  2 | Fire Team       | [4, 5, 6, 37, 58, 77]  |     0     | 2025-01-14 15:20:00 |
+----+-----------------+------------------------+-----------+---------------------+
```

**Uso no código**: `TeamModel.findAllTeams()` - Listar times do usuário

---

#### **5. Adicionar Pokémon a um Time**

```sql
UPDATE user_teams 
SET pokemon_ids = '[1, 4, 7, 25]'
WHERE id = 1;
```

**Resultado**:
```
Query OK, 1 row affected (0.03 sec)
Rows matched: 1  Changed: 1
```

**Uso no código**: `TeamModel.addPokemonToTeam()` - Adicionar Pokémon ao time

---

#### **6. Contar Total de Pokémon no Banco**

```sql
SELECT COUNT(*) as total FROM pokemon;
```

**Resultado**:
```
+-------+
| total |
+-------+
|  151  |
+-------+
```

**Uso no código**: `PokemonModel.getCount()` - Paginação

---

#### **7. Buscar Progresso do Usuário na Pokédex**

```sql
SELECT 
    up.pokemon_id,
    p.name,
    up.status,
    up.is_favorite,
    up.custom_nickname
FROM user_pokedex up
JOIN pokemon p ON up.pokemon_id = p.id
WHERE up.user_id = 1 AND up.status = 'caught'
ORDER BY up.updated_at DESC
LIMIT 20;
```

**Resultado**:
```
+------------+-----------+--------+-------------+-----------------+
| pokemon_id | name      | status | is_favorite | custom_nickname |
+------------+-----------+--------+-------------+-----------------+
|         25 | pikachu   | caught |      1      | Sparky          |
|          1 | bulbasaur | caught |      0      | NULL            |
|        150 | mewtwo    | caught |      1      | Legendary       |
+------------+-----------+--------+-------------+-----------------+
```

**Uso potencial**: Recurso de tracking de progresso (pode ser implementado)

---

### **Queries de Manutenção**

#### **Deletar Usuário e Dados Relacionados (CASCADE)**

```sql
DELETE FROM users WHERE id = 1;
-- Automaticamente deleta registros em user_pokedex e user_teams
```

#### **Atualizar Senha de Usuário**

```sql
UPDATE users 
SET password_hash = '$2b$12$newHash...'
WHERE id = 1;
```

---

## 🧪 Testes

O projeto inclui testes unitários e de integração usando **Jest**.

### **Executar Testes**

```bash
cd backend
npm test
```

### **Cobertura de Testes**

Os testes cobrem:
- **Controllers**: Validação de respostas HTTP
- **Services**: Lógica de negócio e validações
- **Models**: Queries SQL
- **Routes**: Endpoints e middlewares

### **Estrutura de Testes**

```
backend/src/__tests__/
  ├─ controllers/
  │   ├─ UserController.test.js
  │   └─ PokemonController.test.js
  ├─ services/
  │   ├─ UserService.test.js
  │   └─ TeamService.test.js
  ├─ models/
  │   └─ UserModel.test.js
  └─ routes/
      └─ routes.users.test.js
```

---

## ⚠️ Troubleshooting

### **Problema: CORS Error no Frontend**

**Sintoma**: Console mostra erro de CORS ao tentar fazer requisições

**Solução**:
1. Verifique se o backend está rodando na porta 3067
2. Confirme que o arquivo `backend/src/middleware/security.js` contém a URL do frontend
3. Reinicie o backend após mudanças

### **Problema: Banco de Dados Não Conecta**

**Sintoma**: Erro "MySQL connection failed"

**Solução**:
1. Verifique se o MySQL está rodando:
   ```bash
   # Docker
   docker ps | grep pokedb
   
   # Local
   mysql -u root -p
   ```
2. Confirme as credenciais no `.env`
3. Verifique a porta (3069 no host, 3306 no container)

### **Problema: Frontend Não Carrega Estilos**

**Solução**:
```bash
cd frontend
rm -rf node_modules dist .astro
npm install
npm run dev
```

### **Problema: Rate Limit Atingido**

**Sintoma**: Erro "Too many requests"

**Solução**: Aguarde 15 minutos ou ajuste os limites em `backend/src/middleware/rateLimit.js`

### **Problema: Docker Não Inicia**

**Solução**:
```bash
# Limpar containers e volumes antigos
docker-compose down -v

# Reconstruir imagens
docker-compose build --no-cache

# Iniciar novamente
docker-compose up -d
```

---

## 📦 Dependências Principais

### **Backend**

| Pacote              | Versão | Finalidade                          |
| ------------------- | ----- | ----------------------------------- |
| express             | 5.1.0 | Framework web                       |
| mysql2              | 3.15  | Driver MySQL                        |
| bcrypt              | 6.0   | Hash de senhas                      |
| cors                | 2.8   | Habilitar CORS                      |
| helmet              | 7.1   | Segurança HTTP headers              |
| express-rate-limit  | 7.4   | Limitação de requisições            |
| joi                 | 17.13 | Validação de schemas                 |
| dotenv              | 17.2  | Variáveis de ambiente                |
| jest                | 29.7  | Framework de testes                 |

### **Frontend**

| Pacote              | Versão | Finalidade                          |
| ------------------- | ----- | ----------------------------------- |
| astro               | 4.x   | Framework SSR                       |
| JavaScript (Vanilla)| -     | Interações do cliente              |

---

## 🚀 Funcionalidades Implementadas

- ✅ Sistema de autenticação (registro e login)
- ✅ CRUD completo de usuários
- ✅ Busca de Pokémon com autocomplete
- ✅ Criação e gerenciamento de times
- ✅ Validação de limite de 6 Pokémon por time
- ✅ Integração com PokeAPI
- ✅ Rate limiting e segurança
- ✅ Interface responsiva
- ✅ Docker support
- ✅ Testes unitários

## 📈 Possíveis Melhorias Futuras

- ⏳ Implementar JWT para autenticação stateless
- ⏳ Sistema de tracking de progresso na Pokédex
- ⏳ Funcionalidade de favoritos
- ⏳ Chat ou comparação de times entre usuários
- ⏳ Sistema de emblemas/conquistas
- ⏳ Cache com Redis para melhor performance
- ⏳ WebSockets para atualizações em tempo real
- ⏳ Upload de avatares de usuário

---

## 👥 Contribuindo

Contribuições são bem-vindas! Por favor:

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/NovaFuncionalidade`)
3. Commit suas mudanças (`git commit -m 'Adiciona nova funcionalidade'`)
4. Push para a branch (`git push origin feature/NovaFuncionalidade`)
5. Abra um Pull Request

---

## 📜 Licença

Este projeto está sob a **MIT License**.

---

## ✍️ Autores

Desenvolvido como projeto acadêmico de Banco de Dados.

---

**🌟 Se este projeto foi útil, considere dar uma estrela no repositório!**
