require 'spec_helper'
describe Fixturized::Wrapper do

Fixturized::Wrapper

  it "should take a block" do
    Fixturized::Wrapper.new do
      puts 1
    end
  end

  it "should raise if no block given" do
    lambda {Fixturized::Wrapper.new}.should raise_exception
  end

  describe "run" do
    before :each do
      @called = false
      @wrapper = Fixturized::Wrapper.new do
        @called = true
      end
    end

    it "should call the block" do
      @called.should be_false
      @wrapper.call
      @called.should be_true
    end
    
    it "should accept and pass arguments" do
      arg1, arg2 = mock(), mock()
      @wrapper.block.expects(:call).with(arg1, arg2)
      @wrapper.call(arg1, arg2)
    end
  end
end
