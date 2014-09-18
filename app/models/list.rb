class List < ActiveRecord::Base
  has_and_belongs_to_many :emails
  has_many :smses

  default_scope { order('email ASC') }

  validates :email, uniqueness:  true

  def formatted_emails_without(from)
    slice = []
    emails.each_slice(19) do |email_group|
      formatted = ''
      email_group.each do |email|
        formatted << "#{email.name} <#{email.email}>," unless email.email == from
      end
      slice.push formatted
    end

    slice
  end

  def mandrill_emails_without(from, tos)
    formatted = []
    puts "filtering list without #{from} #{tos}"
    emails.each do |email|
      formatted << {email: email.email, name: email.name, type: 'bcc'} unless email.email == from || tos.include?(email.email)
    end

    formatted

  end
end
