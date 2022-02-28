class Admin::Settings::CampusController < AdminController
  load_and_authorize_resource class: "Centre", param_method: :params_centre

  def index
  end

  def new
    current_user.user_admin.current_centre.school_program.school_years.each do |school_year|
      @campu.centre_customer_accounts.build(school_year_id: school_year.id)
    end
  end

  def create
    centre = Centre.new(params_centre)
    centre.school_program = current_user.user_admin.current_centre.school_program
    if centre.save
    else
      @error = true
    end
  end

  def edit
    current_user.user_admin.current_centre.school_program.school_years.each do |school_year|
      if !@campu.centre_customer_accounts.find_by_school_year_id(school_year.id)
        @campu.centre_customer_accounts.build(school_year_id: school_year.id)
      end
    end
  end

  def update
    if @campu.update(params_centre)
    else
      @error = true
      p @campu.errors
    end
  end

  def destroy
    if @campu.destroy
    else
      @error = true
    end
  end

  def json
    centres = current_user.user_admin.current_centre.school_program.centres
    var = []
    centres.each do |centre|
      var << { :id => centre.id, :name => centre.nom, :address => "#{centre.adresse} #{centre.cp} #{centre.ville}", :siret => centre.siret, :updated_at => centre.updated_at.strftime("%d/%m/%y %H:%M") }
    end
    render json: var
  end

  private

  def params_centre
    params.require(:centre).permit!
  end
end
