Trestle.resource(:user_admin_centres) do
  menu do
    item :user_admin_centres, icon: "fa fa-star", label: "Droits Campus"
  end

  # Customize the table columns shown on the index view.
  #
  table do
    column :user, header: "Utilisateur" do |user_admin_centre|
      user_admin_centre.user.email
    end

    column :campus, header: "Campus" do |user_admin_centre|
      user_admin_centre.centre.nom
    end

    column :campus, header: "École / Programme" do |user_admin_centre|
      user_admin_centre.centre.school_program.label_school_program
    end

    column :created_at, align: :center
    actions
  end

  form dialog: true do |centre|
    collection_select :centre_id, Centre.all.order(:nom), :id, :select_nom, { label: "Centre *", required: true, prompt: true }
    collection_select :user_id, User.amin_superadmin_compta, :id, :email, { label: "Utilisateur *", required: true, prompt: true }

  end

  # Customize the form fields shown on the new/edit views.
  #
  # form do |user_admin_centre|
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
  #   params.require(:user_admin_centre).permit(:name, ...)
  # end
end
