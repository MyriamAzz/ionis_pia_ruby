module MyGoCardless
  extend self

  def InitClient(centre)
    client = GoCardlessPro::Client.new(access_token: centre.gocardless_token, environment: GC_ENVIRONMENT)
  end

  # def GetCustomers
  #   client = self.InitClient
  #   client.customers.list.records.each { |customer| puts customer.inspect }
  # end

  # def GetCustomer
  #   client = self.InitClient
  #   id = "CU000E2KBDP9DN"
  #   begin
  #     customer = client.customers.get(id)
  #     p customer
  #   rescue
  #     p "User not found"
  #   end
  # end

  def GetCustomer(customer)
    if !customer.nil?
      begin
        client = self.InitClient
        return client.customers.get(customer)
      rescue
        return false
      end
    else
      return false
    end
  end

  def GetBankAccount(bank_account)
    if !bank_account.nil?
      begin
        client = self.InitClient
        return client.customer_bank_accounts.get(bank_account)
      rescue
        return false
      end
    else
      return false
    end
  end

  def CreateCustomer(user)
    ## IF NO GOCARDLESS ID
    if !user.gocardless_customer_id
      client = self.InitClient(user.centre)
      begin
        customer = client.customers.create(
          params: {
            email: user.user.email,
            given_name: user.prenom,
            family_name: user.nom,
            country_code: "FR",
            metadata: { Etudiant: user.etu_nom + " " + user.etu_prenom + " (" + user.etu_email + ")", Campus: user.centre.nom },
          },
        )
        user.update(gocardless_customer_id: customer.id)
        return true
      rescue
        return false
      end
    else
      return true
    end
  end

  def UpdateCustomer(user)
    ## IF NO GOCARDLESS ID
    if user.gocardless_customer_id
      client = self.InitClient(user.centre)
      begin
        customer = client.customers.update(
          user.gocardless_customer_id,
          params: {
            email: user.user.email,
            given_name: user.prenom,
            family_name: user.nom,
            country_code: "FR",
            metadata: { Etudiant: user.etu_nom + " " + user.etu_prenom + " (" + user.etu_email + ")", Campus: user.centre.nom },
          },
        )
        user.update(gocardless_customer_id: customer.id)
        return true
      rescue
        return false
      end
    else
      return true
    end
  end

  def CreateCustomerBankAccount(user)
    if user.gocardless_customer_id && IBANTools::IBAN.valid?(user.user_financier_rib.iban)
      if user.user_financier_rib.gocardless_account_id
        return true
      else
        client = self.InitClient(user.centre)
        begin
          account = client.customer_bank_accounts.create(
            params: {
              account_holder_name: user.nom + " " + user.prenom,
              iban: user.user_financier_rib.iban,
              links: {
                customer: user.gocardless_customer_id,
              },
            },
          )
          user.user_financier_rib.update(gocardless_account_id: account.id)
          return true
        rescue
          return false
        end
      end
    else
      return false
    end
  end

  def UpdateCustomerBankAccount(user)
    if user.gocardless_customer_id && IBANTools::IBAN.valid?(user.user_financier_rib.iban)
      client = self.InitClient(user.centre)
      begin
        account = client.customer_bank_accounts.create(
          params: {
            account_holder_name: user.nom + " " + user.prenom,
            iban: user.user_financier_rib.iban,
            links: {
              customer: user.gocardless_customer_id,
            },
          },
        )
        user.user_financier_rib.update(gocardless_account_id: account.id)
        return true
      rescue
        return false
      end
    else
      return false
    end
  end

  def CreateCustomerMandate(user)
    if user.user_financier_rib.gocardless_account_id
      ## WebHook retour statut Mandat
      # Par defaut en attente de soumission
      if user.user_financier_rib.gocardless_mandate_id
        return true
      else
        client = self.InitClient(user.centre)
        begin
          mandate = client.mandates.create(
            params: {
              scheme: "sepa_core",
              reference: user.user_financier_rib.rum,
              links: {
                customer_bank_account: user.user_financier_rib.gocardless_account_id,
              },
            },
          )
          user.user_financier_rib.update(gocardless_mandate_id: mandate.id)
          return true
        rescue
          return false
        end
      end
    else
      return false
    end
  end

  def UpdateCustomerMandate(user)
    if user.user_financier_rib.gocardless_account_id
      client = self.InitClient(user.centre)
      begin
        mandate = client.mandates.create(
          params: {
            scheme: "sepa_core",
            links: {
              customer_bank_account: user.user_financier_rib.gocardless_account_id,
            },
          },
        )
        user.user_financier_rib.update(gocardless_mandate_id: mandate.id)
        return true
      rescue
        return false
      end
    else
      return false
    end
  end

  def UpdateCustomerAccountAndMandate(user)
    if user.gocardless_customer_id && IBANTools::IBAN.valid?(user.user_financier_rib.iban)
      client = self.InitClient(user.centre)
      begin
        self.DisableCustomerAccount(user)
        account = client.customer_bank_accounts.create(
          params: {
            account_holder_name: user.nom + " " + user.prenom,
            iban: user.user_financier_rib.iban,
            links: {
              customer: user.gocardless_customer_id,
            },
          },
        )
        user.user_financier_rib.update(gocardless_account_id: account.id)
        mandate = client.mandates.create(
          params: {
            scheme: "sepa_core",
            reference: user.user_financier_rib.rum,
            links: {
              customer_bank_account: account.id,
            },
          },
        )
        user.user_financier_rib.update(gocardless_mandate_id: mandate.id)
        return true
      rescue
        return false
      end
    else
      return true
    end
  end

  def DisableCustomerAccount(user)
    if user.user_financier_rib.gocardless_account_id
      client = self.InitClient(user.centre)
      begin
        client.customer_bank_accounts.disable(user.user_financier_rib.gocardless_account_id)
        user.user_financier_rib.update(gocardless_account_id: nil, gocardless_mandate_id: nil)
        return true
      rescue
        return false
      end
    else
      return false
    end
  end

  def CreateOneTimePayment(instalment)
    if instalment.user_financier_subscription.user_financier.user_financier_rib.gocardless_account_id && instalment.user_financier_subscription.user_financier.user_financier_rib.gocardless_mandate_id
      client = self.InitClient(instalment.user_financier_subscription.user_financier.centre)
      begin
        payment = client.payments.create(
          params: {
            amount: instalment.montant.to_i * 100,
            currency: "EUR",
            description: instalment.v_type_humanized,
            links: {
              mandate: instalment.user_financier_subscription.user_financier.user_financier_rib.gocardless_mandate_id,
            },
            metadata: {
              invoice_number: instalment.facture,
            },
          },
          headers: {
            "Idempotency-Key" => instalment.facture,
          },
        )
        instalment.update(statut: :wip, gocardless_id: payment.id)
        return true
      rescue
        return false
      end
    else
      return false
    end
  end

  def RetryPayment(instalment, date)
    if instalment.user_financier_subscription.user_financier.user_financier_rib.gocardless_account_id && instalment.user_financier_subscription.user_financier.user_financier_rib.gocardless_mandate_id
      client = self.InitClient(instalment.user_financier_subscription.user_financier.centre)
      begin
        client.payments.retry(
          instalment.gocardless_id,
          params: {
            charge_date: date.to_date.strftime("%Y-%m-%d"),
          },
        )
        instalment.update(statut: :wip)
        return true
      rescue
        return false
      end
    else
      return false
    end
  end

  def CheckBankDetails(iban)
    client = self.InitClient(iban.user_financier.centre)
    begin
      result = client.bank_details_lookups.create(
        params: {
          iban: iban.iban,
        },
      )
      return true
    rescue
      return false
    end
  end

  def GetPayouts(centre, limit = 500)
    client = self.InitClient(centre)
    begin
      final = []
      result = client.payouts.list
      final = final + result.records.to_a
      while result.after
        result = client.payouts.list(params: { limit: limit, after: result.after })
        final = final + result.records.to_a
      end
      return final
    rescue
      return false
    end
  end

  def GetPayoutItems(centre, payout, limit = 500)
    client = self.InitClient(centre)
    begin
      final = []
      result = client.payout_items.list(params: { payout: payout.gc_id, limit: limit })
      final = final + result.records.to_a
      while result.after
        result = client.payout_items.list(params: { payout: payout.gc_id, limit: limit, after: result.after })
        final = final + result.records.to_a
      end
      return final
    rescue
      return false
    end
  end
end
