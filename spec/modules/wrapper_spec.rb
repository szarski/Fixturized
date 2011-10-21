require 'spec_helper'
describe Fixturized::Wrapper do

Fixturized::Wrapper

  before :each do
    Fixturized::DatabaseHandler.stubs :collect_db_data
  end

  describe "#initialize" do
    it "should take a blocks array and the self pointer" do
      block = lambda do
        puts 1
      end
      described_class.new(self, [block])
    end

    it "should raise if no block given" do
      lambda {described_class.new(self)}.should raise_exception
    end

    it "should accept multiple blocks" do
      block = lambda do
        puts 1
      end
      described_class.new(self, [block, block])
    end
  end

  describe "#hash" do
    subject {Fixturized::Wrapper.new(self1, [proc1])}
    let (:proc1) {lambda {|a| a=1}}
    let (:proc1_different_arity) {lambda {|a,b| a=1}}
    let (:proc2) {lambda {|a| a=2}}
    let (:self1) {mock}
    let (:self2) {mock}

    context "when self pointers and blocks array match" do
      let(:wrapper) {Fixturized::Wrapper.new(self1, [proc1])}

      it "should be the same" do
        wrapper.hash.should == subject.hash
      end
    end

    context "when self pointers match but one of the block elements has different arity" do
      let(:wrapper) {Fixturized::Wrapper.new(self1, [proc1_different_arity])}

      it "should be different" do
        wrapper.hash.should_not == subject.hash
      end
    end

    context "when self pointers match but block arrays have different amount of elements" do
      let(:wrapper) {Fixturized::Wrapper.new(self1, [proc1, proc1])}

      it "should be different" do
        wrapper.hash.should_not == subject.hash
      end
    end

    context "when self pointers match but block arrays elements have different bodies" do
      let(:wrapper) {Fixturized::Wrapper.new(self1, [proc2])}

      it "should be different" do
        wrapper.hash.should_not == subject.hash
      end
    end

    context "block arrays match but self pointers are different" do
      let(:wrapper) {Fixturized::Wrapper.new(self2, [proc1])}

      it "should be different" do
        wrapper.hash.should_not == subject.hash
      end
    end
  end

  describe "call" do
    before :each do
      @new_var_value = mock()
      @called = false
      block1 = lambda do
        @called = true
        @new_var = @new_var_value
      end
      block2 = lambda do
        @called = true
        @new_var2 = @new_var_value
      end
      @wrapper = Fixturized::Wrapper.new(self, [block1, block2])
    end

    it "should call the block" do
      @called.should be_false
      @wrapper.call
      @called.should be_true
    end

    it "should accept and pass arguments" do
      arg1, arg2 = mock(), mock()
      @wrapper.blocks.first.expects(:call).with(arg1, arg2)
      @wrapper.blocks[1].expects(:call).with(arg1, arg2)
      @wrapper.call(arg1, arg2)
    end

    it "should raise when reading without running the block" do
      method_names = %w{instance_variables constants custom_stuff db_data}
      method_names.each do |method_name|
        lambda {@wrapper.send(method_name)}.should raise_error {|e| e.message.should =~ /without calling/}
      end
      @wrapper.call
      method_names.each do |method_name|
        @wrapper.send(method_name)
      end
    end

    it "should collect instance variables" do
      @wrapper.call
      @wrapper.instance_variables.should be_a(Hash)
      @wrapper.instance_variables.should == {:@called => true, :@new_var => @new_var_value, :@new_var2 => @new_var_value}
    end

    it "should collect constants" do
      block = lambda {B=3;C=4}
      A=1
      B=2
      wrapper = Fixturized::Wrapper.new(self, [block])
      wrapper.call
      wrapper.constants.should == {:B => 3, :C => 4}
    end

    it "should save custom stuff" do
      Fixturized::Wrapper.should respond_to(:custom_stuff_names)
      Fixturized::Wrapper.stubs(:custom_stuff_names).returns(%w{CUSTOM_DATA})
      block = lambda {NORMAL_DATA = 1; CUSTOM_DATA = 2}
      wrapper = Fixturized::Wrapper.new(self, [block])
      wrapper.call
      wrapper.custom_stuff.keys.should include("CUSTOM_DATA")
      wrapper.custom_stuff.keys.should_not include("NORMAL_DATA")
      wrapper.custom_stuff.should == {"CUSTOM_DATA" => 2}
    end

    it "should save database data" do
      block = lambda {NORMAL_DATA = 1; CUSTOM_DATA = 2}
      wrapper = Fixturized::Wrapper.new(self, [block])
      db_mock = mock
      Fixturized::DatabaseHandler.expects(:collect_db_data).returns(db_mock)
      wrapper.call
      wrapper.db_data.should == db_mock
    end
  end
end
