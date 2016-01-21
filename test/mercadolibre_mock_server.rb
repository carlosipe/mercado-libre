require 'mock_server'
class MercadoLibreMock
  include MockServer::Methods
  PRODUCTS = {}
  
  def run
    mock_server {
      post "/oauth/token" do
        if !params['grant_type']
          status 400
          content_type :json
          '{"message":"grant_type is a required parameter","error":"invalid_request","status":400,"cause":[]}'
        else
          content_type :json
          { access_token: 'APP12343' }.to_json
        end
      end

      post '/items' do
        halt 403 unless params[:access_token] == 'APP12343'
        data = JSON.parse(request.body.read)
        data['id'] = 'MLA1234'
        data['title'] = data['title'].split.map(&:capitalize)*' '
        data['permalink'] = 'http://mercadolibre.com/MLA/item/MLA1234'
        PRODUCTS["MLA1234"] = data

        content_type :json
        PRODUCTS.fetch('MLA1234').to_json
      end

      get '/items/:id' do |id|
        content_type :json
        PRODUCTS.fetch(id).to_json { raise Sinatra::NotFound }
      end

      put '/items/:id' do |id|
        halt 403 unless params[:access_token] == 'APP12343'
        product = PRODUCTS.fetch(id) { raise Sinatra::NotFound }
        data = JSON.parse(request.body.read)
        PRODUCTS[id] = product.merge(data) 
        PRODUCTS[id]['title'] = PRODUCTS[id]['title'].split.map(&:capitalize)*' '

        content_type :json
        PRODUCTS[id].to_json
      end

      post '/items/:id/relist' do |id|
        halt 403 unless params[:access_token] == 'APP12343'
        product = PRODUCTS.fetch(id) { raise Sinatra::NotFound }
        data = JSON.parse(request.body.read)
        product['id'] = 'MLA4321'
        product['price'] = data.fetch('price')
        product['available_quantity'] = data.fetch('quantity')
        product['listing_type_id'] = data.fetch 'listing_type_id'
        PRODUCTS['MLA4321'] = product

        content_type :json
        PRODUCTS['MLA4321'].to_json
      end
    }    
  end
end
