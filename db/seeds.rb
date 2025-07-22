# db/seeds.rb

puts "🌱 Iniciando seed do banco de dados..."

# Em desenvolvimento, podemos manter os dados existentes
# Os find_or_create_by evitam duplicatas automaticamente
puts "🔄 Usando find_or_create_by para evitar duplicatas..."

# Criar Fabricantes
puts "🏭 Criando fabricantes..."
bayer = Manufacturer.find_or_create_by(external_id: "MFG001") do |m|
  m.name = "Bayer"
end

zoetis = Manufacturer.find_or_create_by(external_id: "MFG002") do |m|
  m.name = "Zoetis"
end

virbac = Manufacturer.find_or_create_by(external_id: "MFG003") do |m|
  m.name = "Virbac"
end

puts "✅ #{Manufacturer.count} fabricantes criados"

# Criar Categorias
puts "📂 Criando categorias..."
pet_care = Category.find_or_create_by(external_id: "CAT001") do |c|
  c.name = "Pet Care"
end

veterinary = Category.find_or_create_by(external_id: "CAT002") do |c|
  c.name = "Veterinary"
end

puts "✅ #{Category.count} categorias criadas"

# Criar Subcategorias
puts "📁 Criando subcategorias..."
flea_tick = Subcategory.find_or_create_by(external_id: "SUB001") do |s|
  s.name = "Antipulgas e Carrapatos"
  s.category = pet_care
end

vaccines = Subcategory.find_or_create_by(external_id: "SUB002") do |s|
  s.name = "Vacinas"
  s.category = veterinary
end

worming = Subcategory.find_or_create_by(external_id: "SUB003") do |s|
  s.name = "Vermífugos"
  s.category = pet_care
end

puts "✅ #{Subcategory.count} subcategorias criadas"

# Criar CartItems de exemplo
puts "🛒 Criando cart items..."

# Buscar objetos recém-criados para usar nos CartItems
puts "🔍 Buscando objetos para relacionamentos..."
pet_care_obj = Category.find_by(external_id: "CAT001")
flea_tick_obj = Subcategory.find_by(external_id: "SUB001")
worming_obj = Subcategory.find_by(external_id: "SUB003")
bayer_obj = Manufacturer.find_by(external_id: "MFG001")
zoetis_obj = Manufacturer.find_by(external_id: "MFG002")
virbac_obj = Manufacturer.find_by(external_id: "MFG003")

# Criar CartItems usando find_or_create_by para evitar duplicatas
# Usamos uma combinação de barcode + store_cnpj para identificar únicos

puts "📦 Criando CartItems..."

CartItem.find_or_create_by(
  barcode: "7891234567890", 
  store_cnpj: "12.345.678/0001-90"
) do |item|
  item.product_name = "Bravecto 20mg"
  item.state = "SP"
  item.region = "Sudeste"
  item.unit_price = 89.90
  item.quantity = 2
  item.store_name = "Pet Shop ABC"
  item.category = pet_care_obj
  item.subcategory = flea_tick_obj
  item.manufacturer = bayer_obj
end

CartItem.find_or_create_by(
  barcode: "7891234567891", 
  store_cnpj: "98.765.432/0001-10"
) do |item|
  item.product_name = "BRAVECTO 20mg"
  item.state = "RJ"
  item.region = "Sudeste"
  item.unit_price = 92.50
  item.quantity = 1
  item.store_name = "Veterinária XYZ"
  item.category = pet_care_obj
  item.subcategory = flea_tick_obj
  item.manufacturer = bayer_obj
end

CartItem.find_or_create_by(
  barcode: "7891234567892", 
  store_cnpj: "11223344556677"
) do |item|
  item.product_name = "bravecto Braveco BRAVECTO"
  item.state = "MG"
  item.region = "Sudeste"
  item.unit_price = 85.00
  item.quantity = 3
  item.store_name = "Loja de Animais 123"
  item.category = pet_care_obj
  item.subcategory = flea_tick_obj
  item.manufacturer = bayer_obj
end

CartItem.find_or_create_by(
  barcode: "7891234567893", 
  store_cnpj: "22.333.444/0001-55"
) do |item|
  item.product_name = "Simparic 20mg"
  item.state = "RS"
  item.region = "Sul"
  item.unit_price = 76.90
  item.quantity = 1
  item.store_name = "Pet Center Sul"
  item.category = pet_care_obj
  item.subcategory = flea_tick_obj
  item.manufacturer = zoetis_obj
end

CartItem.find_or_create_by(
  barcode: "7891234567894", 
  store_cnpj: "33.444.555/0001-66"
) do |item|
  item.product_name = "Endogard 10mg"
  item.state = "BA"
  item.region = "Nordeste"
  item.unit_price = 45.80
  item.quantity = 4
  item.store_name = "Agropecuária Nordeste"
  item.category = pet_care_obj
  item.subcategory = worming_obj
  item.manufacturer = virbac_obj
end

puts "✅ #{CartItem.count} cart items criados"

# Exibir estatísticas
puts "\n📊 Estatísticas do banco:"
puts "- Fabricantes: #{Manufacturer.count}"
puts "- Categorias: #{Category.count}"
puts "- Subcategorias: #{Subcategory.count}"
puts "- Cart Items: #{CartItem.count}"

puts "\n🎯 Exemplos de consultas:"
puts "- Items por estado SP: #{CartItem.by_state('SP').count}"
puts "- Items por região Sudeste: #{CartItem.by_region('Sudeste').count}"
puts "- Items da categoria Pet Care: #{CartItem.by_category(pet_care_obj.id).count}"

# Testar busca de texto
puts "\n🔍 Teste de busca de texto por 'Bravecto':"
bravecto_items = CartItem.where(product_name: /bravecto/i)
puts "- Encontrados #{bravecto_items.count} items com 'bravecto' no nome"
bravecto_items.each do |item|
  puts "  • #{item.product_name} - #{item.store_name} - R$ #{item.unit_price}"
end

puts "\n🌱 Seed concluído com sucesso!" 