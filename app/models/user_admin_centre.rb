class UserAdminCentre < ApplicationRecord
  validates_uniqueness_of :user_id, case_sensitive: true, scope: [:centre_id]

  belongs_to :user
  belongs_to :centre
end
