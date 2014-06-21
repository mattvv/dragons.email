class InboundController < ApplicationController
  protect_from_forgery except: [:create]

  def create
    puts 'Inbound Email'

    #todo: get the list from the To param
    #todo: ensure person who has sent (From) to the list is on the list.
    email = params

    message = Mail.new do
      from            'team@dragons.email' #Adjust from to be from the original author.
      to              'Matt Van <mattv@mumsweb.net>' #use bcc to send
      bcc             'Matt Van <mattvanveenendaal@gmail.com>' #bcc
      subject         'Test Email from the Dragons'
      text_part do
        body email[:TextBody]
      end

      html_part do
        content_type  'text/html; charset=UTF-8'
        body email[:HtmlBody]
      end

      delivery_method Mail::Postmark, :api_key => ENV['POSTMARK_API_KEY']
    end

    message.deliver
    render json: {}
  end
end
