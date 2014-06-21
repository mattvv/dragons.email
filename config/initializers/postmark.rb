Mail.defaults do
  delivery_method :smtp, {
      :address => ENV['POSTMARK_SMTP_SERVER'],
      :port => '25',
      :domain => 'dragons.email',
      :user_name => ENV['POSTMARK_API_KEY'],
      :password => ENV['POSTMARK_API_KEY'],
      :authentication => :plain,
      :enable_starttls_auto => true
  }
end