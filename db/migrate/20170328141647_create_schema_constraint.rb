class CreateSchemaConstraint < ActiveRecord::Migration[5.0]
  def change
    create_table :schema_constraints do |t|
      t.references  :schema_field
      t.boolean     :required
      t.boolean     :unique
      t.integer     :min_length
      t.integer     :max_length
      t.text        :minimum # Could be a date string for example
      t.text        :maximum # Could be a date string for example
      t.text        :pattern
      t.text        :type
    end
  end
end
