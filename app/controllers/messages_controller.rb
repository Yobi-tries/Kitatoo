class MessagesController < ApplicationController
  def create
    conversation = Conversation.find(params[:conversation_id])
    unless conversation.participant?(current_user)
      return redirect_to root_path, alert: "You don't have access to this chat."
    end

    message = conversation.messages.new(message_params)
    message.user = current_user

    if message.save
      redirect_to conversation
    else
      @conversation = conversation
      @messages = conversation.messages.order(:created_at)
      @message = message
      render "conversations/show", status: :unprocessable_entity
    end
  end

  private

  def message_params
    params.require(:message).permit(:body)
  end
end
