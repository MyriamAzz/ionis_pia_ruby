class Admin::Accounting::PayoutsController < AdminController
  load_and_authorize_resource

  def index
    Payout.sync_gc_payouts
  end

  def export
    filename = "ECR_CPTA_#{Date.today.strftime("%d%m%y")}_#{@payout.gc_reference}"
    send_data "\uFEFF" + @payout.csv_export(true, current_user), filename: "#{filename}.csv"
  end

  def json
    data = []
    if current_user.user_admin.current_centre.school_program.gocardless_general
      payouts = current_user.user_admin.current_centre.school_program.payouts.order(gc_arrival_at: :desc)
    else
      payouts = Payout.where(centre_id: @centres.pluck(:id)).order(gc_arrival_at: :desc)
    end
    payouts.each do |p|
      data << { id: p.id, gc_id: p.gc_id, gc_reference: p.gc_reference, gc_status: p.gc_status, gc_amount: p.gc_amount,
                gc_created_at: p.gc_created_at.strftime("%d/%m/%Y"), gc_arrival_at: p.gc_arrival_at.strftime("%d/%m/%Y"),
                exported: p.exported, exported_at: (p.exported_at.strftime("%d/%m/%Y") rescue nil) }
    end
    render json: data
  end
end
