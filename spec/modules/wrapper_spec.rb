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
    it "should run the block" do
      @a=1
      wrapper = Fixturized::Wrapper.new do
        @a=2
      end
      @a.should == 1
      wrapper.run
      @a.should == 2
    end
  end
end
