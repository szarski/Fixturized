require 'spec_helper'
class Fixturized::Fixture
  attr_reader :filename, :content

  def self.serialization_module
    Marshal
  end

  def initialize(filename)
    @filename = filename
    @content = {}
  end

  def save
    Fixturized::FileHandler.write "#{filename}.yml", dump
  end

  def self.find(filename)
    if Fixturized::FileHandler.exists?("#{filename}.yml")
      fixture = self.new(filename)
      fixture.load Fixturized::FileHandler.read("#{filename}.yml")
      return fixture
    else
      return nil
    end
  end

  def [](*args)
    self.content.send :[], *args
  end

  def []=(*args)
    self.content.send :[]=, *args
  end

  def dump
    return self.class.serialization_module.dump(content)
  end

  def load(value)
    @content = self.class.serialization_module.load(value)
  end
end
