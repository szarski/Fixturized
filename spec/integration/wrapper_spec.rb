require 'spec_helper'

describe "Wrapper behavior" do
  scenario "." do
    RAILS_ROOT = File.join(File.expand_path(__FILE__), '..', 'temp')
    wrapper = Fixturized::Wrapper.new(self, [lambda do
      @a=1
    end])
    @a.should be_nil
    wrapper.resolve
    @a.should == 1
  end
end
