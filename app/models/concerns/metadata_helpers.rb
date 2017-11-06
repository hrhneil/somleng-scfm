module MetadataHelpers
  extend ActiveSupport::Concern
  include ConditionalSerialization

  included do
    conditionally_serialize(:metadata, JSON)
  end

  def call_flow_logic
    metadata["call_flow_logic"]
  end

  module ClassMethods
    def metadata_has_value(key, value)
      # Adapted from:
      # https://stackoverflow.com/questions/33432421/sqlite-json1-example-for-json-extract-set
      # http://guides.rubyonrails.org/active_record_postgresql.html#json

      value_condition = value.nil? ? "IS NULL" : "= ?"

      if database_adapter_helper.adapter_sqlite?
        sql = "json_extract(\"#{table_name}\".\"metadata\", ?) #{value_condition}"
        key = "$.#{key}"
      else
        sql = "\"#{table_name}\".\"metadata\" ->> ? #{value_condition}"
      end

      where(sql, *[key, value].compact)
    end

    def metadata_has_values(hash)
      scope = all
      hash.each do |k, v|
        scope = scope.metadata_has_value(k, v)
      end
      scope
    end
  end
end
