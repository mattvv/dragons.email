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

      row['email'] = row['Email'] if row['Email']
      email = Email.find_by_email(row['email'].downcase) || new
      if row['First Name'] || row['Last Name']
        row['name'] = "#{row['First Name']} #{row['Last Name']}"
      end
      email.email = row['email'].downcase if row['email']
      email.name = row['name'] if row['name']
      email.phone_number = row['phone'] if row['phone']
      email.phone_number = row['Phone Number'] if row['Phone Number']

      email.note = ''

      if row['note'] && !email.note.include?(row['note'])
        email.note = "#{email.note}, #{row['note']}"
      end

      if row['Note'] && !email.note.include?(row['Note'])
        email.note = "#{email.note}, #{row['Note']}"
      end

      if row['Groups'] && email.note && !email.note.include?(row['Groups'])
        email.note = "#{email.note}, #{row['Groups']}"
      end
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
