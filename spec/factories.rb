# frozen_string_literal: true

FactoryBot.define do
  factory :faq do
    sequence(:ordinal)
    question { "FAQ #{ordinal}" }
    answer { Faker::HTML.sandwich }
  end

  factory :person do
    sequence(:name) { |i| "Person #{i}" }
  end

  factory :resource do
    sequence(:index) { |i| i }
    name { "Resource #{index}" }
    category { %i[article documentation report].sample }

    trait :with_image do
      image { Rack::Test::UploadedFile.new(Rails.root.join("../fixtures/images/dummy.png"), "image/png") }
    end

    factory :report do
      category { :report }
    end
  end

  factory :parent do
    sequence(:name) { |i| "Parent #{i}" }
  end

  factory :child do
    sequence(:name) { |i| "Child #{i}" }
    parent
  end

  factory :collection, class: "Katalyst::Tables::Collection::Base" do
    type { :person }
    items { create_list(type, count) }

    transient do
      count { 0 }
    end

    initialize_with do
      type     = attributes.delete(:type)
      items    = attributes.delete(:items)
      sorting  = attributes.delete(:sorting)
      paginate = attributes.delete(:paginate)
      params   = ActionController::Parameters.new(attributes)
      klass    = items.any? ? items.first.class : type.to_s.classify.constantize

      new(sorting:, paginate:).with_params(params).apply(klass.where(id: items.map(&:id)))
    end
  end
end
