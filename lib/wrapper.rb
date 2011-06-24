class Fixturized::Wrapper
  attr_reader :block

  def initialize(&block)
    unless block_given?
      raise Exception.new("Fixturized::Wrapper must take a block at initialization.")
    end
    @block = block
  end

  def run
    self.block.call
  end

end

=begin
  attr_reader :variables, :models

  def initialize(variables={},models={})
    @variables = variables
    @models = models
    @loaded_models = {}
  end

  def method_missing(method_name, *args)
    if method_name.to_s =~ /.+=$/
      raise Exception.new('too many arguments in assignment') unless args.size == 1
      method_name = method_name.to_s.gsub(/=$/,'')
      self.set(method_name, args.first)
    else
      raise Exception.new('unexpected arguments in retrieval') unless args.empty?
      method_name = method_name.to_s
      self.read method_name
    end
  end

  def set(name, value)
    if Fixturized::DatabaseHandler.is_model?(value)
      @models[name] = Fixturized::DatabaseHandler.substitute_model(value)
    else
      @variables[name] = value
    end
  end

  def read(name)
    @variables[name] || read_model(name)
  end

  def read_model(name)
    loaded = @loaded_models[name.to_s]
    value = @models[name.to_s]
    if loaded
      return loaded
    elsif value
      result = Fixturized::DatabaseHandler.load_model(value)
      @loaded_models[name.to_s] = result
      return result
    else
      return nil
    end
  end

  def set_instance_variables_on(object)
    @variables.each do |name, value|
      object.instance_variable_set "@#{name}", value
    end
    @models.each do |name, value|
      object.instance_variable_set "@#{name}", read_model(name)
    end
  end

end
=end
