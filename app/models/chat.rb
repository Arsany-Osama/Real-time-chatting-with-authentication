class Chat < ApplicationRecord
  belongs_to :sender, class_name: 'User'
  belongs_to :receiver, class_name: 'User'
  before_create :set_default_read_status
  after_create_commit :broadcast_message
  after_create_commit :broadcast_notification
  after_update_commit :broadcast_update
  after_destroy_commit :broadcast_destroy

  private

  def set_default_read_status
    self.read = false # Default to unread for the receiver
  end

  def broadcast_message
    ActionCable.server.broadcast(
      "chat_#{[sender_id, receiver_id].sort.join('_')}",
      action: 'create',
      id: id,
      sender_id: sender_id,
      receiver_id: receiver_id,
      sender_name: sender.name,
      message: message,
      read: read
    )
  end

  def broadcast_notification
    ActionCable.server.broadcast(
      "notifications_#{receiver_id}",
      action: 'new_message',
      sender_id: sender_id,
      sender_name: sender.name,
      message: message,
      chat_path: "/chats/#{sender_id}"
    )
  end

  def broadcast_update
    ActionCable.server.broadcast(
      "chat_#{[sender_id, receiver_id].sort.join('_')}",
      action: 'update',
      id: id,
      message: message
    )
  end

  def broadcast_destroy
    ActionCable.server.broadcast(
      "chat_#{[sender_id, receiver_id].sort.join('_')}",
      action: 'destroy',
      id: id
    )
  end
end
