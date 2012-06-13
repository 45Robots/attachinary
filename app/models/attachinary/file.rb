module Attachinary
  class File < ::ActiveRecord::Base
    validates :public_id, :version, presence: true
    validates :resource_type, presence: true

    attr_accessible :public_id, :version, :width, :height, :format, :resource_type
    after_destroy :destroy_file

    def as_json(options)
      super(only: [:id, :public_id, :format, :version, :resource_type], methods: [:path])
    end

    def path(custom_format=nil)
      p = "v#{version}/#{public_id}"
      if resource_type == 'image' && custom_format != false
        custom_format ||= format
        p<< ".#{custom_format}"
      end
      p
    end

    def fullpath(options={})
      Cloudinary::Utils.cloudinary_url(path(options[:format]), options)
    end

    def self.upload!(file)
      response = Cloudinary::Uploader.upload(file, tags: "env_#{Rails.env}")
      create! response.slice('public_id', 'version', 'width', 'height', 'format', 'resource_type')
    end

  private
    def destroy_file
      Cloudinary::Uploader.destroy(public_id) if public_id
    end
  end
end
