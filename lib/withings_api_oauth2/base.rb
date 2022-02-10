require 'withings_api_oauth2/helpers/configuration'
require 'withings_api_oauth2/helpers/utils'
require 'withings_api_oauth2/helpers/exceptions'

module WithingsAPIOAuth2
  extend Configuration

  define_setting :client_id
  define_setting :client_secret
  define_setting :redirect_uri

  define_setting :site_url,        'https://wbsapi.withings.net'
  define_setting :authorize_url,   'https://account.withings.com/oauth2_user/authorize2'
  define_setting :token_url,       'https://wbsapi.withings.net/v2/oauth2'

  define_setting :unit_system,     'en_US'
  define_setting :locale,          'en_US'
  define_setting :scope,           'user.metrics'

  define_setting :api_version,     '1'

  define_setting :snake_case_keys, false
  define_setting :symbolize_keys,  false
end
