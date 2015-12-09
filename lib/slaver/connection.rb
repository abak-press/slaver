module Slaver
  module Connection
    extend ActiveSupport::Concern

    included do
      include ProxyMethods

      class << self
        delegate :current_config, to: :config_handler
        delegate :pools, to: :pools_handler
      end
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
        ScopeProxy.new(self, config_name)
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
      #
      #   It is also possible to nest database connection code
      #
      #   SomeModel.within :slave do
      #     do some computations here
      #     SomeModel.within :slave2 do
      #       # some other computations go here
      #     end
      #   end
      #
      # Returns noting
      def within(config_name)
        config_handler.run_with(self, config_name, pools_handler) { yield }
      end

      # Public: Permanent change of connection for AR model
      #
      # config_name - String or Symbol, name of config_section
      #
      # Examples
      #
      #   SomeModel.switch_class :other
      #
      #   SomeModel.on(:test).connection - will return connection to other!!
      #
      #   SomeModel.switch_class :other, true
      #
      # Returns ConnectionPool
      def slaver_establish_connection(config_name)
        @ignore_slaver = true
        establish_connection config_name
      end

      private

      def config_handler
        ConfigHandler.instance
      end

      def pools_handler
        PoolsHandler.instance
      end
    end
  end
end
