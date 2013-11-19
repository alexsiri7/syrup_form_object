ActiveRecord::Schema.define(:version => 20131108103012) do
  create_table "test_items", :force => true do |t|
    t.integer   "test_item_value"
  end
end
