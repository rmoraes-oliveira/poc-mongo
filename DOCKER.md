# MongoDB com Docker Compose

Este projeto inclui uma configuração Docker Compose para facilitar o desenvolvimento local com MongoDB e Mongo Express.

## 🚀 Como usar

### 1. Iniciar os serviços

```bash
# Iniciar MongoDB e Mongo Express em background
docker compose up -d

# Ver logs dos containers
docker compose logs -f

# Ver status dos containers
docker compose ps
```

### 2. Acessar o Mongo Express

Abra seu navegador em: http://localhost:8081

- **Usuário admin**: admin
- **Senha admin**: password123

### 3. Parar os serviços

```bash
# Parar todos os containers
docker compose down

# Parar e remover volumes (CUIDADO: apaga todos os dados!)
docker compose down -v
```

## 📋 Serviços Incluídos

### MongoDB
- **Porta**: 27017
- **Usuário admin**: admin
- **Senha admin**: password123
- **Bancos criados automaticamente**:
  - `poc_mongo_development` (desenvolvimento)
  - `poc_mongo_test` (testes)

### Mongo Express
- **Porta**: 8081
- **Interface web** para administrar o MongoDB
- **Acesso**: http://localhost:8081

## 🔧 Configuração

### Credenciais do Rails/Mongoid

As configurações do Mongoid já estão atualizadas para usar as credenciais do Docker:

```yaml
# config/mongoid.yml
development:
  clients:
    default:
      uri: mongodb://admin:password123@localhost:27017/poc_mongo_development?authSource=admin
```

### Script de Inicialização

O arquivo `mongo-init/init-mongo.js` cria automaticamente:
- Usuários específicos do projeto
- Coleções básicas
- Configurações iniciais

## 🛠️ Comandos Úteis

```bash
# Acessar o shell do MongoDB
docker compose exec mongodb mongosh -u admin -p password123 --authenticationDatabase admin

# Ver logs específicos do MongoDB
docker compose logs mongodb

# Ver logs específicos do Mongo Express
docker compose logs mongo-express

# Reiniciar apenas o MongoDB
docker compose restart mongodb

# Backup do banco
docker compose exec mongodb mongodump -u admin -p password123 --authenticationDatabase admin --out /backup

# Restaurar backup
docker compose exec mongodb mongorestore -u admin -p password123 --authenticationDatabase admin /backup
```

## 🔒 Segurança

⚠️ **IMPORTANTE**: As credenciais neste arquivo são para desenvolvimento local apenas!

Para produção:
1. Use variáveis de ambiente
2. Configure senhas seguras
3. Habilite SSL/TLS
4. Configure autenticação adequada

## 📂 Estrutura de Arquivos

```
├── docker-compose.yml     # Configuração dos containers
├── mongo-init/
│   └── init-mongo.js     # Script de inicialização do MongoDB
└── config/
    └── mongoid.yml       # Configuração do Mongoid (atualizada)
```

## 🚨 Troubleshooting

### Erro de conexão
```bash
# Verificar se os containers estão rodando
docker compose ps

# Verificar logs de erro
docker compose logs
```

### Problema de permissão
```bash
# No Linux, pode ser necessário ajustar permissões
sudo chown -R $USER:$USER mongo-init/
```

### Limpar dados e recomeçar
```bash
# Para limpar completamente e recomeçar
docker compose down -v
docker compose up -d
``` 