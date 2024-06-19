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
          <input type="search" size="full" autocomplete="off" data-action="focus->tables--filter--modal#open" value="" name="query" id="query">
          <input type="submit" name="commit" value="Apply" data-disable-with="Apply">
        </form>
        <div class="filter-keys-modal" data-tables--filter--modal-target="modal">
          <table>
            <thead>
            <tr>
              <th></th>
              <th>Key</th>
              <th>Values</th>
            </tr>
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
        <th>Active</th>
        <td>active</td>
        <td>
          <code>true</code>, <code>false</code>
        </td>
      </tr>
    HTML
  end

  it "describes date ranges" do
    create_collection do
      attribute :created_at, :date_range
    end
    expect(render_inline(component).at_css("tbody > tr:first-of-type")).to match_html(<<~HTML)
      <tr>
        <th>Created at</th>
        <td>created_at</td>
        <td>
          <code>YYYY-MM-DD</code>,
          <code>&gt;YYYY-MM-DD</code>,
          <code>&lt;YYYY-MM-DD</code>,
          <code>YYYY-MM-DD..YYYY-MM-DD</code>
        </td>
      </tr>
    HTML
  end

  it "describes enums" do
    create_collection do
      attribute :category, default: -> { [] }
    end
    expect(render_inline(component).at_css("tbody > tr:first-of-type")).to match_html(<<~HTML)
      <tr>
        <th>Category</th>
        <td>category</td>
        <td>[<code>article</code>, <code>documentation</code>, <code>report</code>]</td>
      </tr>
    HTML
  end

  it "does not describe association attribute by default" do
    create_collection do
      attribute :"parent.name", :string
    end
    expect(render_inline(component).at_css("tbody > tr:first-of-type")).to match_html(<<~HTML)
      <tr>
        <th>Name</th>
        <td>parent.name</td>
        <td></td>
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
        <th>Name</th>
        <td>parent.name</td>
        <td><code>one</code>, <code>two</code></td>
      </tr>
    HTML
  end
end
# rubocop:enable RSpec/InstanceVariable
