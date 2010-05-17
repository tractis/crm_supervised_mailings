class AddSentByToMailingMails < ActiveRecord::Migration
  def self.up
    add_column :mailing_mails, :sent_by, :integer
    add_column :mailing_mails, :sent_by_email, :string
  end

  def self.down
    remove_column :mailing_mails, :sent_by
    remove_column :mailing_mails, :sent_by_email
  end
end
