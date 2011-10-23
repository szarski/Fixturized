require 'spec_helper'

describe Fixturized::DSL do
  describe "#fixturized" do
    it "should create a wrapper and resolve it" do
      block = lambda{}
      appropriate_wrapper = mock
      Fixturized::Wrapper.expects(:new).with{|pointer, blocks| blocks.count == 1 and blocks.first.is_a?(Proc)}.returns(appropriate_wrapper)
      appropriate_wrapper.expects(:resolve)
      Object.fixturized(&block)
    end
  end
end
