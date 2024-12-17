# frozen_string_literal: true

class IndexBoxesController < BoxesController
  # Use callbacks to share common setup or constraints between actions.
  def set_box
    @box = IndexBox.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def box_params
    params.require(:index_box).permit(:audience)
  end
end
