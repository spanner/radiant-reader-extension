class ReaderSession < Authlogic::Session::Base
  find_by_login_method :find_by_nickname_or_email
end