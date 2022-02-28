#encoding: utf-8
class UserFinancierTimeline < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :user_financier
  belongs_to :user_financier_subscription, optional: true

  enum priority: [:success, :info, :warning, :danger]

  def self.create_subscription(subscription, user)
    msg = "L'étudiant a été "
    if subscription.inscription?
      msg += "inscrit à la formation " + subscription.formation_annee.formation.nom
    elsif subscription.reinscription?
      msg += "réinscrit à la formation " + subscription.formation_annee.formation.nom
    end
    msg += " sur le campus de " + subscription.formation_annee.formation.centre.nom + "."
    UserFinancierTimeline.create(user_id: user, user_financier_id: subscription.user_financier_id, user_financier_subscription_id: subscription.id, descr: msg, priority: :success)
  end

  def self.cancel_subscription(subscription, user)
    msg = "La souscription à la formation " + subscription.formation_annee.formation.nom + " a été annulée."
    UserFinancierTimeline.create(user_id: user, user_financier_id: subscription.user_financier_id, user_financier_subscription_id: subscription.id, descr: msg, priority: :danger)
  end

  def self.discount_subscription(subscription, user)
    msg = "Une remise d'une valeur de " + subscription.reduction.to_s + "€ a été appliquée à la souscription " + subscription.formation_annee.formation.nom + "."
    UserFinancierTimeline.create(user_id: user, user_financier_id: subscription.user_financier_id, user_financier_subscription_id: subscription.id, descr: msg, priority: :warning)
  end

  def self.change_statut_etu_subscription(subscription, user)
    msg = "Un changement de statut étudiant a été appliqué à la souscription " + subscription.formation_annee.formation.nom + "."
    UserFinancierTimeline.create(user_id: user, user_financier_id: subscription.user_financier_id, user_financier_subscription_id: subscription.id, descr: msg, priority: :warning)
  end
  def self.closure_subscription(subscription, user)
    if subscription.exclusion?
      msg = "Exclusion enregistrée pour la souscription " + subscription.formation_annee.formation.nom + "."
    else
      msg = "Démission enregistrée pour la souscription " + subscription.formation_annee.formation.nom + "."
    end
    UserFinancierTimeline.create(user_id: user, user_financier_id: subscription.user_financier_id, user_financier_subscription_id: subscription.id, descr: msg, priority: :danger)
  end
  def self.cancel_closure_subscription(subscription, user)
    if subscription.exclusion?
      msg = "Exclusion annulée pour la souscription " + subscription.formation_annee.formation.nom + "."
    else
      msg = "Démission annulée pour la souscription " + subscription.formation_annee.formation.nom + "."
    end
    UserFinancierTimeline.create(user_id: user, user_financier_id: subscription.user_financier_id, user_financier_subscription_id: subscription.id, descr: msg, priority: :danger)
  end

  def self.formation_change_subscription(subscription, user)
    msg = "La formation de la souscription a été modifiée pour " + subscription.formation_annee.formation.nom + "."
    UserFinancierTimeline.create(user_id: user, user_financier_id: subscription.user_financier_id, user_financier_subscription_id: subscription.id, descr: msg, priority: :warning)
  end

  def self.modalite_change_subscription(subscription, user)
    msg = "La modalité de paiement pour la souscription " + subscription.formation_annee.formation.nom + " a été modifiée pour un paiement en " + subscription.modalite.to_s + " fois."
    UserFinancierTimeline.create(user_id: user, user_financier_id: subscription.user_financier_id, user_financier_subscription_id: subscription.id, descr: msg, priority: :warning)
  end

  def self.echeances_change_subscription(subscription, user)
    msg = "L'échancier a été modifié par l'utilisateur."
    UserFinancierTimeline.create(user_id: user, user_financier_id: subscription.user_financier_id, user_financier_subscription_id: subscription.id, descr: msg, priority: :warning)
  end

  def self.tag_follow(user_financier, user, follow)
    if follow
      msg = "Compte à suivre."
    else
      msg = "Compte à ne plus suivre."
    end
    UserFinancierTimeline.create!(user_id: user, user_financier_id: user_financier, descr: msg, priority: :info)
  end

  def self.tag_relaunch(user_financier, user, relaunch)
    if relaunch
      msg = "À ne pas relancer"
    else
      msg = "À relancer"
    end
    UserFinancierTimeline.create(user_id: user, user_financier_id: user_financier, descr: msg, priority: :info)
  end
end
