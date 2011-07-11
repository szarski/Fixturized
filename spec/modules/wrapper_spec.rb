require 'spec_helper'
describe Fixturized::Wrapper do

Fixturized::Wrapper

  it "should take a block and the self pointer" do
    Fixturized::Wrapper.new(self) do
      puts 1
    end
  end

  it "should raise if no block given" do
    lambda {Fixturized::Wrapper.new(self)}.should raise_exception
  end

  it "should return a hash that is a biection onto the block's code and the self object" do
    self1, self2=mock, mock
    s1a1 = Fixturized::Wrapper.new(self1) {a=1}
    s2a1 = Fixturized::Wrapper.new(self2) {a=1}
    s1a2 = Fixturized::Wrapper.new(self1) {a=2}
    s1a1_ = Fixturized::Wrapper.new(self1) {a= 1}
    s1a1.hash.should == s1a1_.hash
    s1a1.hash.should_not == s2a1.hash
    s1a1.hash.should_not == s1a2.hash
  end

  describe "call" do
    before :each do
      @new_var_value = mock()
      @called = false
      @wrapper = Fixturized::Wrapper.new(self) do
        @called = true
        @new_var = @new_var_value
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

    it "should collect instance variables" do
      @wrapper.call
      @wrapper.instance_variables.should be_a(Hash)
      @wrapper.instance_variables.should include("@new_var")
      @wrapper.instance_variables.should == {"@called" => true, "@new_var" => @new_var_value}
    end
  end
end
