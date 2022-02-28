class User::SupportsController < UserController
  authorize_resource :class => false

  def show
  end
end
