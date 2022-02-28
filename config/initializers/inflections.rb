#encoding: utf-8
# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format. Inflections
# are locale specific, and you may define rules for as many different
# locales as you wish. All of these examples are active by default:
# ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

# These inflection rules are supported but not enabled by default:
# ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.acronym 'RESTful'
# end
ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.acronym "API"
  inflect.human(/prelevement/, "Prélèvement")
  inflect.human(/cheque/, "Chèque")
  inflect.human(/etudiant/, "Étudiant")
  inflect.human(/reinscription/, "Réinscription")

  inflect.human(/alert_discount/, "Remise commerciale")
  inflect.human(/alert_demission/, "Démission")
  inflect.human(/alert_payment/, "Modification échéancier")
  inflect.human(/alert_other/, "Autre")
  inflect.human(/alert_late_registration/, "Souscription tardive")
  inflect.human(/alert_exclusion/, "Exclusion")
  inflect.human(/alert_change_payment_modality/, "Changement modalité")

  inflect.human(/frais_scolarite/, "Frais scolarité")

  inflect.human(/waiting/, "En attente")
  inflect.human(/done/, "Traité")
  inflect.human(/refused/, "Refusé")
end
