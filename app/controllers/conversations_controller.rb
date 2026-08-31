class ConversationsController < ApplicationController
  def index
    if current_user.artist_profile
      artist_conversations = current_user.artist_profile.conversations
    else
      artist_conversations = []
    end

    @conversations = (current_user.conversations + artist_conversations).uniq.sort_by(&:updated_at).reverse
  end

  def show
    @conversation = Conversation.find(params[:id])
    unless @conversation.participant?(current_user)
      return redirect_to root_path, alert: "You don't have access to this chat."
    end

    @messages = @conversation.messages.order(:created_at)
    @message = Message.new
  end

  def new
    @artist_profile = ArtistProfile.find(params[:artist_profile_id])
    existing_conversation = Conversation.find_by(client: current_user, artist_profile: @artist_profile)
    return redirect_to existing_conversation if existing_conversation

    @conversation = Conversation.new(artist_profile: @artist_profile, client: current_user)
    @message = @conversation.messages.build
  end

  def create
    artist_profile = ArtistProfile.find(params[:artist_profile_id])
    conversation = Conversation.find_or_create_by!(client: current_user, artist_profile: artist_profile)
    message = conversation.messages.new(message_params)
    message.user = current_user
    if params.dig(:message, :photo).present?
      upload = Cloudinary::Uploader.upload(params[:message][:photo].tempfile.path)
      message.photo_url = upload["secure_url"]
      message.photo_public_id = upload["public_id"]
    end

    if message.save
      redirect_to conversation
    else
      @artist_profile = artist_profile
      @conversation = conversation
      @message = message
      render :new, status: :unprocessable_entity
    end
  end

  private

  def message_params
    params.require(:message).permit(:body)
  end
end
