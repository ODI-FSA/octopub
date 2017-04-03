FactoryGirl.define do
  factory :dataset do
    name "My Awesome Dataset"
    description "An awesome dataset"
    publisher_name "Awesome Inc"
    publisher_url "http://awesome.com"
    license { Octopub::WEB_LICENCES.sample }
    frequency { Octopub::PUBLICATION_FREQUENCIES.sample }
    publishing_method :github_public

    association :user, factory: :user

    after(:build) { |dataset|
      skip_callback_if_exists( Dataset, :update, :after, :update_dataset_in_github)
      dataset.instance_variable_set(:@repo, FakeData.new)
    }

    trait :with_callback do
      after(:build) { |dataset|
        dataset.class.set_callback(:update, :after, :update_dataset_in_github)
      }
    end

    trait :with_avatar_callback do
      after(:build) { |dataset|
        dataset.class.set_callback(:create, :after, :set_owner_avatar)
      }
    end

    factory :dataset_with_files do
      after(:create) do |dataset, evaluator|
        create_list(:dataset_file, 5, dataset: dataset)
      end
    end
  end
end
