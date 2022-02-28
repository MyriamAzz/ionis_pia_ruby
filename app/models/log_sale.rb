class LogSale < ApplicationRecord
  require "csv"
  belongs_to :user_financier_subscription
  belongs_to :user_financier_subscription_instalment, required: false
  belongs_to :user_financier_subscription_credit, optional: true

  def self.log_inscription(instalment)
    log = instalment.log_sales.build
    reference = self.generate_reference(instalment)
    compte_general = self.generate_compte_client_sage(instalment)
    libelle = "1er Frais de scolarite"
    type_ecriture = "G"
    analytique = instalment.user_financier_subscription.formation_annee.formation.centre.code_sage
    debit = instalment.montant
    credit = 0
    mode_reglement = instalment.v_mode.humanize
    nom_complet = instalment.user_financier_subscription.user_financier.etu_nom_prenom
    annee = instalment.user_financier_subscription.school_year.nom.split("/")[0]
    date_import = LogSale.set_date_import(annee)
    type_frais = 2

    log.assign_attributes(user_financier_subscription_id: instalment.user_financier_subscription_id, code_journal: "VT3", date_import: date_import, numero_facture: instalment.facture,
                          reference: reference, compte_general: compte_general,
                          compte_tiers: instalment.user_financier_subscription.user_financier.code_tiers, libelle: libelle,
                          type_ecriture: type_ecriture, analytique: "", mode_reglement: mode_reglement,
                          date_echeance: instalment.echeance, debit: debit, credit: credit, nom_complet: nom_complet,
                          annee: annee, type_frais: type_frais, modalite: instalment.user_financier_subscription.modalite)
    log.save

    log = instalment.log_sales.build
    compte_general = instalment.user_financier_subscription.formation_annee.formation.compte_produit_sage
    debit = 0
    credit = instalment.montant
    mode_reglement = ""
    log.assign_attributes(user_financier_subscription_id: instalment.user_financier_subscription_id, code_journal: "VT3", date_import: date_import, numero_facture: instalment.facture,
                          reference: reference, compte_general: compte_general,
                          compte_tiers: "", libelle: libelle,
                          type_ecriture: type_ecriture, analytique: "", mode_reglement: mode_reglement,
                          date_echeance: "", debit: debit, credit: credit, nom_complet: nom_complet,
                          annee: annee, type_frais: type_frais, modalite: instalment.user_financier_subscription.modalite)
    log.save

    log = instalment.log_sales.build
    type_ecriture = "A"
    debit = 0
    credit = instalment.montant
    log.assign_attributes(user_financier_subscription_id: instalment.user_financier_subscription_id, code_journal: "VT3", date_import: date_import, numero_facture: instalment.facture,
                          reference: reference, compte_general: compte_general,
                          compte_tiers: "", libelle: libelle,
                          type_ecriture: type_ecriture, analytique: analytique, mode_reglement: mode_reglement,
                          date_echeance: "", debit: debit, credit: credit, nom_complet: nom_complet,
                          annee: annee, type_frais: type_frais, modalite: instalment.user_financier_subscription.modalite)
    log.save
  end

  def self.log_techniques(instalment)
    log = instalment.log_sales.build
    reference = self.generate_reference(instalment)
    compte_general = self.generate_compte_client_sage(instalment)
    libelle = "Frais annexes Techniques"
    type_ecriture = "G"
    analytique = ""
    debit = instalment.montant
    credit = 0
    mode_reglement = instalment.v_mode.humanize
    nom_complet = instalment.user_financier_subscription.user_financier.etu_nom_prenom
    annee = instalment.user_financier_subscription.school_year.nom.split("/")[0]
    date_import = LogSale.set_date_import(annee)
    type_frais = 3

    log.assign_attributes(user_financier_subscription_id: instalment.user_financier_subscription_id, code_journal: "VT3", date_import: date_import, numero_facture: instalment.facture,
                          reference: reference, compte_general: compte_general,
                          compte_tiers: instalment.user_financier_subscription.user_financier.code_tiers, libelle: libelle,
                          type_ecriture: type_ecriture, analytique: analytique, mode_reglement: mode_reglement,
                          date_echeance: instalment.echeance, debit: debit, credit: credit, nom_complet: nom_complet,
                          annee: annee, type_frais: type_frais, modalite: instalment.user_financier_subscription.modalite)
    log.save

    log = instalment.log_sales.build
    compte_general = instalment.user_financier_subscription.formation_annee.formation.compte_produit_sage
    debit = 0
    credit = instalment.montant
    mode_reglement = ""
    log.assign_attributes(user_financier_subscription_id: instalment.user_financier_subscription_id, code_journal: "VT3", date_import: date_import, numero_facture: instalment.facture,
                          reference: reference, compte_general: compte_general,
                          compte_tiers: "", libelle: libelle,
                          type_ecriture: type_ecriture, analytique: analytique, mode_reglement: mode_reglement,
                          date_echeance: "", debit: debit, credit: credit, nom_complet: nom_complet,
                          annee: annee, type_frais: type_frais, modalite: instalment.user_financier_subscription.modalite)
    log.save

    log = instalment.log_sales.build
    type_ecriture = "A"
    analytique = instalment.user_financier_subscription.formation_annee.formation.centre.code_sage
    debit = 0
    credit = instalment.montant
    log.assign_attributes(user_financier_subscription_id: instalment.user_financier_subscription_id, code_journal: "VT3", date_import: date_import, numero_facture: instalment.facture,
                          reference: reference, compte_general: compte_general,
                          compte_tiers: "", libelle: libelle,
                          type_ecriture: type_ecriture, analytique: analytique, mode_reglement: mode_reglement,
                          date_echeance: "", debit: debit, credit: credit, nom_complet: nom_complet,
                          annee: annee, type_frais: type_frais, modalite: instalment.user_financier_subscription.modalite)
    log.save
  end

  def self.log_scolarite(instalment)
    pos = instalment.user_financier_subscription.user_financier_subscription_instalments.where(v_type: :frais_scolarite).map(&:id).index(instalment.id)
    log = instalment.log_sales.build
    reference = self.generate_reference(instalment)
    compte_general = self.generate_compte_client_sage(instalment)
    if (pos + 1) == 1
      libelle = "1er Prelevement sco"
    else
      libelle = (pos + 1).to_s + "eme Prelevement sco"
    end
    if instalment.montant_initial.nil?
      montant = instalment.montant
    else
      montant = instalment.montant_initial
    end
    type_ecriture = "G"
    analytique = ""
    debit = montant
    credit = 0
    mode_reglement = instalment.v_mode.humanize
    nom_complet = instalment.user_financier_subscription.user_financier.etu_nom_prenom
    annee = instalment.user_financier_subscription.school_year.nom.split("/")[0]
    date_import = LogSale.set_date_import(annee)
    type_frais = 2

    log.assign_attributes(user_financier_subscription_id: instalment.user_financier_subscription_id, code_journal: "VT3", date_import: date_import, numero_facture: instalment.facture,
                          reference: reference, compte_general: compte_general,
                          compte_tiers: instalment.user_financier_subscription.user_financier.code_tiers, libelle: libelle,
                          type_ecriture: type_ecriture, analytique: analytique, mode_reglement: mode_reglement,
                          date_echeance: instalment.echeance, debit: debit, credit: credit, nom_complet: nom_complet,
                          annee: annee, type_frais: type_frais, modalite: instalment.user_financier_subscription.modalite)
    log.save

    log = instalment.log_sales.build
    compte_general = instalment.user_financier_subscription.formation_annee.formation.compte_produit_sage
    debit = 0
    credit = montant
    mode_reglement = ""
    log.assign_attributes(user_financier_subscription_id: instalment.user_financier_subscription_id, code_journal: "VT3", date_import: date_import, numero_facture: instalment.facture,
                          reference: reference, compte_general: compte_general,
                          compte_tiers: "", libelle: libelle,
                          type_ecriture: type_ecriture, analytique: analytique, mode_reglement: mode_reglement,
                          date_echeance: "", debit: debit, credit: credit, nom_complet: nom_complet,
                          annee: annee, type_frais: type_frais, modalite: instalment.user_financier_subscription.modalite)
    log.save

    log = instalment.log_sales.build
    type_ecriture = "A"
    analytique = instalment.user_financier_subscription.formation_annee.formation.centre.code_sage
    log.assign_attributes(user_financier_subscription_id: instalment.user_financier_subscription_id, code_journal: "VT3", date_import: date_import, numero_facture: instalment.facture,
                          reference: reference, compte_general: compte_general,
                          compte_tiers: "", libelle: libelle,
                          type_ecriture: type_ecriture, analytique: analytique, mode_reglement: mode_reglement,
                          date_echeance: "", debit: debit, credit: credit, nom_complet: nom_complet,
                          annee: annee, type_frais: type_frais, modalite: instalment.user_financier_subscription.modalite)
    log.save
  end

  def self.log_scolarite_canceled(instalment)
    pos = instalment.user_financier_subscription.user_financier_subscription_instalments.where(v_type: :frais_scolarite, statut: [:inactive, :waiting]).map(&:id).index(instalment.id)
    log = instalment.log_sales.build
    reference = self.generate_reference(instalment)
    compte_general = self.generate_compte_client_sage(instalment)
    if (pos + 1) == 1
      libelle = "1er Prelevement sco"
    else
      libelle = (pos + 1).to_s + "eme Prelevement sco"
    end
    if instalment.montant_initial.nil?
      montant = instalment.montant
    else
      montant = instalment.montant_initial
    end
    type_ecriture = "G"
    analytique = ""
    debit = 0
    credit = montant
    mode_reglement = instalment.v_mode.humanize
    nom_complet = instalment.user_financier_subscription.user_financier.etu_nom_prenom
    annee = instalment.user_financier_subscription.school_year.nom.split("/")[0]
    date_import = LogSale.set_date_import(annee)
    type_frais = 2

    log.assign_attributes(user_financier_subscription_id: instalment.user_financier_subscription_id, code_journal: "VT3", date_import: date_import, numero_facture: instalment.facture,
                          reference: reference, compte_general: compte_general,
                          compte_tiers: instalment.user_financier_subscription.user_financier.code_tiers, libelle: libelle,
                          type_ecriture: type_ecriture, analytique: analytique, mode_reglement: mode_reglement,
                          date_echeance: instalment.echeance, debit: debit, credit: credit, nom_complet: nom_complet,
                          annee: annee, type_frais: type_frais, modalite: instalment.user_financier_subscription.modalite)
    log.save

    log = instalment.log_sales.build
    compte_general = instalment.user_financier_subscription.formation_annee.formation.compte_produit_sage
    debit = montant
    credit = 0
    mode_reglement = ""
    log.assign_attributes(user_financier_subscription_id: instalment.user_financier_subscription_id, code_journal: "VT3", date_import: date_import, numero_facture: instalment.facture,
                          reference: reference, compte_general: compte_general,
                          compte_tiers: "", libelle: libelle,
                          type_ecriture: type_ecriture, analytique: analytique, mode_reglement: mode_reglement,
                          date_echeance: "", debit: debit, credit: credit, nom_complet: nom_complet,
                          annee: annee, type_frais: type_frais, modalite: instalment.user_financier_subscription.modalite)
    log.save

    log = instalment.log_sales.build
    type_ecriture = "A"
    analytique = instalment.user_financier_subscription.formation_annee.formation.centre.code_sage
    log.assign_attributes(user_financier_subscription_id: instalment.user_financier_subscription_id, code_journal: "VT3", date_import: date_import, numero_facture: instalment.facture,
                          reference: reference, compte_general: compte_general,
                          compte_tiers: "", libelle: libelle,
                          type_ecriture: type_ecriture, analytique: analytique, mode_reglement: mode_reglement,
                          date_echeance: "", debit: debit, credit: credit, nom_complet: nom_complet,
                          annee: annee, type_frais: type_frais, modalite: instalment.user_financier_subscription.modalite)
    log.save
  end

  def self.log_techniques_changed(instalment)
    log = instalment.log_sales.build
    reference = self.generate_reference(instalment)
    compte_general = self.generate_compte_client_sage(instalment)
    montant = instalment.montant
    libelle = "Frais annexes Techniques"
    type_ecriture = "G"
    analytique = ""
    debit = 0
    credit = montant
    mode_reglement = instalment.v_mode.humanize
    nom_complet = instalment.user_financier_subscription.user_financier.etu_nom_prenom
    annee = instalment.user_financier_subscription.school_year.nom.split("/")[0]
    date_import = LogSale.set_date_import(annee)
    type_frais = 3

    log.assign_attributes(user_financier_subscription_id: instalment.user_financier_subscription_id, code_journal: "VT8", date_import: date_import, numero_facture: instalment.facture,
                          reference: reference, compte_general: compte_general,
                          compte_tiers: instalment.user_financier_subscription.user_financier.code_tiers, libelle: libelle,
                          type_ecriture: type_ecriture, analytique: analytique, mode_reglement: mode_reglement,
                          date_echeance: instalment.echeance, debit: debit, credit: credit, nom_complet: nom_complet,
                          annee: annee, type_frais: type_frais, modalite: instalment.user_financier_subscription.modalite)
    log.save

    log = instalment.log_sales.build
    compte_general = instalment.user_financier_subscription.formation_annee.formation.compte_produit_sage
    debit = montant
    credit = 0
    mode_reglement = ""
    log.assign_attributes(user_financier_subscription_id: instalment.user_financier_subscription_id, code_journal: "VT8", date_import: date_import, numero_facture: instalment.facture,
                          reference: reference, compte_general: compte_general,
                          compte_tiers: "", libelle: libelle,
                          type_ecriture: type_ecriture, analytique: analytique, mode_reglement: mode_reglement,
                          date_echeance: "", debit: debit, credit: credit, nom_complet: nom_complet,
                          annee: annee, type_frais: type_frais, modalite: instalment.user_financier_subscription.modalite)
    log.save

    log = instalment.log_sales.build
    type_ecriture = "A"
    analytique = instalment.user_financier_subscription.formation_annee.formation.centre.code_sage
    log.assign_attributes(user_financier_subscription_id: instalment.user_financier_subscription_id, code_journal: "VT8", date_import: date_import, numero_facture: instalment.facture,
                          reference: reference, compte_general: compte_general,
                          compte_tiers: "", libelle: libelle,
                          type_ecriture: type_ecriture, analytique: analytique, mode_reglement: mode_reglement,
                          date_echeance: "", debit: debit, credit: credit, nom_complet: nom_complet,
                          annee: annee, type_frais: type_frais, modalite: instalment.user_financier_subscription.modalite)
    log.save
  end

  def self.log_scolarite_changed(instalment)
    pos = instalment.user_financier_subscription.user_financier_subscription_instalments.where(v_type: :frais_scolarite).map(&:id).index(instalment.id)
    log = instalment.log_sales.build
    reference = self.generate_reference(instalment)
    compte_general = self.generate_compte_client_sage(instalment)
    if (pos + 1) == 1
      libelle = "1er Prelevement sco"
    else
      libelle = (pos + 1).to_s + "eme Prelevement sco"
    end
    if instalment.montant_initial.nil?
      montant = instalment.montant
    else
      montant = instalment.montant_initial
    end
    type_ecriture = "G"
    analytique = ""
    debit = 0
    credit = montant
    mode_reglement = instalment.v_mode.humanize
    nom_complet = instalment.user_financier_subscription.user_financier.etu_nom_prenom
    annee = instalment.user_financier_subscription.school_year.nom.split("/")[0]
    date_import = LogSale.set_date_import(annee)
    type_frais = 2

    log.assign_attributes(user_financier_subscription_id: instalment.user_financier_subscription_id, code_journal: "VT8", date_import: date_import, numero_facture: instalment.facture,
                          reference: reference, compte_general: compte_general,
                          compte_tiers: instalment.user_financier_subscription.user_financier.code_tiers, libelle: libelle,
                          type_ecriture: type_ecriture, analytique: analytique, mode_reglement: mode_reglement,
                          date_echeance: instalment.echeance, debit: debit, credit: credit, nom_complet: nom_complet,
                          annee: annee, type_frais: type_frais, modalite: instalment.user_financier_subscription.modalite)
    log.save

    log = instalment.log_sales.build
    compte_general = instalment.user_financier_subscription.formation_annee.formation.compte_produit_sage
    debit = montant
    credit = 0
    mode_reglement = ""
    log.assign_attributes(user_financier_subscription_id: instalment.user_financier_subscription_id, code_journal: "VT8", date_import: date_import, numero_facture: instalment.facture,
                          reference: reference, compte_general: compte_general,
                          compte_tiers: "", libelle: libelle,
                          type_ecriture: type_ecriture, analytique: analytique, mode_reglement: mode_reglement,
                          date_echeance: "", debit: debit, credit: credit, nom_complet: nom_complet,
                          annee: annee, type_frais: type_frais, modalite: instalment.user_financier_subscription.modalite)
    log.save

    log = instalment.log_sales.build
    type_ecriture = "A"
    analytique = instalment.user_financier_subscription.formation_annee.formation.centre.code_sage
    log.assign_attributes(user_financier_subscription_id: instalment.user_financier_subscription_id, code_journal: "VT8", date_import: date_import, numero_facture: instalment.facture,
                          reference: reference, compte_general: compte_general,
                          compte_tiers: "", libelle: libelle,
                          type_ecriture: type_ecriture, analytique: analytique, mode_reglement: mode_reglement,
                          date_echeance: "", debit: debit, credit: credit, nom_complet: nom_complet,
                          annee: annee, type_frais: type_frais, modalite: instalment.user_financier_subscription.modalite)
    log.save
  end

  def self.log_discount(instalment, discount)
    pos = instalment.user_financier_subscription.user_financier_subscription_instalments.where(v_type: :frais_scolarite).map(&:id).index(instalment.id)
    log = instalment.log_sales.build
    reference = self.generate_reference(instalment)
    compte_general = self.generate_compte_client_sage(instalment)
    if (pos + 1) == 1
      libelle = "1er Prelevement sco"
    else
      libelle = (pos + 1).to_s + "eme Prelevement sco"
    end
    type_ecriture = "G"
    analytique = ""
    debit = 0
    credit = discount
    mode_reglement = instalment.v_mode.humanize
    nom_complet = instalment.user_financier_subscription.user_financier.etu_nom_prenom
    annee = instalment.user_financier_subscription.school_year.nom.split("/")[0]
    date_import = LogSale.set_date_import(annee)
    type_frais = 2

    log.assign_attributes(user_financier_subscription_id: instalment.user_financier_subscription_id, code_journal: "VT6", date_import: date_import, numero_facture: instalment.facture,
                          reference: reference, compte_general: compte_general,
                          compte_tiers: instalment.user_financier_subscription.user_financier.code_tiers, libelle: libelle,
                          type_ecriture: type_ecriture, analytique: analytique, mode_reglement: mode_reglement,
                          date_echeance: instalment.echeance, debit: debit, credit: credit, nom_complet: nom_complet,
                          annee: annee, type_frais: type_frais, modalite: instalment.user_financier_subscription.modalite)
    log.save

    log = instalment.log_sales.build
    compte_general = instalment.user_financier_subscription.formation_annee.formation.compte_produit_sage
    debit = discount
    credit = 0
    mode_reglement = ""
    log.assign_attributes(user_financier_subscription_id: instalment.user_financier_subscription_id, code_journal: "VT6", date_import: date_import, numero_facture: instalment.facture,
                          reference: reference, compte_general: compte_general,
                          compte_tiers: "", libelle: libelle,
                          type_ecriture: type_ecriture, analytique: analytique, mode_reglement: mode_reglement,
                          date_echeance: "", debit: debit, credit: credit, nom_complet: nom_complet,
                          annee: annee, type_frais: type_frais, modalite: instalment.user_financier_subscription.modalite)
    log.save

    log = instalment.log_sales.build
    type_ecriture = "A"
    analytique = instalment.user_financier_subscription.formation_annee.formation.centre.code_sage
    debit = discount
    credit = 0
    log.assign_attributes(user_financier_subscription_id: instalment.user_financier_subscription_id, code_journal: "VT6", date_import: date_import, numero_facture: instalment.facture,
                          reference: reference, compte_general: compte_general,
                          compte_tiers: "", libelle: libelle,
                          type_ecriture: type_ecriture, analytique: analytique, mode_reglement: mode_reglement,
                          date_echeance: "", debit: debit, credit: credit, nom_complet: nom_complet,
                          annee: annee, type_frais: type_frais, modalite: instalment.user_financier_subscription.modalite)
    log.save
  end

  def self.log_discount_canceled(instalment, discount)
    pos = instalment.user_financier_subscription.user_financier_subscription_instalments.where(v_type: :frais_scolarite).map(&:id).index(instalment.id)
    log = instalment.log_sales.build
    reference = self.generate_reference(instalment)
    compte_general = self.generate_compte_client_sage(instalment)
    if (pos + 1) == 1
      libelle = "1er Prelevement sco"
    else
      libelle = (pos + 1).to_s + "eme Prelevement sco"
    end
    type_ecriture = "G"
    analytique = ""
    debit = discount
    credit = 0
    mode_reglement = instalment.v_mode.humanize
    nom_complet = instalment.user_financier_subscription.user_financier.etu_nom_prenom
    annee = instalment.user_financier_subscription.school_year.nom.split("/")[0]
    date_import = LogSale.set_date_import(annee)
    type_frais = 2

    log.assign_attributes(user_financier_subscription_id: instalment.user_financier_subscription_id, code_journal: "VT6", date_import: date_import, numero_facture: instalment.facture,
                          reference: reference, compte_general: compte_general,
                          compte_tiers: instalment.user_financier_subscription.user_financier.code_tiers, libelle: libelle,
                          type_ecriture: type_ecriture, analytique: analytique, mode_reglement: mode_reglement,
                          date_echeance: instalment.echeance, debit: debit, credit: credit, nom_complet: nom_complet,
                          annee: annee, type_frais: type_frais, modalite: instalment.user_financier_subscription.modalite)
    log.save

    log = instalment.log_sales.build
    compte_general = instalment.user_financier_subscription.formation_annee.formation.compte_produit_sage
    debit = 0
    credit = discount
    mode_reglement = ""
    log.assign_attributes(user_financier_subscription_id: instalment.user_financier_subscription_id, code_journal: "VT6", date_import: date_import, numero_facture: instalment.facture,
                          reference: reference, compte_general: compte_general,
                          compte_tiers: "", libelle: libelle,
                          type_ecriture: type_ecriture, analytique: analytique, mode_reglement: mode_reglement,
                          date_echeance: "", debit: debit, credit: credit, nom_complet: nom_complet,
                          annee: annee, type_frais: type_frais, modalite: instalment.user_financier_subscription.modalite)
    log.save

    log = instalment.log_sales.build
    type_ecriture = "A"
    analytique = instalment.user_financier_subscription.formation_annee.formation.centre.code_sage
    log.assign_attributes(user_financier_subscription_id: instalment.user_financier_subscription_id, code_journal: "VT6", date_import: date_import, numero_facture: instalment.facture,
                          reference: reference, compte_general: compte_general,
                          compte_tiers: "", libelle: libelle,
                          type_ecriture: type_ecriture, analytique: analytique, mode_reglement: mode_reglement,
                          date_echeance: "", debit: debit, credit: credit, nom_complet: nom_complet,
                          annee: annee, type_frais: type_frais, modalite: instalment.user_financier_subscription.modalite)
    log.save
  end

  def self.log_inscription_change_statut_etu(instalment)
    log = instalment.log_sales.build
    reference = self.generate_reference(instalment)
    compte_general = self.generate_compte_client_sage(instalment)
    libelle = "1er Frais de scolarite"
    type_ecriture = "G"
    analytique = ""
    debit = 0
    credit = instalment.montant
    mode_reglement = instalment.v_mode.humanize
    nom_complet = instalment.user_financier_subscription.user_financier.etu_nom_prenom
    annee = instalment.user_financier_subscription.school_year.nom.split("/")[0]
    date_import = LogSale.set_date_import(annee)
    type_frais = 2
    log.assign_attributes(user_financier_subscription_id: instalment.user_financier_subscription_id, code_journal: "VT3", date_import: date_import, numero_facture: instalment.facture,
                          reference: reference, compte_general: compte_general,
                          compte_tiers: instalment.user_financier_subscription.user_financier.code_tiers, libelle: libelle,
                          type_ecriture: type_ecriture, analytique: "", mode_reglement: mode_reglement,
                          date_echeance: instalment.echeance, debit: debit, credit: credit, nom_complet: nom_complet,
                          annee: annee, type_frais: type_frais, modalite: instalment.user_financier_subscription.modalite)
    log.save

    log = instalment.log_sales.build
    compte_general = instalment.user_financier_subscription.formation_annee.formation.compte_produit_sage
    debit = instalment.montant
    credit = 0
    mode_reglement = ""
    log.assign_attributes(user_financier_subscription_id: instalment.user_financier_subscription_id, code_journal: "VT3", date_import: date_import, numero_facture: instalment.facture,
                          reference: reference, compte_general: compte_general,
                          compte_tiers: "", libelle: libelle,
                          type_ecriture: type_ecriture, analytique: "", mode_reglement: mode_reglement,
                          date_echeance: "", debit: debit, credit: credit, nom_complet: nom_complet,
                          annee: annee, type_frais: type_frais, modalite: instalment.user_financier_subscription.modalite)
    log.save

    log = instalment.log_sales.build
    type_ecriture = "A"
    analytique = instalment.user_financier_subscription.formation_annee.formation.centre.code_sage
    log.assign_attributes(user_financier_subscription_id: instalment.user_financier_subscription_id, code_journal: "VT3", date_import: date_import, numero_facture: instalment.facture,
                          reference: reference, compte_general: compte_general,
                          compte_tiers: "", libelle: libelle,
                          type_ecriture: type_ecriture, analytique: analytique, mode_reglement: mode_reglement,
                          date_echeance: "", debit: debit, credit: credit, nom_complet: nom_complet,
                          annee: annee, type_frais: type_frais, modalite: instalment.user_financier_subscription.modalite)
    log.save
  end

  def self.log_techniques_change_statut_etu(instalment)
    log = instalment.log_sales.build
    reference = self.generate_reference(instalment)
    compte_general = self.generate_compte_client_sage(instalment)
    libelle = "Frais annexes Techniques"
    type_ecriture = "G"
    analytique = ""
    debit = 0
    credit = instalment.montant
    mode_reglement = instalment.v_mode.humanize
    nom_complet = instalment.user_financier_subscription.user_financier.etu_nom_prenom
    annee = instalment.user_financier_subscription.school_year.nom.split("/")[0]
    date_import = LogSale.set_date_import(annee)
    type_frais = 3
    log.assign_attributes(user_financier_subscription_id: instalment.user_financier_subscription_id, code_journal: "VT3", date_import: date_import, numero_facture: instalment.facture,
                          reference: reference, compte_general: compte_general,
                          compte_tiers: instalment.user_financier_subscription.user_financier.code_tiers, libelle: libelle,
                          type_ecriture: type_ecriture, analytique: analytique, mode_reglement: mode_reglement,
                          date_echeance: instalment.echeance, debit: debit, credit: credit, nom_complet: nom_complet,
                          annee: annee, type_frais: type_frais, modalite: instalment.user_financier_subscription.modalite)
    log.save

    log = instalment.log_sales.build
    compte_general = instalment.user_financier_subscription.formation_annee.formation.compte_produit_sage
    debit = instalment.montant
    credit = 0
    mode_reglement = ""
    log.assign_attributes(user_financier_subscription_id: instalment.user_financier_subscription_id, code_journal: "VT3", date_import: date_import, numero_facture: instalment.facture,
                          reference: reference, compte_general: compte_general,
                          compte_tiers: "", libelle: libelle,
                          type_ecriture: type_ecriture, analytique: analytique, mode_reglement: mode_reglement,
                          date_echeance: "", debit: debit, credit: credit, nom_complet: nom_complet,
                          annee: annee, type_frais: type_frais, modalite: instalment.user_financier_subscription.modalite)
    log.save

    log = instalment.log_sales.build
    type_ecriture = "A"
    analytique = instalment.user_financier_subscription.formation_annee.formation.centre.code_sage
    log.assign_attributes(user_financier_subscription_id: instalment.user_financier_subscription_id, code_journal: "VT3", date_import: date_import, numero_facture: instalment.facture,
                          reference: reference, compte_general: compte_general,
                          compte_tiers: "", libelle: libelle,
                          type_ecriture: type_ecriture, analytique: analytique, mode_reglement: mode_reglement,
                          date_echeance: "", debit: debit, credit: credit, nom_complet: nom_complet,
                          annee: annee, type_frais: type_frais, modalite: instalment.user_financier_subscription.modalite)
    log.save
  end

  def self.log_scolarite_change_statut_etu(instalment)
    pos = instalment.user_financier_subscription.user_financier_subscription_instalments.where(v_type: :frais_scolarite).map(&:id).index(instalment.id)
    log = instalment.log_sales.build
    reference = self.generate_reference(instalment)
    compte_general = self.generate_compte_client_sage(instalment)
    if (pos + 1) == 1
      libelle = "1er Prelevement sco"
    else
      libelle = (pos + 1).to_s + "eme Prelevement sco"
    end
    if instalment.montant_initial.nil?
      montant = instalment.montant
    else
      montant = instalment.montant_initial
    end
    type_ecriture = "G"
    analytique = ""
    debit = 0
    credit = montant
    mode_reglement = instalment.v_mode.humanize
    nom_complet = instalment.user_financier_subscription.user_financier.etu_nom_prenom
    annee = instalment.user_financier_subscription.school_year.nom.split("/")[0]
    date_import = LogSale.set_date_import(annee)
    type_frais = 2

    log.assign_attributes(user_financier_subscription_id: instalment.user_financier_subscription_id, code_journal: "VT3", date_import: date_import, numero_facture: instalment.facture,
                          reference: reference, compte_general: compte_general,
                          compte_tiers: instalment.user_financier_subscription.user_financier.code_tiers, libelle: libelle,
                          type_ecriture: type_ecriture, analytique: analytique, mode_reglement: mode_reglement,
                          date_echeance: instalment.echeance, debit: debit, credit: credit, nom_complet: nom_complet,
                          annee: annee, type_frais: type_frais, modalite: instalment.user_financier_subscription.modalite)
    log.save

    log = instalment.log_sales.build
    compte_general = instalment.user_financier_subscription.formation_annee.formation.compte_produit_sage
    debit = montant
    credit = 0
    mode_reglement = ""
    log.assign_attributes(user_financier_subscription_id: instalment.user_financier_subscription_id, code_journal: "VT3", date_import: date_import, numero_facture: instalment.facture,
                          reference: reference, compte_general: compte_general,
                          compte_tiers: "", libelle: libelle,
                          type_ecriture: type_ecriture, analytique: analytique, mode_reglement: mode_reglement,
                          date_echeance: "", debit: debit, credit: credit, nom_complet: nom_complet,
                          annee: annee, type_frais: type_frais, modalite: instalment.user_financier_subscription.modalite)
    log.save

    log = instalment.log_sales.build
    type_ecriture = "A"
    analytique = instalment.user_financier_subscription.formation_annee.formation.centre.code_sage
    log.assign_attributes(user_financier_subscription_id: instalment.user_financier_subscription_id, code_journal: "VT3", date_import: date_import, numero_facture: instalment.facture,
                          reference: reference, compte_general: compte_general,
                          compte_tiers: "", libelle: libelle,
                          type_ecriture: type_ecriture, analytique: analytique, mode_reglement: mode_reglement,
                          date_echeance: "", debit: debit, credit: credit, nom_complet: nom_complet,
                          annee: annee, type_frais: type_frais, modalite: instalment.user_financier_subscription.modalite)
    log.save
  end

  def self.log_inscription_closure(instalment)
    log = instalment.log_sales.build
    reference = self.generate_reference(instalment)
    compte_general = self.generate_compte_client_sage(instalment)
    libelle = "1er Frais de scolarite"
    type_ecriture = "G"
    analytique = ""
    debit = 0
    credit = instalment.montant
    mode_reglement = instalment.v_mode.humanize
    nom_complet = instalment.user_financier_subscription.user_financier.etu_nom_prenom
    annee = instalment.user_financier_subscription.school_year.nom.split("/")[0]
    date_import = LogSale.set_date_import(annee)
    type_frais = 2
    if instalment.user_financier_subscription.demission_before_start?
      code_journal = "VT3"
    else
      code_journal = "VT5"
    end
    log.assign_attributes(user_financier_subscription_id: instalment.user_financier_subscription_id, code_journal: code_journal, date_import: date_import, numero_facture: instalment.facture,
                          reference: reference, compte_general: compte_general,
                          compte_tiers: instalment.user_financier_subscription.user_financier.code_tiers, libelle: libelle,
                          type_ecriture: type_ecriture, analytique: "", mode_reglement: mode_reglement,
                          date_echeance: instalment.echeance, debit: debit, credit: credit, nom_complet: nom_complet,
                          annee: annee, type_frais: type_frais, modalite: instalment.user_financier_subscription.modalite)
    log.save

    log = instalment.log_sales.build
    compte_general = instalment.user_financier_subscription.formation_annee.formation.compte_produit_sage
    debit = instalment.montant
    credit = 0
    mode_reglement = ""
    log.assign_attributes(user_financier_subscription_id: instalment.user_financier_subscription_id, code_journal: code_journal, date_import: date_import, numero_facture: instalment.facture,
                          reference: reference, compte_general: compte_general,
                          compte_tiers: "", libelle: libelle,
                          type_ecriture: type_ecriture, analytique: "", mode_reglement: mode_reglement,
                          date_echeance: "", debit: debit, credit: credit, nom_complet: nom_complet,
                          annee: annee, type_frais: type_frais, modalite: instalment.user_financier_subscription.modalite)
    log.save

    log = instalment.log_sales.build
    type_ecriture = "A"
    analytique = instalment.user_financier_subscription.formation_annee.formation.centre.code_sage
    log.assign_attributes(user_financier_subscription_id: instalment.user_financier_subscription_id, code_journal: code_journal, date_import: date_import, numero_facture: instalment.facture,
                          reference: reference, compte_general: compte_general,
                          compte_tiers: "", libelle: libelle,
                          type_ecriture: type_ecriture, analytique: analytique, mode_reglement: mode_reglement,
                          date_echeance: "", debit: debit, credit: credit, nom_complet: nom_complet,
                          annee: annee, type_frais: type_frais, modalite: instalment.user_financier_subscription.modalite)
    log.save
  end

  def self.log_techniques_closure(instalment)
    log = instalment.log_sales.build
    reference = self.generate_reference(instalment)
    compte_general = self.generate_compte_client_sage(instalment)
    libelle = "Frais annexes Techniques"
    type_ecriture = "G"
    analytique = ""
    debit = 0
    credit = instalment.montant
    mode_reglement = instalment.v_mode.humanize
    nom_complet = instalment.user_financier_subscription.user_financier.etu_nom_prenom
    annee = instalment.user_financier_subscription.school_year.nom.split("/")[0]
    date_import = LogSale.set_date_import(annee)
    type_frais = 3
    if instalment.user_financier_subscription.demission_before_start?
      code_journal = "VT3"
    else
      code_journal = "VT5"
    end
    log.assign_attributes(user_financier_subscription_id: instalment.user_financier_subscription_id, code_journal: code_journal, date_import: date_import, numero_facture: instalment.facture,
                          reference: reference, compte_general: compte_general,
                          compte_tiers: instalment.user_financier_subscription.user_financier.code_tiers, libelle: libelle,
                          type_ecriture: type_ecriture, analytique: analytique, mode_reglement: mode_reglement,
                          date_echeance: instalment.echeance, debit: debit, credit: credit, nom_complet: nom_complet,
                          annee: annee, type_frais: type_frais, modalite: instalment.user_financier_subscription.modalite)
    log.save

    log = instalment.log_sales.build
    compte_general = instalment.user_financier_subscription.formation_annee.formation.compte_produit_sage
    debit = instalment.montant
    credit = 0
    mode_reglement = ""
    log.assign_attributes(user_financier_subscription_id: instalment.user_financier_subscription_id, code_journal: code_journal, date_import: date_import, numero_facture: instalment.facture,
                          reference: reference, compte_general: compte_general,
                          compte_tiers: "", libelle: libelle,
                          type_ecriture: type_ecriture, analytique: analytique, mode_reglement: mode_reglement,
                          date_echeance: "", debit: debit, credit: credit, nom_complet: nom_complet,
                          annee: annee, type_frais: type_frais, modalite: instalment.user_financier_subscription.modalite)
    log.save

    log = instalment.log_sales.build
    type_ecriture = "A"
    analytique = instalment.user_financier_subscription.formation_annee.formation.centre.code_sage
    log.assign_attributes(user_financier_subscription_id: instalment.user_financier_subscription_id, code_journal: code_journal, date_import: date_import, numero_facture: instalment.facture,
                          reference: reference, compte_general: compte_general,
                          compte_tiers: "", libelle: libelle,
                          type_ecriture: type_ecriture, analytique: analytique, mode_reglement: mode_reglement,
                          date_echeance: "", debit: debit, credit: credit, nom_complet: nom_complet,
                          annee: annee, type_frais: type_frais, modalite: instalment.user_financier_subscription.modalite)
    log.save
  end

  def self.log_scolarite_closure(instalment)
    pos = instalment.user_financier_subscription.user_financier_subscription_instalments.where(v_type: :frais_scolarite).map(&:id).index(instalment.id)
    log = instalment.log_sales.build
    reference = self.generate_reference(instalment)
    compte_general = self.generate_compte_client_sage(instalment)
    if (pos + 1) == 1
      libelle = "1er Prelevement sco"
    else
      libelle = (pos + 1).to_s + "eme Prelevement sco"
    end
    if instalment.montant_initial.nil?
      montant = instalment.montant
    else
      montant = instalment.montant_initial
    end
    reference = self.generate_reference(instalment)
    type_ecriture = "G"
    analytique = ""
    debit = 0
    credit = montant
    mode_reglement = instalment.v_mode.humanize
    nom_complet = instalment.user_financier_subscription.user_financier.etu_nom_prenom
    annee = instalment.user_financier_subscription.school_year.nom.split("/")[0]
    date_import = LogSale.set_date_import(annee)
    type_frais = 2
    if instalment.user_financier_subscription.demission_before_start?
      code_journal = "VT3"
    else
      code_journal = "VT5"
    end
    log.assign_attributes(user_financier_subscription_id: instalment.user_financier_subscription_id, code_journal: code_journal, date_import: date_import, numero_facture: instalment.facture,
                          reference: reference, compte_general: compte_general,
                          compte_tiers: instalment.user_financier_subscription.user_financier.code_tiers, libelle: libelle,
                          type_ecriture: type_ecriture, analytique: analytique, mode_reglement: mode_reglement,
                          date_echeance: instalment.echeance, debit: debit, credit: credit, nom_complet: nom_complet,
                          annee: annee, type_frais: type_frais, modalite: instalment.user_financier_subscription.modalite)
    log.save

    log = instalment.log_sales.build
    compte_general = instalment.user_financier_subscription.formation_annee.formation.compte_produit_sage
    debit = montant
    credit = 0
    mode_reglement = ""
    log.assign_attributes(user_financier_subscription_id: instalment.user_financier_subscription_id, code_journal: code_journal, date_import: date_import, numero_facture: instalment.facture,
                          reference: reference, compte_general: compte_general,
                          compte_tiers: "", libelle: libelle,
                          type_ecriture: type_ecriture, analytique: analytique, mode_reglement: mode_reglement,
                          date_echeance: "", debit: debit, credit: credit, nom_complet: nom_complet,
                          annee: annee, type_frais: type_frais, modalite: instalment.user_financier_subscription.modalite)
    log.save

    log = instalment.log_sales.build
    type_ecriture = "A"
    analytique = instalment.user_financier_subscription.formation_annee.formation.centre.code_sage
    log.assign_attributes(user_financier_subscription_id: instalment.user_financier_subscription_id, code_journal: code_journal, date_import: date_import, numero_facture: instalment.facture,
                          reference: reference, compte_general: compte_general,
                          compte_tiers: "", libelle: libelle,
                          type_ecriture: type_ecriture, analytique: analytique, mode_reglement: mode_reglement,
                          date_echeance: "", debit: debit, credit: credit, nom_complet: nom_complet,
                          annee: annee, type_frais: type_frais, modalite: instalment.user_financier_subscription.modalite)
    log.save
  end

  def self.log_inscription_transfer(instalment)
    log = instalment.log_sales.build
    reference = self.generate_reference(instalment)
    compte_general = self.generate_compte_client_sage(instalment)
    libelle = "1er Frais de scolarite"
    type_ecriture = "G"
    analytique = ""
    debit = 0
    credit = instalment.montant
    mode_reglement = instalment.v_mode.humanize
    nom_complet = instalment.user_financier_subscription.user_financier.etu_nom_prenom
    annee = instalment.user_financier_subscription.school_year.nom.split("/")[0]
    date_import = LogSale.set_date_import(annee)
    type_frais = 2
    log.assign_attributes(user_financier_subscription_id: instalment.user_financier_subscription_id, code_journal: "VT8", date_import: date_import, numero_facture: instalment.facture,
                          reference: reference, compte_general: compte_general,
                          compte_tiers: instalment.user_financier_subscription.user_financier.code_tiers, libelle: libelle,
                          type_ecriture: type_ecriture, analytique: "", mode_reglement: mode_reglement,
                          date_echeance: instalment.echeance, debit: debit, credit: credit, nom_complet: nom_complet,
                          annee: annee, type_frais: type_frais, modalite: instalment.user_financier_subscription.modalite)
    log.save

    log = instalment.log_sales.build
    compte_general = instalment.user_financier_subscription.formation_annee.formation.compte_produit_sage
    debit = instalment.montant
    credit = 0
    mode_reglement = ""
    log.assign_attributes(user_financier_subscription_id: instalment.user_financier_subscription_id, code_journal: "VT8", date_import: date_import, numero_facture: instalment.facture,
                          reference: reference, compte_general: compte_general,
                          compte_tiers: "", libelle: libelle,
                          type_ecriture: type_ecriture, analytique: "", mode_reglement: mode_reglement,
                          date_echeance: "", debit: debit, credit: credit, nom_complet: nom_complet,
                          annee: annee, type_frais: type_frais, modalite: instalment.user_financier_subscription.modalite)
    log.save

    log = instalment.log_sales.build
    type_ecriture = "A"
    analytique = instalment.user_financier_subscription.formation_annee.formation.centre.code_sage
    log.assign_attributes(user_financier_subscription_id: instalment.user_financier_subscription_id, code_journal: "VT8", date_import: date_import, numero_facture: instalment.facture,
                          reference: reference, compte_general: compte_general,
                          compte_tiers: "", libelle: libelle,
                          type_ecriture: type_ecriture, analytique: analytique, mode_reglement: mode_reglement,
                          date_echeance: "", debit: debit, credit: credit, nom_complet: nom_complet,
                          annee: annee, type_frais: type_frais, modalite: instalment.user_financier_subscription.modalite)
    log.save
  end

  def self.log_techniques_transfer(instalment)
    log = instalment.log_sales.build
    reference = self.generate_reference(instalment)
    compte_general = self.generate_compte_client_sage(instalment)
    libelle = "Frais annexes Techniques"
    type_ecriture = "G"
    analytique = ""
    debit = 0
    credit = instalment.montant
    mode_reglement = instalment.v_mode.humanize
    nom_complet = instalment.user_financier_subscription.user_financier.etu_nom_prenom
    annee = instalment.user_financier_subscription.school_year.nom.split("/")[0]
    date_import = LogSale.set_date_import(annee)
    type_frais = 3
    log.assign_attributes(user_financier_subscription_id: instalment.user_financier_subscription_id, code_journal: "VT8", date_import: date_import, numero_facture: instalment.facture,
                          reference: reference, compte_general: compte_general,
                          compte_tiers: instalment.user_financier_subscription.user_financier.code_tiers, libelle: libelle,
                          type_ecriture: type_ecriture, analytique: analytique, mode_reglement: mode_reglement,
                          date_echeance: instalment.echeance, debit: debit, credit: credit, nom_complet: nom_complet,
                          annee: annee, type_frais: type_frais, modalite: instalment.user_financier_subscription.modalite)
    log.save

    log = instalment.log_sales.build
    compte_general = instalment.user_financier_subscription.formation_annee.formation.compte_produit_sage
    debit = instalment.montant
    credit = 0
    mode_reglement = ""
    log.assign_attributes(user_financier_subscription_id: instalment.user_financier_subscription_id, code_journal: "VT8", date_import: date_import, numero_facture: instalment.facture,
                          reference: reference, compte_general: compte_general,
                          compte_tiers: "", libelle: libelle,
                          type_ecriture: type_ecriture, analytique: analytique, mode_reglement: mode_reglement,
                          date_echeance: "", debit: debit, credit: credit, nom_complet: nom_complet,
                          annee: annee, type_frais: type_frais, modalite: instalment.user_financier_subscription.modalite)
    log.save

    log = instalment.log_sales.build
    type_ecriture = "A"
    analytique = instalment.user_financier_subscription.formation_annee.formation.centre.code_sage
    log.assign_attributes(user_financier_subscription_id: instalment.user_financier_subscription_id, code_journal: "VT8", date_import: date_import, numero_facture: instalment.facture,
                          reference: reference, compte_general: compte_general,
                          compte_tiers: "", libelle: libelle,
                          type_ecriture: type_ecriture, analytique: analytique, mode_reglement: mode_reglement,
                          date_echeance: "", debit: debit, credit: credit, nom_complet: nom_complet,
                          annee: annee, type_frais: type_frais, modalite: instalment.user_financier_subscription.modalite)
    log.save
  end

  def self.log_scolarite_transfer(instalment)
    pos = instalment.user_financier_subscription.user_financier_subscription_instalments.where(v_type: :frais_scolarite).map(&:id).index(instalment.id)
    log = instalment.log_sales.build
    reference = self.generate_reference(instalment)
    compte_general = self.generate_compte_client_sage(instalment)
    if (pos + 1) == 1
      libelle = "1er Prelevement sco"
    else
      libelle = (pos + 1).to_s + "eme Prelevement sco"
    end
    if instalment.montant_initial.nil?
      montant = instalment.montant
    else
      montant = instalment.montant_initial
    end
    reference = self.generate_reference(instalment)
    type_ecriture = "G"
    analytique = ""
    debit = 0
    credit = montant
    mode_reglement = instalment.v_mode.humanize
    nom_complet = instalment.user_financier_subscription.user_financier.etu_nom_prenom
    annee = instalment.user_financier_subscription.school_year.nom.split("/")[0]
    date_import = LogSale.set_date_import(annee)
    type_frais = 2
    log.assign_attributes(user_financier_subscription_id: instalment.user_financier_subscription_id, code_journal: "VT8", date_import: date_import, numero_facture: instalment.facture,
                          reference: reference, compte_general: compte_general,
                          compte_tiers: instalment.user_financier_subscription.user_financier.code_tiers, libelle: libelle,
                          type_ecriture: type_ecriture, analytique: analytique, mode_reglement: mode_reglement,
                          date_echeance: instalment.echeance, debit: debit, credit: credit, nom_complet: nom_complet,
                          annee: annee, type_frais: type_frais, modalite: instalment.user_financier_subscription.modalite)
    log.save

    log = instalment.log_sales.build
    compte_general = instalment.user_financier_subscription.formation_annee.formation.compte_produit_sage
    debit = montant
    credit = 0
    mode_reglement = ""
    log.assign_attributes(user_financier_subscription_id: instalment.user_financier_subscription_id, code_journal: "VT8", date_import: date_import, numero_facture: instalment.facture,
                          reference: reference, compte_general: compte_general,
                          compte_tiers: "", libelle: libelle,
                          type_ecriture: type_ecriture, analytique: analytique, mode_reglement: mode_reglement,
                          date_echeance: "", debit: debit, credit: credit, nom_complet: nom_complet,
                          annee: annee, type_frais: type_frais, modalite: instalment.user_financier_subscription.modalite)
    log.save

    log = instalment.log_sales.build
    type_ecriture = "A"
    analytique = instalment.user_financier_subscription.formation_annee.formation.centre.code_sage
    log.assign_attributes(user_financier_subscription_id: instalment.user_financier_subscription_id, code_journal: "VT8", date_import: date_import, numero_facture: instalment.facture,
                          reference: reference, compte_general: compte_general,
                          compte_tiers: "", libelle: libelle,
                          type_ecriture: type_ecriture, analytique: analytique, mode_reglement: mode_reglement,
                          date_echeance: "", debit: debit, credit: credit, nom_complet: nom_complet,
                          annee: annee, type_frais: type_frais, modalite: instalment.user_financier_subscription.modalite)
    log.save
  end

  ## AVOIR
  def self.log_custom_credit(lcredit)
    log = lcredit.log_sales.build
    reference = self.generate_reference(lcredit.user_financier_subscription_instalment)
    compte_general = self.generate_compte_client_sage(lcredit)
    libelle = lcredit.libelle
    montant = lcredit.montant
    code = lcredit.code_export

    type_ecriture = "G"
    analytique = ""
    debit = 0
    credit = montant
    mode_reglement = "Aucun"
    nom_complet = lcredit.user_financier_subscription.user_financier.etu_nom_prenom
    annee = lcredit.user_financier_subscription.school_year.nom.split("/")[0]
    date_import = LogSale.set_date_import(annee)
    if lcredit.user_financier_subscription_instalment.frais_techniques?
      type_frais = 3
    else
      type_frais = 2
    end
    log.assign_attributes(user_financier_subscription_id: lcredit.user_financier_subscription_id, user_financier_subscription_instalment_id: lcredit.user_financier_subscription_instalment_id, code_journal: code, date_import: date_import, numero_facture: lcredit.facture_ref,
                          reference: reference, compte_general: compte_general,
                          compte_tiers: lcredit.user_financier_subscription.user_financier.code_tiers, libelle: libelle,
                          type_ecriture: type_ecriture, analytique: analytique, mode_reglement: mode_reglement,
                          date_echeance: lcredit.echeance, debit: debit, credit: credit, nom_complet: nom_complet,
                          annee: annee, type_frais: type_frais, modalite: lcredit.user_financier_subscription.modalite)
    log.save

    log = lcredit.log_sales.build
    compte_general = lcredit.user_financier_subscription.formation_annee.formation.compte_produit_sage
    debit = montant
    credit = 0
    mode_reglement = ""
    log.assign_attributes(user_financier_subscription_id: lcredit.user_financier_subscription_id, user_financier_subscription_instalment_id: lcredit.user_financier_subscription_instalment_id, code_journal: code, date_import: date_import, numero_facture: lcredit.facture_ref,
                          reference: reference, compte_general: compte_general,
                          compte_tiers: "", libelle: libelle,
                          type_ecriture: type_ecriture, analytique: analytique, mode_reglement: mode_reglement,
                          date_echeance: "", debit: debit, credit: credit, nom_complet: nom_complet,
                          annee: annee, type_frais: type_frais, modalite: lcredit.user_financier_subscription.modalite)
    log.save

    log = lcredit.log_sales.build
    type_ecriture = "A"
    analytique = lcredit.user_financier_subscription.formation_annee.formation.centre.code_sage
    log.assign_attributes(user_financier_subscription_id: lcredit.user_financier_subscription_id, user_financier_subscription_instalment_id: lcredit.user_financier_subscription_instalment_id, code_journal: code, date_import: date_import, numero_facture: lcredit.facture_ref,
                          reference: reference, compte_general: compte_general,
                          compte_tiers: "", libelle: libelle,
                          type_ecriture: type_ecriture, analytique: analytique, mode_reglement: mode_reglement,
                          date_echeance: "", debit: debit, credit: credit, nom_complet: nom_complet,
                          annee: annee, type_frais: type_frais, modalite: lcredit.user_financier_subscription.modalite)
    log.save
  end

  def self.to_csv_async
    directory_name = "public/export"
    public_directory_name = "export"
    Dir.mkdir(directory_name) unless File.exists?(directory_name)
    filename = "ECR_CPTA_" + DateTime.now.strftime("%d%m%y") + "_EART_#{SecureRandom.hex(5)}"
    file = "#{directory_name}/#{filename}.csv"
    headers = ["CODE JOURNAL", "DATE IMPORT", "NUMERO FACTURE", "REFERENCE", "COMPTE GENERAL", "COMPTE TIERS", "LIBELLE", "TYPE ECRITURE", "SECTION ANALYTIQUE", "MODE REGLEMENT", "DATE ECHEANCE", "DEBIT", "CREDIT", "NOM PRENOM", "ANNEE", "TYPE FRAIS", "MODALITE"]
    CSV.open(file, "w", :col_sep => ";") do |csv|
      csv.to_io.write "\uFEFF"
      all.each do |data|
        csv << [data.code_journal, data.date_import.strftime("%d/%m/%Y"), data.numero_facture, data.reference, data.compte_general, data.compte_tiers, data.libelle, data.type_ecriture, '="' + data.analytique + '"', data.mode_reglement, (data.date_echeance.strftime("%d/%m/%Y") rescue ""), data.debit.round, data.credit.round, I18n.transliterate(data.nom_complet), data.annee, data.type_frais, data.modalite]
      end
    end
    Thread.new {
      sleep 10
      File.delete(file) if File.exist?(file)
    }
    return Rails.application.routes.default_url_options[:host] + "/" + public_directory_name + "/" + filename + ".csv"
  end

  def self.set_date_import(annee)
    today = Date.today
    limit = Date.strptime("01/07/#{annee}", "%d/%m/%Y")
    if today < limit
      return limit.strftime("%d/%m/%Y")
    else
      return today.strftime("%d/%m/%Y")
    end
  end

  def self.generate_reference(instalment)
    return instalment.user_financier_subscription.formation_annee.formation.code + " " + instalment.user_financier_subscription.formation_annee.formation.centre.acronyme.upcase
  end

  def self.generate_compte_client_sage(instalment)
    compte = instalment.user_financier_subscription.formation_annee.formation.centre.centre_customer_accounts.find_by(school_year_id: instalment.user_financier_subscription.school_year_id).compte_client_sage rescue nil
    if compte
      return compte
    else
      return ""
    end
  end
end
