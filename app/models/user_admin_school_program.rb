class UserAdminSchoolProgram < ApplicationRecord
  validates_uniqueness_of :user_id, case_sensitive: true, scope: [:school_program_id]

  belongs_to :school_program
  belongs_to :user
end
