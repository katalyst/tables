# Customization

A common pattern we use is to have a cell at the end of the table for actions. For example:

```html
<table class="action-table">
  <thead>
    <tr>
      <th>Name</th>
      <th class="actions"></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>Alice</td>
      <td class="actions">
        <a href="/people/1/edit">Edit</a>
        <a href="/people/1" method="delete">Delete</a>
      </td>
    </tr>
  </tbody>
</table>
```

You can write a custom component that helps generate this type of table by
adding the required classes and adding helpers for generating the actions.
This allows for a declarative table syntax, something like this:

```erb
<%= render ActionTableComponent.new(collection:) do |row| %>
  <% row.text :name %>
  <% row.actions do |cell| %>
    <%= cell.action "Edit", :edit %>
    <%= cell.action "Delete", :delete, method: :delete %>
  <% end %>
<% end %>
```

And the customized component:

```ruby
class ActionTableComponent < Katalyst::TableComponent
  def actions(column = :_actions, label: "", heading: false, **, &)
    with_cell(ActionsComponent.new(collection:, row:, column:, record:, label:, heading:, **), &)
  end

  def default_html_attributes
    { class: "action-table" }
  end

  class ActionsComponent < Katalyst::Tables::CellComponent
    def action(label, href, **opts)
      content_tag :a, label, { href: }.merge(opts)
    end

    def default_html_attributes
      { class: "actions" }
    end
  end
end
```
