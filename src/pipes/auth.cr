module Pipes
  class Auth < Amber::Pipe::Base
    def call(context)
      call_next(context) if context.request.method == "OPTION"
      begin
        token = context.request.headers["JWT"]
        data = ::Auth::JWTService.new.decode(token)
      rescue JWT::VerificationError
        return not_auth(context)
      rescue KeyError
        return missing_JWT(context)
      end

      return not_auth(context) if context.session[:current_user_id] != data[0]["user_id"].to_s

      call_next(context)
    end

    private def not_auth(context)
      context.response.status_code = 404
      error = {errors: ["Please Sign In"]}.to_json
      context.response.print error
    end

    private def missing_JWT(context)
      context.response.status_code = 403
      error = {errors: ["Missing JWT headers"]}.to_json
      context.response.print error
    end
  end
end
