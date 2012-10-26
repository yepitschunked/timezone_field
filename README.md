timezone_field
==============

This is a simple library for letting Rails apps store standard TZinfo
identifiers in the database, while still using friendly Rails zone names in
application logic. It also handles inflating/deflating timezone strings into
ActiveSupport::TimeZone objects automatically.

Usage
=====

````
class Model < ActiveRecord::Base
  include TimezoneField
  has_timezone_field :my_field
end

# assigning a TZInfo identifier
model.my_field = "America/Los_Angeles"
# still looks like Rails!
model.my_field.name
=> "Pacific Time (US & Canada)"

# assigning a Rails identifier
model.my_field = "Pacific Time (US & Canada)"
model.my_field.name
=> "Pacific Time (US & Canada)"
# Gets stored as a TZinfo identifier!
model.read_attribute(:my_field)
=> "America/Los_Angeles"
````

Why?
=====
ActiveSupport::TimeZone supports two formats for timezone strings - Rails has a
set of human-friendly zone strings, which are aliases for the standard TZInfo
identifiers used by the rest of the world. This library attempts to hide the
mapping under the covers. Your data will be stored in a standard format, while
still being friendly with Rails.
