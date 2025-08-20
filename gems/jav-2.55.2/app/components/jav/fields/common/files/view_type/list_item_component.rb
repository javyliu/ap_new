# frozen_string_literal: true

class Jav::Fields::Common::Files::ViewType::ListItemComponent < Jav::Fields::Common::Files::ViewType::GridItemComponent
  def icon_for_file
    if is_image?
      "photo"
    elsif is_audio?
      "speaker-wave"
    elsif is_video?
      "video-camera"
    else
      "document"
    end
  end
end
