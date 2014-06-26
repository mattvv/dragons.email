class EmailsAsMany < ActiveRecord::Migration
  def change
    create_table :emails_lists do |t|
      t.belongs_to :email
      t.belongs_to :list
    end

    remove_column :emails, :list_id
  end
end
