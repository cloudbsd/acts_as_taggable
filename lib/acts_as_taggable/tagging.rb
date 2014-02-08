module ActsAsTaggable
  class Tagging < ActiveRecord::Base
    belongs_to :tag, :class_name => 'ActsAsTaggable::Tag'
    belongs_to :tagger, :polymorphic => true
    belongs_to :taggable, :polymorphic => true

    validates :tag_id, presence: true
  # validates :tagger, presence: true
    validates :taggable, presence: true
    validates :context, presence: true, length: { maximum: 128 }
  end
end
