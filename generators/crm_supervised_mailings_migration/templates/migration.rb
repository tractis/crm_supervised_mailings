class CrmSupervisedMailingsMigration < ActiveRecord::Migration
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
      t.string     :attachment_file_name
      t.string     :attachment_content_type
      t.integer    :attachment_file_size
      t.datetime   :attachment_updated_at
      
      t.timestamps
      t.datetime   :deleted_at
    end
    
    create_table :mailing_mails do |t|
      t.integer    :mailing_id
      t.string     :status, :default => "new"
      t.string     :subject
      t.text       :body 
      t.references :user
      t.boolean    :needs_update, :null => false, :default => false
      t.string     :needs_update_help
      
      t.references :mailable, :polymorphic => true

      t.timestamps
      t.datetime   :deleted_at
      t.datetime   :sent_at
    end
    
    add_index :mailing_mails, [:mailing_id, :status]
  end
  
  def self.down
    drop_table :mailings
    drop_table :mailing_mails
  end
end
