# frozen_string_literal: true

require "rails_helper"

# rubocop:disable RSpec/InstanceVariable
RSpec.describe Katalyst::Tables::FilterComponent do
  subject(:component) { described_class.new(collection: @collection, url: "/resources") }

  def create_collection(&block)
    @collection = Class.new(Katalyst::Tables::Collection::Base) do
      include Katalyst::Tables::Collection::Query
      instance_exec(&block) if block
    end.new.apply(Resource)
  end

  it "renders filter form + modal" do
    create_collection
    expect(render_inline(component)).to match_html(<<~HTML)
      <div data-controller="tables--filter--modal" data-action="click@window->tables--filter--modal#close click->tables--filter--modal#open:stop keydown.esc->tables--filter--modal#close ">
        <form action="/resources" accept-charset="UTF-8" method="get">
          <input autocomplete="off" type="hidden" name="sort" id="sort">
          <input type="search" autocomplete="off" data-action="focus->tables--filter--modal#open" value="" name="query" id="query">
          <button type="submit">Apply</button>
        </form>
        <div class="filter-keys-modal" data-tables--filter--modal-target="modal">
          <table>
            <thead>
              <tr>
                <th class="label"></th>
                <th class="key">Key</th>
                <th class="values">Values</th>
              </tr>#{' '}
            </thead>
            <tbody>
            </tbody>
          </table>
        </div>
      </div>
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
