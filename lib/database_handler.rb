module Fixturized::DatabaseHandler
  # This module handles all features related to the db (ActiveRecrod assumend).
  # If you want to hook a different mapper, here's the place

  # engine required methods:
  #
  # is_model?
  # substitute_model(value)
  # load_model(value)
  # data_to_object
  # object_to_data
  # clear_all_tables

  def engine
    ActiveRecordAndMysqlEngine
  end

  def is_model?(value)
    self.engine.is_model? value
  end

  def substitute_model(value)
    self.engine.substitute_model(value)
  end

  def load_model(value)
    self.engine.load_model(value)
  end
  
  def collect_db_data
    return self.engine.data_to_object
  end

  def write_db_data(data)
    self.engine.object_to_data(data)
  end

  def clear_db
    clear_all_tables
  end

  module ActiveRecordAndMysqlEngine
  
    def is_model?(value)
      defined?(ActiveRecord::Base) and value.class.superclass == ActiveRecord::Base
    end

    def substitute_model(value)
      return [value.class, value.id]
    end

    def load_model(value)
      klass = value.first
      id = value.last.to_i
      return klass.find(id)
    end
  
    def clear_all_tables
      interesting_tables.each do |tbl|
        ActiveRecord::Base.connection.execute "DELETE FROM #{tbl}"
      end
    end

    def interesting_tables
      ActiveRecord::Base.connection.tables.sort.reject do |tbl|
        ['schema_info', 'sessions', 'public_exceptions'].include?(tbl)
      end
    end

    def object_to_data(objects)
      objects.each do |tbl, fixtures|
        begin
          klass = tbl.classify.constantize
          ActiveRecord::Base.transaction do 
              unless fixtures.to_a.empty?
                statement =  "INSERT INTO #{tbl} (#{fixtures.first.keys.collect{|k| "`#{k}`"}.join(",")}) " + fixtures.collect do |fixture|
                  "(SELECT #{fixture.values.collect { |value| ActiveRecord::Base.connection.quote(value) }.join(', ')})"
                end.join(" UNION ")
                ActiveRecord::Base.connection.execute statement, 'Fixture Insert'
              end
          end
        end
      end
    end  

    def data_to_object
      objects = {}
      interesting_tables.each do |tbl|
        klass = tbl.classify.constantize
        objects[tbl] = klass.find(:all).collect(&:attributes)
      end
      return objects
    end  

    self.extend self
  end

  self.extend self
end
