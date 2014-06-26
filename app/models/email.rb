class Email < ActiveRecord::Base
  has_and_belongs_to_many :lists

  default_scope { order('name ASC') }

  validates :email, uniqueness:  true
end
