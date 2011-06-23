class Time
  class <<self
    attr_reader :offset
    alias_method :real_now, :now
    def now
      @offset = 0 if @offset.nil?
      real_now - @offset
    end
    alias_method :new, :now

    # Warp to an absolute  time  in the past or future, making sure it takes
    # the present as the reference starting point when making the jump.
    def set(time)
      reset
      @offset = now - time
    end

    # Jump back to present.
    def reset
      @offset = 0
    end
  end
end

module Fixturized::RspecAdapter
    FORBIDDEN_METHODS = %w{stubs expects any_instance}
    def self.cache
      @cache
    end
    def self.cache=val
      @cache=val
    end
  module ExampleGroupHierarchyExtension
      SPECIAL_PLACES = %w{ActionMailer::Base.deliveries}
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
#puts "read: "+data[:constants].inspect
          data[:constants].each {|const_name, const_value| #puts(const_name.inspect, const_value.inspect);
            Object.const_set(const_name, const_value)}
          vars = data[:variables]
          set_instance_variables_from_hash(vars)
          Fixturized::DatabaseHandler.write_db_data(data[:database])
          #Time.set(data[:time])
          data[:special_places].each do |p,val|
            val = "Marshal.load(#{Marshal.dump(val).inspect})"
            eval "#{p} = #{val}"
          end
        else
          Fixturized::RspecAdapter.cache={}
          consts = Object.constants
          blocks.each {|block| instance_eval(&block)}
          consts = Object.constants - Fixturized::RspecAdapter.startup_consts
          consts = consts.inject({}) {|r,const_name| r.merge({const_name => Object.const_get(const_name)})}
          #puts "writing: "+consts.inspect
          begin
          vars = instance_variable_hash.clone
          vars.to_a.each do |k,v|
            if v.is_a?(Proc)
              vars.delete k
            end
          end
          vars.delete "@_proxy"
          vars.delete "@_result"
          vars.delete "@method_name"
          vars.delete "@_backtrace"
          vars.delete "@_implementation"
          special_places = SPECIAL_PLACES.inject({}) {|r,p| r.merge(p => eval(p))}
          stubs = Fixturized::RspecAdapter.cache[:stubs]
          puts stubs.inspect
          Fixturized::FileHandler.write_fixture filename, {:database => Fixturized::DatabaseHandler.collect_db_data, :variables => vars, :constants => consts, :time => Time.now, :special_places => special_places}#, :stubs => stubs}
          rescue Exception => e
            puts e.message, e.backtrace
          end
        end
      end
  end
  def plug_in
    puts "PLUGGING IN!!!!!"
#    ::Spec::Example::ExampleMethods.extend Fixturized::RspecAdapter::ExampleGroupHierarchyExtension
#    ::Spec::Example::ExampleMethods.send :include, Fixturized::RspecAdapter::ExampleGroupHierarchyExtension
#    ::Spec::Example::ExampleGroup.send :include, Fixturized::RspecAdapter::ExampleGroupHierarchyExtension
#    ::Spec::Example.extend Fixturized::RspecAdapter::ExampleGroupHierarchyExtension
#    ::Spec::Example::ModelExampleGroup.send :include, Fixturized::RspecAdapter::ExampleGroupHierarchyExtension


    @startup_consts=Object.constants
    ::Spec::Rails::Example::ModelExampleGroup.send :include, Fixturized::RspecAdapter::ExampleGroupHierarchyExtension

    Class.class_eval do
      FORBIDDEN_METHODS.each do |method_name|
        define_method method_name do |*args|
          #raise SkipFixturizedError.new "Fixturized does not support methods like #{method_name}, please add skip_fixturized inside this block."
          Fixturized::RspecAdapter.cache[:stubs] ||= []
          Fixturized::RspecAdapter.cache[:stubs] << [self.name, method_name, args]
        end
      end
    end

  end

  def startup_consts
    @startup_consts
  end
  self.extend self
  class SkipFixturizedError < Exception
  end
end
