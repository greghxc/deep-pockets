class Api::TestController < Api::ApiController
  def test
    @values = {}
    render json: @values.to_json
  end
end
