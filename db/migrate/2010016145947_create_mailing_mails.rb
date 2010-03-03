class CreateMailingMails < ActiveRecord::Migration
  def self.up
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
    drop_table :mailing_mails
  end
end
