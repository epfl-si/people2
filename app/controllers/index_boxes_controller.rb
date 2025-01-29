# frozen_string_literal: true

class IndexBoxesController < BoxesController
  # Use callbacks to share common setup or constraints between actions.
  def set_box
    @box = IndexBox.includes(:profile).find(params[:id])
  end

  def box_symbol
    :index_box
  end
end
