#encoding: utf-8
module SalesForce
  extend self

  def GetStudent(student_id)
    access_token, instance_url = self.GetAuthorization
    url = URI(instance_url + "/services/apexrest/Erp/getRecord/?id=#{student_id}")

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request["Authorization"] = "Bearer " + access_token
    response = JSON.parse(https.request(request).body)
    saved, error = self.SaveStudent(response)
    if saved
      self.StudentSaved(response["ID18"])
      return true
    else
      self.StudentNotSaved(response["ID18"], error)
      return false
    end
  end

  def SaveStudent(data)
    #data["ProductCode"] = "PIAANIM1"
    ## TO DELETE
    centre = School.find_by(nom: data["School"]).centres.find_by_ville(data["Campus"]) rescue nil
    if centre.nil?
      Rollbar.warning("CAND FROM SF - CAMPUS NOT FOUND")
      return false, "CAMPUS NOT FOUND"
    end
    modalite = ["1", "3", "10", "De la totalité", "En 3 fois", "En 10 mensualités"]
    if data["FinancialRepresentativeMail"].nil?
      Rollbar.warning("CAND FROM SF - EMAIL RF BLANK")
      return false, "EMAIL RF BLANK"
    elsif !modalite.include?(data["DirectDebitMode"])
      Rollbar.warning("CAND FROM SF - MODALITE NOT FOUND")
      return false, "MODALITE NOT FOUND"
    elsif !Formation.where(code: data["ProductCode"]).any?
      Rollbar.warning("CAND FROM SF - FORMATION NOT FOUND")
      return false, "FORMATION NOT FOUND"
    end
    password = Devise.friendly_token.first(10)

    user_financier = UserFinancier.find_by(email_etu: data["StudentEmail"]) rescue nil
    if user_financier
      if user_financier.user_financier_subscriptions.joins(:school_year).where(school_years: { nom: data["SessionSchoolYear"] }).any?
        Rollbar.warning("CAND FROM SF - APPLICATION ALREADY EXIST")
        return false, "APPLICATION ALREADY EXIST"
      else
        user = user_financier.user
      end
    else
      user = User.new(email: data["FinancialRepresentativeMail"], role: :user, password: password)
    end
    user.build_user_financier if user.user_financier.nil?
    user.user_financier.centre = centre
    user.user_financier.etu_id_sf = data["ID18"]
    user.user_financier.nom = data["FinancialRepresentativeLastName"]
    user.user_financier.prenom = data["FinancialRepresentativeFirstName"]
    user.user_financier.adresse = data["FinancialRepresentativeHomeStreet"]
    user.user_financier.ville = data["FinancialRepresentativeHomeCity"]
    user.user_financier.code_postal = data["FinancialRepresentativeHomeZipCode"]
    user.user_financier.pays = data["FinancialRepresentativeHomeCountry"]
    user.user_financier.tel = data["FinancialRepresentativeMobilePhone"]
    user.user_financier.etu_nom = data["LastName"]
    user.user_financier.etu_prenom = data["FirstName"]
    user.user_financier.etu_email = data["StudentEmail"]
    user.user_financier.etu_tel = data["MobilePhone"]
    user.user_financier.etu_adresse = data["MailingStreet"]
    user.user_financier.etu_ville = data["MailingCity"]
    user.user_financier.etu_code_postal = data["MailingPostalCode"]
    user.user_financier.etu_pays = nil
    user.user_financier.etu_famille_ionis = data["RelativeInIonisSchool"]
    user.user_financier.etu_famille_ionis_nom = data["LastnameBrotherSisterStudentIonis"]
    user.user_financier.etu_famille_ionis_prenom = data["FirstnameBrotherSisterStudentIonis"]

    if user.save
      user.user_financier.build_user_financier_rib if user.user_financier.user_financier_rib.nil?
      user.user_financier.user_financier_rib.iban = data["IBAN"]
      user.user_financier.user_financier_rib.bic = data["BIC"]
      user.user_financier.user_financier_rib.rum = data["RUM"]
      user.save

      if user.user_financier.api_create_subscription_inscription(centre, data["ProductCode"], data["SessionSchoolYear"], data["DirectDebitMode"], data["RegistrationPaymentMode"], data["RegistrationPaymentNoneComment"], data["ScholarFeesPaymentMode"], data["ScholarFeesPaymentNoneComment"], data["RegistrationPaymentDate"])
        UserMailer.send_credentials(user, password).deliver_later
        return true
      else
        user.destroy
        Rollbar.warning("CAND FROM SF - SOUSCRIPTION FAILED")
        return false, "SOUSCRIPTION FAILED"
      end
    else
      Rollbar.warning("CAND FROM SF - APPLICATION ALREADY EXIST")
      return false, "APPLICATION ALREADY EXIST"
    end
  end

  def StudentSaved(student_id)
    access_token, instance_url = self.GetAuthorization
    url = URI(instance_url + "/services/apexrest/Erp/recordSaved/?id=#{student_id}")
    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true
    request = Net::HTTP::Post.new(url)
    request["Authorization"] = "Bearer " + access_token
    request["content-type"] = "application/json"
    request.body = { success: true }.to_json
    https.request(request)
  end

  def StudentNotSaved(student_id, error)
    access_token, instance_url = self.GetAuthorization
    url = URI(instance_url + "/services/apexrest/Erp/recordSaved/?id=#{student_id}")
    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true
    request = Net::HTTP::Post.new(url)
    request["Authorization"] = "Bearer " + access_token
    request["content-type"] = "application/json"
    request.body = { success: false, error: error }.to_json
    https.request(request)
  end

  def GetAuthorization
    url = URI(SF_URL_AUTH + "?username=#{SF_USERNAME}&password=#{SF_PASSWORD + SF_TOKEN}&client_id=#{SF_CLIENT_ID}&client_secret=#{SF_CLIENT_SECRET}&grant_type=password")
    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true
    request = Net::HTTP::Post.new(url)
    response = JSON.parse(https.request(request).body)
    return response["access_token"], response["instance_url"]
  end
end
