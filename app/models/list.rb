class List < ActiveRecord::Base
  has_many :emails

  def formatted_emails_without(from)
    formatted = ''
    emails.each do |email|
      formatted << "#{email.name} <#{email.email}>," unless email.email == from
    end
    formatted
  end
end
