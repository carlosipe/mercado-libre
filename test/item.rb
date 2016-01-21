$:.unshift File.expand_path("../../lib", __FILE__)
require 'mercado-libre'
include MercadoLibre

def assignable_properties
  {
    site_id: 'MLA',
    title: 'title',
    category_id: 'MLA1212',
    price: 100.19,
    currency_id: 'ARS',
    available_quantity: 10,
    buying_mode: 'buy_it_now',
    listing_type_id: 'gold_special',
    condition: 'new',
    description: 'description eheh',
    warranty: 'GARANTIA TOTAL CONTRA FALLAS',
    video_id: nil,
    pictures: [],
    shipping: {mode: 'me2', local_pick_up: true},
    start_time: "2015-12-30T20:28:49.097Z",
    stop_time: "2016-02-28T20:28:49.097Z",
    end_time: "2016-02-28T20:28:49.097Z",
    permalink: "http://articulo.mercadolibre.com.ar/MLA-597837524-title-_JM",
    thumbnail: "",
    secure_thumbnail: "",
    descriptions:[{id: "MLA597837524-998844341"}],
    accepts_mercadopago: true,
    non_mercado_pago_payment_methods:[],
    status: "not_yet_active",
    date_created: "2015-12-30T20:28:49.292Z",
    last_updated: "2015-12-30T20:28:49.292Z"
  }
end

def publishable_fields
  {
    site_id: 'MLA',
    title: 'title',
    category_id: 'MLA1212',
    price: 100.19,
    currency_id: 'ARS',
    available_quantity: 10,
    buying_mode: 'buy_it_now',
    listing_type_id: 'gold_special',
    condition: 'new',
    description: 'description eheh',
    warranty: 'GARANTIA TOTAL CONTRA FALLAS',
    video_id: nil,
    pictures: [],
    shipping: {mode: 'me2', local_pick_up: true}
  }
end

test "item sets all assignable properties" do
  item = Item.new(assignable_properties)
  assignable_properties.each{|k,v| assert_equal(item.send(k),v)}
end

test "item publishable_hash" do
  item = Item.new(publishable_fields)
  assert_equal(item.publishable_hash, publishable_fields)
end