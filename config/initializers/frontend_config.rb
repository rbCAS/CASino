require 'casino_core/settings'

# default config
config = {
  sso_name: 'CASino',
  footer_text: 'Powered by <a href="http://rbcas.com/">CASino</a>'
}

CASinoCore::Settings.add_defaults :frontend, config
