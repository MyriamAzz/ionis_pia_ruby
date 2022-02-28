class Ability
  include CanCan::Ability

  def initialize(user, controller_namespace = nil)
    user ||= User.new
    #case controller_namespace
    # when "Admin::Settings"
    #   if user.super_admin?
    #     can :manage, :all
    #   end
    # else
    # rules for non-admin controllers here
    if user.super_admin? or user.admin? or user.compta? or user.supervisor?
      # can :manage, :all
      can [:show, :filter, :async_stats, :async_stats_1, :async_stats_2, :chart_registrations, :chart_new_registrations], :dashboard
      can [:switch_centre, :switch_school_program], :profile

      if user.admin_school_programs.pluck(:id).include?(user.user_admin.current_centre.school_program_id)
        can :manage, UserAdmin
        can :manage, Centre

        can [:new, :create], UserAdmin
        can :manage, User do |a|
          !(a.school_programs.pluck(:id) & user.admin_school_programs.pluck(:id)).empty?
        end
        can [:new, :create], Centre
        can :manage, Centre, school_program_id: user.admin_school_programs.pluck(:id)
        can [:new, :create], SchoolYear
        can :manage, SchoolYear, school_program_id: user.admin_school_programs.pluck(:id)

        can :index, :payment_term

        can [:manage], PaymentPlan
        can [:table], PaymentCalendar

        can [:new, :create], Formation
        can :manage, Formation, centre_id: user.centres.pluck(:id)

        can [:new, :create], FormationAnnee
        can :manage, FormationAnnee, formation: { centre_id: user.centres.pluck(:id) }

        if user.super_admin? or user.compta?
          can :manage, UserFinancierSubscription, user_financier: { centre_id: user.centres.pluck(:id) }
          can [:manage], UserFinancierSubscriptionInstalment, user_financier_subscription: { user_financier: { centre_id: user.centres.pluck(:id) } }
          can [:canceled], UserFinancierSubscriptionInstalment, user_financier_subscription: { user_financier: { centre_id: user.centres.pluck(:id) } }
          can :manage, AccountingAlert, centre_id: user.centres.pluck(:id)
          can [:manage], UserFinancierSubscriptionCredit
          can :manage, :invoice
          can :manage, :payment
          can :manage, :log
          can :manage, :statistic
          can :manage, Payout
        end
      end

      can [:manage], :student
      can :new, User
      can :manage, User, user_financier: { centre_id: user.centres.pluck(:id) }

      # can :centres, Formation
      # can :read, FormationAnnee

      # can :read, :update, User
      can :download, UserFinancierMandate
      # can [:new, :create, :read, :table_json, :edit, :update, :edit_card], User
      can [:show, :facture_pdf], UserFinancierSubscriptionInstalment, user_financier_subscription: { user_financier: { centre_id: user.centres.pluck(:id) } }
      can [:new, :create], UserFinancierTimeline
      can [:manage], UserFinancierTimeline, user_financier: { centre_id: user.centres.pluck(:id) }
      can [:new, :create], UserFinancierSubscription
      can [:new, :create, :edit, :launch_change_formation, :launch_change_statut,
           :edit_instalments, :update_instalments, :facture_pdf, :facture_proforma_pdf, :attestation_scolarite, :update, :destroy], UserFinancierSubscription, user_financier: { centre_id: user.centres.pluck(:id) }
      if user.admin? or user.supervisor?
        cannot [:edit_instalments, :update_instalments], UserFinancierSubscription, user_financier: { centre_id: user.centres.pluck(:id) }
        cannot [:transfer], User, user_financier: { centre_id: user.centres.pluck(:id) }
      end

      # if user.supervisor?
      #   cannot [:new, :create, :edit, :launch_change_formation, :launch_change_statut,
      #           :edit_instalments, :update_instalments, :update, :destroy], UserFinancierSubscription, user_financier: { centre_id: user.centres.pluck(:id) }
      #   cannot [:new, :create], UserFinancierSubscription
      # end

      can [:new, :create, :index, :table_json, :edit], AccountingAlert
      can :manage, :statistic

      if user.compta?
        can [:manage], UserFinancierSubscriptionInstalment, user_financier_subscription: { user_financier: { centre_id: user.centres.pluck(:id) } }
        can [:manage], UserFinancierSubscriptionCredit
        can :manage, AccountingAlert, centre_id: user.centres.pluck(:id)
        can :manage, :invoice
        can :manage, :payment
        can :manage, :log
        can :manage, :statistic
        can :manage, Payout

        # can [:new, :create], Centre
        # can :manage, Centre, id: user.centres.pluck(:id)
        # can [:new, :create], SchoolYear
        # can :manage, SchoolYear, school_program_id: user.admin_school_programs.pluck(:id)

        # can :index, :payment_term

        # can [:manage], PaymentPlan
        # can [:table], PaymentCalendar

        # can [:new, :create], Formation
        # can :manage, Formation, centre_id: user.centres.pluck(:id)

        # can [:new, :create], FormationAnnee
        # can :manage, FormationAnnee, formation: { centre_id: user.centres.pluck(:id) }
      end
    elsif user.admin?
      # can [:show], :dashboard
      # can [:switch_centre], :profile

      # can :read, SchoolYear
      # can :read, Formation
      # can :centres, Formation
      # can :read, FormationAnnee
      # can :download, UserFinancierMandate
      # can [:new, :create, :read, :table_json, :edit, :edit_card, :update, :send_email_ids], User
      # can [:create, :facture_proforma_pdf, :attestation_scolarite, :facture_pdf, :edit_instalments, :update_instalments, :show], UserFinancierSubscription
      # can [:facture_pdf, :show], UserFinancierSubscriptionInstalment
      # can [:read, :table_json_waiting, :table_json_done, :echeancier], :facturation
      # elsif user.compta?
      #   can :read, SchoolYear
      #   can :centres, Formation
      #   can :read, FormationAnnee
      #   can :read, :update, User
      #   can :download, UserFinancierMandate
      #   can [:new, :create, :read, :table_json, :edit, :update, :edit_card], User
      #   can [:manage], UserFinancierSubscriptionInstalment
      #   can [:manage], UserFinancierSubscriptionCredit
      #   can :manage, UserFinancierSubscription
      #   can :manage, :facturation
      #   can :manage, :echeance
      #   can :manage, :log
    elsif user.user?
      can [:show, :attestation_scolarite], :dashboard
      can :show, :support
      can [:facture_pdf, :facture_echeance_pdf], :facture
      can [:show, :update_password, :update], :profil
      can [:show, :new_mandate, :validate_mandate, :confirm_mandate, :download_mandate], :paiement
    end
  end

  #end
end
