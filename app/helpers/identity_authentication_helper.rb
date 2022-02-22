module IdentityAuthenticationHelper
  class JsonWebKeyError < StandardError; end
  class JwtDecodeError < StandardError; end
  class InvalidTokenError < StandardError; end

  def identity_authenticate_url(state)
    params = {
      response_type: "code",
      client_id: ENV["CLIO_IDENTITY_CLIENT_ID"],
      redirect_uri: ENV["ROOT_URL"] + "identity_callback",
      scope: "openid",
      state: state
    }
    ENV["CLIO_IDENTITY_SITE_URL"] + "oauth2/auth?" + params.to_query
  end

  def identity_token_url
    ENV["CLIO_IDENTITY_SITE_URL"] + "oauth2/token"
  end

  def identity_token_body(code)
    {
      client_id: ENV["CLIO_IDENTITY_CLIENT_ID"],
      client_secret: ENV["CLIO_IDENTITY_CLIENT_SECRET"],
      grant_type: "authorization_code",
      code: code,
      redirect_uri: ENV["ROOT_URL"] + "identity_callback"
    }
  end

  def identity_state_valid?(identity_state)
    identity_state.present? && (identity_state == cookies.encrypted[:identity_state])
  end

  def get_json_web_keys
    @public_keys ||= begin
      response = HTTP.get(ENV["CLIO_IDENTITY_SITE_URL"] + ".well-known/jwks.json")

      if response.code != 200
        raise JsonWebKeyError.new(response.body.to_s)
      end

      JSON.parse(response.body)["keys"]
    end
  end

  def decode_and_validate_identity_token(identity_token)
    json_web_keys = get_json_web_keys

    decode_options = {
      algorithm: "RS256",
      iss: ENV["CLIO_IDENTITY_SITE_URL"],
      verify_iss: true,
      aud: [ENV["CLIO_IDENTITY_CLIENT_ID"]],
      verify_aud: true,
      verify_iat: true,
      jwks: {
        keys: json_web_keys.map(&:symbolize_keys)
      }
    }

    decoded_token = JWT.decode(identity_token, nil, true, decode_options)

    if identity_token_valid?(decoded_token[0])
      decoded_token
    else
      raise InvalidTokenError.new("token missing sid or has invalid azp value")
    end
  rescue JWT::DecodeError => e
    raise JwtDecodeError.new(e.message)
  end

  def identity_token_valid?(token)
    token["sid"].present? &&
      (!token["azp"].present? || token["azp"] == ENV["CLIO_IDENTITY_CLIENT_ID"])
  end

end
