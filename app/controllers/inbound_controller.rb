class InboundController < ApplicationController
  protect_from_forgery except: [:create]

  def create
    puts 'Inbound Email'

    #todo: get the list from the To param (not including current senders email)
    #todo: ensure person who has sent (From) to the list is on the list.

    if params[:To].include? "<"
      params[:To] = params[:To].match(/[A-Za-z\d_\-\.+]+@[A-Za-z\d_\-\.]+\.[A-Za-z\d_\-]+/)[0]
    end

    if params[:to] == params[:From]
      #this means it was sent from us!
      render json: {} and return
    end


    list = List.where(email: params[:To]).first
    from_name = params[:FromName]
    subject = params[:Subject]
    from = params[:From]

    if list
      if list.emails.map{ |x| x.email.downcase}.include? from.downcase
        email = params
        coder = HTMLEntities.new
        html = coder.decode(email[:HtmlBody])
        message = Mail.new do
          from            "#{from_name} <team@dragons.email>" #Adjust from to be from the original author.
          bcc             list.formatted_emails_without(from) #bcc
          subject         subject
          reply_to        list.email
          to              list.email
          text_part do
            body email[:TextBody]
          end

          html_part do
            content_type  'text/html; charset=UTF-8'
            body html
          end

          delivery_method Mail::Postmark, :api_key => ENV['POSTMARK_API_KEY']
        end

        unless params[:Attachments].nil?
          params[:Attachments].each do |attachment|
            message.attachments[params[:Attachments][:Name].to_s] = params[:Attachments][:Content]
          end
        end

        message.deliver
      else
        unless from.split("@").last == 'dragons.email'
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
    end
    render json: {}
  end
end
