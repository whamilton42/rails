require 'active_record/scoping/default'
require 'active_record/scoping/named'
require 'active_record/base'

module ActiveRecord
  class SchemaMigration < ActiveRecord::Base
    class << self

      def table_name
        "#{table_name_prefix}schema_migrations#{table_name_suffix}"
      end

      def index_name
        "#{table_name_prefix}unique_schema_migrations#{table_name_suffix}"
      end

      def table_exists?
        connection.table_exists?(table_name)
      end

      def create_table(limit=nil)
        unless table_exists?
          version_options = {null: false}
          version_options[:limit] = limit if limit

          connection.create_table(table_name, id: false) do |t|
            t.column :version, :string, version_options
          end
          connection.add_index table_name, :version, unique: true, name: index_name
        end
      end

      def drop_table
        if table_exists?
          connection.remove_index table_name, name: index_name
          connection.drop_table(table_name)
        end
      end
    end

    def version
      super.to_i
    end
  end
end
