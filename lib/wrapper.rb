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

  def fixture_filename
    hash.to_s
  end

  def find_fixture
    Fixturized::Fixture.find(fixture_filename)
  end

  def load_from_fixture
    set_environment_state find_fixture.content
  end

  def call_blocks_and_save_to_fixture
    fixture = Fixturized::Fixture.new(fixture_filename)
    fixture.content = call_blocks_and_get_environment_state
    fixture.save
  end

  def resolve
    if find_fixture
      load_from_fixture
    else
      call_blocks_and_save_to_fixture
    end
  end

  def proper_binding
    @block_self.respond_to?(:binding) ? @block_self.send(:binding) : binding
  end

  def self_pointer
    @block_self
  end

  def call_blocks_and_get_environment_state
    Fixturized::Environment.new(self_pointer).state do
      call_blocks
    end
  end

  def set_environment_state(state)
    Fixturized::Environment.new(self_pointer).state = state
  end
end
