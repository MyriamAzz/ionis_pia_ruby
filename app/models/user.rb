#encoding: utf-8
class User < ApplicationRecord
  attr_accessor :skip_password_validation

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable
  validates_uniqueness_of :username, case_sensitive: true

  enum role: [:user, :admin, :super_admin, :compta, :supervisor]

  has_one :user_admin, dependent: :destroy
  has_one :user_financier, dependent: :destroy

  has_many :user_admin_centres, dependent: :destroy
  has_many :centres, -> { order(:nom) }, through: :user_admin_centres
  has_many :school_programs, -> { distinct }, through: :centres

  has_many :user_admin_school_programs, dependent: :destroy
  has_many :admin_school_programs, through: :user_admin_school_programs, source: :school_program

  # has_many :user_admin_schools, dependent: :destroy
  # has_many :schools, through: :user_admin_schools

  scope :amin_superadmin_compta, -> { joins(:user_admin).where(role: [User.roles[:admin], User.roles[:super_admin], User.roles[:compta]]).order("user_admins.nom") }

  accepts_nested_attributes_for :user_admin, update_only: true
  accepts_nested_attributes_for :user_financier, update_only: true

  before_validation :process_before_validation
  before_create :process_before_create

  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end

  def active_for_authentication?
    super and !self.archived?
  end

  def process_before_validation
    if self.username.nil?
      username = self.generate_username
      check = true
      while check
        if !User.find_by_username(username).nil?
          username = self.generate_username
        else
          self.username = username
          check = false
        end
      end
    end
  end

  def process_before_create
    self.uuid = SecureRandom.uuid
  end

  def label_role
    if self.admin?
      return '<span class="label label-gray label-inline font-weight-bold mr-2">Pédagogie</span>'
    elsif self.super_admin?
      return '<span class="label label-gray label-inline font-weight-bold mr-2"><i class="fas fa-star text-warning icon-sm mr-2"></i> Administrateur</span>'
    elsif self.compta?
      return '<span class="label label-gray label-inline font-weight-bold mr-2">Comptabilité</span>'
    end
  end

  ### Methode pour role admin, compta, super admin
  def admin_get_centres
    if self.super_admin?
      return Centre.actived
    elsif self.admin? or self.compta?
      return self.centres.actived
    end
  end

  def nom_complet
    if self.user?
      return self.user_financier.nom + " " + self.user_financier.prenom
    else
      return self.user_admin.nom + " " + self.user_admin.prenom
    end
  end

  def will_save_change_to_email?
    false
  end

  def generate_username
    return SecureRandom.alphanumeric(8)
  end

  def mailer_logo_school
    if self.user?
      logo = self.user_financier.centre.school_program.logo_color rescue nil
    else
      if !self.user_admin.current_centre.nil?
        logo = self.user_admin.current_centre.school_program.logo_color rescue nil
      else
        logo = self.centres.first.school_program.logo_color rescue nil
      end
    end
    if logo
      return logo
    else
      return "/assets/logo/logo.png"
    end
  end

  def invoice_logo_school
    if self.user?
      logo = self.user_financier.centre.school_program.logo_color.service_url rescue nil
    else
      if !self.user_admin.current_centre.nil?
        logo = self.user_admin.centre.school_program.logo_color rescue nil
      else
        logo = self.centres.first.school_program.logo_color rescue nil
      end
    end
    if logo
      return logo
    else
      return "/assets/logo/logo.png"
    end
  end

  def get_email_from
    if self.user?
      self.user_financier.centre.school_program.email_from
    else
      self.centres.first.school_program.email_from
    end
  end

  protected

  def password_required?
    return false if skip_password_validation
    super
  end
end
