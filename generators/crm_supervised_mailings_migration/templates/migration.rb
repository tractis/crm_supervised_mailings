class CrmSupervisedMailingsMigration < ActiveRecord::Migration
  def self.up
    create_table :mailings do |t|
      t.string     :name
      t.string     :status, :default => "ongoing"
      t.text       :background_info
      t.string     :email_from
      t.string     :subject
      t.text       :body
      t.text       :signature
      t.references :user
      t.integer    :assigned_to
      t.string     :access, :limit => 8, :default => "Private"
      
      t.timestamps
      t.datetime   :deleted_at
    end
    
    create_table :mailing_mails do |t|
      t.integer    :mailing_id
      t.string     :status, :default => "new"
      t.string     :subject
      t.text       :body
      t.text       :signature 
      t.references :user
      t.boolean    :needs_update, :null => false, :default => false
      
      t.references :mailable, :polymorphic => true

      t.timestamps
      t.datetime   :deleted_at
    end
    
    add_index :mailing_mails, [:mailing_id, :status]
  end
  
  def self.down
    drop_table :mailings
    drop_table :mailing_mails
  end
end
