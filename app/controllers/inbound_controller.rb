require 'mandrill'

class InboundController < ApplicationController
  protect_from_forgery except: [:create]

  def create
    puts 'Inbound Email'

    #todo: get the list from the To param (not including current senders email)
    #todo: ensure person who has sent (From) to the list is on the list.

    # if params[:To].include? "<"
    #   params[:To] = params[:To].match(/[A-Za-z\d_\-\.+]+@[A-Za-z\d_\-\.]+\.[A-Za-z\d_\-]+/)[0]
    # end

    if params[:to] == params[:From]
      #this means it was sent from us!
      render json: {} and return
    end


    tos = params[:To].split(", ") + params[:Cc].split(", ")

    count = 0
    direct_messages = []
    list_sent = false
    from = params[:From]

    unless from.split("@").last == 'dragons.email'
      tos.each do |to|
        puts "applying scan to #{to}"
        to = to.match(/[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,5}/i)[0]
        puts "checking to #{to}"
        list = List.where(email: to).first
        if list
          count = count + 1
          if list.emails.map{ |x| x.email.downcase}.include? from.downcase
            puts "Sending mail to list! #{list.email}"
            send_email list.mandrill_emails_without(from, tos), params, list.email
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
          to_emails = []
          direct_messages.each do |dm|
            to_emails << {name: dm.name, email: dm.email, type: 'to'}
          end
          puts "sending a message to private addresses #{to_emails}"
          send_email(to_emails, params)
        elsif !list_sent
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

  def send_email(to_emails, params, list_email='')
    mandrill = Mandrill::API.new ENV['MANDRILL_APIKEY']

    coder = HTMLEntities.new
    html = coder.decode(params[:HtmlBody])
    user = Email.where(email: params[:From]).first

    unless list_email.blank?
      to_emails = to_emails
    end
    message = {
        subject: params[:Subject],
        from_name: params[:FromName],
        from_email: "#{user.id}@dragons.email",
        text: params[:TextBody],
        html: html,
        to: to_emails,
        headers: { "Reply-To" => user.email }
    }

    unless params[:Attachments].nil?
      message[:attachments] = []
      params[:Attachments].each do |attachment|
        message[:attachments] << { type: attachment[:ContentType], name: attachment[:Name], content: attachment[:Content] }
      end
    end

    sending = mandrill.messages.send message
    puts "did we sent message? #{sending}"

    # email = params
    # from_name = params[:FromName]
    # subject = params[:Subject]
    # from = params[:From]
    # coder = HTMLEntities.new
    # html = coder.decode(email[:HtmlBody])
    # user = Email.where(email: from).first
    # message = Mail.new do
    #   from            "#{from_name} <team@dragons.email>" #Adjust from to be from the original author.
    #   bcc             to_emails #bcc
    #   subject         subject
    #   reply_to        "#{params[:FromName]} <#{user.id}@dragons.email>"
    #   to              list_email
    #   text_part do
    #     body email[:TextBody]
    #   end
    #
    #   html_part do
    #     content_type  'text/html; charset=UTF-8'
    #     body html
    #   end
    #
    #   delivery_method Mail::Postmark, :api_key => ENV['POSTMARK_API_KEY']
    # end
    #
    #
    #
    # message.deliver
  end

  def email_user(id)
    puts 'trying to find email! ' + id
    Email.where(id: id).first
  end
end
