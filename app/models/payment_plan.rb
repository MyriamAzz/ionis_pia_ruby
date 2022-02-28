class PaymentPlan < ApplicationRecord
  validates_uniqueness_of :plan, case_sensitive: true, scope: [:school_program_id]

  belongs_to :school_program

  # enum plan: { plan_1: 1, plan_2: 2, plan_3: 3, plan_4: 4, plan_5: 5, plan_6: 6, plan_7: 7, plan_8: 8, plan_9: 9, plan_10: 10 }

  def self.select_plans
    tab = []
    (1..10).each do |i|
      tab << ["#{i} fois", i]
    end
    return tab
  end
end
