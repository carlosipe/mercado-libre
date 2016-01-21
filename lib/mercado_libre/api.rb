module MercadoLibre
  require 'requests'
  require "requests/sugar"
  class API
    attr_accessor :access_token

    def initialize(params)
      @app_key    = params.fetch(:app_key)
      @app_secret = params.fetch(:app_secret)
      @host       = params.fetch(:host) { ENV.fetch('MERCADOLIBRE_API_HOST') }
    end

    def publish_item(item)
      url = "/items"
      response = authenticated_request(:post, url, item.publishable_hash.to_json)
      
      Item.new(response)
    end

    def update_item(item_id, params)
      url = "/items/#{item_id}"
      response = authenticated_request(:put, url, params.to_json)

      Item.new(response)
    end

    def close_item(item_id)
      url = "/items/#{item_id}"
      authenticated_request(:put, url, {status: :closed}.to_json)
    end
    
    def relist_item(item_id, params)
      url = "/items/#{item_id}/relist"
      payload = {
        price: params.fetch(:price),
        quantity: params.fetch(:quantity),
        listing_type_id: params.fetch(:listing_type_id)
      }
      response = authenticated_request(:post, url, payload.to_json)

      Item.new response
    end

    def get_item(item_id)
      url = "/items/#{item_id}"
      response = authenticated_request(:get, url)

      Item.new(response)
    end

    def authenticated_request(verb, url, data = {})
      url_with_token = "#{url}?access_token=#{access_token}"
      begin
        request(verb, url_with_token, data)
      rescue Requests::Error
        @retries ||=0
        @retries +=1
        if $!.message.strip == 'Forbidden'
          @access_token = nil
          authenticated_request(verb, url, data) if @retries < 10
        else
          raise $!
        end
      end
    end

    def request(verb, url, data)
      url = "#{@host}#{url}"
      verb = verb.to_s.upcase
      begin
        response = Requests.request(verb, url, data: data)
      rescue StandardError => e
        new_message = [e.message.strip,e.response.body].join("\n")
        raise $!, new_message, $!.backtrace
      end
      JSON.parse(response.body)
    end

    def access_token
      @access_token ||= request_access_token
    end

    def request_access_token
      url = "/oauth/token"
      data = {
        client_id:      @app_key,
        client_secret:  @app_secret,
        grant_type:     'client_credentials'
      }

      request(:post, url, data).fetch('access_token')
    end
  end
end