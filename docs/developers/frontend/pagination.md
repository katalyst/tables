---
layout: default
title: Pagination
parent: Frontend
grand_parent: Developers
nav_order: 5
---

# Pagination

When pagination is enabled for a collection, table rows will be automatically paginated prior to rendering the table.
The pagy metadata will be available on the collection as `pagination` for you to use with your preferred method of
pagination control rendering.

You can use `table_pagination_with` for pagy rendering with sensible defaults:

```erb
<%= table_pagination_with(collection:) %>
```

See [collections pagination](../collections/pagination) for configuration details.
