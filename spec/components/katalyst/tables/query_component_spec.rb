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

  it "renders filter form + modal" do
    create_collection
    expect(render_inline(component).css("form > *")).to match_html(<<~HTML)
      <div class="query-input">
        <label hidden="hidden" for="q">Search</label>
        <input type="search" autocomplete="off" data-turbo-permanent="true" data-action="keyup.enter->tables--query#closeModal" value="" name="q" id="q">
        <input autocomplete="off" type="hidden" name="p" id="p">
        <button type="submit" tabindex="-1">Apply</button>
      </div>
      <div class="query-modal" data-tables--query-target="modal" data-action="turbo:before-morph-attribute->tables--query#beforeMorphAttribute">
        <p><strong>Available filters:</strong></p>
        <dl>
        </dl>
      </div>
    HTML
  end

  it "renders with custom content" do
    create_collection
    expect((render_inline(component) do
      component.form(class: "custom") do |form|
        component.concat(form.hidden_field(:example))
      end
    end).at_css("form.custom > input[name=example]")).to match_html(<<~HTML)
      <input autocomplete="off" type="hidden" name="example" id="example">
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
    expect(render_inline(component).css(".query-modal > *")).to match_html(<<~HTML)
      <p><strong>Available filters:</strong></p>
      <dl>
        <dt><code>active:</code></dt>
        <dd>Filter on values for active</dd>
      </dl>
    HTML
  end

  it "describes errors" do
    create_collection(q: "index:") do
      attribute :active, :boolean
    end
    expect(render_inline(component).css(".query-modal > *")).to match_html(<<~HTML)
      <p>Unknown filter <code>index</code></p>
      <p><strong>Available filters:</strong></p>
      <dl>
        <dt><code>active:</code></dt>
        <dd>Filter on values for active</dd>
      </dl>
    HTML
  end

  it "describes values" do
    create_list(:resource, 3)
    create_collection(q: "index:", p: 6) do
      attribute :index, :integer
    end
    expect(render_inline(component).css(".query-modal > *")).to match_html(<<~HTML)
      <h4>Possible values for <code>index:</code></h4>
      <ul>
          <li><code>1</code></li>
          <li><code>2</code></li>
          <li><code>3</code></li>
      </ul>
    HTML
  end

  it "excludes scopes when describing values" do
    create_list(:resource, 3)
    create_collection(q: "example index:", p: 13) do
      attribute :search, :search, scope: :table_search
      attribute :index, :integer
    end
    expect(render_inline(component).css(".query-modal > *")).to match_html(<<~HTML)
      <h4>Possible values for <code>index:</code></h4>
      <ul>
          <li><code>1</code></li>
          <li><code>2</code></li>
          <li><code>3</code></li>
      </ul>
    HTML
  end

  it "filters against the active key while ignoring other scopes" do
    create_list(:resource, 3)
    create_collection(q: "example index: 2", p: 13) do
      attribute :search, :search, scope: :table_search
      attribute :index, :integer
    end
    expect(render_inline(component).css(".query-modal > *")).to match_html(<<~HTML)
      <h4>Possible values for <code>index:</code></h4>
      <ul>
          <li><code>2</code></li>
      </ul>
    HTML
  end
end
# rubocop:enable RSpec/InstanceVariable, RSpec/ExampleLength
