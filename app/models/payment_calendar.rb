class PaymentCalendar < ApplicationRecord
  validates_uniqueness_of :school_year_id, case_sensitive: true, scope: [:plan, :plan_order]

  belongs_to :school_year
end
