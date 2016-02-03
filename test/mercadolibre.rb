$:.unshift File.expand_path("../../lib", __FILE__)
require 'mercado-libre'
require './test/mercadolibre_mock_server'
include MercadoLibre
mercadolibre_mock = MercadoLibreMock.new
mercadolibre_mock.run

File.read("env.sh").scan(/(.*?)="?(.*)"?$/).each do |key, value|
  ENV[key] ||= value
end

def api
  API.new(
    app_key: ENV['ML_TEST_APP_KEY'],
    app_secret: ENV['ML_TEST_APP_SECRET'],
    host: ENV['TESTING_AGAINST_ML_SERVER'] ? 'https://api.mercadolibre.com' : 'http://localhost:4000'
  )
end

def item
  Item.new(
    site_id: 'MLA',
    title: 'title',
    category_id: 'MLA1227',
    price: 100.19,
    currency_id: 'ARS',
    available_quantity: 10,
    buying_mode: 'buy_it_now',
    listing_type_id: 'bronze',
    condition: 'new',
    description: 'description eheh',
    video_id: nil,
    warranty: 'GARANTIA TOTAL CONTRA FALLAS',
    pictures: [],
    shipping: {"mode"=> 'me2', "local_pick_up" => true}
    )
end

test "API gets access token" do
  assert( api.request_access_token() =~ /^APP/ )
end

test "API.publish item returns item with id and title" do
  published_item = api.publish_item(item)
  assert(published_item.id =~ /^MLA(\d*)/ )
  assert_equal(published_item.title, 'Title')
end

test "publish item and check its published" do
  published_item = api.publish_item(item)
  assert_equal(api.get_item(published_item.id).title, 'Title')
end

test "updates item and check its updated" do
  published_item = api.publish_item(item)
  params = {title: 'New title', price: 200, available_quantity: 99}
  api.update_item(published_item.id, params)
  retrieved_item = api.get_item(published_item.id)

  assert_equal(retrieved_item.title, 'New Title')
  assert_equal(retrieved_item.price, 200)
  assert_equal(retrieved_item.available_quantity, 99)
  assert_equal(retrieved_item.id, published_item.id)
end

test "publish item returns item with permalink" do
  published_item = api.publish_item(item)
  assert(published_item.permalink =~ /http/)
end

test "closes item and status is closed" do
  published_item = api.publish_item(item)
  sleep(10) if ENV['TESTING_AGAINST_ML_SERVER']
  api.close_item(published_item.id)
  assert_equal(api.get_item(published_item.id).status, 'closed')
end

test "relists an item returns item with new ML_ID and values" do
  published_item = api.publish_item(item)
  sleep(10) if ENV['TESTING_AGAINST_ML_SERVER']
  api.close_item(published_item.id)
  relisted_item = api.relist_item(published_item.id,{
    price: 90,
    quantity: 40,
    listing_type_id: 'bronze'
  })
  assert_equal(relisted_item.price, 90)
  assert_equal(relisted_item.available_quantity, 40)
end

test "returns verbose exceptions" do
  begin
    api.request(:post, '/oauth/token', {client_id: '123'})
  rescue StandardError =>e
    verbose_error_message = "Bad Request\n{\"message\":\"grant_type is a required parameter\",\"error\":\"invalid_request\",\"status\":400,\"cause\":[]}"
    assert_equal(e.message, verbose_error_message )
  end
end

test "authenticated_request gets new access token when forbidden" do
  ml = api
  ml.access_token = 'Invalid one'
  published_item = ml.publish_item(item)
  assert(ml.access_token =~ /^APP/)
end

test ".url_with_token(url) returns right url when doesnt have  other query params" do
  ml = api
  ml.access_token = 'APP123456'
  url = '/users/189517696/items/search'
  assert_equal ml.url_with_token(url), '/users/189517696/items/search?access_token=APP123456'
end

test ".url_with_token(url) returns right url when has query params" do
  ml = api
  ml.access_token = 'APP123456'
  url = '/users/189517696/items/search?limit=200&offset=100'
  assert_equal ml.url_with_token(url), '/users/189517696/items/search?limit=200&offset=100&access_token=APP123456'
end