require 'active_record'
require 'active_support'

module TimezoneField
  extend ActiveSupport::Concern

  class ZoneValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      value = record.send(:read_attribute, attribute)
      if value.present?
        record.errors[attribute] << 'Unrecognized timezone' if ActiveSupport::TimeZone[value].nil?
      end
    end
  end

  module ClassMethods
    def has_timezone_field(field_name)
      self.timezone_fields << field_name
      define_timezone_accessors(field_name)
      validates :"#{field_name}", :zone => true
    end

    def define_timezone_accessors(field_name)
      define_method(:"#{field_name}") do
        mapping = ActiveSupport::TimeZone::MAPPING
        zone_str = read_attribute(field_name)
        if mapping.has_key?(zone_str)
          rails_zone_identifier = zone_str
        else
          rails_zone_identifier = mapping.invert[zone_str] || Time.zone.name
        end
        ActiveSupport::TimeZone[rails_zone_identifier]
      end
      define_method(:"#{field_name}=") do |tz|
        zone = tz && ActiveSupport::TimeZone[tz]
        if zone
          write_attribute(field_name, zone.tzinfo.name)
        else
          write_attribute(field_name, tz) # This will produce a validation error when you try to save
        end
      end
    end
  end

  included do
    class_attribute :timezone_fields
    self.timezone_fields ||= []
  end
end
