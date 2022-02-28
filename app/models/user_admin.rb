class UserAdmin < ApplicationRecord
  belongs_to :user, dependent: :destroy
  before_save :format_data

  belongs_to :current_centre, class_name: "Centre", foreign_key: "centre_id", required: false

  accepts_nested_attributes_for :user, update_only: true

  after_commit :process_after_commit_create, on: :create

  def process_after_commit_create
    if self.user.admin? or self.user.super_admin? or self.user.compta? or self.user.supervisor?
      password = Devise.friendly_token.first(10)
      self.user.update(password: password)
      AdminMailer.send_credentials(self.user, password).deliver_later
    end
  end

  def format_data
    self.nom.upcase!
    self.prenom = self.prenom.titleize
  end
end
