---
layout: default
title: Pagination
parent: Frontend
grand_parent: Developers
nav_order: 5
---

# Pagination

Tables provides [`Pagy`](https://github.com/ddnexus/pagy) integration for pagination using the latest Pagy releases.

Add `gem pagy` to your gem file to install pagy and it be picked up by collections and frontend table rendering.

Pagy 43+ removed the `Backend` and `Frontend` modules; tables will include `Pagy::Method` for you automatically. Tables
does not provide default styling for pagy navigation so you will want to write your own or include one of the styling
options that Pagy provides.

## Backend

When pagination is enabled for a collection, table rows will be automatically paginated prior to rendering the table.
Tables will generate pagy metadata and store it in the collection, which will be available as `pagination` for the
frontend to consume.

Enable pagination on a collection:

```ruby
config.paginate = true
```

See [collections pagination](../collections/pagination) for configuration details.

## Frontend

In the frontend, you can use `table_pagination_with` which wraps the Pagy `series_nav` helper with sensible defaults:

```erb
<%= table_pagination_with(collection:) %>
```

You can also use other pagy navigation generators or change the options by extending
`Katalyst::Tables::PagyNavComponent` and setting `default_table_pagination_component`. The rendered nav uses the
`pagy series-nav` classes by default.
