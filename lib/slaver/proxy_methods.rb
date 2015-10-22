module Slaver
  module ProxyMethods
    extend ActiveSupport::Concern

    included do
      class << self
        alias_method_chain :connection, :proxy
        alias_method_chain :connection_pool, :proxy
        alias_method_chain :clear_all_connections!, :proxy
        alias_method_chain :clear_active_connections!, :proxy
        alias_method_chain :connected?, :proxy
      end
    end

    module ClassMethods
      def connection_pool_with_proxy
        if config = current_config
          connection_proxy.init(self, config).connection_pool
        else
          connection_pool_without_proxy
        end
      end

      def connection_with_proxy
        if config = current_config
          connection_proxy.init(self, config)
        else
          (connection_pool && connection_pool.connection)
        end
      end

      def clear_active_connections_with_proxy!
        if config = current_config
          connection_proxy.init(self, config).clear_active_connections!
        else
          clear_active_connections_without_proxy!
        end
      end

      def clear_all_connections_with_proxy!
        if config = current_config
          connection_proxy.init(self, config).clear_all_connections!
        else
          clear_all_connections_without_proxy!
        end
      end

      def connected_with_proxy?
        if config = current_config
          connection_proxy.init(self, config).connected?
        else
          connected_without_proxy?
        end
      end

      def connection_proxy
        ::ActiveRecord::Base.class_variable_defined?(:@@connection_proxy) &&
          ::ActiveRecord::Base.class_variable_get(:@@connection_proxy) ||
          ::ActiveRecord::Base.class_variable_set(:@@connection_proxy, Proxy.new)
      end
    end
  end
end
