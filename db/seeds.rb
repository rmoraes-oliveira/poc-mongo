# db/seeds.rb
# Seed otimizado usando bulk insert para MongoDB

require_relative '../config/environment'

puts "🌱 Iniciando seed do banco de dados..."
start_time = Time.now

# Limpar dados existentes
puts "🗑️  Limpando dados existentes..."
CartItem.delete_all
Subcategory.delete_all  
Category.delete_all
Manufacturer.delete_all

# Criar dados base
puts "🏭 Criando dados base..."

# Criar manufacturers com informações básicas
manufacturers_data = [
  {name: "Bayer", external_id: "BAYER", weight: 25},           # Líder de mercado
  {name: "Zoetis", external_id: "ZOETS", weight: 20},          # Segundo maior
  {name: "Virbac", external_id: "VIRBC", weight: 12},          # Terceiro
  {name: "MSD Saúde Animal", external_id: "MSDSA", weight: 12}, # Quarto
  {name: "Elanco", external_id: "ELANC", weight: 10},          # Quinto
  {name: "Boehringer Ingelheim", external_id: "BOEHR", weight: 8}, # Sexto
  {name: "Ceva", external_id: "CEVA", weight: 7},              # Sétimo
  {name: "Vetnil", external_id: "VETNIL", weight: 6}           # Oitavo
]

# Criar manufacturers no banco
manufacturers = manufacturers_data.map do |mfg_data|
  Manufacturer.create!(name: mfg_data[:name], external_id: mfg_data[:external_id])
end

# Criar array com pesos para seleção ponderada
manufacturers_with_weights = manufacturers_data.map.with_index do |mfg_data, index|
  {
    id: manufacturers[index].id,
    name: mfg_data[:name],
    weight: mfg_data[:weight]
  }
end

# Calcular total de pesos dos manufacturers
manufacturer_total_weight = manufacturers_with_weights.sum { |m| m[:weight] }
puts "🏭 Total de pesos dos fornecedores: #{manufacturer_total_weight}"

pet_care = Category.create!(name: "Pet Care", external_id: "CAT001")
veterinary = Category.create!(name: "Veterinary", external_id: "CAT002")
farm_animals = Category.create!(name: "Farm Animals", external_id: "CAT003")

subcategories = [
  Subcategory.create!(name: "Antipulgas e Carrapatos", external_id: "SUB001", category_id: pet_care.id),
  Subcategory.create!(name: "Vermífugos", external_id: "SUB002", category_id: pet_care.id),
  Subcategory.create!(name: "Suplementos", external_id: "SUB003", category_id: pet_care.id),
  Subcategory.create!(name: "Vacinas", external_id: "SUB004", category_id: veterinary.id),
  Subcategory.create!(name: "Antibióticos", external_id: "SUB005", category_id: veterinary.id),
  Subcategory.create!(name: "Anti-inflamatórios", external_id: "SUB006", category_id: veterinary.id),
  Subcategory.create!(name: "Bovinos", external_id: "SUB007", category_id: farm_animals.id),
  Subcategory.create!(name: "Suínos", external_id: "SUB008", category_id: farm_animals.id)
]

puts "✅ #{manufacturers.count} fabricantes criados"
puts "✅ #{Category.count} categorias criadas"  
puts "✅ #{subcategories.count} subcategorias criadas"

# Arrays para geração rápida
products = [
  "Bravecto", "BRAVECTO", "bravecto", "Bravecto 20mg", "BRAVECTO 40mg",
  "Simparic", "SIMPARIC", "simparic", "Simparic 20mg", "SIMPARIC 40mg",
  "NexGard", "NEXGARD", "nexgard", "NexGard 28mg", "NEXGARD 68mg",
  "Frontline", "FRONTLINE", "frontline", "Frontline Plus",
  "Revolution", "REVOLUTION", "revolution", "Revolution Plus",
  "Endogard", "ENDOGARD", "endogard", "Endogard 10mg",
  "Drontal", "DRONTAL", "drontal", "Drontal Plus",
  "Canex", "CANEX", "canex", "Canex Plus",
  "Milbemax", "MILBEMAX", "milbemax"
].freeze

# Estados com pesos realistas baseados no mercado brasileiro
states_with_weights = [
  # Sudeste (maior mercado do Brasil)
  {state: "SP", region: "Sudeste", weight: 30}, # São Paulo - maior mercado
  {state: "MG", region: "Sudeste", weight: 15}, # Minas Gerais - segundo do Sudeste
  {state: "RJ", region: "Sudeste", weight: 12}, # Rio de Janeiro
  {state: "ES", region: "Sudeste", weight: 4},  # Espírito Santo
  
  # Sul (forte economia)
  {state: "RS", region: "Sul", weight: 10}, # Rio Grande do Sul
  {state: "PR", region: "Sul", weight: 8},  # Paraná
  {state: "SC", region: "Sul", weight: 6},  # Santa Catarina
  
  # Nordeste (mercado em crescimento)
  {state: "BA", region: "Nordeste", weight: 7}, # Bahia - maior do Nordeste
  {state: "PE", region: "Nordeste", weight: 5}, # Pernambuco
  {state: "CE", region: "Nordeste", weight: 4}, # Ceará
  {state: "PB", region: "Nordeste", weight: 2}, # Paraíba
  {state: "RN", region: "Nordeste", weight: 2}, # Rio Grande do Norte
  {state: "AL", region: "Nordeste", weight: 2}, # Alagoas
  
  # Centro-Oeste (agronegócio forte)
  {state: "GO", region: "Centro-Oeste", weight: 5}, # Goiás
  {state: "MT", region: "Centro-Oeste", weight: 4}, # Mato Grosso
  {state: "DF", region: "Centro-Oeste", weight: 3}, # Distrito Federal
  {state: "MS", region: "Centro-Oeste", weight: 3}, # Mato Grosso do Sul
  
  # Norte (mercado menor)
  {state: "PA", region: "Norte", weight: 3}, # Pará
  {state: "AM", region: "Norte", weight: 2}, # Amazonas
  {state: "TO", region: "Norte", weight: 2}, # Tocantins
  {state: "RO", region: "Norte", weight: 1}, # Rondônia
  {state: "AC", region: "Norte", weight: 1}  # Acre
].freeze

# Calcular total de pesos para seleção proporcional
total_weight = states_with_weights.sum { |s| s[:weight] }
puts "📊 Total de pesos dos estados: #{total_weight}"

store_types = ["Pet Shop", "Veterinária", "Clínica Veterinária", "Agropecuária", "Pet Center"].freeze
store_names = ["ABC", "XYZ", "Central", "Popular", "Premium", "Max", "Plus", "Super", "Top", "Elite"].freeze

# Pre-computar dados para performance
subcategory_data = subcategories.map { |s| { id: s.id, category_id: s.category_id } }.freeze

# Função para timestamp aleatório otimizada
def random_timestamp
  @start_timestamp ||= Date.new(2023, 1, 1).to_time.to_i
  @end_timestamp ||= Date.new(2025, 12, 31).to_time.to_i
  Time.at(rand(@start_timestamp..@end_timestamp))
end

# Função para selecionar estado baseado em pesos
def weighted_state_selection(states_with_weights, total_weight)
  random_number = rand(total_weight)
  cumulative_weight = 0
  
  states_with_weights.each do |state|
    cumulative_weight += state[:weight]
    return state if random_number < cumulative_weight
  end
  
  # Fallback (não deveria acontecer)
  states_with_weights.last
end

# Função para selecionar manufacturer baseado em pesos
def weighted_manufacturer_selection(manufacturers_with_weights, total_weight)
  random_number = rand(total_weight)
  cumulative_weight = 0
  
  manufacturers_with_weights.each do |manufacturer|
    cumulative_weight += manufacturer[:weight]
    return manufacturer if random_number < cumulative_weight
  end
  
  # Fallback (não deveria acontecer)
  manufacturers_with_weights.last
end

# Função para gerar lote de dados
def generate_cart_items_batch(batch_size, manufacturers_with_weights, manufacturer_total_weight, subcategory_data, products, states_with_weights, state_total_weight, store_types, store_names)
  items = []
  
  batch_size.times do
    # Usar seleção ponderada para estados
    location = weighted_state_selection(states_with_weights, state_total_weight)
    
    # Usar seleção ponderada para manufacturers
    manufacturer = weighted_manufacturer_selection(manufacturers_with_weights, manufacturer_total_weight)
    
    subcategory_info = subcategory_data.sample
    timestamp = random_timestamp
    
    items << {
      product_name: products.sample,
      barcode: "789#{rand(1000000000..9999999999)}",
      state: location[:state],
      region: location[:region],
      unit_price: rand(20.0..150.0).round(2),
      quantity: rand(1..8),
      store_cnpj: sprintf('%014d', rand(10000000000000..99999999999999)),
      store_name: "#{store_types.sample} #{store_names.sample}",
      category_id: subcategory_info[:category_id],
      subcategory_id: subcategory_info[:id],
      manufacturer_id: manufacturer[:id],
      created_at: timestamp,
      updated_at: timestamp
    }
  end
  
  items
end

# Gerar CartItems usando bulk insert
target_count = 2000000
batch_size = 100000
total_created = 0

puts "\n📦 Gerando #{target_count} CartItems usando bulk insert com distribuição ponderada..."

(target_count / batch_size).times do |batch_num|
  print "   Lote #{batch_num + 1}/#{target_count / batch_size}... "
  
  # Gerar dados com distribuição ponderada
  items = generate_cart_items_batch(batch_size, manufacturers_with_weights, manufacturer_total_weight, subcategory_data, products, states_with_weights, total_weight, store_types, store_names)
  
  # Inserção em lote - otimizada para MongoDB
  result = CartItem.collection.insert_many(items)
  total_created += result.inserted_count
  
  puts "✅ #{result.inserted_count} inseridos"
end

total_time = Time.now - start_time
records_per_second = (total_created / total_time).round(0)

puts "\n🎉 Seed concluído com sucesso!"
puts "📊 Estatísticas:"
puts "- CartItems criados: #{total_created}"
puts "- Tempo total: #{total_time.round(2)}s"
puts "- Velocidade: #{records_per_second} registros/s"
puts "- Fabricantes: #{Manufacturer.count}"
puts "- Categorias: #{Category.count}"
puts "- Subcategorias: #{Subcategory.count}"

# Mostrar distribuição real por estado (top 10)
puts "\n📈 Distribuição por Estado (Top 10):"
state_distribution = CartItem.collection.aggregate([
  { "$group" => { "_id" => "$state", "count" => { "$sum" => 1 } } },
  { "$sort" => { "count" => -1 } },
  { "$limit" => 10 }
]).to_a

state_distribution.each_with_index do |state, index|
  percentage = ((state["count"].to_f / total_created) * 100).round(1)
  puts "   #{index + 1}. #{state["_id"]}: #{state["count"].to_s.rjust(8)} items (#{percentage}%)"
end

# Mostrar distribuição por região
puts "\n🗺️  Distribuição por Região:"
region_distribution = CartItem.collection.aggregate([
  { "$group" => { "_id" => "$region", "count" => { "$sum" => 1 } } },
  { "$sort" => { "count" => -1 } }
]).to_a

region_distribution.each do |region|
  percentage = ((region["count"].to_f / total_created) * 100).round(1)
  puts "   #{region["_id"]}: #{region["count"].to_s.rjust(8)} items (#{percentage}%)"
end

# Mostrar distribuição por manufacturer
puts "\n🏭 Distribuição por Fornecedor:"
manufacturer_distribution = CartItem.collection.aggregate([
  {
    "$lookup" => {
      "from" => "manufacturers",
      "localField" => "manufacturer_id",
      "foreignField" => "_id",
      "as" => "manufacturer"
    }
  },
  { "$unwind" => "$manufacturer" },
  { "$group" => { "_id" => "$manufacturer.name", "count" => { "$sum" => 1 } } },
  { "$sort" => { "count" => -1 } }
]).to_a

manufacturer_distribution.each_with_index do |mfg, index|
  percentage = ((mfg["count"].to_f / total_created) * 100).round(1)
  puts "   #{index + 1}. #{mfg["_id"]}: #{mfg["count"].to_s.rjust(8)} items (#{percentage}%)"
end

puts "\n📅 Distribuição por ano:"
(2023..2025).each do |year|
  count = CartItem.where(:created_at.gte => Date.new(year, 1, 1), 
                        :created_at.lt => Date.new(year + 1, 1, 1)).count
  puts "- #{year}: #{count} registros"
end

puts "\n🏆 Top 5 produtos:"
top_products = CartItem.collection.aggregate([
  {"$group" => {"_id" => "$product_name", "count" => {"$sum" => 1}}},
  {"$sort" => {"count" => -1}},
  {"$limit" => 5}
])

top_products.each_with_index do |product, index|
  puts "   #{index + 1}. #{product['_id']}: #{product['count']} items"
end

puts "\n✨ Use 'rails db:seed' para executar este seed" 