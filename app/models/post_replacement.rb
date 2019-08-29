class PostReplacement < ApplicationRecord
  DELETION_GRACE_PERIOD = 30.days

  belongs_to :post
  belongs_to :creator, class_name: "User"
  before_validation :initialize_fields, on: :create
  attr_accessor :replacement_file, :final_source, :tags

  def initialize_fields
    self.creator = CurrentUser.user
    self.original_url = post.source
    self.tags = post.tag_string + " " + self.tags.to_s

    self.file_ext_was =  post.file_ext
    self.file_size_was = post.file_size
    self.image_width_was = post.image_width
    self.image_height_was = post.image_height
    self.md5_was = post.md5
  end

  concerning :Search do
    class_methods do
      def search(params = {})
        q = super

        q = q.attribute_matches(:replacement_url, params[:replacement_url])
        q = q.attribute_matches(:original_url, params[:original_url])
        q = q.attribute_matches(:file_ext_was, params[:file_ext_was])
        q = q.attribute_matches(:file_ext, params[:file_ext])
        q = q.attribute_matches(:md5_was, params[:md5_was])
        q = q.attribute_matches(:md5, params[:md5])
        q = q.search_user_attribute(:creator, params)
        q = q.search_post_id_attribute(params)
        q.apply_default_order(params)
      end
    end
  end

  def suggested_tags_for_removal
    tags = post.tag_array.select { |tag| Danbooru.config.remove_tag_after_replacement?(tag) }
    tags = tags.map { |tag| "-#{tag}" }
    tags.join(" ")
  end

end
