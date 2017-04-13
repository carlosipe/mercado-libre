module MercadoLibre
  require 'requests'
  require "requests/sugar"
  class API
    attr_accessor :access_token

    def initialize(params)
      @app_key      = params.fetch(:app_key)
      @app_secret   = params.fetch(:app_secret)
      @host         = params.fetch(:host) { ENV.fetch('MERCADOLIBRE_API_HOST') }
      @retries_num  = Integer( params.fetch(:retries) { ENV.fetch('MERCADOLIBRE_HTTP_RETRIES') { 10 } } )
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
      request(verb, url, data, authenticated: true)
    end

    def request(verb, url, data, authenticated: false)
      full_url = "#{@host}#{url}"
      full_url = url_with_token(full_url) if authenticated
      verb = verb.to_s.upcase
      tries ||= @retries_num
      response = Requests.request(verb, full_url, data: data)

      JSON.parse(response.body)

    rescue *HTTPErrors
      retry unless (tries -=1).zero?
      raise
    rescue Requests::Error
      @access_token = nil if $!.message.strip == 'Forbidden' # Release access token
      retry unless (tries -=1).zero?
      raise $!, [$!.message.strip,$!.response.body].join("\n"), $!.backtrace #Verbose errors
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

    def url_with_token(url)
      "#{url}#{url.include?('?') ? '&' : '?'}access_token=#{access_token}"
    end
  end
end

module MercadoLibre
  HTTPErrors = [Timeout::Error, Errno::ETIMEDOUT, Errno::EINVAL, Errno::ECONNRESET,
    Errno::ECONNREFUSED, EOFError, Net::HTTPBadResponse,
    Net::HTTPHeaderSyntaxError, Net::ProtocolError]
end