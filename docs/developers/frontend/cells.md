---
layout: default
title: Cells
parent: Frontend
grand_parent: Developers
nav_order: 1
---

# Cells

If you do not provide a value when you call the cell builder, the attribute you provide will be retrieved from the 
current item and the result will be rendered in the table cell. This is often all you need to do, but if you do want 
to customize the value you can pass a block instead:

```erb
<% row.text :status do %>
  <%= person.password.present? ? "Active" : "Invited" %>
<% end %>
```

In the context of the block you have access to the cell component if you simply want to extend the default behavior:

```erb
<%# @type [Katalyst::Tables::CellComponent] cell %>
<% row.text :name do |cell| %>
  <%= link_to cell, person %>
<% end %>
```

## Arguments

All cells support the following arguments, as documented in `Katalyst::TableComponent`.

 * `column`: `[Symbol]` the column's name, called as a method on the record
 * `label`: `[String|nil]` the label to use for the column header
 * `heading`: `[boolean]` if true, data cells will use `th` tags
 * `**`: `[Hash]` HTML attributes to be added to cell tags
 * If a block is provided, it will be called a the cell component as an argument

You can also update `html_attributes` on the cell builder, similar to the row builder, see
[HTML attributes](html-attributes) for details.

## Types

Tables provides a number of different types of cells out of the box in addition to the default text cell.
Detailed documentation on arguments is available in `Katalyst::TableComponent` docstrings.

### `text`

Generates a column from values rendered as text.

```erb
<% row.text :name %> # label => <th>Name</th>, data => <td>John Doe</td>
```

### `boolean`

Generates a column from boolean values rendered as "Yes" or "No".

```erb
<% row.boolean :active %> # => <td>Yes</td>
```

### `date`

Generates a column from date values rendered using `I18n.l`.
The default format is `:default`, can be configured or overridden.

 * `format`: [Symbol] the I18n date format to use when rendering
 * `relative`: [Boolean] if true, the date may be shown as a relative date (if within 5 days)

```erb
<% row.date :created_at %> # => <td>29 Feb 2024</td>
```

### `datetime`

Generates a column from datetime values rendered using `I18n.l`.
The default format is `:default`, can be configured or overridden.

 * `format`: [Symbol] the I18n datetime format to use when rendering
 * `relative`: [Boolean] if true, the datetime may be(if today) shown as a relative date/time
 
```erb
   <% row.datetime :created_at %> # => <td>29 Feb 2024, 5:00pm</td>
```

### `enum`

Generates a column from an enum value rendered as a tag.
The target attribute must be defined as an `enum` in the model.

When rendering an enum value, the component will check for translations
using the key `active_record.attributes.[model]/[column].[value]`,
e.g. `active_record.attributes.banner/status.published`.

```erb
<% row.enum :status %>
<%# label => <th>Status</th> %>
<%# data => <td class="type-enum"><span data-enum="status" data-value="published">Published</span></td> %>
```

### `number`

Generates a column from numeric values formatted appropriately.

* `format`: [String|Symbol] Rails `number_to_X` format option, defaults to `delimited`
* `options`: [Hash] options to be passed to `number_to_<format>`

Supports Rails' built in number formatters, i.e.
  * `phone`: `ActiveSupport::NumberHelper#number_to_phone`
  * `currency`: `ActiveSupport::NumberHelper#number_to_currency`
  * `percentage`: `ActiveSupport::NumberHelper#number_to_percentage`
  * `delimited`: `ActiveSupport::NumberHelper#number_to_delimited`
  * `rounded`: `ActiveSupport::NumberHelper#number_to_rounded`
  * `human_size`: `ActiveSupport::NumberHelper#number_to_human_size`
  * `human`: `ActiveSupport::NumberHelper#number_to_human`

```erb
<% row.number :comment_count %> # => <td>0</td>
```

### `currency`

Generates a column from numeric values rendered using `number_to_currency`.

* `options`: [Hash] options to be passed to `number_to_currency`

```erb
<% row.currency :price %> # => <td>$3.50</td>
```

### `rich_text`
 
Generates a column for displaying HTML markup.

This cell assumes that the model will return HTML-safe content.
If the content is not marked HTML-safe already it will be escaped.

```erb
<% row.rich_text :description %> # => <td><em>Emphasis</em></td>
```
