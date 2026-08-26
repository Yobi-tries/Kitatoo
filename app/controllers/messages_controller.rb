class MessagesController < ApplicationController
  def create
    @conversation = Conversation.find(params[:conversation_id])
    unless @conversation.participant?(current_user)
      return redirect_to root_path, alert: "You don't have access to this chat."
    end

    @message = @conversation.messages.new(message_params)
    @message.user = current_user
    @message.save
    @messages = @conversation.messages.order(:created_at) unless @message.persisted?

    respond_to_message
  end

  private

  def respond_to_message
    respond_to do |format|
      format.turbo_stream { render status: @message.persisted? ? :ok : :unprocessable_entity }
      format.html do
        if @message.persisted?
          redirect_to @conversation
        else
          render "conversations/show", status: :unprocessable_entity
        end
      end
    end
  end

  def message_params
    params.require(:message).permit(:body)
  end
end
