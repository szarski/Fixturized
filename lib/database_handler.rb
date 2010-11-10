module Fixturized::DatabaseHandler
  # This module handles all features related to the db (ActiveRecrod assumend).
  # If you want to hook a different mapper, here's the place

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
  
  def collect_db_data
    return nil
  end

  def write_db_data(data)
  end

  def clear_db
  end

  def is_model?(value)
  end

  self.extend self
end
