# frozen_string_literal: true

module Avatarable
  extend ActiveSupport::Concern

  included do
    prepend ShadowMethods
    include Booky::Utils::StrongMemoize

    validate :avatar_type, if: ->(user) { user.avatar.present? && user.avatar_changed? }
    validates :avatar, file_size: { maximum: 200.kilobytes.to_i }, if: :avatar_changed?

    mount_uploader :avatar, AvatarUploader

    after_initialize :add_avatar_to_batch
  end

  module ShadowMethods
    def avatar_url(**args)
      #
      # We use avatar_path instead of overriding avatar_url because of carrierwave.
      # See https://gitlab.com/gitlab-org/gitlab-ce/merge_requests/11001/diffs#note_28659864
      #
      avatar_path(only_path: args.fetch(:only_path, true), size: args[:size]) || super
    end

    def retrieve_upload(identifier, paths)
      upload = retrieve_upload_from_batch(identifier)

      #
      # This fallback is needed when deleting an upload, because we may have already been removed from the DB.
      # We have to check an explicit `#nil?` because it's a BatchLoader instance.
      #
      upload = super if upload.nil?

      upload
    end
  end

  def avatar_type
    return true if self.avatar.image?

    message_template = 'file format is not supported. Please try one of the following supported formats:'
    extensions_list = AvatarUploader::IMAGE_EXTENSIONS.join(', ')

    message = "#{message_template} #{extensions_list}"

    errors.add :avatar, message
  end

  def avatar_path(only_path: true, size: nil)
    return if self[:avatar].blank?

    asset_host = ActionController::Base.asset_host
    use_asset_host = asset_host.present?
    query_params = size&.nonzero? ? "?width=#{size}" : ""

    url_base = []

    if use_asset_host
      url_base << asset_host unless only_path
    else
      url_base << booky_config.base_url unless only_path
      url_base << booky_config.relative_url_root
    end

    url_base.join + avatar.local_url + query_params
  end

  #
  # Path that is persisted in the tracking Upload model.
  # Used to fetch the upload from the model.
  #
  def upload_paths(identifier)
    avatar_mounter.blank_uploader.store_dirs.map { |_store, path| File.join(path, identifier) }
  end

  private

  def retrieve_upload_from_batch(identifier)
    BatchLoader.for(identifier: identifier, model: self).batch(key: self.class) do |upload_params, loader, args|
      model_class = args[:key]
      paths = upload_params.flat_map do |params|
        params[:model].upload_paths(params[:identifier])
      end

      Upload.where(uploader: AvatarUploader.name, path: paths).find_each do |upload|
        model = model_class.instantiate('id' => upload.model_id)

        loader.call({ model: model, identifier: File.basename(upload.path) }, upload)
      end
    end
  end

  def add_avatar_to_batch
    return unless avatar_mounter

    avatar_mounter.read_identifiers.each(&method(:retrieve_upload_from_batch))
  end

  def avatar_mounter
    strong_memoize(:avatar_mounter) { _mounter(:avatar) }
  end

  def booky_config
    Booky.config.booky
  end
end
