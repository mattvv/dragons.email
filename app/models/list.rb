class List < ActiveRecord::Base
  has_many :emails

  def formatted_emails
    formatted = ''
    emails.each do |email|
      formatted << "#{email.name} <#{email.email}>,"
    end
    formatted
  end
end
