module Vidibus
  module CategoryTag
    module Mongoid
      extend ActiveSupport::Concern

      included do
        field :tags_hash, type: Hash, default: {}
        before_save :save_category_tags
      end

      module ClassMethods
        def tags_separator(separator = nil)
          @tags_separator = separator if separator
          @tags_separator || ','
        end

        def clean_tags_array(tags)
          tags = tags.split(tags_separator) unless tags.is_a?(Array)
          tags.map(&:strip).reject(&:blank?)
        end
      end

      def tag_objects
        tag_list = []
        tags_hash.each do |k,v|
          category = tag_category(uuid)
          next unless category
          v.each do |tag|
            next unless tag_object = category.tag_objects.where(value: tag).first
            tag_list.push({category: category.label, value: tag_object.value, uuid: tag_object.uuid})
          end
        end
        tag_list
      end

      def tags
        (tags_hash || {}).inject({}) do |categories, (key,tags)|
          categories[key] = tags.join(self.class.tags_separator)
          categories
        end
      end

      def tags=(categories)
        raise Error unless categories.is_a?(Hash)
        hash = {}
        categories.each do |category, tags|
          category = category.to_s
          tags = self.class.clean_tags_array(tags)
          hash[category] = tags if tags.present?
        end
        self.tags_hash = hash
      end

      private

      # Save all changed category tags.
      def save_category_tags
        return true unless tags_hash_changed?
        tags_hash.each do |uuid, tags|
          next if tags_hash_was && tags_hash_was[uuid] == tags
          category = tag_category(uuid)
          next unless category
          category.tags += tags
          category.save
        end
      end

      # Find tag category by uuid.
      def tag_category(uuid)
        TagCategory.where(:uuid => uuid).first
      end
    end
  end
end
