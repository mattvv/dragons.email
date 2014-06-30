class MessagesController < ApplicationController
  def index
    @message = Message.new
  end

  def create
    message = Message.create(params[:message].permit(:list_id, :message))

    account_sid = 'ACfc5d0b5f589d2de22b0aa9f54d6c6862'
    auth_token = '9fccaf117492c602f25fdb2101f306b0'

    @client = Twilio::REST::Client.new account_sid, auth_token

    message.list.emails.each do |email|
      if email.phone_number
        @client.account.messages.create(
            :from => '+13238928500',
            :to => "+1#{email.phone_number}",
            :body => message.message
        )
      end
    end

    flash[:success] = "Your SMS was sent to #{message.list.email}"

    redirect_to :back
  end
end
