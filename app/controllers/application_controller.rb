class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordInvalid do |e|
    render json: ErrorSerializer.format_errors([ e.message ]), status: :unprocessable_entity
  end

  rescue_from ActiveRecord::RecordNotFound do |e|
    render json: ErrorSerializer.format_errors([e.message]), status: :not_found
  end

  def render_error
    render json: ErrorSerializer.format_invalid_search_response,
        status: :bad_request
  end
end

