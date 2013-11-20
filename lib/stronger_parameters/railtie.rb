require 'rails/railtie'

module StrongParameters
  class Railtie < ::Rails::Railtie
    initializer "stronger_parameters.config", :before => "action_controller.set_configs" do |app|
      ActionController::Parameters.action_on_invalid_parameters = app.config.action_controller.delete(:action_on_invalid_parameters) do
        (Rails.env.test? || Rails.env.development?) ? :log : false
      end
    end
  end
end
