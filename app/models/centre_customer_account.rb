class CentreCustomerAccount < ApplicationRecord
  validates_uniqueness_of :school_year, case_sensitive: true, scope: :centre

  belongs_to :school_year
  belongs_to :centre
end
