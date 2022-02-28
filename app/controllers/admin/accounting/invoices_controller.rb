#encoding: utf-8
class Admin::Accounting::InvoicesController < AdminController
  load_and_authorize_resource class: false
  require "csv"

  def index
    session[:students_filter_school_year] = current_user.user_admin.current_centre.school_program.get_current_school_year.id rescue nil
  end

  def filter
    if params[:school_year] && params[:school_year] == "-1"
      session[:students_filter_school_year] = nil
    elsif params[:school_year]
      session[:students_filter_school_year] = params[:school_year]
    end
  end

  def echeancier
    @subscription = UserFinancierSubscription.find(params[:user_financier_subscription_id])
  end

  # def process_all
  #   @done = 0
  #   @error = []
  #   sp = { "#{session[:admin_comptabilite_to_process]}": false, s_type: session[:admin_comptabilite_s_type_waiting], special_case: session[:admin_comptabilite_commentaire_waiting], statut: [:waiting_compta, :partial_techniques, :partial_inscription] }

  #   if session[:admin_comptabilite_to_process] == "frais_scolarite_done" && !session[:admin_comptabilite_modalite].nil?
  #     sp[:modalite] = session[:admin_comptabilite_modalite]
  #   end
  #   if session[:admin_comptabilite_centre]
  #     centre = Centre.find(session[:admin_comptabilite_centre])
  #     UserFinancierSubscription.joins(:user_financier).where(sp).where(user_financiers: { centre_id: centre }).each do |sub|
  #       @done += 1
  #       if sub.process_active_partial_subscription(session[:admin_comptabilite_to_process]) == false
  #         @error << [student: sub.user_financier.etu_nom + " " + sub.user_financier.etu_prenom]
  #       else
  #       end
  #     end
  #   else
  #     if current_user.admin_get_centres.count > 1
  #       centres = current_user.admin_get_centres.pluck(:id)
  #       UserFinancierSubscription.joins(:user_financier).where(sp).where(user_financiers: { centre_id: centres }).each do |sub|
  #         @done += 1
  #         if sub.process_active_partial_subscription(session[:admin_comptabilite_to_process]) == false
  #           @error << [student: sub.user_financier.etu_nom + " " + sub.user_financier.etu_prenom]
  #         else
  #         end
  #       end
  #     else
  #       centre = current_user.admin_get_centres.first
  #       UserFinancierSubscription.joins(:user_financier).where(sp).where(user_financiers: { centre_id: centre }).each do |sub|
  #         @done += 1
  #         if sub.process_active_partial_subscription(session[:admin_comptabilite_to_process]) == false
  #           @error << [student: sub.user_financier.etu_nom + " " + sub.user_financier.etu_prenom]
  #         else
  #         end
  #       end
  #     end
  #   end
  # end

  def process_selected
    @done = 0
    @error = []

    sp = { id: params["records"], "#{params[:v_type].parameterize(separator: "_")}_done": false, statut: [:waiting_compta, :partial_techniques, :partial_inscription] }
    UserFinancierSubscription.where(sp).each do |sub|
      @done += 1
      done, error = sub.process_active_partial_subscription("#{params[:v_type].parameterize(separator: "_")}_done")
      if !done
        @error << { student: "#{sub.user_financier.etu_nom} #{sub.user_financier.etu_prenom} - Erreur : #{error}" }
      end
    end
  end

  # def export_all
  #   @done = 0
  #   @error = []
  #   if session[:admin_comptabilite_centre]
  #     centre = Centre.find(session[:admin_comptabilite_centre])
  #     arr_csv = UserFinancierSubscription.joins(:user_financier).where(statut: :active).where(user_financiers: { centre_id: centre }).pluck(:id)
  #   else
  #     if current_user.admin_get_centres.count > 1
  #       centres = current_user.admin_get_centres.pluck(:id)
  #       arr_csv = UserFinancierSubscription.joins(:user_financier).where(statut: :active).where(user_financiers: { centre_id: centres }).pluck(:id)
  #     else
  #       centre = current_user.admin_get_centres.first
  #       arr_csv = UserFinancierSubscription.joins(:user_financier).where(statut: :active).where(user_financiers: { centre_id: centre }).pluck(:id)
  #     end
  #   end
  #   if arr_csv.count > 0
  #     @csv_file = ExportVente.csv_done_active(arr_csv)
  #   end
  # end

  # def export_selected
  #   arr_csv = UserFinancierSubscription.where(id: params["records"], statut: :active).pluck(:id)
  #   if arr_csv.count > 0
  #     @csv_file = ExportVente.csv_done_active(arr_csv)
  #   end
  # end

  def table_json_waiting
    data = f_table_json(params, false, false)
    render json: data
  end

  def table_json_done
    data = f_table_json(params, true, true)
    render json: data
  end

  private

  def f_table_json(params, done, value)
    data = []
    if !done
      subscriptions = UserFinancierSubscription.where(statut: [:waiting_compta, :partial_inscription, :partial_techniques], school_year_id: session[:students_filter_school_year]).includes([:user_financier, :formation_annee, :school_year]).joins(:user_financier).where("user_financiers.centre_id IN (?)", @centres.pluck(:id))
      subscriptions.each do |s|
        if !s.frais_inscription_done
          payment_mode = s.payment_mode_inscription.humanize
          modalite = ""
          data << { :RecordID => s.id, :uuid => s.user_financier.user.uuid, :id => s.user_financier.id, :user_id => s.user_financier.user_id, :etu_nom => s.user_financier.etu_nom,
                   :etu_prenom => s.user_financier.etu_prenom, :etu_email => s.user_financier.etu_email, :statut_etu => s.statut_etu.humanize, :type => "Frais inscription", :s_type => s.s_type.humanize,
                   :rum => s.user_financier.user_financier_rib.rum, :formation => s.formation_annee.formation.nom, :school_year => s.school_year.nom, :payment_mode => payment_mode,
                   :modalite => modalite, :special_case => (s.special_case ? "Oui" : "Non"), :created_at => s.created_at.strftime("%d/%m/%Y"), :updated_at => s.updated_at.strftime("%d/%m/%Y"), :centre => s.user_financier.centre.nom }
        end
        if !s.frais_techniques_done
          payment_mode = s.payment_mode_scolarite.humanize
          modalite = ""
          data << { :RecordID => s.id, :uuid => s.user_financier.user.uuid, :id => s.user_financier.id, :user_id => s.user_financier.user_id, :etu_nom => s.user_financier.etu_nom,
                   :etu_prenom => s.user_financier.etu_prenom, :etu_email => s.user_financier.etu_email, :statut_etu => s.statut_etu.humanize, :type => "Frais techniques", :s_type => s.s_type.humanize,
                   :rum => s.user_financier.user_financier_rib.rum, :formation => s.formation_annee.formation.nom, :school_year => s.school_year.nom, :payment_mode => payment_mode,
                   :modalite => modalite, :special_case => (s.special_case ? "Oui" : "Non"), :created_at => s.created_at.strftime("%d/%m/%Y"), :updated_at => s.updated_at.strftime("%d/%m/%Y"), :centre => s.user_financier.centre.nom }
        end
        if !s.frais_scolarite_done
          payment_mode = s.payment_mode_scolarite.humanize
          modalite = "en " + s.modalite.to_s + " fois"
          data << { :RecordID => s.id, :uuid => s.user_financier.user.uuid, :id => s.user_financier.id, :user_id => s.user_financier.user_id, :etu_nom => s.user_financier.etu_nom,
                   :etu_prenom => s.user_financier.etu_prenom, :etu_email => s.user_financier.etu_email, :statut_etu => s.statut_etu.humanize, :type => "Frais scolarité", :s_type => s.s_type.humanize,
                   :rum => s.user_financier.user_financier_rib.rum, :formation => s.formation_annee.formation.nom, :school_year => s.school_year.nom, :payment_mode => payment_mode,
                   :modalite => modalite, :special_case => (s.special_case ? "Oui" : "Non"), :created_at => s.created_at.strftime("%d/%m/%Y"), :updated_at => s.updated_at.strftime("%d/%m/%Y"), :centre => s.user_financier.centre.nom }
        end
      end
    else
      subscriptions = UserFinancierSubscription.where(statut: [:partial_inscription, :partial_techniques, :active], school_year_id: session[:students_filter_school_year]).includes([:user_financier, :formation_annee, :school_year]).joins(:user_financier).where("user_financiers.centre_id IN (?)", @centres.pluck(:id))
      subscriptions.each do |s|
        if s.frais_inscription_done
          payment_mode = s.payment_mode_inscription.humanize
          modalite = ""
          done_at = s.frais_inscription_done_date.strftime("%d/%m/%Y %H:%M")
          data << { :RecordID => s.id, :uuid => s.user_financier.user.uuid, :id => s.user_financier.id, :user_id => s.user_financier.user_id, :etu_nom => s.user_financier.etu_nom,
                   :etu_prenom => s.user_financier.etu_prenom, :etu_email => s.user_financier.etu_email, :statut_etu => s.statut_etu.humanize, :type => "Frais inscription", :s_type => s.s_type.humanize,
                   :rum => s.user_financier.user_financier_rib.rum, :formation => s.formation_annee.formation.nom, :school_year => s.school_year.nom, :payment_mode => payment_mode,
                   :modalite => modalite, :special_case => (s.special_case ? "Oui" : "Non"), :done_at => done_at, :created_at => s.created_at.strftime("%d/%m/%Y"), :updated_at => s.updated_at.strftime("%d/%m/%Y"), :centre => s.user_financier.centre.nom }
        end
        if s.frais_techniques_done
          payment_mode = s.payment_mode_scolarite.humanize
          modalite = ""
          done_at = s.frais_techniques_done_date.strftime("%d/%m/%Y %H:%M")

          data << { :RecordID => s.id, :uuid => s.user_financier.user.uuid, :id => s.user_financier.id, :user_id => s.user_financier.user_id, :etu_nom => s.user_financier.etu_nom,
                   :etu_prenom => s.user_financier.etu_prenom, :etu_email => s.user_financier.etu_email, :statut_etu => s.statut_etu.humanize, :type => "Frais techniques", :s_type => s.s_type.humanize,
                   :rum => s.user_financier.user_financier_rib.rum, :formation => s.formation_annee.formation.nom, :school_year => s.school_year.nom, :payment_mode => payment_mode,
                   :modalite => modalite, :special_case => (s.special_case ? "Oui" : "Non"), :done_at => done_at, :created_at => s.created_at.strftime("%d/%m/%Y"), :updated_at => s.updated_at.strftime("%d/%m/%Y"), :centre => s.user_financier.centre.nom }
        end
        if s.frais_scolarite_done
          payment_mode = s.payment_mode_scolarite.humanize
          modalite = "en " + s.modalite.to_s + " fois"
          done_at = s.frais_scolarite_done_date.strftime("%d/%m/%Y %H:%M")
          data << { :RecordID => s.id, :uuid => s.user_financier.user.uuid, :id => s.user_financier.id, :user_id => s.user_financier.user_id, :etu_nom => s.user_financier.etu_nom,
                   :etu_prenom => s.user_financier.etu_prenom, :etu_email => s.user_financier.etu_email, :statut_etu => s.statut_etu.humanize, :type => "Frais scolarité", :s_type => s.s_type.humanize,
                   :rum => s.user_financier.user_financier_rib.rum, :formation => s.formation_annee.formation.nom, :school_year => s.school_year.nom, :payment_mode => payment_mode,
                   :modalite => modalite, :special_case => (s.special_case ? "Oui" : "Non"), :done_at => done_at, :created_at => s.created_at.strftime("%d/%m/%Y"), :updated_at => s.updated_at.strftime("%d/%m/%Y"), :centre => s.user_financier.centre.nom }
        end
      end
    end

    return data
  end
end
