Gem::Specification.new do |s|
  s.name        = 'timezone_field'
  s.version     = '1.1.0'
  s.summary     = "Rails-friendly timezone field"
  s.description = "Stores timezones as standard TZInfo identifiers and handles conversion to/from Rails-friendly timezones"
  s.authors     = ["Victor Lin"]
  s.email       = 'victor@wellnessfx.com'
  s.files       = ["lib/timezone_field.rb"]
  s.homepage    = ''
  s.require_paths = ['lib']

  s.add_dependency "activerecord"
  s.add_dependency "activesupport"
end
