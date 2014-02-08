module ActsAsTaggable
  class Tag < ActiveRecord::Base
    belongs_to :user, :polymorphic => true
    has_many :taggings, :dependent => :destroy, :class_name => 'ActsAsTaggable::Tagging'

    validates :user_id, presence: true
    validates :user_type, presence: true
    validates :name, presence: true, uniqueness: true, length: { maximum: 255 }
  end
end
