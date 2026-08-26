module ConversationsHelper
  def format_conversation_time(time)
    if time.today?
      time.strftime("%H:%M")
    elsif time.yesterday?
      "Yesterday"
    else
      "#{time_ago_in_words(time)} ago"
    end
  end
end
