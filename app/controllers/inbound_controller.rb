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


    tos = List.where(email: params[:To])

    count = 0
    direct_messages = []

    tos.each do |to|
      if to
        count += 1
        from = params[:From]
        if to.emails.map{ |x| x.email.downcase}.include? from.downcase
          to.formatted_emails_without(from).each do |emails|
            send_email(emails,params, to.email)
          end
        else
          user = email_user id: to.split('@').first
          if user
            direct_messages << user
          end
        end
      end
    end

    if count == 0
      if direct_messages.count > 0
        to_emails = "";
        direct_messages.each do |dm|
          to_emails << "#{dm.name} <#{dm.email}>,"
        end
        send_email(to_emails, params, 'private@dragons.email')
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

  private

  def send_email(to_emails, params, list_email)
    email = params
    from_name = params[:FromName]
    subject = params[:Subject]
    from = params[:From]
    coder = HTMLEntities.new
    html = coder.decode(email[:HtmlBody])
    user = Email.where(email: from).first
    message = Mail.new do
      from            "#{from_name} <team@dragons.email>" #Adjust from to be from the original author.
      bcc             to_emails #bcc
      subject         subject
      reply_to        "#{user.id}@dragons.email"
      to              list_email
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
        message.attachments[attachment[:Name]] =  Base64.decode64 attachment[:Content]
      end
    end

    message.deliver
  end

  def email_user(id)
    Email.where(id: id).first
  end
end
