# frozen_string_literal: true

require "rails_helper"

# rubocop:disable RSpec/InstanceVariable
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
    expect(render_inline(component)).to match_html(<<~HTML)
      <form data-controller="tables--query"
            data-action="click@window->tables--query#closeModal click->tables--query#openModal:stop focusin@window->tables--query#closeModal focusin->tables--query#openModal:stop keydown.esc->tables--query#clear:stop submit->tables--query#submit"
            action="/resources" accept-charset="UTF-8" method="get">
        <div class="query-input">
          <label hidden="hidden" for="q">Search</label>
          <input type="search" autocomplete="off" value="" name="q" id="q">
          <button type="submit" tabindex="-1">Apply</button>
        </div>
        <div class="query-modal" data-tables--query-target="modal">
          <table>
            <thead>
              <tr>
                <th class="label"></th>
                <th class="key">Key</th>
                <th class="values">Values</th>
              </tr>
            </thead>
            <tbody>
            </tbody>
          </table>
        </div>
      </form>
    HTML
  end

  it "renders with custom content" do
    create_collection
    expect(render_inline(component) do
      component.form(class: "custom") do |form|
        component.concat(form.hidden_field(:example))
      end
    end).to match_html(<<~HTML)
      <form class="custom"
            data-controller="tables--query"
            data-action="click@window->tables--query#closeModal click->tables--query#openModal:stop focusin@window->tables--query#closeModal focusin->tables--query#openModal:stop keydown.esc->tables--query#clear:stop submit->tables--query#submit"
            action="/resources" accept-charset="UTF-8" method="get">
        <input autocomplete="off" type="hidden" name="example" id="example">
      </form>
    HTML
  end

  it "renders sort when non-default" do
    create_collection(sort: "name desc")
    expect(render_inline(component).at_css("input[name=sort]")).to match_html(<<~HTML)
      <input autocomplete="off" type="hidden" value="name desc" name="sort" id="sort">
    HTML
  end

  it "describes booleans" do
    create_collection do
      attribute :active, :boolean
    end
    expect(render_inline(component).at_css("tbody > tr:first-of-type")).to match_html(<<~HTML)
      <tr>
        <th class="label">Active</th>
        <td class="key">active</td>
        <td class="values">
          <code>true</code>, <code>false</code>
        </td>
      </tr>
    HTML
  end

  it "describes date ranges" do
    create_collection do
      attribute :created_at, :date
    end
    expect(render_inline(component).at_css("tbody > tr:first-of-type")).to match_html(<<~HTML)
      <tr>
        <th class="label">Created at</th>
        <td class="key">created_at</td>
        <td class="values">
          <code>YYYY-MM-DD</code>,
          <code>>YYYY-MM-DD</code>,
          <code>&lt;YYYY-MM-DD</code>,
          <code>YYYY-MM-DD..YYYY-MM-DD</code>
        </td>
      </tr>
    HTML
  end

  it "describes enums" do
    create_collection do
      attribute :category, :enum
    end
    expect(render_inline(component).at_css("tbody > tr:first-of-type")).to match_html(<<~HTML)
      <tr>
        <th class="label">Category</th>
        <td class="key">category</td>
        <td class="values">[<code>article</code>, <code>documentation</code>, <code>report</code>]</td>
      </tr>
    HTML
  end

  it "describes integers" do
    create_collection do
      attribute :index, :integer
    end
    expect(render_inline(component).at_css("tbody > tr:first-of-type")).to match_html(<<~HTML)
      <tr>
        <th class="label">Index</th>
        <td class="key">index</td>
        <td class="values">
          <code>10</code>, <code>&gt;10</code>, <code>&lt;10</code>, <code>0..10</code>
        </td>
      </tr>
    HTML
  end

  it "describes integers with multiple: true" do
    create_collection do
      attribute :index, :integer, multiple: true
    end
    expect(render_inline(component).at_css("tbody > tr:first-of-type")).to match_html(<<~HTML)
      <tr>
        <th class="label">Index</th>
        <td class="key">index</td>
        <td class="values">[<code>0</code>, <code>1</code>, <code>...</code>]</td>
      </tr>
    HTML
  end

  it "describes floats" do
    create_collection do
      attribute :factor, :float
    end
    expect(render_inline(component).at_css("tbody > tr:first-of-type")).to match_html(<<~HTML)
      <tr>
        <th class="label">Factor</th>
        <td class="key">factor</td>
        <td class="values">
          <code>0.5</code>, <code>&gt;0.5</code>, <code>&lt;0.5</code>, <code>-0.5..0.5</code>
        </td>
      </tr>
    HTML
  end

  it "describes floats with multiple: true" do
    create_collection do
      attribute :factor, :float, multiple: true
    end
    expect(render_inline(component).at_css("tbody > tr:first-of-type")).to match_html(<<~HTML)
      <tr>
        <th class="label">Factor</th>
        <td class="key">factor</td>
        <td class="values">[<code>0.5</code>, <code>1</code>, <code>...</code>]</td>
      </tr>
    HTML
  end

  it "describes strings" do
    create_collection do
      attribute :"parent.name", :string
    end
    expect(render_inline(component).at_css("tbody > tr:first-of-type")).to match_html(<<~HTML)
      <tr>
        <th class="label">Name</th>
        <td class="key">parent.name</td>
        <td class="values"><code>example</code>, <code>"an example"</code> (fuzzy match)</td></td>
      </tr>
    HTML
  end

  it "describes strings with exact matching" do
    create_collection do
      attribute :"parent.name", :string, exact: true
    end
    expect(render_inline(component).at_css("tbody > tr:first-of-type")).to match_html(<<~HTML)
      <tr>
        <th class="label">Name</th>
        <td class="key">parent.name</td>
        <td class="values"><code>example</code>, <code>"an example"</code> (exact match)</td></td>
      </tr>
    HTML
  end

  it "describes association attribute when provided" do
    @collection = Class.new(Katalyst::Tables::Collection::Base) do
      include Katalyst::Tables::Collection::Query

      attribute :"parent.name", :string

      def parent_name_values
        %w[one two]
      end
    end.new.apply(Resource)

    expect(render_inline(component).at_css("tbody > tr:first-of-type")).to match_html(<<~HTML)
      <tr>
        <th class="label">Name</th>
        <td class="key">parent.name</td>
        <td class="values"><code>one</code>, <code>two</code></td>
      </tr>
    HTML
  end
end
# rubocop:enable RSpec/InstanceVariable
