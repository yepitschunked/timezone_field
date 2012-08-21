require 'active_record'
require 'active_support'

module TimezoneField
  extend ActiveSupport::Concern

  class ZoneValidator < ActiveModel::Validator
    def validate(record)
      record.class.timezone_fields.each do |tz_field|
        value = record.send(:read_attribute, tz_field)
        if value.present?
          record.errors[tz_field.to_sym] << 'Unrecognized timezone' if ActiveSupport::TimeZone[value].nil?
        end
      end
    end
  end

  module ClassMethods
    def has_timezone_field(field_name)
      self.timezone_fields ||= []
      self.timezone_fields << field_name
      define_timezone_accessors(field_name)
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
    validates_with ZoneValidator
  end
end
