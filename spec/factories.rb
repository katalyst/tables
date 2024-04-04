# frozen_string_literal: true

FactoryBot.define do
  factory :resource, class: "Resource" do
    sequence(:index) { |i| i }
    name { "Resource #{index + 1}" }
  end

  factory :parent do
    sequence(:name) { |i| "Parent #{i}" }
  end

  factory :child do
    sequence(:name) { |i| "Child #{i}" }
    parent
  end

  factory :relation, class: "ActiveRecord::Relation" do
    model { Resource }
    values { Array.new(count) { |i| build(:resource, index: i) } }
    count { 0 }
    attributes { %i[index name] }

    initialize_with do
      # use a relaxed double to add scope
      collection = double(ActiveRecord::Relation) # rubocop:disable RSpec/VerifiedDoubles
      model      = attributes[:model]
      values     = attributes[:values]

      allow(collection).to receive_messages(reorder: collection, model:, model_name: model.model_name)
      allow(collection).to(receive(:count)) { values.count }
      allow(collection).to(receive(:empty?)) { values.empty? }
      allow(collection).to(receive(:any?)) { values.any? }
      allow(collection).to(receive(:new)) { build(:resource) }
      allow(collection).to(receive(:first)) { values.first }
      allow(collection).to receive(:offset) do |i|
        values.replace(values.slice(i..-1))
        collection
      end
      allow(collection).to receive(:limit) do |i|
        values.replace(values.take(i))
        collection
      end
      allow(collection).to receive(:each) do |&block|
        values.each(&block)
      end

      allow(model).to receive(:has_attribute?) do |attribute|
        attributes[:attributes].include?(attribute.to_sym)
      end

      collection
    end
  end

  factory :collection, class: "Katalyst::Tables::Collection::Base" do
    items { association :relation, count: }
    transient do
      count { 0 }
    end

    initialize_with do
      items    = attributes.delete(:items)
      sorting  = attributes.delete(:sorting)
      paginate = attributes.delete(:paginate)
      params   = ActionController::Parameters.new(attributes)

      new(sorting:, paginate:).with_params(params).apply(items)
    end
  end
end
