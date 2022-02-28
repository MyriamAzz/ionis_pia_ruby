module Gocardless
  class API < Grape::API
    version "v1", using: :header, vendor: "gocardless"
    format :json
    prefix :api

    resource :gocardless do
      #   http_digest({ :realm => "PIA EARTSUP", :opaque => "app secret" }) do |username|
      #     { SF_API_AUTH_USER => SF_API_AUTH_PASSWORD }[username]
      #   end

      desc "Webhook post update Go Cardless"
      params do
      end
      post "webhook" do
        webhook_endpoint_secret = GC_WEBHOOK_ENDPOINT_SECRET
        request_body = request.body.tap(&:rewind).read
        signature_header = request.headers["Webhook-Signature"]
        begin
          events = GoCardlessPro::Webhook.parse(request_body: request_body,
                                                signature_header: signature_header,
                                                webhook_endpoint_secret: webhook_endpoint_secret)

          events.each do |event|
            case event.resource_type
            when "payments"
              UserFinancierSubscriptionInstalmentEvent.LogEventGoCardless(event)
            when "mandates"
              UserFinancierRibEvent.LogEventGoCardless(event)
            when "payer_authorisations"
              UserFinancierRibPending.LogEventGoCardless(event)
            else
            end
          end
          status 200
        rescue GoCardlessPro::Webhook::InvalidSignatureError
          status 498
        end
      end
    end
  end
end
