#encoding: utf-8
Trestle.resource(:centres) do
  menu do
    item :centres, icon: "fa fa-star", label: "Campus"
  end

  active_storage_fields do
    [:bank_details]
  end

  table do
    column :nom, header: "Nom"
    column :school_program, header: "Programme (école)", format: :tags do |centre|
      centre.school_program.select_nom rescue nil
    end
    column :updated_at, header: "Modification"
    column :created_at, header: "Ajoutée le"
  end

  form dialog: true do |centre|
    collection_select :school_program_id, SchoolProgram.all.order(:nom), :id, :select_nom, { label: "Programme *", required: true, prompt: true }
    text_field :nom, label: "Nom *", required: true
    text_field :adresse, label: "Adresse *", required: true
    text_field :cp, label: "CP *", required: true
    text_field :ville, label: "Ville *", required: true
    text_field :ics, label: "Identifiant Créancier SEPA", required: false

    text_field :gocardless_token, label: "Gocardless Token", required: false
    # text_field :gocardless_endpoint_secret, label: "Gocardless endpoint secret", required: false
    active_storage_field :bank_details, label: "RIB"
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
  # form do |centre|
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
  #   params.require(:centre).permit(:name, ...)
  # end
end
