---
layout: default
title: Custom columns
parent: Advanced
grand_parent: Developers
nav_order: 1
---

# Custom columns

As you use tables, you will likely encounter situations that call for a type of column that is not provided by default.
While you can easily customize how a column renders, if you find that your application has a repeated pattern that would
benefit from a custom column type, you can also define a new type of column.

A common pattern we see is a list of links next to each row for actions such as "edit" or "delete". For example,
consider this output HTML:

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

You can achieve this by subclassing `Katalyst::TableComponent` to add the required classes and adding helpers for
generating the actions. This allows for a declarative table syntax, something like this:

```erb
<%# in your controller: default_table_component ActionTableComponent %>
<%= table_with(collection:) do |row, person| %>
  <% row.text :name %>
  <% row.actions do |cell| %>
    <%= cell.action "Edit", edit_person_path(person) %>
    <%= cell.action "Delete", person_path(person), method: :delete %>
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
    def action(label, href, **)
      link_to(label, href, **)
    end

    def default_html_attributes
      { class: "actions" }
    end
  end
end
```

This is a simplistic example – it would be trivial to implement this without the custom component – however, it shows
all the requirements for building custom components that are more useful. For example, the action component could
generate a context menu instead of simply listing the links inline.
