class Post < ActiveRecord::Base
  acts_as_taggable
  acts_as_taggable_by :favorite_tags
  acts_as_taggable_by :read_tags
end
