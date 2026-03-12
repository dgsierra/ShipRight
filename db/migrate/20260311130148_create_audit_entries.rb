class CreateAuditEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :audit_entries do |t|
      t.references :auditable, polymorphic: true, null: false
      t.string :event, null: false
      t.references :user, null: true, foreign_key: true
      t.string :whodunnit
      t.jsonb :changes_data, default: {}

      t.timestamps
    end

    add_index :audit_entries, [ :auditable_type, :auditable_id ]
  end
end
