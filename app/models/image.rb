class Image < ApplicationRecord
  def self.created_after(date)
    where("imageurl like ?", "%#{date}%")
  end
end
