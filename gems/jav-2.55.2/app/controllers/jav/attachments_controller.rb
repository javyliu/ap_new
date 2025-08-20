require_dependency "jav/application_controller"

module Jav
  class AttachmentsController < ApplicationController
    before_action :set_resource_name, only: %i[destroy create]
    before_action :set_resource, only: %i[destroy create]
    before_action :set_model, only: %i[destroy create]

    def create
      blob = ActiveStorage::Blob.create_and_upload! io: params[:file].to_io, filename: params[:filename]
      association_name = BaseResource.valid_attachment_name(@model, params[:attachment_key])

      raise ActionController::BadRequest, "Could not find the attachment association for #{params[:attachment_key]} (check the `attachment_key` for this Trix field)" if association_name.blank?

      @model.send(association_name).attach blob
      url = if blob.representable?
              ori_variant = @model.attachment_reflections[association_name]&.named_variants&.fetch(:ori, nil)
              if ori_variant
                main_app.rails_blob_path(blob.representation(ori_variant.transformations))
              else
                main_app.rails_blob_path(blob.representation(resize_to_limit: [1024, 1024], saver: { subsample_mode: "on", strip: true, interlace: true, quality: 85 }))
              end
            else
              main_app.rails_blob_path(blob)
            end

      render json: {
        previewable: blob.representable?,
        url: url,
        href: main_app.url_for(blob)
      }
    end

    def destroy
      if authorized_to :delete
        attachment = ActiveStorage::Attachment.find(params[:attachment_id])

        flash.now[:notice] = if attachment.present?
                               @destroyed = attachment.destroy
                               t("jav.attachment_destroyed")
                             else
                               t("jav.failed_to_find_attachment")
                             end
      else
        flash.now[:notice] = t("jav.not_authorized")
      end

      respond_to do |format|
        format.turbo_stream do
          render "destroy"
        end
      end
    end

    private

    def authorized_to(action)
      @resource.authorization.authorize_action("#{action}_#{params[:attachment_name]}?", record: @model, raise_exception: false)
    end
  end
end
