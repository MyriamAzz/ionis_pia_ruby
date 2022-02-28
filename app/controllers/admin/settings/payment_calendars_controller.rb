class Admin::Settings::PaymentCalendarsController < AdminController
  load_and_authorize_resource

  def table
    school_program = current_user.user_admin.current_centre.school_program
    if params[:date]
      school_program.school_years.each do |school_year|
        if params[:date]["#{school_year.id}"]
          p "TESt"
          school_year.update(frais_inscription_jours: params[:date]["#{school_year.id}"]["frais_inscription_jours"], frais_techniques_date: params[:date]["#{school_year.id}"]["frais_techniques_date"])
          school_program.payment_plans.each do |plan|
            if params[:date]["#{school_year.id}"]["#{plan.plan}"]
              params[:date]["#{school_year.id}"]["#{plan.plan}"].each do |i, date|
                cal = school_year.payment_calendars.find_or_initialize_by(plan_order: i, plan: plan.plan)
                cal.plan_date = date
                cal.save
              end
            end
          end
        end
      end
    end
    #   params[:date].each do |school_year|
    #     p school_year
    #     school_year.each do |plan|
    #       p plan
    #       plan.each do |i|
    #         p i
    #       end
    #     end
    #   end
    # end
  end
end
