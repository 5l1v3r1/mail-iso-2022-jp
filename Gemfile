source "https://rubygems.org"

if mail_gem_version = ENV['MAIL_GEM_VERSION']
  gem "mail", "= #{mail_gem_version}"
else
  gem "mail", "<= 2.5.2"
end

rails_version = ENV['MAIL_ISO_2022_JP_RAILS_VERSION']

group :development, :test do
  gem "rake"
  gem "bundler"
  if mail_gem_version
    gem "activesupport"
  elsif rails_version == "edge"
    gem "actionmailer", :git => "git://github.com/rails/rails.git"
  elsif rails_version && rails_version.strip != ""
    gem "actionmailer", rails_version
  else
    gem "actionmailer", ">= 3.0.0"
  end
  gem "rdoc", ">= 3.12"
end