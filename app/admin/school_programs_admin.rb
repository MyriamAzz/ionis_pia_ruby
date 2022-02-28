#encoding: utf-8
Trestle.resource(:school_programs) do
  menu do
    item :school_programs, icon: "fa fa-school", label: "Programmes"
  end

  active_storage_fields do
    [:logo, :logo_color, :bank_details, :resp_signature]
  end

  table do
    column :nom, header: "Nom"
    column :school, header: "École", format: :tags do |programme|
      programme.school.nom
    end
    column :updated_at, header: "Modification"
    column :created_at, header: "Ajoutée le"
  end

  form dialog: true do |ecole|
    collection_select :school_id, School.all.order(:nom), :id, :nom, { label: "École", required: true, prompt: true }
    text_field :nom, label: "Nom *", required: true
    text_field :adresse, label: "Adresse *", required: true
    text_field :cp, label: "CP *", required: true
    text_field :ville, label: "Ville *", required: true
    text_field :resp_nom, label: "Nom responsable", required: false
    text_field :resp_prenom, label: "Prénom responsable", required: false
    text_field :resp_fonction, label: "Fonction responsable", required: false
    active_storage_field :resp_signature, label: "Signature responsable"
    text_field :ics, label: "Identifiant Créancier SEPA", required: false
    text_field :email_from, label: "Email From *", required: true
    text_field :email_contact, label: "Email contact RF", required: false

    text_field :footer_1, label: "Doc - Footer 1", required: false
    text_field :footer_2, label: "Doc - Footer 2", required: false
    check_box :gocardless_general, label: "Compte GoCardless commun"
    active_storage_field :bank_details, label: "RIB"
    active_storage_field :logo, label: "Logo blanc"
    active_storage_field :logo_color, label: "Logo couleur"
  end

  # Customize the table columns shown on the index view.
  #
  # table do
  #   column :name
  #   column :created_at, align: :center
  #   actions
  # end

  # Customize the form fields shown on the new/edit views.
  #
  # form do |school_program|
  #   text_field :name
  #
  #   row do
  #     col { datetime_field :updated_at }
  #     col { datetime_field :created_at }
  #   end
  # end

  # By default, all parameters passed to the update and create actions will be
  # permitted. If you do not have full trust in your users, you should explicitly
  # define the list of permitted parameters.
  #
  # For further information, see the Rails documentation on Strong Parameters:
  #   http://guides.rubyonrails.org/action_controller_overview.html#strong-parameters
  #
  # params do |params|
  #   params.require(:school_program).permit(:name, ...)
  # end
end
