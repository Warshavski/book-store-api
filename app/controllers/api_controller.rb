# ApplicationController
#
#   Used to represent core information about API
#
class ApiController < ApplicationController
  def show
    api_info = {
      version: BookyApi.version,
      revision: BookyApi.revision
    }

    render json: { data: api_info }, status: :ok
  end
end
