module Slaver
  class Proxy
    include Singleton

    attr_reader :connection_pool, :klass

    def for_config(klass, config_name)
      @klass = klass
      @connection_pool = klass.pools[config_name]

      self
    end

    def connected?
      connection_pool.connected?
    end

    def clear_all_connections!
      connection_pool.disconnect!
    end

    def clear_active_connections!
      connection_pool.release_connection
    end

    def safe_connection
      connection_pool.automatic_reconnect = true
      if !connection_pool.connected? && klass.connection_without_proxy.query_cache_enabled
        connection_pool.connection.enable_query_cache!
      end
      connection_pool.connection
    end

    def method_missing(method, *args, &block)
      safe_connection.send(method, *args, &block)
    end
  end
end
