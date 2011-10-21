require 'spec_helper'
describe Fixturized::Wrapper do

  subject {Fixturized::Wrapper.new self, [lambda{}]}

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

  describe "#call_blocks" do
    let(:block1) {lambda {|a| 1}}
    let(:block2) {lambda {|a| 2}}
    subject {Fixturized::Wrapper.new(mock, [block1, block2])}

    it "should call all the blocks" do
      block1.expects(:call).with
      block2.expects(:call).with
      subject.call_blocks
    end
  end

  describe "#fixture_filename" do
    before do
      subject.stubs(:hash).returns(mock(:to_s => hash_mock))
    end
    let(:hash_mock) {mock}

    it "should return hash plus the extension" do
      subject.fixture_filename.should == hash_mock
    end
  end

  describe "#find_fixture" do
    before do
      subject.stubs(:fixture_filename).returns(filename_mock)
    end
    let(:filename_mock) {mock}

    it "should run Fixture#find with proper filename" do
      valid_result = mock
      Fixturized::Fixture.expects(:find).with(filename_mock).returns valid_result
      subject.find_fixture.should == valid_result
    end
  end

  describe "#load_from_fixture" do
    it "should load from fixture" do
      fixture_mock = mock
      fixture_content_mock = mock
      subject.stubs(:find_fixture).returns(fixture_mock)
      fixture_mock.stubs(:content).returns(fixture_content_mock)
      subject.expects(:set_environment_state).with(fixture_content_mock)
      subject.load_from_fixture
    end
  end

  describe "#save_to_fixture" do
    before do
      subject.stubs(:fixture_filename).returns(filename_mock)
      subject.stubs(:get_environment_state).returns(environment_state_mock)
    end
    let(:filename_mock) {mock}
    let(:environment_state_mock) {mock}

    it "should save to fixture" do
      valid_result = mock
      fixture_mock = mock
      Fixturized::Fixture.expects(:new).with(filename_mock).returns fixture_mock
      fixture_mock.expects(:content=).with(environment_state_mock)
      fixture_mock.expects(:save)
      subject.save_to_fixture
    end
  end

  describe "#resolve" do
    context "when there is no fixture" do
      before do
        subject.stubs(:find_fixture).returns(nil)
      end

      it "should load environment state" do
        subject.expects(:call_blocks)
        subject.expects(:save_to_fixture)
        subject.resolve
      end
    end

    context "when there is a fixture" do
      before do
        fixture_mock = mock
        subject.stubs(:find_fixture).returns(fixture_mock)
      end

      it "should call blocks and save environment state" do
        subject.expects(:load_from_fixture)
        subject.resolve
      end
    end
  end

  describe "#get_environment_state" do
    it "should initialize Environment and get it's state"
  end

  describe "#set_environment_state" do
    it "should initialize Environment and set it's state"
  end
end

# (JS) will move all that to a different class
#
#  describe "call" do
#    before :each do
#      @new_var_value = mock()
#      @called = false
#      block1 = lambda do
#        @called = true
#        @new_var = @new_var_value
#      end
#      block2 = lambda do
#        @called = true
#        @new_var2 = @new_var_value
#      end
#      @wrapper = Fixturized::Wrapper.new(self, [block1, block2])
#    end
#
#    it "should call the block" do
#      @called.should be_false
#      @wrapper.call
#      @called.should be_true
#    end
#
#    it "should accept and pass arguments" do
#      arg1, arg2 = mock(), mock()
#      @wrapper.blocks.first.expects(:call).with(arg1, arg2)
#      @wrapper.blocks[1].expects(:call).with(arg1, arg2)
#      @wrapper.call(arg1, arg2)
#    end
#
#    it "should raise when reading without running the block" do
#      method_names = %w{instance_variables constants custom_stuff db_data}
#      method_names.each do |method_name|
#        lambda {@wrapper.send(method_name)}.should raise_error {|e| e.message.should =~ /without calling/}
#      end
#      @wrapper.call
#      method_names.each do |method_name|
#        @wrapper.send(method_name)
#      end
#    end
#
#    it "should collect instance variables" do
#      @wrapper.call
#      @wrapper.instance_variables.should be_a(Hash)
#      @wrapper.instance_variables.should == {:@called => true, :@new_var => @new_var_value, :@new_var2 => @new_var_value}
#    end
#
#    it "should collect constants" do
#      block = lambda {B=3;C=4}
#      A=1
#      B=2
#      wrapper = Fixturized::Wrapper.new(self, [block])
#      wrapper.call
#      wrapper.constants.should == {:B => 3, :C => 4}
#    end
#
#    it "should save custom stuff" do
#      Fixturized::Wrapper.should respond_to(:custom_stuff_names)
#      Fixturized::Wrapper.stubs(:custom_stuff_names).returns(%w{CUSTOM_DATA})
#      block = lambda {NORMAL_DATA = 1; CUSTOM_DATA = 2}
#      wrapper = Fixturized::Wrapper.new(self, [block])
#      wrapper.call
#      wrapper.custom_stuff.keys.should include("CUSTOM_DATA")
#      wrapper.custom_stuff.keys.should_not include("NORMAL_DATA")
#      wrapper.custom_stuff.should == {"CUSTOM_DATA" => 2}
#    end
#
#    it "should save database data" do
#      block = lambda {NORMAL_DATA = 1; CUSTOM_DATA = 2}
#      wrapper = Fixturized::Wrapper.new(self, [block])
#      db_mock = mock
#      Fixturized::DatabaseHandler.expects(:collect_db_data).returns(db_mock)
#      wrapper.call
#      wrapper.db_data.should == db_mock
#    end
#  end
#end
