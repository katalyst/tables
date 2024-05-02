class ChangeFaqToRichText < ActiveRecord::Migration[7.1]
  def change
    remove_column :faqs, :answer, :string
    add_column :faqs, :answer, :text
  end
end
