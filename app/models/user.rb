class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2]
  # database_authenticatable: Allows users to sign in with a username and password.
  # registerable: Enables user register new account
  # recoverable: Allows users to reset their password.
  # rememberable: Manages generating and clearing a token for remembering the user from a saved cookie.
  # validatable: Validates email and password.
  # omniauthable: Enables OmniAuth support for third-party authentication.
  # omniauth_providers: Specifies the providers to use for OmniAuth, in this case: Google OAuth2.

  validates :name, presence: true
  validates :email, uniqueness: true # can't be duplicated
  validates :phone, uniqueness: true, allow_blank: true
  validates :role, inclusion: { in: %w[user admin] }

  before_validation :assign_role

  def admin?
    role == 'admin'
  end

  def can_chat_with?(other_user)
    return true if other_user.role == 'user' # Users can chat with other users
    return true if Chat.exists?(sender_id: other_user.id, receiver_id: id) # Users can chat with admins who initiated

    false
  end

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.name = auth.info.name || "User_#{Time.now.to_i}"
      user.phone = auth.info.phone || '+1234567890'
      user.role = 'user'
      user.password = Devise.friendly_token(20)
    end
  end

  private

  def assign_role
    self.role = 'user' if role.blank?
  end
end
