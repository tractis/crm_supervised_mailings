class CrmSupervisedMailingsMigration < ActiveRecord::Migration
  def self.up
    create_table :mailings do |t|
      t.string     :name
      t.string     :status
      t.text       :description
      t.string     :email_from
      t.string     :subject
      t.text       :body
      t.text       :signature
      t.references :user
      
      t.timestamps
    end
    
    create_table :mailing_mails do |t|
      t.integer    :mailing_id
      t.string     :status
      t.string     :subject
      t.text       :body
      t.text       :signature 
      t.references :user
      
      t.references :mailable, :polymorphic => true

      t.timestamps
    end
    
    add_index :mailing_mails, [:mailing_id, :status]
  end
  
  def self.down
    drop_table :mailings
    drop_table :mailing_mails
  end
end
