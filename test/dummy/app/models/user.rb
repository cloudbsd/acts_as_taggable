class User < ActiveRecord::Base
  acts_as_tagger
  acts_as_tagger_on :favorite_tags
  acts_as_tagger_on :read_tags
end
