ActiveRecord::Schema.define do
  create_table :foos do |t|
    t.string :name
  end

  create_table :bars do |t|
    t.integer :foo_id
  end
end
