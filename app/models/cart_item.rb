class CartItem
  include Mongoid::Document
  include Mongoid::Timestamps

  # Descrição do produto
  field :product_name, type: String
  
  # Código de barras do produto
  field :barcode, type: String
  
  # Localização
  field :state, type: String
  field :region, type: String
  
  # Preço e quantidade
  field :unit_price, type: BigDecimal
  field :quantity, type: Integer
  
  # Informações da loja
  field :store_cnpj, type: String  # Indicador principal de loja
  field :store_name, type: String
  
  # Relacionamentos
  belongs_to :category
  belongs_to :subcategory
  belongs_to :manufacturer
  
  # Validações
  validates :product_name, presence: true
  validates :barcode, presence: true
  validates :state, presence: true
  validates :region, presence: true
  validates :unit_price, presence: true, numericality: { greater_than: 0 }
  validates :quantity, presence: true, numericality: { greater_than: 0, only_integer: true }
  validates :store_cnpj, presence: true, format: { 
    with: /\A(\d{2}\.\d{3}\.\d{3}\/\d{4}-\d{2}|\d{14})\z/, 
    message: "deve estar no formato XX.XXX.XXX/XXXX-XX ou 14 dígitos"
  }
  validates :store_name, presence: true
  validates :category, presence: true
  validates :subcategory, presence: true
  validates :manufacturer, presence: true
  
  # Validação personalizada para garantir que subcategoria pertence à categoria
  validate :subcategory_belongs_to_category
  
  # Índices para otimização de consultas
  index({ product_name: 1 })
  index({ barcode: 1 })
  index({ store_cnpj: 1 })
  index({ state: 1, region: 1 })
  index({ category_id: 1 })
  index({ subcategory_id: 1 })
  index({ manufacturer_id: 1 })
  index({ created_at: -1 })  # Para consultas por timestamp
  index({ 
    product_name: "text", 
    store_name: "text" 
  }, { 
    name: "text_search_index" 
  })  # Índice de texto para busca

  # Scopes úteis
  scope :by_state, ->(state) { where(state: state) }
  scope :by_region, ->(region) { where(region: region) }
  scope :by_store, ->(cnpj) { where(store_cnpj: cnpj) }
  scope :by_category, ->(category_id) { where(category_id: category_id) }
  scope :recent, -> { order_by(created_at: :desc) }
  scope :price_range, ->(min, max) { where(unit_price: min..max) }

  # Método para busca de texto
  def self.search_text(query)
    where("$text" => { "$search" => query })
  end

  # Método para calcular valor total do item
  def total_value
    unit_price * quantity
  end

  # Método para normalizar CNPJ (remover formatação)
  def normalized_cnpj
    store_cnpj.gsub(/\D/, '') if store_cnpj
  end

  # Método para formatar CNPJ
  def formatted_cnpj
    return store_cnpj unless store_cnpj&.match?(/^\d{14}$/)
    
    cnpj = store_cnpj
    "#{cnpj[0..1]}.#{cnpj[2..4]}.#{cnpj[5..7]}/#{cnpj[8..11]}-#{cnpj[12..13]}"
  end

  private

  def subcategory_belongs_to_category
    return unless subcategory && category
    
    unless subcategory.category_id == category.id
      errors.add(:subcategory, "deve pertencer à categoria selecionada")
    end
  end
end 