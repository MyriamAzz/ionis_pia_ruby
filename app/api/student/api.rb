module Student
  class API < Grape::API
    version "v1", using: :header, vendor: "students"
    format :json
    prefix :api

    resource :students do
      #   http_digest({ :realm => "PIA EARTSUP", :opaque => "app secret" }) do |username|
      #     { SF_API_AUTH_USER => SF_API_AUTH_PASSWORD }[username]
      #   end
      helpers do
        def authentification
          if !request.headers["Authorization"].nil?
            @school = School.find_by(grape_api_token: request.headers["Authorization"]) rescue nil
            if !@school
              error!("Unauthorized. Invalid or expired token.", 401)
            end
          else
            error!("Unauthorized. Invalid or expired token.", 401)
          end
        end
      end

      desc "Get array third party code"
      params do
      end
      get "third_party_codes" do
        authentification
        return @school.user_financiers.select(:etu_email, :code_tiers)
        status 200
      end
    end
  end
end
