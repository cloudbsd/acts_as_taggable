require 'active_support'
require 'active_model'
require 'active_record'

require "acts_as_taggable/version"
require "acts_as_taggable/tag"
require "acts_as_taggable/tagging"
require "acts_as_taggable/tagger"
require "acts_as_taggable/taggable"

module ActsAsTaggable
  extend ActiveSupport::Concern

  included do
  end

  module ClassMethods
    def acts_as_taggable(options={})
      do_acts_as_taggable(options)
    end

    # context_tags = :favorite_users
    #   names = favorite_users
    #   names[0] = favorite_users
    #   context = names[1] = 'favorite'
    #   names[2] = users
    #   context_taggings = favorite_taggings
    def acts_as_taggable_by(context_tags, options={})
      do_acts_as_taggable(options)

      if context_tags.present?
      # names = /(.+?)_(.+)/.match(context_tags.to_s)
        names = /(.+?)_tags/.match(context_tags.to_s)
        context = names[1]
        context_taggings = (context + '_taggings').to_sym

        has_many context_taggings, -> { where(context: context) }, as: :taggable, dependent: :destroy, class_name: 'ActsAsTaggable::Tagging'
        has_many context_tags, through: context_taggings, source: :tag, class_name: "ActsAsTaggable::Tag"

        context_list = (context + '_list').to_sym
        scope context_list, -> { "true, false" }

        do_generate_taggable_methods(context)
      end
    end # acts_as_taggable_by

    def acts_as_tagger(options={})
      do_acts_as_tagger(options)
    end

    def acts_as_tagger_on(context_tags, options={})
      do_acts_as_tagger(options)

      if context_tags.present?
      # names = /(.+?)_(.+)/.match(context_tags.to_s)
        names = /(.+?)_tags/.match(context_tags.to_s)
        context = names[1]
        context_taggings = (context + '_taggings').to_sym

        has_many context_taggings, -> { where(context: context) }, as: :tagger, dependent: :destroy, class_name: 'ActsAsTaggable::Tagging'
        has_many context_tags, through: context_taggings, source: :tag, class_name: 'ActsAsTaggable::Tagging'

        do_generate_tagger_methods(context)
      end

    # def self.tagged_with(name)
    # # Tag.find_by_name!(name).articles
    # # Tag.find_by(name: name)!.taggings.
    # end

    # def self.tag_counts
    # # Tag.select("tags.*, count(taggings.tag_id) as count").
    # #   joins(:taggings).group("taggings.tag_id")
    # end
    end # acts_as_tagger_on

    def do_generate_taggable_methods(context)
      method_name = "#{context}_tag_list"
      unless self.respond_to? method_name.to_sym
        define_method(method_name) do
        # tags =  self.send((context + '_tags').to_sym)
          tags = base_tags.where(["#{ActsAsTaggable::Tagging.table_name}.context = ?", context.to_s])
          tags.map(&:name).join(", ")
        end
      end

      method_name = "#{context}_tag_list="
      unless self.respond_to? method_name.to_sym
        define_method(method_name) do |name_list|
          tag_names = name_list.split(",")

          tags =  self.send (context + '_tags').to_sym
          tags.each do |tag|
            unless tag_names.include? tag.name
              self.untag_by tag, nil, context
            end
          end

          tag_names.map do |name|
            tag = ActsAsTaggable::Tag.find_by(name: name.strip)
            tag = ActsAsTaggable::Tag.create(name: name.strip, user: User.first) if tag.nil?
            self.tag_by tag, User.first, context
          end
        end
      end

      method_name = "#{context}_by?"
      unless self.respond_to? method_name.to_sym
        define_method(method_name) do |tag, tagger|
          self.tag_by?(tag, tagger, context)
        end
      end

      method_name = "#{context}_by"
      unless self.respond_to? method_name.to_sym
        define_method(method_name) do |tag, tagger|
          self.tag_by(tag, tagger, context)
        end
      end

      method_name = "un#{context}_by"
      unless self.respond_to? method_name.to_sym
        define_method(method_name) do |tag, tagger|
          self.untag_by(tag, tagger, context)
        end
      end

      method_name = "#{context}_by_count"
      unless self.respond_to? method_name.to_sym
        define_method(method_name) do
          self.taggings.where(context: context).size
        end
      end
    end # do_generate_taggable_methods

    def do_generate_tagger_methods(action_name)
      method_name = "#{action_name}?"
      unless self.respond_to? method_name.to_sym
        define_method(method_name) do |tag, taggable|
          self.tag?(tag, taggable, action_name)
        end
      end

      method_name = "#{action_name}"
      unless self.respond_to? method_name.to_sym
        define_method(method_name) do |taggable|
          self.tag(tag, taggable, action_name)
        end
      end

      method_name = "un#{action_name}"
      unless self.respond_to? method_name.to_sym
        define_method(method_name) do |tag, taggable|
          self.untag(tag, taggable, action_name)
        end
      end

      method_name = "#{action_name}_count"
      unless self.respond_to? method_name.to_sym
        define_method(method_name) do
          self.taggings.where(context: action_name).size
        end
      end
    end # do_generate_tagger_methods

    def do_acts_as_taggable(options={})
      unless self.is_taggable?
        has_many :taggings, {as: :taggable, dependent: :destroy, class_name: 'ActsAsTaggable::Tagging'}.merge(options)
        has_many :base_tags, :through => :taggings, :source => :tag, :class_name => "ActsAsTaggable::Tag"
        include ActsAsTaggable::Taggable::Methods
      end
    end

    def do_acts_as_tagger(options={})
      unless self.is_tagger?
        has_many :taggings, {as: :tagger, dependent: :destroy, class_name: 'ActsAsTaggable::Tagging'}.merge(options)
        has_many :base_tags, :through => :taggings, :source => :tag, :class_name => "ActsAsTaggable::Tag"
        include ActsAsTaggable::Tagger::Methods
      end
    end

    def is_taggable?
      false
    end

    def is_tagger?
      false
    end
  end # ClassMethods
end # ActsAsTaggable


ActiveRecord::Base.send :include, ActsAsTaggable
