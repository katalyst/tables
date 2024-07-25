---
layout: default
title: Headers
parent: Frontend
grand_parent: Developers
nav_order: 2
---

# Table Headers

Tables generates a header row by calling your row partial or provided block with no object:

```erb
<%= table_with(collection:) do |row, person| %>
  <% if row.header? %>
    <%# header specific code %>
  <% else %>
    <%# body specific code %>
  <% end %>
<% end %>
```

When Tables is generating the header, you'll be able to observe that:
* `row.header?` is true,
* `row.body?` is false,
* and the object (`person`) is nil.

Using the same block for header row generation and body row generation keeps the syntax declarative and avoids
duplicating the column definitions, but occasionally you'll want logic in your row generation that refers to the
current object, and so you may need to guard against running that logic during header row generation.

If the column has a block for content generation (see [cells](cells)) it is not called during header row generation. 
This is because the block is assumed to be for generating data for the body, not the header.

You can suppress table header generation by passing `header: false` to `table_with`.

## Body row headings

All cells generated in the table header iteration will automatically be header cells (`th`), but you can also make
header cells in your body rows by passing `heading: true` when you generate the cell.

```erb
<% row.number :id, heading: true %>
<%# => <th>1</th> %>
```

## Customizing headings

The table header cells default to showing the capitalized column name, using `Model.human_attribute_name`, if 
available. You can customize the default inline:

```erb
<% row.number :id, label: "ID" %>
```

Or you can modify the I18n translation used by `human_attribute_name`:

```yml
# en.yml
activerecord:
  attributes:
    person:
      id: "ID"
```
