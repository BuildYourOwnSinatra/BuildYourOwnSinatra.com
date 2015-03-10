FactoryGirl.define do
  factory :identity do
    email           { "#{Faker::Internet.user_name}_#{rand(0...1000)}@example.org" }
    username        { Faker::Internet.user_name.gsub('.','') + "_#{rand(0...20000)}" }
    name            'Leroy, Jenkins'
    password_digest 'password'
    provider        'identity'
    uid             { Faker::Internet.user_name.gsub('.','') + rand(0...1000).to_s }
    avatar          'avatar'
  end

  factory :identity_github, parent: :identity do
    provider 'github'
  end

  factory :identity_with_user, parent: :identity do
    user
  end
end
