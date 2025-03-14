# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Tables::Sortable do
  def render_header(collection: nil, url: "/people", &)
    with_request_url(url) do
      params = Rack::Utils.parse_query(vc_test_request.get_header(Rack::QUERY_STRING))
      collection ||= Katalyst::Tables::Collection::Base
                       .new(sorting: "name asc")
                       .with_params(params)
                       .apply(Person.all)
      component = Katalyst::TableComponent.new(collection:)
      render_inline(component, &).at_css("thead > tr > th")
    end
  end

  it "omits sort when not configured on the collection" do
    expect(render_header(collection: Person.all) do |row|
      row.text(:name)
    end).to match_html(<<~HTML)
      <th>Name</th>
    HTML
  end

  it "renders sort link when enabled" do
    expect(render_header do |row|
      row.text(:name)
    end).to match_html(<<~HTML)
      <th data-sort="asc"><a class="sortable" data-turbo-action="replace" href="/people?sort=name+desc">Name</a></th>
    HTML
  end

  it "does not add sort link to unsupported columns" do
    expect(render_header do |row|
      row.text(:itself)
    end).to match_html(<<~HTML)
      <th>Itself</th>
    HTML
  end

  it "does not render status on unsorted columns" do
    expect(render_header do |row|
      row.date(:created_at)
    end).to match_html(<<~HTML)
      <th data-cell-type="date"><a class="sortable" data-turbo-action="replace" href="/people?sort=created_at+asc">Created at</a></th>
    HTML
  end

  it "does not cobber other html_attributes" do
    expect(render_header do |row|
      row.text(:name, data: { other: "" })
    end).to match_html(<<~HTML)
      <th data-sort="asc" data-other><a class="sortable" data-turbo-action="replace" href="/people?sort=name+desc">Name</a></th>
    HTML
  end

  it "omits unnecessary sort param linking to default sort" do
    expect(render_header(url: "/people?sort=name+desc") do |row|
      row.text(:name)
    end).to match_html(<<~HTML)
      <th data-sort="desc"><a class="sortable" data-turbo-action="replace" href="/people">Name</a></th>
    HTML
  end
end
