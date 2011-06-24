module Fixturized::FileHandler
  # All filesystem operations are handled here

  def base_dir
    return File.join(File.expand_path(RAILS_ROOT), 'fixturized')
  end

  def create_base_dir
    if Dir[base_dir].empty?
      FileUtils.mkdir_p base_dir
    end
  end

  def filename_with_path(filename)
    return File.join(base_dir, filename)
  end

  def write(filename, content)
    create_base_dir
    return File.open(filename_with_path(filename), 'w') {|f| f.write(content)}
  end

  def read(filename)
    create_base_dir
    if exists?(filename)
      File.read(filename_with_path(filename))
    else
      nil
    end
  end

  def exists?(filename)
    FileTest.exists?(filename_with_path(filename))
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
