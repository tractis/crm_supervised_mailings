class Mailing < ActiveRecord::Base
  has_many    :mailing_mails, :dependent => :destroy

  def self.statuses
    ["ongoing", "rejected", "finished"]
  end
end
