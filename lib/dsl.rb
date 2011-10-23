module Fixturized::DSL
  def fixturized(&block)
    Fixturized::Wrapper.new(self, [block]).resolve
  end
end

Object.send :include, Fixturized::DSL
