module Slaver
  class Railtie < Rails::Railtie
    initializer "slaver.hack_ar" do |app|
      ActiveSupport.on_load(:active_record) do
        include Connection
      end
    end
  end
end
