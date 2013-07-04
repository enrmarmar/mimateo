class ApiController < Api::V1::BaseController
  respond_to :json

  def index
    @tasks = Task.all
    render "api/index"
  end 
end