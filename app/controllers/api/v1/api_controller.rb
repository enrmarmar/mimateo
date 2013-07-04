class Api::V1::ApiController < Api::V1::BaseController
  def index
    @tasks = Task.all
    render text: @tasks.to_json
  end
end