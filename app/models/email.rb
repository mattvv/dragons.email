class Email < ActiveRecord::Base
  has_and_belongs_to_many :lists

  default_scope { order('name ASC') }

  validates :email, uniqueness:  true

  def self.not_in_list(list)
    if list.emails.count > 0
      Email.where('id not in (?)', list.emails.all.map(&:id)).all
    else
      Email.all
    end
  end
end
