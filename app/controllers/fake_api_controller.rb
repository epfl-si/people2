


class FakeAPIController < ActionController::Base
  # person data for one sciper
  # /fakeapi/persons/:sciper 
  def person
    respond_to do |format|
      format.json { render json: {sciper: params[:sciper] } }
    end
  end 
  # list of person data for query data
  # /fakeapi/persons         
  def persons
  end
  # accred for one sciper
  # /fakeapi/accreds/:sciper 
  def accred
  end
  # list of accreds data for query data
  # /fakeapi/accreds         
  def accreds
  end

  PERSON_FAKEDATA = File.read(Rails.root.join("path/to/gcs.keyfile")
    persons: {

    }
  } 


end