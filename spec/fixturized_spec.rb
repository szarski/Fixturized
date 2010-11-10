require File.expand_path(File.dirname(__FILE__) + '/spec_helper')


describe "Fixturized" do
  before(:each) do
    Fixturized::FileHandler.stubs(:fixture_dir).returns(TEMP_FIXTURE_DIR)
  end

  describe "file operations" do
    before(:each) do
      remove_temp_dir
    end
    after(:each) do
      remove_temp_dir
    end

    it "should set the fixtures path properly" do
      Fixturized.create_fixture_dir
      Dir[TEMP_FIXTURE_DIR].should_not be_empty
    end

    it "should create fixture files in the fixture dir" do
      Fixturized::FileHandler.write_fixture("some_name", {:a => 3})
      FileTest.exists?(File.join(TEMP_FIXTURE_DIR, 'some_name')).should be_true
    end

    it "should write and load proper data into and from fixtures" do
      Fixturized::FileHandler.write_fixture "some_name", {:a => 3}
      Fixturized::FileHandler.load_fixture("some_name").should == {:a => 3}
    end

    it "should check if a file exists" do
      Fixturized::FileHandler.fixture_exists?("some_name").should be_false
      Fixturized.create_fixture_dir
      FileUtils.touch(File.join(TEMP_FIXTURE_DIR, 'some_name'))
      Fixturized::FileHandler.fixture_exists?("some_name").should be_true
    end

    it "should not mix fixtures up" do
      Fixturized::FileHandler.write_fixture "some_name", {:a => 3}
      Fixturized::FileHandler.write_fixture "some_other_name", {:a => 4}
      Fixturized::FileHandler.load_fixture("some_name").should == {:a => 3}
      Fixturized::FileHandler.load_fixture("some_other_name").should == {:a => 4}
    end

    it "should overwrite files" do
      Fixturized::FileHandler.write_fixture "some_name", {:a => 3}
      Fixturized::FileHandler.write_fixture "some_name", {:a => 4}
      Fixturized::FileHandler.load_fixture("some_name").should == {:a => 4}
    end

  end

  describe "working with tests" do

    before(:each) do
      Fixturized::FileHandler.stubs(:write_fixture).raises(Exception.new('write_fixture call not stubbed!'))
      Fixturized::FileHandler.stubs(:load_fixture).raises(Exception.new('load_fixture call not stubbed!'))
      Fixturized::DatabaseHandler.stubs(:collect_db_data)
      Fixturized::DatabaseHandler.stubs(:clear_db)
    end

    it "should add the fixturized command" do
      Fixturized::FileHandler.stubs(:write_fixture)
      fixturized do
      end
    end

    it "should run the block first time" do
      Fixturized::FileHandler.stubs(:write_fixture)
      class A;end
      A.expects(:method).once
      fixturized do
        A.method
      end
    end

    it "should create block hashes that are their code iniections" do
      Fixturized::FileHandler.stubs(:write_fixture)
      runner1 = Fixturized::Runner.new do
        a=1
      end
      runner2 = Fixturized::Runner.new do
        a=2
      end
      runner3 = Fixturized::Runner.new do
        a=1
      end
      runner1.block_hash.should == runner3.block_hash
      runner1.block_hash.should_not == runner2.block_hash
    end

    it "should call write_fixture with the block hash name + '.yml' at first run" do
      Fixturized::Runner.any_instance.stubs(:block_hash).returns("stubbed_block_hash")
      Fixturized::FileHandler.expects(:write_fixture).with {|filename, objects| filename == "stubbed_block_hash.yml"}.once
      fixturized do
      end
    end

    it "should call write_fixture with collected db data on first run" do
      @fake_data = 1
      Fixturized::DatabaseHandler.expects(:collect_db_data).once.returns(@fake_data)
      Fixturized::FileHandler.expects(:write_fixture).once.with {|filename, objects| objects[:database] = @fake_data}
      fixturized do
      end
    end

    it "should load fixture on second run" do
      @fake_data = 1
      Fixturized::Runner.any_instance.stubs(:block_hash).returns("stubbed_block_hash")
      Fixturized::FileHandler.expects(:fixture_exists?).with("stubbed_block_hash.yml").returns(true)
      Fixturized::FileHandler.expects(:load_fixture).once.returns({:database => @fake_data, :variables => {}, :models => {}})
      Fixturized::DatabaseHandler.expects(:write_db_data).once.with(@fake_data)
      fixturized do
      end
    end

    it "should pass instance variables on first run" do
      Fixturized::FileHandler.stubs(:write_fixture)
      fixturized do |o|
        o.variable = 123
      end
      @variable.should == 123
    end

    it "should load instance variables on second run" do
      Fixturized::FileHandler.expects(:write_fixture).with {|name, content| content[:variables] == {"variable" => 123}}.once
      Fixturized::FileHandler.expects(:load_fixture).returns(:variables => {:variable => 123}, :models => {})
      fixturized do |o|
        o.variable = 123
      end
      Fixturized::FileHandler.expects(:fixture_exists?).once.returns true
      Fixturized::DatabaseHandler.expects(:write_db_data).once
      @variable = nil
      fixturized do |o|
        o.variable = 123
      end
      @variable.should == 123
    end

    describe "models" do
      before(:each) do
        class SomeModel
          def id; 5; end
        end
        Fixturized::DatabaseHandler.stubs(:is_model?).with{|val| val.class == SomeModel}.returns(true)
      end

      it "should retrieve objects on and after first run" do
        Fixturized::FileHandler.expects(:write_fixture).with {|name, content| content[:models] == {"model" => [SomeModel,5]}}.once
        Fixturized::FileHandler.expects(:load_fixture).returns(:models => {"model" => [SomeModel,5]}, :variables => {})
        SomeModel.expects(:find).with(5).returns(SomeModel.new)
        fixturized do |o|
          o.model = SomeModel.new
        end
        Fixturized::FileHandler.expects(:fixture_exists?).once.returns true
        Fixturized::DatabaseHandler.expects(:write_db_data).once
        SomeModel.expects(:find).with(5).returns(SomeModel.new)
        @model.class.should == SomeModel
        @model.id.should == 5
        @model = nil
        fixturized do |o|
          o.model = SomeModel.new
        end
        @model.class.should == SomeModel
        @model.id.should == 5
      end

      it "should cache models so they're not loaded unneccesairly" do
        Fixturized::FileHandler.expects(:write_fixture)
        SomeModel.expects(:find).with(5).returns(SomeModel.new).once
        fixturized do |o|
          o.model = SomeModel.new
          a=o.model
          a=o.model
          a=o.model
        end
      end

      it "should request db clear on first and second run" do
        Fixturized::FileHandler.stubs(:write_fixture)
        Fixturized::DatabaseHandler.expects(:clear_db).twice
        fixturized do
          8
        end
        fixturized do
          8
        end
      end
    end

  end

  describe "collecting data [DB related]" do
    before(:all) do
      #TODO: hook db here
    end
    after(:all) do
      #TODO: close db connection here
    end
    # collect_db_data and load_db_data
    it "should collect data form the db properly" do
      pending
      runner = Fixturized::Runner.new do
        DATA_INITAILIZATION_HERE
      end
      runner.collect_db_data.should == DATA_HERE
      runner.write_db_data.should == DATA_HERE
    end

    it "should write data to db properly" do
      pending
    end

    it "should clear database when begining block first run" do
      pending
    end

    it "should clear database before loading data" do
      pending
    end
  end
end
