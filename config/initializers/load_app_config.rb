#Hvyhorse::Application.config.custom = YAML.load_file(Rails.root.join('config', 'app_config.yml'))[Rails.env].with_indifferent_access
APP_CONFIG = YAML.load_file(Rails.root.join('config', 'app_config.yml'))[Rails.env].with_indifferent_access
