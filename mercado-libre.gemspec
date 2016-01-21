Gem::Specification.new do |s|
  s.name              = "mercado-libre"
  s.version           = "0.0.1"
  s.summary           = "MercadoLibre API"
  s.description       = "mercado-libre"
  s.authors           = ["CarlosIPe"]
  s.email             = ["carlos2@compendium.com.ar"]
  s.homepage          = "https://github.com/carlosipe/mercado-libre"
  s.license           = "MIT"

  s.files = `git ls-files`.split("\n")

  s.add_dependency "requests", '~> 1'
  s.add_development_dependency "cutest", '~> 1'
  s.add_development_dependency "mock-server", '~> 0'
end