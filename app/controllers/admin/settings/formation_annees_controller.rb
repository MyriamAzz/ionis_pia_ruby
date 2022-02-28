class Admin::Settings::FormationAnneesController < AdminController
  load_and_authorize_resource param_method: :params_formation_annee

  def index
    @formation = Formation.find(params[:formation_id])
  end
end
