Trestle.resource(:schools) do

  menu do
    item :schools, icon: "fa fa-school", label: "Écoles"
  end

 

  table do
    column :nom, header: "Nom"
    column :couleur, header: "Couleur"
    column :updated_at, header: "Modification"
    column :created_at, header: 'Ajoutée le'
  end

  form dialog: true do |ecole|
    text_field :nom, label: "Nom *", required: true
    color_field :couleur, label: "Couleur *", required: true
    text_field :grape_api_token, label: "API Token", readonly: true
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
  # form do |school|
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
  #   params.require(:school).permit(:name, ...)
  # end
end
