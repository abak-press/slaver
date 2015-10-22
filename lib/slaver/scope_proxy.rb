module Slaver
  class ScopeProxy
    attr_reader :klass, :config_name

    def initialize(klass, config_name)
      @klass = klass
      @config_name = config_name
    end

    def on(config_name)
      @config_name = config_name
      self
    end

    def method_missing(method, *args, &block)
      result = self
      ::ActiveRecord::Base.within(config_name) do
        result = klass.send(method, *args, &block)

        if result.is_a?(ActiveRecord::Relation)
          @klass = result
          return self
        end
      end

      result
    end
  end
end
