class AccountsUser < ApplicationRecord
  include Discard::Model
  # Would prefer to not have optional: true but seems to be
  # required for validation despite accepts_nested_attributes_for
  # https://github.com/rails/rails/issues/25198#issuecomment-372894070
  belongs_to :account, inverse_of: :accounts_users, optional: true
  counter_culture :account, column_name: :active_users_count, delta_magnitude: proc { |model| model.active? ? 1 : 0 }
  belongs_to :user, autosave: true, inverse_of: :accounts_users
  enum role: %i(admin user)

  accepts_nested_attributes_for :user

  validates :user, uniqueness: {
    scope: :account_id,
    message: 'User already exists in this account.'
  }

  scope :admins, -> { Apartment::Tenant.switch('public') { AccountsUser.with_role(:admin) } }

  delegate :email, to: :user
  delegate :name, to: :user
  delegate :avatar, to: :user

  def owner?
    Apartment::Tenant.switch('public') { account.owner_au == self }
  end

  def public_has_role?(role)
    Apartment::Tenant.switch('public') do
      self.has_role? role
    end
  end

  def active?
    !discarded? \
    && user.invitation_accepted_at.present?
  end
end
