SecureHeaders::Configuration.default do |config|
  config.csp = {
    default_src: %w('none'), # nothing allowed by default
    script_src: %w('self'),
    connect_src: %w('self'),
    img_src: %w('self' data:),
    font_src: %w('self' data:),
    base_uri: %w('self'),
    style_src: %w('unsafe-inline' 'self'),
    form_action: %w('self'),
    frame_ancestors: %w(*.app.clio.com app.myclio.ca:3000),
  }
end