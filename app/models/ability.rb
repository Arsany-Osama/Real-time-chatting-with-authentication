class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # if not user, guest user to avoid nil errors

    if user.admin?
      can :manage, User # read, create, update
      can :chat_with, User # chat with anyone
    else
      can :read, User # read other users
      can :chat_with, User do |other_user| # chat with other users
        user.can_chat_with?(other_user)
      end
      can :index, User do |other_user| # can see pages of other users
        user.can_chat_with?(other_user)
      end
    end
    # chat message: owner of the message can edit, update, destroy
    can %i[edit update destroy], Chat, sender_id: user.id
  end
end
