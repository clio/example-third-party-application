require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ExampleThirdPartyIntegrationApp
  class Application < Rails::Application
    config.before_configuration do
      env_file = File.join(Rails.root, "config", "local_env.yml")
      YAML.safe_load(File.open(env_file)).each do |key, value|
        ENV[key.to_s] = value
      end if File.exists?(env_file)
    end
  end
end
