class AddReadToChats < ActiveRecord::Migration[5.2]
  def change
    add_column :chats, :read, :boolean
  end
end
