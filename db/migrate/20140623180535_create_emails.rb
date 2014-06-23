class CreateEmails < ActiveRecord::Migration
  def change
    create_table :emails do |t|
      t.string :email
      t.references :list, index: true
      t.string :name

      t.timestamps
    end
  end
end
