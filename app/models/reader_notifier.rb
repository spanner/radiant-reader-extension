class ReaderNotifier < ActionMailer::Base
  
  def activation(reader)
    setup_email(reader)
    @subject += "Please activate your account"
  end

  def welcome(reader)
    setup_email(reader)
    @subject += "Welcome to #{Radiant::Config['forum.site_title']}"
  end

  def password(reader)
    setup_email(reader)
    @subject += 'Reset your password'
  end

  protected
  
    def setup_email(reader)
      @from = 'temporary@spanner.org'
      @content_type = 'text/plain'
      @recipients = "#{reader.email}"
      @subject = ""
      @sent_on = Time.now
      @body[:reader] = reader
    end
  
end
