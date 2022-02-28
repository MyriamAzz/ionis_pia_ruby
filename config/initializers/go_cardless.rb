GC_ACCESS_TOKEN = Rails.application.credentials.gocardless[:token]
GC_WEBHOOK_ENDPOINT_SECRET = Rails.application.credentials.gocardless[:endpoint_secret]
GC_PAYER_AUTH_PUBLIC_TOKEN = Rails.application.credentials.gocardless[:payer_authorisation_public_token]

if Rails.application.credentials.gocardless[:environment] == "nil"
  GC_ENVIRONMENT = nil
else
  GC_ENVIRONMENT = Rails.application.credentials.gocardless[:environment]
end
