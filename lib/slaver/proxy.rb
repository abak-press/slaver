module Slaver
  class Proxy
    attr_accessor :klass
    attr_reader :connection_pool

    def init(klass, config)
      @klass = klass
      @connection_pool = klass.pools[config]

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
      klass.clear_config if should_clean?(method)
      safe_connection.send(method, *args, &block)
    end

    private

    def should_clean?(method)
      method.to_s =~ /insert|select|execute/ && !klass.within_block?
    end
  end
end
