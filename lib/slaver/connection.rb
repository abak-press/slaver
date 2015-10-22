module Slaver
  module Connection
    extend ActiveSupport::Concern

    included do
      include ProxyMethods
    end

    module ClassMethods
      # Public: Change database connection for next query
      # WARNING: It'll change current DB connection until
      # insert, select or execute methods call
      #
      # config_name  - String or Symbol, name of config_section
      #
      # NOTE:
      #  if config was not found:
      #  1) On production
      #    throws ArgumentError
      #  2) Uses default configuration for current environment
      #
      # Exception safety:
      #  throws ArgumentError if no configuration was found
      #
      # Examples
      #
      # SomeModel.on(:slave).create(...)
      # SomeModel.on(:slave).where(...).first
      #
      # It also can be chained with other 'on' methods
      # SomeModel.on(:slave).on(:other).find_by(...)
      #
      # Returns self
      def on(config_name)
        @saved_config ||= @current_config
        @saved_block ||= @block
        @block = false

        @current_config = prepare(config_name)

        initialize_pool(@current_config) unless pools[@current_config]

        self
      end

      # Public: Changes model's connection to database temporarily to execute block.
      #
      # config_name - String or Symbol, name of config_section
      #
      # NOTE:
      #  if config was not found:
      #  1) On production
      #    throws ArgumentError
      #  2) Uses default configuration for current environment
      #
      # Exception safety:
      #  throws ArgumentError if no configuration was found
      #
      # Examples
      #
      #   SomeModel.within :test_slave do
      #     # do some computations here
      #   end
      #   => will execute given block with different db_connection
      #
      #   It is also possible to nest database connection code
      #
      #   SomeModel.within :slave do
      #     do some computations here
      #     SomeModel.within :slave2 do
      #       # some other computations go here
      #     end
      #   end
      #   => will execute given block with different db_connection
      #
      # Returns noting
      def within(config_name)
        config_name = prepare(config_name)

        initialize_pool(config_name) unless pools[config_name]

        with_config(config_name) do
          keep_block do
            yield
          end
        end
      end

      def clear_config
        @block = @saved_block if @saved_block
        @saved_block = nil
        @current_config = @block && @saved_config
        @saved_config = nil
      end

      def pools
        ((self == ::ActiveRecord::Base) && (@pools ||= {})) || ::ActiveRecord::Base.pools
      end

      def current_config
        @current_config || ((self != ::ActiveRecord::Base) && ::ActiveRecord::Base.current_config)
      end

      def within_block?
        !!@block
      end

      private

      def with_config(config_name)
        last_config = @current_config
        @current_config = config_name

        begin
          yield
        ensure
          @current_config = last_config
        end
      end

      def keep_block
        last_block = @block
        @block = true

        begin
          yield
        ensure
          @block = last_block
        end
      end

      def initialize_pool(config_name)
        if config_name == default_config
          pools[config_name] = connection_pool_without_proxy
        else
          pools[config_name] = create_connection_pool(config_name)
        end
      end

      def prepare(config_name)
        config_name = config_name.to_s

        return config_name if ::ActiveRecord::Base.configurations[config_name].present?

        config_name = "#{Rails.env}_#{config_name}"

        if (::ActiveRecord::Base.configurations[config_name]).blank?
          if Rails.env.production?
            raise ArgumentError, "Can't find #{config_name} on database configurations"
          else
            config_name = default_config
          end
        end

        config_name
      end

      def default_config
        Rails.env
      end

      def create_connection_pool(config_name)
        config = ::ActiveRecord::Base.configurations[config_name]
        config.symbolize_keys!
        arg = ActiveRecord::Base::ConnectionSpecification.new(config, "#{config[:adapter]}_connection")

        ActiveRecord::ConnectionAdapters::ConnectionPool.new(arg)
      end
    end
  end
end
