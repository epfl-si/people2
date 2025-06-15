# frozen_string_literal: true

class IndexBoxesController < BoxesController
  def load_and_authorize_box
    @box = IndexBox.includes(:profile).find(params[:id])
    authorize! @box, to: :update?
  end

  def box_symbol
    :index_box
  end
end
