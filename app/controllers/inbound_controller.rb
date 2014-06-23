class InboundController < ApplicationController
  protect_from_forgery except: [:create]

  def create
    puts 'Inbound Email'

    #todo: get the list from the To param (not including current senders email)
    #todo: ensure person who has sent (From) to the list is on the list.

    list = List.where(email: params[:To]).first
    from_name = params[:FromName]
    subject = params[:Subject]

    if list
      if list.emails.map(&:email).include? params[:From]
        puts "email #{params[:From]} is in list #{list.emails.map(&:email).inspect}"
        email = params
        coder = HTMLEntities.new
        html = coder.decode(email[:HtmlBody])
        message = Mail.new do
          from            "#{from_name} <team@dragons.email>" #Adjust from to be from the original author.
          to              'noreply@dragons.email'
          bcc             list.formatted_emails #bcc
          subject         subject
          text_part do
            body email[:TextBody]
          end

          html_part do
            content_type  'text/html; charset=UTF-8'
            body html
          end

          delivery_method Mail::Postmark, :api_key => ENV['POSTMARK_API_KEY']
        end

        message.deliver
      else
        puts "email is not in list"
        #todo: deliver a bounced email.
      end
    end
    render json: {}
  end
end
