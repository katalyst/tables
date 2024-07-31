# frozen_string_literal: true

require "rails_helper"

# rubocop:disable RSpec/InstanceVariable, RSpec/ExampleLength
RSpec.describe Katalyst::Tables::QueryComponent do
  subject(:component) { described_class.new(collection: @collection, url: "/resources") }

  def create_collection(params = {}, &block)
    @collection = Class.new(Katalyst::Tables::Collection::Base) do
      include Katalyst::Tables::Collection::Query
      config.sorting = :name
      instance_exec(&block) if block
    end.with_params(params).apply(Resource)
  end

  it "renders the query input" do
    create_collection
    expect(render_inline(component)).to have_css("form .query-input")
  end

  it "renders query modal" do
    create_collection
    expect(render_inline(component)).to have_css("form .query-modal")
  end

  it "renders with custom content" do
    create_collection
    expect((render_inline(component) do
      component.with_form(class: "custom") do |form|
        component.helpers.concat(form.text_field(:example))
      end
    end).at_css("form.custom > input[name=example]")).to match_html(<<~HTML)
      <input type="text" name="example" id="example">
    HTML
  end

  it "renders sort when non-default" do
    create_collection(sort: "name desc")
    expect(render_inline(component).at_css("input[name=sort]")).to match_html(<<~HTML)
      <input autocomplete="off" type="hidden" value="name desc" name="sort" id="sort">
    HTML
  end

  it "describes keys" do
    create_collection do
      attribute :active, :boolean
    end
    expect(render_inline(component).css(".query-modal > .content > *")).to match_html(<<~HTML)
      <h4 id="suggestions-title">Search options</h4>
      <ul id="suggestions" role="listbox" aria-labelledby="suggestions-title">
        <li id="suggestion_0" role="option" class="suggestion attribute" data-action="click->tables--query#selectSuggestion query:select->tables--query#selectSuggestion" data-tables--query-value-param="active:"><span class="value">active</span></li>
      </ul>
    HTML
  end

  it "describes unknown keys" do
    create_collection(q: "index:", p: 6) do
      # stub model_name for anonymous testing collection
      class_eval { instance_variable_set(:@_model_name, Katalyst::Tables::Collection::Base.model_name.dup) }
      attribute :active, :boolean
    end
    expect(render_inline(component).css(".query-modal > header > *")).to match_html(<<~HTML)
      <div class="error unknown_key">The search option 'index' isn’t valid. Please check your input.</div>
    HTML
  end

  it "describes unknown completions" do
    create_collection(q: "unknown", p: 7) do
      # stub model_name for anonymous testing collection
      class_eval { instance_variable_set(:@_model_name, Katalyst::Tables::Collection::Base.model_name.dup) }
      attribute :active, :boolean
    end
    expect(render_inline(component).css(".query-modal > header > *")).to match_html(<<~HTML)
      <div class="error no_untagged_search">'unknown' isn't searchable. Please choose a valid search option.</div>
    HTML
  end

  it "describes values" do
    create_list(:resource, 3)
    create_collection(q: "name:", p: 5) do
      attribute :name, :string
    end
    expect(render_inline(component).css(".query-modal > .content > *")).to match_html(<<~HTML)
      <h4 id="suggestions-title">Search options</h4>
      <ul id="suggestions" role="listbox" aria-labelledby="suggestions-title">
        <li id="suggestion_0" class="suggestion database_value" role="option" data-action="click->tables--query#selectSuggestion query:select->tables--query#selectSuggestion" data-tables--query-value-param="Resource 1"><span class="value">Resource 1</span></li>
        <li id="suggestion_1" class="suggestion database_value" role="option" data-action="click->tables--query#selectSuggestion query:select->tables--query#selectSuggestion" data-tables--query-value-param="Resource 2"><span class="value">Resource 2</span></li>
        <li id="suggestion_2" class="suggestion database_value" role="option" data-action="click->tables--query#selectSuggestion query:select->tables--query#selectSuggestion" data-tables--query-value-param="Resource 3"><span class="value">Resource 3</span></li>
      </ul>
    HTML
  end
end
# rubocop:enable RSpec/InstanceVariable, RSpec/ExampleLength
