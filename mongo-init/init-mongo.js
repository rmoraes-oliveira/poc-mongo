// Script de inicialização do MongoDB
// Este script é executado quando o container do MongoDB é criado pela primeira vez

// Conecta ao banco de desenvolvimento
db = db.getSiblingDB('poc_mongo_development');

// Cria um usuário específico para o projeto
db.createUser({
  user: "poc_user",
  pwd: "poc_password",
  roles: [
    {
      role: "readWrite",
      db: "poc_mongo_development"
    }
  ]
});

print('Usuário poc_user criado para banco poc_mongo_development');

// Conecta ao banco de teste
db = db.getSiblingDB('poc_mongo_test');

// Cria o mesmo usuário para o banco de teste
db.createUser({
  user: "poc_user", 
  pwd: "poc_password",
  roles: [
    {
      role: "readWrite",
      db: "poc_mongo_test"
    }
  ]
});

print('Usuário poc_user criado para banco poc_mongo_test');

// Cria uma coleção de exemplo no banco de desenvolvimento
db = db.getSiblingDB('poc_mongo_development');
db.createCollection('users');
print('Coleção users criada'); 