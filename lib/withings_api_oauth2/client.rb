require 'withings_api_oauth2/base'
require 'withings_api_oauth2/measure'

module WithingsAPIOAuth2
  class Client
    attr_accessor :api_version, :unit_system, :locale, :scope,
                  :snake_case_keys, :symbolize_keys
    attr_reader   :user_id

    def initialize(opts={})
      validate_args(opts)
      assign_attrs(opts)
      set_client
      establish_token(opts)
    end

    def auth_url
      @client.auth_code.authorize_url(redirect_uri: @redirect_uri, scope: @scope, response_type: 'code', state: 'dummystate')
    end

    def get_token(auth_code)
      @token = @client.auth_code.get_token(
        auth_code,
        action: 'requesttoken',
        redirect_uri: @redirect_uri,
        headers: auth_header
      )
      @user_id = @token.params['user_id']
      @token
    end

    def token
      @token.expired? ? refresh_token! : @token
    end

    def refresh_token!
      @token = @token.refresh!(action: 'requesttoken', headers: auth_header)
      @user_id ||= @token.params['user_id']
      @token
    end

    def auth_header
      { 'Authorization' => ('Basic ' + Base64.strict_encode64(@client_id + ':' + @client_secret)) }
    end

    def request_headers
      {
        'User-Agent' => "withings_api_oauth2-#{WithingsAPIOAuth2::VERSION} gem (#{WithingsAPIOAuth2::REPO_URL})",
        'Accept-Language' => @unit_system,
        'Accept-Locale' => @locale
      }
    end

    def get(path, opts={})
      params = opts.delete(:params) || {}
      response = token.get(("#{@api_version}/" + path), params: deep_keys_to_camel_case!(params), headers: request_headers).response
      object = MultiJson.load(response.body) unless response.status == 204
      process_keys!(object, opts)
    end

    def post(path, opts={})
      response = token.post(("#{@api_version}/" + path), body: deep_keys_to_camel_case!(opts), headers: request_headers).response
      object = MultiJson.load(response.body) unless response.status == 204
      process_keys!(object, opts)
    end

    def delete(path, opts={})
      response = token.delete(("#{@api_version}/" + path), headers: request_headers).response
      object = MultiJson.load(response.body) unless response.status == 204
      process_keys!(object, opts)
    end

    def process_keys!(object, opts={})
      deep_keys_to_snake_case!(object) if (opts[:snake_case_keys] || snake_case_keys)
      deep_symbolize_keys!(object) if (opts[:symbolize_keys] || symbolize_keys)
      return object
    end

    private

    def validate_args(opts)
      required_args = %i[client_id client_secret].freeze
      missing_args = []

      required_args.each do |arg|
        missing_args << arg if (opts[arg] || WithingsAPIOAuth2.send(arg)).nil?
      end

      return if missing_args.empty?
      raise WithingsAPIOAuth2::InvalidArgumentError,
            "Required arguments: #{missing_args.join(', ')}"
    end

    def assign_attrs(opts)
      attrs = %i[client_id client_secret redirect_uri site_url
                 authorize_url token_url unit_system locale scope
                 api_version snake_case_keys symbolize_keys].freeze

      attrs.each do |attr|
        instance_variable_set("@#{attr}", (opts[attr] || WithingsAPIOAuth2.send(attr)))
      end

      @user_id = opts[:user_id]
    end

    def set_client
      @client = OAuth2::Client.new(
        @client_id,
        @client_secret,
        site: @site_url,
        authorize_url: @authorize_url,
        token_url: @token_url,
        extract_access_token: EXTRACT_ACCESS_TOKEN
      )
    end

    EXTRACT_ACCESS_TOKEN = proc do |client, hash|
      token = hash['body'].delete('access_token')
      token && OAuth2::AccessToken.new(client, token, hash['body'])
    end

    def establish_token(opts)
      return unless opts[:access_token] || opts[:refresh_token]

      if opts[:access_token] && !opts[:user_id]
        raise WithingsAPIOAuth2::InvalidArgumentError,
              'user_id is required if using existing access token'
      end

      @token = OAuth2::AccessToken.new(
        @client,
        opts[:access_token],
        refresh_token: opts[:refresh_token],
        expires_at: opts[:expires_at]
      )

      refresh_token! if @token.token.empty?
    end
  end
end
