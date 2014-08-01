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


    tos = params[:To].split(", ")


    count = 0
    direct_messages = []
    list_sent = false
    from = params[:From]

    tos.each do |to|
      list = List.where(email: to).first
      if list
        count += 1
        if list.emails.map{ |x| x.email.downcase}.include? from.downcase
          list.formatted_emails_without(from).each do |emails|
            puts "sending a message to group address #{list.email}"
            send_email(emails,params, list.email)
            list_sent = true
          end
        end
      else
        user = email_user to.split('@').first
        if user
          puts "got the email! #{user}"
          direct_messages << user
        end
      end
    end

    if count == 0
      if direct_messages.count > 0 && !list_sent
        to_emails = "";
        direct_messages.each do |dm|
          to_emails << "#{dm.name} <#{dm.email}>,"
        end
        puts "sending a message to private addresses #{to_emails}"
        send_email(to_emails, params, 'private@dragons.email')
      elsif !list_sent
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
      to              "#{params[:FromName]} <#{list_email}>"
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
    puts 'trying to find email! ' + id
    Email.where(id: id).first
  end
end
