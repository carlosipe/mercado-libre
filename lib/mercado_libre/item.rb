module MercadoLibre
  class Item
    def self.publishable_params
      [:site_id, :title, :category_id, :price, :currency_id, :available_quantity,
       :buying_mode, :listing_type_id, :condition, :description, :video_id, :warranty,
       :pictures, :shipping]
    end

    def self.attr_list
      other_fields = [:id, :start_time, :stop_time, :end_time, :permalink, :thumbnail, 
      :secure_thumbnail, :descriptions, :accepts_mercadopago, :status, :date_created,
      :last_updated, :non_mercado_pago_payment_methods ]
      
      self.publishable_params + other_fields
    end

    attr_accessor *attr_list

    def initialize(params = {})
      params = Hash[params.map { |k, v| [k.to_sym, v] }] #Symbolize keys
      self.class.attr_list.each do |k|
        send("#{k}=", params[k]) if params[k]
      end
    end

    def publishable_hash
      hash = {}
      self.class.publishable_params.each { |k| hash[k] = send(k) }

      hash
    end
  end
end