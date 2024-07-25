---
layout: default
title: Generate IDs
parent: Frontend
grand_parent: Developers
nav_order: 10
---

# Generate IDs

`Katalyst::Tables::Identifiable` adds default DOM ids to the table and data rows:

```html
<table id="people">
  <thead>
    <tr><th>Name</th></tr>
  </thead>
  <tbody>
    <tr id="person_1"><td>John Doe</td></tr>
  </tbody>
</table>
```

## Usage

The extension is included by default and can be enabled by passing `generate_ids: true`:

```erb
<%= table_with(collection:, generate_ids: true) do |row| %>
  <% row.text :name %>
<% end %>
```
