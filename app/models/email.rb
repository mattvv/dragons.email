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

  def self.import(file)
    spreadsheet = open_spreadsheet(file)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      email = find_by_id(row['id']) || new
      email.attributes = row.to_hash.slice(*accessible_attributes)
      email.save!
    end
  end

  def self.open_spreadsheet(file)
    case File.extname(file.original_filename)
      when '.csv' then Roo::Csv.new(file.path)
      when '.xls', '.xlsm' then Roo::Excel.new(file.path)
      when '.xlsx' then Roo::Excelx.new(file.path)
      else raise "Unknown file type: #{file.original_filename}"
    end
  end
end
