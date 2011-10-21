require 'spec_helper'
describe Fixturized::Fixture do
  subject {Fixturized::Fixture.new("whatever")}

  it "should initialize given a name" do
    Fixturized::Fixture.new("whatever")
  end

  it "should store the filename" do
    Fixturized::Fixture.new("whatever").filename.should == "whatever"
  end

  describe ".serialization_module" do
    it "should return Marshal by default" do
      Fixturized::Fixture.serialization_module.should == Marshal
    end
  end

  describe "#dump" do
    it "should use the proper serialization module" do
      dump_result, serialization_module = mock(), mock()
      serialization_module.expects(:dump).with({:some_key => :some_value}).returns dump_result
      Fixturized::Fixture.expects(:serialization_module).returns serialization_module
      fixture = Fixturized::Fixture.new("whatever")
      fixture[:some_key] = :some_value
      fixture.dump.should == dump_result
    end
  end

  describe "#load" do
    it "should use the proper serialization module" do
      load_result, serialization_module = mock(), mock()
      serialization_module.expects(:load).with({:some_key => :some_value}).returns load_result
      Fixturized::Fixture.expects(:serialization_module).returns serialization_module
      fixture = Fixturized::Fixture.new('fname')
      fixture.load({:some_key => :some_value})
      fixture.content.should == load_result
    end
  end

  it "should save using FileHandler, with a proper name and content" do
    dump_result = mock()
    fixture = Fixturized::Fixture.new('whatever')
    fixture.expects(:dump).returns(dump_result)
    Fixturized::FileHandler.expects(:write).with("whatever.yml", dump_result)
    fixture.save
  end

  describe ".find" do
    it "should set the file name and load from file" do
      file_content = mock()
      Fixturized::FileHandler.expects(:exists?).with("whatever.yml").returns true
      Fixturized::FileHandler.expects(:read).with("whatever.yml").returns(file_content)
      Fixturized::Fixture.any_instance.expects(:load).with(file_content)
      fixture = Fixturized::Fixture.find "whatever"
      fixture.filename.should == "whatever"
    end

    it "should return nil if file not found" do
      Fixturized::FileHandler.expects(:exists?).with("whatever.yml").returns false
      Fixturized::Fixture.find("whatever").should be_nil
    end
  end

  describe "#content" do
    it "should return fixture's content" do
      content_mock = mock
      subject.content = content_mock
      subject.content.should == content_mock
    end
  end

  it "should be empty by default" do
    Fixturized::Fixture.new("whatever").content.should == {}
  end

end
