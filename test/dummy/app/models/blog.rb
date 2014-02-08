class Blog < ActiveRecord::Base
  acts_as_taggable
  acts_as_taggable_by :favorite_tags
end
