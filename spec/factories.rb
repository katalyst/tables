# frozen_string_literal: true

FactoryBot.define do
  factory :faq do
    sequence(:question) { |i| "FAQ #{i}" }
    answer { Faker::HTML.sandwich }
  end

  factory :person do
    sequence(:name) { |i| "Person #{i}" }
  end

  factory :resource do
    sequence(:index) { |i| i }
    name { "Resource #{index}" }
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
