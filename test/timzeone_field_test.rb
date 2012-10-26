require 'minitest/autorun'
require 'timezone_field'

class TestTimezoneField < MiniTest::Unit::TestCase
  class TestModel < ActiveRecord::Base
    def self.columns
      @columns ||= []
    end
    def self.column(name, sql_type = nil, default = nil, null = true)
      columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
    end

    column :test_zone, :string
    include TimezoneField
    has_timezone_field :test_zone
    has_timezone_field :other_zone
  end

  def setup
    Time.zone = "Arizona"
    @model = TestModel.new
  end

  def test_field_name_class_attribute
    assert_equal :test_zone, TestModel.timezone_fields.first
  end

  def test_timezone_read_map_from_rails_identifier
    @model.send(:write_attribute, :test_zone, "Pacific Time (US & Canada)")
    assert_equal "Pacific Time (US & Canada)", @model.test_zone.name
  end

  def test_timezone_read_map_from_tzinfo_identifier
    @model.send(:write_attribute, :test_zone, "America/Los_Angeles")
    assert_equal "Pacific Time (US & Canada)", @model.test_zone.name
  end

  def test_timezone_read_map_from_unknown_identifier
    @model.send(:write_attribute, :test_zone, "ajksdfhaskjdfs")
    assert_equal Time.zone.name, @model.test_zone.name
  end

  def test_timezone_read_map_from_nil_identifier
    @model.send(:write_attribute, :test_zone, nil)
    assert_equal Time.zone.name, @model.test_zone.name
  end

  def test_timezone_write_map_from_rails_identifier
    @model.test_zone = "Pacific Time (US & Canada)"
    assert_equal "America/Los_Angeles", @model.send(:read_attribute, :test_zone)
  end

  def test_timezone_write_map_from_tzinfo_identifier
    @model.test_zone = "America/Los_Angeles"
    assert_equal "America/Los_Angeles", @model.send(:read_attribute, :test_zone)
  end

  def test_timezone_validation_from_rails_identifier
    @model.test_zone = "Pacific Time (US & Canada)"
    assert_equal true, @model.valid?
  end

  def test_timezone_validation_from_tzinfo_identifier
    @model.test_zone = "America/Los_Angeles"
    assert_equal true, @model.valid?
  end

  def test_timezone_validation_from_unknown_identifier
    @model.test_zone = "asdfasfasdfasdf"
    assert_equal false, @model.valid?
  end

  def test_multiple_timezone_fields
    @model.send(:write_attribute, :test_zone, "Pacific Time (US & Canada)")
    @model.send(:write_attribute, :other_zone, "Alaska")
    assert_equal "Pacific Time (US & Canada)", @model.test_zone.name
    assert_equal "Alaska", @model.other_zone.name
  end
end
