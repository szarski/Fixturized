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
    it "should call #get_beginning_instance_variabless, call block, call #get_instance_variables and merge it to the output" do
      instance_variables_sequence = sequence('instance variables')
      passed_block, k, v = mock, mock, mock
      subject.expects(:get_beginning_instance_variables).returns(result).in_sequence(instance_variables_sequence)
      passed_block.expects(:call).in_sequence(instance_variables_sequence)
      subject.expects(:get_instance_variables).returns({k=>v}).in_sequence(instance_variables_sequence)
      subject.state{passed_block.call}[:instance_variables].should == {k=>v}
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

  describe "#get_beginning_instance_variables" do
    it "should call #get_instance_variables and save to @beginning_instance_variables" do
      vars_mock = mock
      subject.stubs(:get_instance_variables).returns(vars_mock)
      subject.get_beginning_instance_variables
      subject.instance_variable_get("@beginning_instance_variables").should == vars_mock
    end
  end

  describe "get_instance_variables_diff" do
    it "should get all the new variables" do
      subject.instance_variable_set("@beginning_instance_variables", {:a => 1})
      subject.stubs(:get_instance_variables).returns({:b => 1})
      subject.get_instance_variables_diff[:b].should == 1
    end

    it "should get all variables that changed" do
      subject.instance_variable_set("@beginning_instance_variables", {:a => 1})
      subject.stubs(:get_instance_variables).returns({:a => 3})
      subject.get_instance_variables_diff[:a].should == 3
    end

    it "should not get the variables that did not change" do
      subject.instance_variable_set("@beginning_instance_variables", {:a => 1})
      subject.stubs(:get_instance_variables).returns({:a => 1})
      subject.get_instance_variables_diff[:a].should be_nil
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
