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

  def creation_error(coupon)
    render json: { message: 'Creation Failed', errors: coupon.errors.full_messages.to_sentence }, status: :unprocessable_entity
  end
end
