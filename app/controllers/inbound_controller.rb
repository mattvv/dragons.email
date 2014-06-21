class InboundController < ApplicationController
  protect_from_forgery except: [:create]

  def create
    puts 'Inbound Email'
    email = Postmark::Json.decode params


    message = Mail.new do
      from            'team@ladragons.com'
      to              'Matt Van <mattv@mumsweb.net>'
      subject         'Test Email from the Dragons'
      text_part do
        body email[:TextBody]
      end

      html_part do
        body email[:HtmlBody]
      end

      delivery_method Mail::Postmark, :api_key => ENV['POSTMARK_API_KEY']
    end

    message.deliver
    render json: {}
  end
end
