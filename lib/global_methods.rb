module Fixturized::GlobalMethods
  def fixturized(&block)
    Fixturized::Runner.new(self, &block)
  end
end

Object.send :include, Fixturized::GlobalMethods
