module ActsAsTaggable
  module Taggable
    module Methods
      extend ActiveSupport::Concern

      self.included do
      end

      module ClassMethods
        def is_taggable?
          true
        end
      end # module ClassMethods

      def tag_by?(tag, tagger, context)
        if tagger.nil?
          self.taggings.find_by(tag: tag, context: context).present?
        else
          self.taggings.find_by(tag: tag, tagger: tagger, context: context).present?
        end
      end

      def tag_by(tag, tagger, context)
        self.taggings.create(tag: tag, tagger: tagger, context: context)
      end

      def untag_by(tag, tagger, context)
        if tagger.nil?
          self.taggings.where(tag: tag, context: context).destroy_all
        else
          self.taggings.where(tag: tag, tagger: tagger, context: context).destroy_all
        end

      # if context.nil?
      #   self.taggings.where(tagger: tagger).delete_all
      # else
      #   conditions = []
      #   context.each do |act|
      #     conditions << "context = '#{act}'"
      #   end
      #   self.taggings.where(tagger: tagger).where(conditions.join(" or ")).destroy_all
      # end
      end
    end # module Methods
  end # module Taggable
end # module ActsAsTaggable
