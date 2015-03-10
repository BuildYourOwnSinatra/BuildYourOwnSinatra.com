FactoryGirl.define do
  factory :user do
    email    { "#{Faker::Internet.user_name}_#{rand(0...1000)}@example.org" }
    username { Faker::Internet.user_name.gsub('.','') + "_#{rand(0...20000)}" }
    name     { Faker::Name.name }
  end

  factory :user_with_omniauth_github, parent: :user do
    after(:create) do |user|
      user.identities << FactoryGirl.create(:identity_github, user: user)
    end
  end

  factory :user_with_purchases, parent: :user do
    after(:create) do |user|
      user.purchases << FactoryGirl.create(:purchase, user: user)
    end
  end
end
