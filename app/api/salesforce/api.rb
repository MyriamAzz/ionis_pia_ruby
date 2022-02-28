module Salesforce
  class API < Grape::API
    version "v1", using: :header, vendor: "salesforce"
    format :json
    prefix :api

    resource :salesforce do
      http_digest({ :realm => "PIAEARTSUP" }) do |username|
        { SF_API_AUTH_USER => SF_API_AUTH_PASSWORD }[username]
      end

      desc "Put new student from SF"
      params do
        requires :id, type: String, desc: "ID"
      end
      put "new_student/:id" do
        #SalesForce.GetStudent(params[:id])
        SalesforceNewStudentWorker.perform_async(params[:id])
        return {}
      end
    end
  end
end
