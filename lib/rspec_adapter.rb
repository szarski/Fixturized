module Fixturized::RspecAdapter
  module ExampleGroupHierarchyExtension
      def eval_each_fail_fast(blocks) # :nodoc:
        # IF you operate on an array here it will behave weirdly:
        # it won't be overwritten the next time an example is run
        # all the hashes will be added each time.
        @c ||= ""
        @c += blocks.collect {|b| Digest::MD5.hexdigest(b.to_source)}.join('+')+'+'
        filename = 'block_chain_' + Digest::MD5.hexdigest(@c) + '.yml'
        if Fixturized::FileHandler.fixture_exists?(filename)
          Fixturized::DatabaseHandler.clear_db
          data = Fixturized::FileHandler.load_fixture filename
          vars = data[:variables]
          #vars.delete "@_proxy"
          #vars.delete "@_result"
          #vars.delete "@method_name"
          #vars.delete "@_backtrace"
          #vars.delete "@_implementation"
          set_instance_variables_from_hash(vars)
          Fixturized::DatabaseHandler.write_db_data(data[:database])
        else
          blocks.each {|block| instance_eval(&block)}
          vars = instance_variable_hash.clone
          vars.to_a.each do |k,v|
            if v.is_a?(Proc)
              vars.delete k
            end
          end
          Fixturized::FileHandler.write_fixture filename, {:database => Fixturized::DatabaseHandler.collect_db_data, :variables => vars}
        end
      end
  end
  def plug_in
    puts "PLUGGING IN!!!!!"
    ::Spec::Example::ExampleMethods.extend Fixturized::RspecAdapter::ExampleGroupHierarchyExtension
    ::Spec::Example::ExampleGroup.include Fixturized::RspecAdapter::ExampleGroupHierarchyExtension
    ::Test::Unit::TestCase.include Fixturized::RspecAdapter::ExampleGroupHierarchyExtension
  end
  self.extend self
end



Fixturized::RspecAdapter.plug_in
