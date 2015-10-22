module Slaver
  class ConfigHandler
    include Singleton

    attr_reader :block, :saved_block, :saved_config, :current_config

    def run_with(klass, config_name, pools_handler)
      config_name = prepare(config_name)

      pools_handler.for_config(klass, config_name)

      with_config(config_name) { yield }
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

    def prepare(config_name)
      config_name = config_name.to_s

      return config_name if ::ActiveRecord::Base.configurations.key?(config_name)

      config_name = "#{Rails.env}_#{config_name}"

      unless ::ActiveRecord::Base.configurations.key?(config_name)
        if Rails.env.production?
          raise ArgumentError, "Can't find #{config_name} on database configurations"
        else
          config_name = Rails.env
        end
      end

      config_name
    end
  end
end
