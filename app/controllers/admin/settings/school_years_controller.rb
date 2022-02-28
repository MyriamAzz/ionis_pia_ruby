class Admin::Settings::SchoolYearsController < AdminController
  load_and_authorize_resource param_method: :params_school_year

  def index
  end

  def new
  end

  def create
    school_year = SchoolYear.new(params_school_year)
    school_year.school_program = current_user.user_admin.current_centre.school_program
    if school_year.save
    else
      @error = true
    end
  end

  def edit
  end

  def update
    if @school_year.update(params_school_year)
    else
      @error = true
    end
  end

  def destroy
    if @school_year.destroy
    else
      @error = true
    end
  end

  def json
    school_years = current_user.user_admin.current_centre.school_program.school_years
    var = []
    school_years.each do |school_year|
      var << { :id => school_year.id, :name => school_year.nom, :start => school_year.debut.strftime("%d/%m/%Y"), :end => school_year.fin.strftime("%d/%m/%Y"), :updated_at => school_year.updated_at.strftime("%d/%m/%y %H:%M") }
    end
    render json: var
  end

  private

  def params_school_year
    params.require(:school_year).permit!
  end
end
