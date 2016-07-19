class Api::TokensController < Api::ApiController
  def index
    @values = {}
    render json: @values.to_json
  end
end
