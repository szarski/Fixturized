require 'spec_helper'

describe Fixturized::Environment do
  subject {Fixturized::Environment.new(1)}
  let(:result) {mock}

  describe "#initialize" do
    it "should accept self_pointer and store it" do
      pointer = mock
      env = described_class.new(pointer)
      env.self_pointer.should == pointer
    end
  end

  describe "#state" do
    it "should call #get_instance_variabless and merge it to the output" do
      subject.stubs(:get_instance_variables).returns(result)
      subject.state[:instance_variables].should == result
    end
  end

  describe "#state=" do
    it "should extract :instance_variables and pass to #set_instance_variables" do
      subject.expects(:set_instance_variables).with(result)
      subject.state = {:instance_variables => result}
    end
  end

  describe "#get_instance_variables" do
    before do
      class X; attr_accessor :a; end
      @x=X.new
      @x.a = 123
    end

    it "should get all object's instance variables" do
      described_class.new(@x).get_instance_variables.should == {:a => 123}
    end
  end

  describe "#set_instance_variables" do
    before do
      class X; attr_accessor :a; end
      @x=X.new
    end

    it "should set given instance variables" do
      described_class.new(@x).state = {:instance_variables => {:a => 345}}
      @x.a.should == 345
    end
  end
end
