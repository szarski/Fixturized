require 'spec_helper'
describe Fixturized::FileHandler do
  ####### helper stuff #######
  TEMP_DIR = File.join(File.dirname(__FILE__),'..','temp')
  TEMP_BASE_DIR = File.join(TEMP_DIR,'base_dir')
  TEMP_FILE_PATH = File.join(TEMP_BASE_DIR, 'some.temp.file')

  def temp_base_dir_exists?
    Dir[TEMP_BASE_DIR]
  end

  def remove_temp_base_dir
    if temp_base_dir_exists?
      FileUtils.rm_rf TEMP_BASE_DIR
    end
    temp_base_dir_exists?.should be_false
  end

  def create_temp_base_dir
    if temp_base_dir_exists?
      FileUtils.mkdir_p TEMP_BASE_DIR
    end
    temp_base_dir_exists?.should be_true
  end

  def write_temp_file(content)
    create_temp_base_dir
    FileTest.exists?(TEMP_FILE_PATH).should be_false
    File.new(TEMP_FILE_PATH, "w") do |f|
      f.puts content
    end
    FileTest.exists?(TEMP_FILE_PATH).should be_true
  end

  def read_temp_file
    FileTest.exists?(TEMP_FILE_PATH).should be_true
    File.read TEMP_FILE_PATH 
  end

  def remove_temp_file
    if FileTest.exists?(TEMP_FILE_PATH)
      File.delete TEMP_FILE_PATH
    end
    FileTest.exists?(TEMP_FILE_PATH).should be_false
  end
  ###### /helper stuff #######
  
  describe ".base_dir" do
    it "should return the fixturized temp directory" do
      RAILS_ROOT = '/some_dir'
      Fixturized::FileHandler.base_dir.should == '/some_dir/fixturized'
    end
  end
  
  describe ".create_base_dir" do
    before :each do
      remove_temp_base_dir
      Fixturized::FileHandler.stubs(:base_dir).returns TEMP_BASE_DIR
    end
    it "should create the base dir" do
      Fixturized::FileHandler.create_base_dir
      temp_base_dir_exists?.should be_true
    end
    it "should not break if the directory exists already" do
      create_temp_base_dir
      Fixturized::FileHandler.create_base_dir
      temp_base_dir_exists?.should be_true
    end
  end

  describe ".filename_with_path" do
    it "should accept a filename and add the base_dir suffix" do
      Fixturized::FileHandler.stubs(:base_dir).returns '/base_dir'
      Fixturized::FileHandler.filename_with_path('fname').should == '/base_dir/fname'
    end
  end

  describe ".write" do
    it "should save a file with given content" do
      Fixturized::FileHandler.expects(:filename_with_path).with("some.filetype").returns TEMP_FILE_PATH
      remove_temp_file
      Fixturized::FileHandler.write(TEMP_FILE_PATH,"some content")
      read_temp_file.should == "some content"
    end
  end

  describe ".read" do
    it "should return file content if exists" do
      Fixturized::FileHandler.expects(:filename_with_path).with("some.filetype").returns TEMP_FILE_PATH
      write_temp_file "some other content"
      Fixturized::FileHandler.read("somefile.type").should == "some other content"
    end
  end
end
