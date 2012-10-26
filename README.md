timezone_field
==============

This is a simple library for letting Rails apps store standard TZinfo
identifiers in the database, while still using friendly Rails zone names in
application logic. It also handles validation and inflating/deflating timezone
strings into ActiveSupport::TimeZone objects automatically.

Usage
=====

````ruby
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

# assigning a bogus identifier
model.my_field = "HAMMER TIME"
model.valid?
=> false
model.errors
=> {:timezone=>["Unrecognized timezone"]}
=> model.my_field == Time.zone
=> true

# handling of nil values - returns Time.zone
model.my_field = nil
model.valid?
=> true
=> model.my_field == Time.zone
=> true
````

Why?
=====
ActiveSupport::TimeZone supports two formats for timezone strings - Rails has a
set of human-friendly zone strings, which are aliases for the standard TZInfo
identifiers used by the rest of the world. This library attempts to hide the
mapping under the covers. Your data will be stored in a standard format, while
still being friendly with Rails.

Handling unrecognized zones
=====
When encountering blank or unrecognized zones, this library returns the current
value of Time.zone, rather than nil. I found myself writing
`current_user.timezone || Time.zone` a lot, and decided a nil timezone doesn't
really make sense - you're probably using this field to store user timezone
settings, and if they didn't set one, you probably want to default. A caveat to
be aware of if you're writing migrations or something.
