class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :message
      t.references :list, index: true

      t.timestamps
    end
  end
end
