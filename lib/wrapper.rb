class Fixturized::Wrapper
  CUSTOM_STUFF_NAMES = []
  attr_reader :blocks

  def initialize(object, blocks)
    @block_self = object
    unless blocks.is_a?(Array) and blocks.reject {|b| b.is_a?(Proc)}.empty?
      raise Exception.new("Fixturized::Wrapper must take a block array at initialization.")
    end
    @blocks = blocks
    @block_called = false
  end

  def call_blocks(*args)
    self.blocks.each do |b|
      b.call(*args)
    end
  end

  def hash
    Digest::MD5.hexdigest(@blocks.map(&:to_source).join('||') + '|-|' + @block_self.hash.to_s)
  end

  def proper_binding
    @block_self.respond_to?(:binding) ? @block_self.send(:binding) : binding
  end
end

# (JS) will move all that to a different class

#  def get_custom_stuff
#    self.class.custom_stuff_names.inject({}) {|r,thing| r.merge(thing => eval(thing, proper_binding))}
#  end
#
#  def get_constants
#    Object.constants.inject({}) {|r,const_name| r.merge({const_name.to_sym => Object.const_get(const_name)})}
#  end
#
#  def get_start_constants
#    @start_constants = get_constants
#  end
#
#  def get_constants_diff
#    result = get_constants.to_a.reject {|name, value| @start_constants.keys.include?(name) and @start_constants[name] == value}
#    return result.inject({}){|r,(k,v)| r.merge(k=>v)}
#  end
#
#  def get_start_instance_variables
#    @start_instance_variables = get_instance_variables
#  end
#
#  def get_instance_variables_diff
#    result = get_instance_variables.to_a.reject {|name, value| @start_instance_variables.keys.include?(name) and @start_instance_variables[name] == value}
#    return result.inject({}){|r,(k,v)| r.merge(k=>v)}
#  end
#
#  def get_instance_variables
#    variable_names = @block_self.instance_variables
#    variables = variable_names.inject({}) {|r, var_name| r.merge(var_name.to_sym => @block_self.instance_variable_get(var_name))}
#    return variables || {}
#  end
#
#  def ensure_block_called_for(name)
#    raise Exception.new("attempt to call Fixturized::Wrapper##{name} without calling the block") unless @block_called
#  end
#
#  def constants
#    ensure_block_called_for 'constants'
#    @constants
#  end
#
#  def custom_stuff
#    ensure_block_called_for 'custom_stuff'
#    @custom_stuff
#  end
#
#  def db_data
#    ensure_block_called_for 'db_data'
#    @db_data
#  end
#
#  def instance_variables
#    ensure_block_called_for 'instance_variables'
#    @instance_variables
#  end
#
#  def self.custom_stuff_names
#    CUSTOM_STUFF_NAMES
#  end
#
#end

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
