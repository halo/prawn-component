require 'prawn/component'

require 'sandbox/components/button_component'
require 'sandbox/components/hello_world_component'
require 'sandbox/components/article_component'
require 'sandbox/components/blog_component'
require 'sandbox/components/box_component'
require 'sandbox/components/street_component'

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.raise_errors_for_deprecations!
  config.color = true
  config.order = :random if ENV['CI']
  config.fail_fast = true
end
