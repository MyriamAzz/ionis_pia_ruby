class Admin::Settings::FormationsController < AdminController
  load_and_authorize_resource param_method: :params_formation

  def index
    session[:formations_archived] = false
  end

  def campus
    @centre = Centre.find(params[:campus_id])
    session[:admin_manage_formations_centre] = @centre.id
    session[:formations_archived] = false
  end

  # def centres_school_years
  #   @centre = Centre.find(params[:centre_id])
  #   @school_year = SchoolYear.find(params[:school_year_id])
  #   @school_years = SchoolYear.all.where.not(id: @school_year.id)
  # end

  def new
    # @formation = Formation.new
  end

  def create
    formation = Formation.new(params_formation)
    formation.centre_id = session[:admin_manage_formations_centre]
    if formation.save
      @formations = Formation.where(centre_id: session[:admin_manage_formations_centre])
    else
      @error = true
    end
  end

  def edit
  end

  def update
    if @formation.update(params_formation)
      @formations = Formation.where(centre_id: session[:admin_manage_formations_centre])
    else
      @error = true
    end
  end

  def init_clone
    @centre = Centre.find(params[:centre_id])
  end

  def clone
    @centre = Centre.find(params[:centre_id])
    @centre_dest = Centre.find(params[:centre_dest_id])

    @centre.formations.filter_actived.each do |formation|
      if !formation.code.blank?
        formation_dest = @centre_dest.formations.where(code: formation.code).first rescue nil
        if formation_dest
          formation.formation_annees.each do |annee|
            annee_dest = annee.dup
            annee_dest.formation_id = formation_dest.id
            annee_dest.save
          end
        else
          clone = formation.deep_clone include: [:formation_annees]
          clone.centre_id = @centre_dest.id
          clone.save
        end
      else
        clone = formation.deep_clone include: [:formation_annees]
        clone.centre_id = @centre_dest.id
        clone.save
      end
    end
  end

  def destroy
    if @formation.destroy
    else
      @error = true
    end
  end

  def filter
    if params[:archived] == "true"
      session[:formations_archived] = true
    else
      session[:formations_archived] = false
    end
  end

  def json
    formations = Centre.find(session[:admin_manage_formations_centre]).formations.where(archived: session[:formations_archived])
    var = []
    formations.each do |formation|
      var << { :id => formation.id, :name => formation.nom, :product_code => formation.code, :product_account_sage => formation.compte_produit_sage, :updated_at => formation.updated_at.strftime("%d/%m/%y %H:%M") }
    end
    render json: var
  end

  private

  def params_formation
    params.require(:formation).permit!
  end
end
