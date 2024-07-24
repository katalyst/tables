---
layout: default
title: Identifiable
parent: Extensions
grand_parent: Developers
nav_order: 3
---

# Katalyst::Tables::Identifiable

`Identifiable` adds default dom ids to the table and data rows:

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

The extension is included by default and can be enabled by passing `generate_ids: true`
the `table_with` helper or any table component.

```erb
<%= table_with(collection:, generate_ids: true) do |table| %>
  <%= table.text :name %>
<% end %>
```
