# frozen_string_literal: true

module ErrorResponsesHelper
  def render_bad_request(detail: 'The request was unacceptable due to missing or invalid parameters.')
    render_error_response('Bad Request', detail, :bad_request)
  end

  def render_unauthorized_request(detail: 'Credentials invalid or expired.')
    render_error_response('Unauthorized', detail, :unauthorized)
  end

  def render_forbidden_request(detail: 'You do not have permission to perform this action.')
    render_error_response('Forbidden', detail, :forbidden)
  end

  def render_not_found(detail: 'Resource not found.')
    render_error_response('Not Found', detail, :not_found)
  end

  def render_bad_gateway(detail: 'External service error.')
    render_error_response('Bad Gateway', detail, :bad_gateway)
  end

  def render_error_response(title, detail, status)
    render json: {
      errors: [
        {
          title: title,
          detail: detail,
          status: Rack::Utils::SYMBOL_TO_STATUS_CODE[status],
          params: sanitized_params
        }
      ]
    }, status: status
  end

  def sanitized_params
    request.filtered_parameters.except(:controller, :action)
  end
end
