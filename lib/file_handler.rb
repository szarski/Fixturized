module Fixturized::FileHandler
  # All filesystem operations are handled here

  def base_dir
    return File.join(File.expand_path(RAILS_ROOT), 'fixturized')
  end

  self.extend self
=begin
  def fixture_dir
    "#{RAILS_ROOT}/fixturized"
  end

  def create_fixture_dir
    if Dir[self.fixture_dir].empty?
      FileUtils.mkdir_p self.fixture_dir
    end
  end

  def write_fixture(filename, objects)
    Fixturized.create_fixture_dir
    return File.open(self.fixture_path(filename), 'w') {|f| YAML.dump objects, f}      
  end

  def load_fixture(filename)
    return YAML.load_file(self.fixture_path(filename))
  end

  def fixture_exists?(filename)
    return FileTest.exists?(self.fixture_path(filename))
  end

  def fixture_path(filename)
    return File.join(self.fixture_dir, filename)
  end

=end
end
