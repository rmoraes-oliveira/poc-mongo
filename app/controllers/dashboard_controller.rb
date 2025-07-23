class DashboardController < ApplicationController
  # Cache simples em memória para melhorar performance
  @@cache_ttl = 5.minutes
  @@cache_store = {}
  def index
    @manufacturer_id = params[:manufacturer_id]
    
    # Filtro por manufacturer se especificado
    base_query = @manufacturer_id ? { manufacturer_id: BSON::ObjectId(@manufacturer_id) } : {}
    
    @total_items = CartItem.where(base_query).count
    @total_manufacturers = Manufacturer.count
    @total_categories = Category.count
    
    # Se há um manufacturer selecionado, buscar informações dele
    if @manufacturer_id
      @selected_manufacturer = Manufacturer.find(@manufacturer_id)
      @manufacturer_name = @selected_manufacturer.name
    end
    
    # Buscar datas usando aggregation do MongoDB
    date_pipeline = [
      (@manufacturer_id ? { "$match" => base_query } : nil),
      {
        "$group" => {
          "_id" => nil,
          "min_date" => { "$min" => "$created_at" },
          "max_date" => { "$max" => "$created_at" }
        }
      }
    ].compact
    
    date_stats = CartItem.collection.aggregate(date_pipeline).first
    
    @date_range = {
      start: date_stats ? date_stats["min_date"].strftime("%Y-%m-%d") : Date.current.strftime("%Y-%m-%d"),
      end: date_stats ? date_stats["max_date"].strftime("%Y-%m-%d") : Date.current.strftime("%Y-%m-%d")
    }
    
    # Lista de todos os manufacturers para o dropdown
    @all_manufacturers = Manufacturer.all.limit(20)
  end

  # Endpoint para dados de vendas por região
  def regional_sales
    manufacturer_id = params[:manufacturer_id]
    
    # Usar cache para melhorar performance
    cache_key = "regional_sales_#{manufacturer_id || 'all'}"
    regional_data = get_cached_data(cache_key) do
      calculate_regional_sales(manufacturer_id)
    end
    
    render json: {
      regional_sales: regional_data,
      total_items: regional_data.values.sum { |r| r[:total] }
    }
  end

  # Endpoint para dados de vendas por estado de uma região
  def state_sales
    region = params[:region]
    manufacturer_id = params[:manufacturer_id]
    
    if region.blank?
      render json: { error: 'Region is required' }, status: 400
      return
    end
    
    # Usar cache para melhorar performance
    cache_key = "state_sales_#{region}_#{manufacturer_id || 'all'}"
    state_data = get_cached_data(cache_key) do
      calculate_state_sales(region, manufacturer_id)
    end
    
    render json: {
      region: region,
      state_sales: state_data,
      total_items: state_data.values.sum { |s| s[:total] }
    }
  end

  # Endpoint para dados de sazonalidade de um estado
  def state_seasonality
    state = params[:state]
    manufacturer_id = params[:manufacturer_id]
    
    if state.blank?
      render json: { error: 'State is required' }, status: 400
      return
    end
    
    # Usar cache para melhorar performance
    cache_key = "state_seasonality_#{state}_#{manufacturer_id || 'all'}"
    seasonality_data = get_cached_data(cache_key) do
      calculate_state_seasonality(state, manufacturer_id)
    end
    
    render json: {
      state: state,
      seasonality: seasonality_data
    }
  end

  # Endpoint para dados de sazonalidade de uma região (todos os estados)
  def regional_seasonality
    region = params[:region]
    manufacturer_id = params[:manufacturer_id]
    
    if region.blank?
      render json: { error: 'Region is required' }, status: 400
      return
    end
    
    # Usar cache para melhorar performance
    cache_key = "regional_seasonality_#{region}_#{manufacturer_id || 'all'}"
    seasonality_data = get_cached_data(cache_key) do
      calculate_regional_seasonality(region, manufacturer_id)
    end
    
    render json: {
      region: region,
      seasonality: seasonality_data
    }
  end

  # Endpoint para comparação de produtos por categoria
  def category_comparison
    manufacturer_id = params[:manufacturer_id]
    
    if manufacturer_id.blank?
      render json: { error: 'Manufacturer ID is required' }, status: 400
      return
    end
    
    # Usar cache para melhorar performance
    cache_key = "category_comparison_#{manufacturer_id}"
    comparison_data = get_cached_data(cache_key) do
      calculate_category_comparison(manufacturer_id)
    end
    
    render json: {
      category_comparison: comparison_data
    }
  end

  private

  # Método para cache simples em memória
  def get_cached_data(cache_key)
    now = Time.current
    
    # Verificar se existe cache válido
    if @@cache_store[cache_key] && 
       @@cache_store[cache_key][:expires_at] > now
      
      puts "🚀 Cache HIT para #{cache_key}"
      return @@cache_store[cache_key][:data]
    end
    
    # Cache miss - calcular dados
    puts "💾 Cache MISS para #{cache_key} - calculando..."
    start_time = Time.current
    
    data = yield
    
    duration = ((Time.current - start_time) * 1000).round(2)
    puts "⏱️  Cálculo concluído em #{duration}ms"
    
    # Armazenar no cache
    @@cache_store[cache_key] = {
      data: data,
      expires_at: now + @@cache_ttl
    }
    
    # Limpar cache antigo (simples garbage collection)
    @@cache_store.delete_if { |_, v| v[:expires_at] <= now }
    
    data
  end

  def calculate_state_sales(region, manufacturer_id)
    # Pipeline base
    pipeline = []
    
    # Filtro por região
    match_criteria = { "region" => region }
    
    # Filtro por manufacturer se especificado
    if manufacturer_id.present?
      match_criteria["manufacturer_id"] = BSON::ObjectId(manufacturer_id)
    end
    
    pipeline << { "$match" => match_criteria }
    
    # Agregação por estado
    pipeline += [
      {
        "$group" => {
          "_id" => "$state",
          "total" => { "$sum" => 1 },
          "total_value" => { "$sum" => { "$multiply" => ["$unit_price", "$quantity"] } },
          "avg_price" => { "$avg" => "$unit_price" }
        }
      },
      { "$sort" => { "total" => -1 } }
    ]

    results = CartItem.collection.aggregate(pipeline).to_a
    
    # Calcular percentuais
    total_items = results.sum { |r| r["total"] }
    
    state_data = {}
    results.each do |item|
      state = item["_id"]
      state_data[state] = {
        total: item["total"],
        percentage: total_items > 0 ? ((item["total"].to_f / total_items) * 100).round(1) : 0,
        total_value: item["total_value"].to_f.round(2),
        avg_price: item["avg_price"].to_f.round(2)
      }
    end

    state_data
  end

  def calculate_state_seasonality(state, manufacturer_id)
    # Pipeline base
    pipeline = []
    
    # Filtro por estado
    match_criteria = { "state" => state }
    
    # Filtro por manufacturer se especificado
    if manufacturer_id.present?
      match_criteria["manufacturer_id"] = BSON::ObjectId(manufacturer_id)
    end
    
    pipeline << { "$match" => match_criteria }
    
    # Agregação por mês
    pipeline += [
      {
        "$group" => {
          "_id" => {
            "month" => { "$month" => "$created_at" },
            "year" => { "$year" => "$created_at" }
          },
          "total" => { "$sum" => 1 },
          "total_value" => { "$sum" => { "$multiply" => ["$unit_price", "$quantity"] } },
          "avg_price" => { "$avg" => "$unit_price" }
        }
      },
      { "$sort" => { "_id.year" => 1, "_id.month" => 1 } }
    ]

    results = CartItem.collection.aggregate(pipeline).to_a
    
    # Agrupar por mês (consolidando anos)
    monthly_data = {}
    
    results.each do |item|
      month = item["_id"]["month"]
      monthly_data[month] ||= { total: 0, total_value: 0.0, avg_prices: [] }
      monthly_data[month][:total] += item["total"]
      monthly_data[month][:total_value] += item["total_value"].to_f
      monthly_data[month][:avg_prices] << item["avg_price"].to_f
    end
    
    # Definir celebrações e fatores sazonais
    seasonal_factors = {
      1 => { factor: 1.2, celebration: "Verão, Férias de Janeiro" },
      2 => { factor: 1.1, celebration: "Carnaval, Verão" },
      3 => { factor: 0.9, celebration: "Volta às Aulas, Outono" },
      4 => { factor: 1.0, celebration: "Páscoa, Outono" },
      5 => { factor: 1.1, celebration: "Dia das Mães, Clima Ameno" },
      6 => { factor: 0.8, celebration: "Festa Junina, Inverno" },
      7 => { factor: 0.9, celebration: "Férias Escolares, Inverno" },
      8 => { factor: 0.8, celebration: "Dia dos Pais, Inverno" },
      9 => { factor: 1.0, celebration: "Primavera, Volta Atividades" },
      10 => { factor: 1.2, celebration: "Dia das Crianças, Primavera" },
      11 => { factor: 1.3, celebration: "Black Friday, Pré-Verão" },
      12 => { factor: 1.4, celebration: "Natal, Férias, Verão" }
    }
    
    # Calcular médias e aplicar fatores sazonais
    total_items = monthly_data.values.sum { |data| data[:total] }
    
    seasonality_data = {}
    
    (1..12).each do |month|
      month_data = monthly_data[month] || { total: 0, total_value: 0.0, avg_prices: [] }
      seasonal_info = seasonal_factors[month]
      
      avg_price = month_data[:avg_prices].any? ? 
                  (month_data[:avg_prices].sum / month_data[:avg_prices].size) : 0
      
      # Aplicar fator sazonal
      adjusted_total = (month_data[:total] * seasonal_info[:factor]).round
      
      seasonality_data[month] = {
        month_name: Date::MONTHNAMES[month],
        month_abbr: Date::ABBR_MONTHNAMES[month],
        raw_total: month_data[:total],
        adjusted_total: adjusted_total,
        total_value: month_data[:total_value].round(2),
        avg_price: avg_price.round(2),
        seasonal_factor: seasonal_info[:factor],
        celebration: seasonal_info[:celebration],
        percentage: total_items > 0 ? ((month_data[:total].to_f / total_items) * 100).round(1) : 0
      }
    end

    seasonality_data
  end

  def calculate_regional_seasonality(region, manufacturer_id)
    # Mapeamento de regiões para estados
    region_states = {
      'Norte' => ['AC', 'AP', 'AM', 'PA', 'RO', 'RR', 'TO'],
      'Nordeste' => ['AL', 'BA', 'CE', 'MA', 'PB', 'PE', 'PI', 'RN', 'SE'],
      'Centro-Oeste' => ['DF', 'GO', 'MT', 'MS'],
      'Sudeste' => ['ES', 'MG', 'RJ', 'SP'],
      'Sul' => ['PR', 'RS', 'SC']
    }
    
    states_list = region_states[region] || []
    
    if states_list.empty?
      return {}
    end
    
    # Pipeline base
    pipeline = []
    
    # Filtro por região (estados)
    match_criteria = { "state" => { "$in" => states_list } }
    
    # Filtro por manufacturer se especificado
    if manufacturer_id.present?
      match_criteria["manufacturer_id"] = BSON::ObjectId(manufacturer_id)
    end
    
    pipeline << { "$match" => match_criteria }
    
    # Agregação por mês e estado
    pipeline += [
      {
        "$group" => {
          "_id" => {
            "month" => { "$month" => "$created_at" },
            "year" => { "$year" => "$created_at" },
            "state" => "$state"
          },
          "total" => { "$sum" => 1 },
          "total_value" => { "$sum" => { "$multiply" => ["$unit_price", "$quantity"] } },
          "avg_price" => { "$avg" => "$unit_price" }
        }
      },
      { "$sort" => { "_id.year" => 1, "_id.month" => 1, "_id.state" => 1 } }
    ]

    results = CartItem.collection.aggregate(pipeline).to_a
    
    # Organizar dados por mês e estado
    monthly_data = {}
    
    results.each do |item|
      month = item["_id"]["month"]
      state = item["_id"]["state"]
      
      monthly_data[month] ||= {}
      monthly_data[month][state] ||= { total: 0, total_value: 0.0, avg_prices: [] }
      monthly_data[month][state][:total] += item["total"]
      monthly_data[month][state][:total_value] += item["total_value"].to_f
      monthly_data[month][state][:avg_prices] << item["avg_price"].to_f
    end
    
    # Definir celebrações
    celebrations = {
      1 => "Verão, Férias de Janeiro",
      2 => "Carnaval, Verão",
      3 => "Volta às Aulas, Outono",
      4 => "Páscoa, Outono",
      5 => "Dia das Mães, Clima Ameno",
      6 => "Festa Junina, Inverno",
      7 => "Férias Escolares, Inverno",
      8 => "Dia dos Pais, Inverno",
      9 => "Primavera, Volta Atividades",
      10 => "Dia das Crianças, Primavera",
      11 => "Black Friday, Pré-Verão",
      12 => "Natal, Férias, Verão"
    }
    
    # Processar dados finais
    seasonality_data = {}
    
    (1..12).each do |month|
      month_states = monthly_data[month] || {}
      
      # Calcular totais do mês
      month_total = month_states.values.sum { |data| data[:total] }
      month_value = month_states.values.sum { |data| data[:total_value] }
      
      seasonality_data[month] = {
        month_name: Date::MONTHNAMES[month],
        month_abbr: Date::ABBR_MONTHNAMES[month],
        celebration: celebrations[month],
        total: month_total,
        total_value: month_value.round(2),
        states: {}
      }
      
      # Adicionar dados de cada estado
      states_list.each do |state|
        state_data = month_states[state] || { total: 0, total_value: 0.0, avg_prices: [] }
        avg_price = state_data[:avg_prices].any? ? 
                    (state_data[:avg_prices].sum / state_data[:avg_prices].size) : 0
        
        seasonality_data[month][:states][state] = {
          total: state_data[:total],
          total_value: state_data[:total_value].round(2),
          avg_price: avg_price.round(2)
        }
      end
    end

    seasonality_data
  end

  def calculate_regional_sales(manufacturer_id)
    # Pipeline base
    pipeline = []
    
    # Filtro por manufacturer se especificado
    if manufacturer_id.present?
      pipeline << { "$match" => { "manufacturer_id" => BSON::ObjectId(manufacturer_id) } }
    end
    
    # Agregação por região
    pipeline += [
      {
        "$group" => {
          "_id" => "$region",
          "total" => { "$sum" => 1 },
          "total_value" => { "$sum" => { "$multiply" => ["$unit_price", "$quantity"] } },
          "avg_price" => { "$avg" => "$unit_price" }
        }
      },
      { "$sort" => { "total" => -1 } }
    ]

    results = CartItem.collection.aggregate(pipeline).to_a
    
    # Calcular percentuais
    total_items = results.sum { |r| r["total"] }
    
    regional_data = {}
    results.each do |item|
      region = item["_id"]
      regional_data[region] = {
        total: item["total"],
        percentage: total_items > 0 ? ((item["total"].to_f / total_items) * 100).round(1) : 0,
        total_value: item["total_value"].to_f.round(2),
        avg_price: item["avg_price"].to_f.round(2)
      }
    end

    regional_data
  end

  def calculate_category_comparison(manufacturer_id)
    # Cache de manufacturers e categories para evitar lookups
    @manufacturers_cache ||= Manufacturer.all.index_by(&:id)
    @categories_cache ||= Category.all.index_by(&:id)
    
    manufacturer = @manufacturers_cache[BSON::ObjectId(manufacturer_id)]
    return [] unless manufacturer
    
    # Buscar categorias do manufacturer (simples e rápido)
    my_categories = CartItem.where(manufacturer_id: BSON::ObjectId(manufacturer_id))
                           .distinct(:category_id)
                           .first(10) # Limitar para performance
    
    comparison_data = []
    
    my_categories.each do |category_id|
      category = @categories_cache[category_id]
      next unless category
      
      # Agregação simplificada - apenas na categoria específica
      pipeline = [
        { "$match" => { "category_id" => category_id } },
        {
          "$group" => {
            "_id" => "$manufacturer_id",
            "total_items" => { "$sum" => 1 },
            "total_value" => { "$sum" => { "$multiply" => ["$unit_price", "$quantity"] } },
            "avg_price" => { "$avg" => "$unit_price" }
          }
        },
        { "$sort" => { "total_items" => -1 } },
        { "$limit" => 10 }
      ]
      
      results = CartItem.collection.aggregate(pipeline).to_a
      
      # Calcular totais
      total_category_items = results.sum { |r| r["total_items"] }
      
      # Mapear resultados
      manufacturers_data = results.map do |item|
        mfg_id = item["_id"]
        mfg = @manufacturers_cache[mfg_id]
        mfg_name = mfg ? mfg.name : "Unknown"
        
        {
          name: mfg_name,
          total_items: item["total_items"],
          market_share: total_category_items > 0 ? ((item["total_items"].to_f / total_category_items) * 100).round(1) : 0,
          total_value: item["total_value"].to_f.round(2),
          avg_price: item["avg_price"].to_f.round(2),
          is_selected: mfg_name == manufacturer.name
        }
      end
      
      comparison_data << {
        category_name: category.name,
        category_id: category_id.to_s,
        manufacturers: manufacturers_data,
        total_category_items: total_category_items
      }
    end
    
    comparison_data
  end
end 