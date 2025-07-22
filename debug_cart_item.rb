#!/usr/bin/env ruby
# Debug script para CartItem

puts "=== Debug CartItem ==="

puts "1. Carregando Rails..."
require_relative 'config/environment'

puts "2. Verificando modelos existentes..."
puts "Categories: #{Category.count}"
puts "Subcategories: #{Subcategory.count}"  
puts "Manufacturers: #{Manufacturer.count}"

puts "3. Buscando objetos..."
cat = Category.first
subcat = cat.subcategories.first
mfg = Manufacturer.first

puts "Category: #{cat.name} (#{cat.id})"
puts "Subcategory: #{subcat.name} (#{subcat.id}) - belongs to: #{subcat.category.name}"
puts "Manufacturer: #{mfg.name} (#{mfg.id})"

puts "4. Criando CartItem..."
item = CartItem.new(
  product_name: "Test Product",
  barcode: "1234567890123",
  state: "SP",
  region: "Sudeste",
  unit_price: 50.0,
  quantity: 1,
  store_cnpj: "12345678901234",
  store_name: "Test Store",
  category: cat,
  subcategory: subcat,
  manufacturer: mfg
)

puts "5. Validando..."
puts "Valid? #{item.valid?}"

if !item.valid?
  puts "Errors:"
  item.errors.full_messages.each do |error|
    puts "  - #{error}"
  end
  
  puts "\nErrors details:"
  item.errors.details.each do |field, details|
    puts "  #{field}: #{details}"
  end
end

puts "6. Tentando salvar..."
begin
  item.save!
  puts "✅ Salvou com sucesso! ID: #{item.id}"
rescue => e
  puts "❌ Erro ao salvar: #{e.message}"
  puts "Backtrace:"
  puts e.backtrace.first(5)
end

puts "=== Fim Debug ===" 