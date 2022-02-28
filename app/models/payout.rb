class Payout < ApplicationRecord
  validates_uniqueness_of :gc_id, case_sensitive: true

  belongs_to :school_program
  belongs_to :centre, required: false
  belongs_to :user, required: false

  has_many :user_financier_subscription_instalments

  enum gc_status: [:pending, :paid, :bounced]

  #   after_commit :process_after_create, on: :create

  def process_after_create
    if self.centre_id
      base = self.centre
    else
      base = self.school_program.centres.first
    end
    items = MyGoCardless.GetPayoutItems(base, self)
    items.each do |item|
      UserFinancierSubscriptionInstalment.find_by(gocardless_id: item.links.payment).update(payout_id: self.id) rescue nil
    end
  end

  def self.sync_gc_payouts
    SchoolProgram.all.each do |school_program|
      if school_program.gocardless_general
        base = school_program.centres.first rescue nil
        if base && !base.gocardless_token.blank?
          payouts = MyGoCardless.GetPayouts(base)
          payouts.each do |payout|
            if payout.status == "paid"
              Payout.create(school_program: school_program, gc_status: payout.status, gc_id: payout.id, gc_reference: payout.reference,
                            gc_amount: (payout.amount / 100), gc_created_at: payout.created_at, gc_arrival_at: payout.arrival_date)
            end
          end
        end
      else
      end
    end
  end

  def csv_export(tag = false, user = nil)
    file = CSV.generate(converters: :all, :col_sep => ";") do |csv|
      rows = self.user_financier_subscription_instalments
      if self.centre_id
        compte_banque = self.centre.compte_banque_sage
      else
        compte_banque = self.school_program.centres.first.compte_banque_sage
      end
      if self.centre_id
        base = self.centre
      else
        base = self.school_program.centres.first
      end
      items = MyGoCardless.GetPayoutItems(base, self)

      items.each do |item|
        data = UserFinancierSubscriptionInstalment.find_by(gocardless_id: item.links.payment) rescue nil
        if data
          case data.v_type
          when "frais_inscription"
            libelle = "1er Frais de scolarite"
            type_frais = 2
          when "frais_techniques"
            libelle = "Frais annexes Techniques"
            type_frais = 3
          when "frais_scolarite"
            pos = data.user_financier_subscription.user_financier_subscription_instalments.where(v_type: :frais_scolarite).map(&:id).index(data.id)
            if (pos + 1) == 1
              libelle = "1er Prelevement sco"
            else
              libelle = (pos + 1).to_s + "eme Prelevement sco"
            end
            type_frais = 2
          end

          code = "BN"
          reference = data.generate_reference
          compte_general = data.user_financier_subscription.formation_annee.formation.centre.compte_client_sage
          compte_tiers = data.user_financier_subscription.user_financier.code_tiers
          type_ecriture = "G"
          analytique = ""
          mode_reglement = data.v_mode.humanize
          date_echeance = data.echeance.strftime("%d/%m/%Y")
          # date_import = Date.today.strftime("%d/%m/%Y")
          date_import = self.gc_arrival_at.strftime("%d/%m/%Y")

          montant = data.montant

          compte_general = LogSale.generate_compte_client_sage(data)

          if item.type == "payment_paid_out"
            debit = 0
            credit = montant
            rejet = ""

            nom_complet = I18n.transliterate(data.user_financier_subscription.user_financier.etu_nom_prenom)
            annee = data.user_financier_subscription.school_year.nom.split("/")[0]

            csv << [code, date_import, data.facture, reference, compte_general, compte_tiers, libelle, type_ecriture,
                    analytique, mode_reglement, date_echeance, debit, credit, nom_complet, annee, type_frais,
                    data.user_financier_subscription.modalite, rejet, ""]
          else
            rejet = 1
            debit = montant
            credit = 0

            nom_complet = I18n.transliterate(data.user_financier_subscription.user_financier.etu_nom_prenom)
            annee = data.user_financier_subscription.school_year.nom.split("/")[0]

            csv << [code, date_import, data.facture, reference, compte_general, compte_tiers, libelle, type_ecriture,
                    analytique, mode_reglement, date_echeance, debit, credit, nom_complet, annee, type_frais,
                    data.user_financier_subscription.modalite, rejet, ""]
          end
        end
      end
      csv << ["BN", self.gc_arrival_at.strftime("%d/%m/%Y"), self.gc_reference, "", compte_banque, "", "Virement GoCardless", "G",
              "", "", "", self.gc_amount, "", "", "", "", "", ""]
    end
    if tag
      self.update(user: user, exported: true, exported_at: DateTime.now)
    end
    return file
  end
end
