module ActsAsTaggable
  module Tagger
    module Methods
      extend ActiveSupport::Concern

      self.included do
      end

      module ClassMethods
        def is_tagger?
          true
        end
      end # module ClassMethods

      def tag?(tag, taggable, context)
        self.taggings.find_by(tag: tag, taggable: taggable, context: context).present?
      end

      def tag(tag, taggable, context)
        self.taggings.create(tag: tag, taggable: taggable, context: context)
      end

      def untag(tag, taggable, context)
        self.taggings.where(tag: tag, taggable: taggable, context: context).destroy_all
      end
    end # module Methods
  end # module Tagger
end # module ActsAsTaggable
