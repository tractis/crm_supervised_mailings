class CreateMailings < ActiveRecord::Migration
  def self.up
    create_table :mailings do |t|
      t.string     :name
      t.string     :status, :default => "open"
      t.text       :background_info
      t.string     :subject
      t.text       :body
      t.string     :sent_folder
      t.references :user
      t.integer    :assigned_to
      t.string     :access, :limit => 8, :default => "Private"
      t.string     :attc_file_name
      t.string     :attc_content_type
      t.integer    :attc_file_size
      t.datetime   :attc_updated_at
      
      t.timestamps
      t.datetime   :deleted_at
    end
  end
  
  def self.down
    drop_table :mailings
  end
end
