class List < ActiveRecord::Base
  has_and_belongs_to_many :emails

  default_scope { order('email ASC') }

  validates :email, uniqueness:  true

  def formatted_emails_without(from)
    formatted = ''
    emails.each do |email|
      formatted << "#{email.name} <#{email.email}>," unless email.email == from
    end
    formatted
  end
end
