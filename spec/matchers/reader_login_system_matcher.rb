module Spec
  module Rails
    module Matchers
      class ReaderLoginRequirement
        def initialize(example)
          @example = example
        end

        def matches?(proc)
          proc.call
          @response = @example.response
          @was_redirect = @response.redirect?
          @was_redirect_to_login = @response.redirect_url_match?("/readers/login")
          @was_redirect && @was_redirect_to_login
        end

        def failure_message
          if @was_redirect
            "expected to redirect to /readers/login but redirected to #{@response.redirect_url}"
          else
            "expected to require reader login but did not redirect"
          end
        end

        def negative_failure_message
          "expected not to require reader login"
        end
      end

      def require_reader_login
        ReaderLoginRequirement.new(self)
      end
    end
  end
end
