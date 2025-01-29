# frozen_string_literal: true

class RichTextBoxesController < BoxesController
  # Use callbacks to share common setup or constraints between actions.
  def set_box
    @box = RichTextBox.includes(:profile).find(params[:id])
  end

  def box_symbol
    :rich_text_box
  end

  def extra_plist
    %i[title_fr title_en content_fr content_en]
  end
end
