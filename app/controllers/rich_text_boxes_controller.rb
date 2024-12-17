# frozen_string_literal: true

class RichTextBoxesController < BoxesController
  # Use callbacks to share common setup or constraints between actions.
  def set_box
    @box = RichTextBox.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def box_params
    params.require(:rich_text_box).permit(
      :audience,
      :title_fr, :title_en, :content_fr, :content_en
    )
  end
end
