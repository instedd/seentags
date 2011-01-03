require 'machinist/active_record'

require 'ffaker'

Sham.define do
  name { Faker::Name.name }
  email { Faker::Internet.email }
  username { Faker::Internet.user_name }
  url { Faker::Internet.domain_name }
  password { Faker::Name.name }
  phone_number { Faker::PhoneNumber::phone_number }
  address { Faker::Address::street_address }
end

Account.blueprint do
  name { Sham.username }
  password
  password_confirmation { password }
end

ReportSet.blueprint do
  name
  account
end

Report.blueprint do
  report_set
end