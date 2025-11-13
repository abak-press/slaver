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

      mirror_query_cache_state(connection_pool.connection)
    end

    def mirror_query_cache_state(connection)
      master = klass.connection_without_proxy

      if master.query_cache_enabled
        connection.enable_query_cache!
      else
        connection.clear_query_cache
        connection.disable_query_cache!
      end

      connection
    end

    def method_missing(method, *args, &block)
      safe_connection.send(method, *args, &block)
    end

    def respond_to_missing?(method, include_private = false)
      safe_connection.respond_to?(method, include_private) || super
    end
  end
end
