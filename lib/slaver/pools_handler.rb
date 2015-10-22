module Slaver
  class PoolsHandler
    include Singleton

    def pools
      @pools ||= {}
    end

    def for_config(klass, config_name)
      @klass = klass

      initialize_pool(config_name) unless pools[config_name]

      self
    end

    private

    def initialize_pool(config_name)
      if config_name == Rails.env
        pools[config_name] = @klass.connection_pool_without_proxy
      else
        pools[config_name] = create_connection_pool(config_name)
      end
    end

    def create_connection_pool(config_name)
      config = ::ActiveRecord::Base.configurations[config_name]
      config.symbolize_keys!
      spec = ActiveRecord::Base::ConnectionSpecification.new(config, "#{config[:adapter]}_connection")

      ActiveRecord::ConnectionAdapters::ConnectionPool.new(spec)
    end
  end
end
