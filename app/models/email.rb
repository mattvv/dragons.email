class Email < ActiveRecord::Base
  has_and_belongs_to_many :lists

  validates :email, uniqueness:  true
end
