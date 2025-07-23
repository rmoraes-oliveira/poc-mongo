# 📊 Dashboard de Análise - POC MongoDB

Dashboard interativo desenvolvido com **Chart.js** e **D3.js** para visualizar a predominância de fornecedores por região no Brasil.

## 🎯 Funcionalidades

### 📍 **Mapa do Brasil Coroplético**
- **Mapa geográfico real** das regiões brasileiras usando coordenadas precisas
- **Cores dinâmicas** indicando o fabricante dominante em cada região
- **Tooltips interativos** com informações detalhadas ao passar o mouse
- **Cliques para modal** com dados completos de cada região
- **Projeção Mercator** para visualização geográfica precisa

### 📈 **Gráficos e Estatísticas**
- **Cards de estatísticas** com totais gerais
- **Gráfico de pizza** dos top fabricantes
- **Gráfico de linha** da evolução temporal
- **Ranking regional** com contadores

### 🔍 **Dados Analisados**
- **10.000 registros** distribuídos entre 2023-2025
- **5 regiões** brasileiras
- **8 fabricantes** diferentes
- **Predominância calculada** em tempo real via MongoDB Aggregation

## 🛠️ Tecnologias Utilizadas

### **Frontend**
- **Bootstrap 5.3** - Layout responsivo e componentes
- **Chart.js** - Gráficos interativos (pizza, linha e mapa)
- **chartjs-chart-geo v4** - Mapa coroplético real do Brasil
- **TopoJSON** - Dados geográficos para renderização
- **Font Awesome 6.4** - Ícones modernos
- **CSS customizado** - Design moderno com gradientes

### **Backend**
- **Ruby on Rails 8.0** - Framework web
- **MongoDB Aggregation Pipeline** - Processamento de dados em tempo real
- **Mongoid 9.0** - ODM para MongoDB
- **JSON APIs** - Endpoints RESTful para dados

### **Database**
- **MongoDB 7.0** - Banco de dados NoSQL
- **Aggregation Framework** - Análises complexas
- **Índices otimizados** - Performance de consultas

## 🚀 Como Usar

### 1. **Iniciar Serviços**
```bash
# Iniciar MongoDB
docker compose up -d

# Verificar se há dados (opcional)
rails runner "puts CartItem.count"

# Se não houver dados, executar seed
rails db:seed
```

### 2. **Iniciar Dashboard**
```bash
# Iniciar servidor Rails
rails server

# Acessar dashboard
# http://localhost:3000
```

### 3. **Navegar pelo Dashboard**
- **Visualizar mapa** com predominância por região
- **Analisar gráficos** de fabricantes e evolução temporal
- **Interagir com tooltips** para informações detalhadas
- **Consultar estatísticas** regionais

## 📊 Estrutura dos Dados

### **APIs Disponíveis**

#### `GET /api/regional-dominance`
```json
{
  "regions": {
    "Centro-Oeste": {
      "dominant": {
        "name": "Elanco",
        "count": 301,
        "percentage": 13.6
      },
      "total": 2211
    }
  },
  "legend": {
    "Elanco": "#FF6384",
    "Zoetis": "#36A2EB"
  }
}
```

#### `GET /api/stats`
```json
{
  "total_items": 10000,
  "manufacturers_stats": [...],
  "regional_stats": [...],
  "temporal_stats": [...]
}
```

## 🎨 Características do Design

### **Interface Moderna**
- **Gradientes vibrantes** no header e cards
- **Cards com hover effects** para interatividade
- **Layout responsivo** para diferentes telas
- **Animações suaves** em transições

### **Cores e Temas**
- **Paleta principal**: Azul/Roxo gradiente (#667eea → #764ba2)
- **Cards de estatísticas**: Gradiente matching
- **Cores do mapa**: Paleta diversificada para fabricantes
- **Background**: Cinza claro (#f8f9fa)

### **Tipografia**
- **Fonte**: Segoe UI, Tahoma, Geneva, Verdana
- **Ícones**: Font Awesome 6.4
- **Hierarquia visual** clara com tamanhos consistentes

## 📈 Dados de Demonstração

### **Estatísticas Atuais** (baseado no seed)
- **Total de Items**: 10.000
- **Fabricantes**: 8 (Elanco, Zoetis, MSD, Boehringer, etc.)
- **Regiões**: 5 regiões brasileiras
- **Período**: 2023-2025

### **Predominância Regional**
- **Centro-Oeste**: Elanco (13.6%)
- **Nordeste**: Zoetis (13.6%)
- **Sudeste**: Boehringer Ingelheim (13.3%)
- **Norte**: Variável por estado
- **Sul**: Variável por estado

## 🔧 Customização

### **Adicionar Novos Fabricantes**
1. Inserir dados via seed ou console Rails
2. Dashboard atualiza automaticamente via API
3. Cores são atribuídas dinamicamente

### **Modificar Regiões**
1. Editar constante `BRASIL_REGIONS` no JavaScript
2. Ajustar coordenadas se necessário
3. API backend funciona com qualquer região

### **Personalizar Gráficos**
1. Modificar configurações do Chart.js
2. Alterar cores na paleta
3. Adicionar novos tipos de gráfico

## 🚨 Troubleshooting

### **Dashboard não carrega**
```bash
# Verificar se MongoDB está rodando
docker compose ps

# Verificar dados no banco
rails runner "puts CartItem.count"

# Verificar logs do Rails
tail -f log/development.log
```

### **Erro nas APIs**
```bash
# Testar API diretamente
curl http://localhost:3000/api/stats

# Verificar aggregations no MongoDB
rails console
> CartItem.collection.aggregate([...])
```

### **Problemas de Performance**
- Dados são processados via **MongoDB Aggregation**
- **Índices otimizados** para consultas rápidas
- **Cache de browser** para assets estáticos

## 🎉 Conclusão

O dashboard oferece uma **visualização completa e interativa** da distribuição de fornecedores por região, combinando:

- **Performance** com MongoDB Aggregation
- **Design moderno** com Chart.js e mapa coroplético geográfico
- **Responsividade** com Bootstrap
- **Dados realistas** de 10.000 registros
- **Visualização geográfica precisa** com chartjs-chart-geo

**Pronto para análises de negócio e tomada de decisões baseadas em dados!** 📊✨ 