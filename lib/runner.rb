class Fixturized::Runner
  def initialize(main_object=nil, &block)
    Fixturized::DatabaseHandler.clear_db
    @block = block
    if Fixturized::FileHandler.fixture_exists?(self.filename)
      data = Fixturized::FileHandler.load_fixture self.filename
      Fixturized::DatabaseHandler.write_db_data(data[:database])
      wrapper = Fixturized::Wrapper.new(data[:variables],data[:models])
      wrapper.set_instance_variables_on(main_object)
    else
      wrapper = Fixturized::Wrapper.new
      @block.call wrapper
      Fixturized::FileHandler.write_fixture self.filename, {:database => Fixturized::DatabaseHandler.collect_db_data, :variables => wrapper.variables, :models => wrapper.models}
      wrapper.set_instance_variables_on(main_object)
    end
  end

  def filename
    return "#{self.block_hash}.yml"
  end

  def block_hash
    Digest::MD5.hexdigest(@block.to_source)
  end

end
