class ChatsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_chat, only: %i[edit update destroy]

  def index
    @users = User.select { |u| can?(:chat_with, u) }
    Rails.logger.debug("Current user: #{current_user.email}, Role: #{current_user.role}")
    Rails.logger.debug("Available users for chat: #{@users.map { |u| [u.id, u.email, u.role] }.inspect}")
    respond_to do |format|
      format.html
      format.json { render json: @users }
    end
  end

  def show
    @receiver = User.find(params[:id])
    authorize! :chat_with, @receiver
    @chats = Chat.where(
      sender_id: [current_user.id, @receiver.id],
      receiver_id: [current_user.id, @receiver.id]
    ).order(:created_at)
    if @receiver.id != current_user.id
      @chats.where(sender_id: @receiver.id, receiver_id: current_user.id, read: false).update_all(read: true)
      # Broadcast updated unread count and messages
      unread_count = Chat.where(receiver_id: current_user.id, read: false).count
      unread_messages = Chat.where(receiver_id: current_user.id, read: false).order(created_at: :desc).limit(5).map do |chat|
        {
          sender_id: chat.sender_id,
          sender_name: chat.sender.name,
          message: chat.message,
          time_ago: ActionView::Base.new.time_ago_in_words(chat.created_at)
        }
      end
      unread_count_per_sender = Chat.where(receiver_id: current_user.id, read: false)
                                    .group(:sender_id)
                                    .count
      ActionCable.server.broadcast(
        "notifications_#{current_user.id}",
        action: 'read_messages',
        unread_count: unread_count,
        messages: unread_messages,
        unread_count_per_sender: unread_count_per_sender
      )
    end
    Rails.logger.debug("Loaded chats: #{@chats.map { |c| [c.sender_id, c.receiver_id, c.message, c.read] }.inspect}")
    @chat = Chat.new
    respond_to do |format|
      format.html
      format.json { render json: @chats }
    end
  end

  def create
    @chat = Chat.new(chat_params)
    @chat.sender = current_user
    @chat.read = false # Explicitly set to false for receiver
    authorize! :chat_with, @chat.receiver
    respond_to do |format|
      if @chat.save
        format.html { redirect_to chat_path(@chat.receiver), notice: 'Message sent.' }
        format.json { render json: @chat, status: :created }
      else
        format.html { render :show }
        format.json { render json: @chat.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    authorize! :edit, @chat
    respond_to do |format|
      format.js
    end
  end

  def update
    authorize! :update, @chat
    respond_to do |format|
      if @chat.update(chat_params)
        format.html { redirect_to chat_path(@chat.receiver), notice: 'Message updated.' }
        format.json { render json: { id: @chat.id, message: @chat.message }, status: :ok }
      else
        format.html { render :show }
        format.json { render json: @chat.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize! :destroy, @chat
    @chat.destroy
    respond_to do |format|
      format.html { redirect_to chat_path(@chat.receiver), notice: 'Message deleted.' }
      format.json { head :no_content }
    end
  end

  private

  def set_chat
    @chat = Chat.find(params[:id])
  end

  def chat_params
    params.require(:chat).permit(:receiver_id, :message)
  end
end
