class InboundController < ApplicationController
  protect_from_forgery except: [:create]

  def create
    puts 'Inbound Email'

    #todo: get the list from the To param (not including current senders email)
    #todo: ensure person who has sent (From) to the list is on the list.

    list = List.where(email: params[:To]).first
    from_name = params[:FromName]
    subject = params[:Subject]
    from = params[:From]

    puts "To is #{params[:To]}"
    puts "List is #{list}"

    if list.exists?
      if list.emails.map{ |x| x.email.downcase}.include? from.downcase
        puts "EMAIL IS IN THE LIST, SENDING TO #{list.email}"
        email = params
        coder = HTMLEntities.new
        html = coder.decode(email[:HtmlBody])
        message = Mail.new do
          from            "#{from_name} <team@dragons.email>" #Adjust from to be from the original author.
          bcc             list.formatted_emails_without(from) #bcc
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
        message = Mail.new do
          from "team@dragons.email"
          to from
          subject 'You must be registered to post on this group'
          body "You are sending e-mail to this group, but your e-mail is not allowed to post on the group. Sorry"
        end
        message.deliver
      end
    end
    render json: {}
  end
end
