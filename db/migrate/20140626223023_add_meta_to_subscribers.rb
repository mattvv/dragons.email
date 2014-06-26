class AddMetaToSubscribers < ActiveRecord::Migration
  def change
    add_column :emails, :phone_number, :string
    add_column :emails, :note, :text
  end
end
