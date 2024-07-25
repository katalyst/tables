---
layout: default
title: Queries
parent: Users
nav_order: 1
---

# Queries

The Query interface allows you to perform advanced searches and filter data based on various criteria. This guide 
will walk you through the steps to use the Query interface effectively.

Tables that include query support will have a query search box above the table. When you click on the query search box,
a list of suggestions will appear below the box.

## Basic Search

Basic search will look for the text that you enter in the important text fields.

* In the search bar, type the keyword or phrase you want to search for.
* Press `Enter` to apply the search and close the suggestions list.
* Example: To find a person named "Aaron", type `Aaron` and press `Enter`.
* Clear an existing search by pressing `Esc`.

## Advanced Search with Tags

Advanced search lets you specify which column you want to match on, and also supports columns like dates, numbers, and
columns with restricted values.

* Use specific tags to filter data more precisely.
* Tags are predefined keywords that usually correspond to column names.
* Format: `tag:value`

Examples:
* Search for text specifically in the Name column: `name:John`
* Filter by Date Range: `created_at:2024-01-01..2024-12-31`
* Multiple Filters: `name:John created_at:2024-01-01..2024-12-31`

### Combining Multiple Filters

* You can combine multiple tags to narrow down your search results.
* Separate each tag with a space.
* Example: `first_name:John created_at:2024-01-01..2024-12-31 active:true`

### Query Suggestions

As you type, the suggestions box will update with suggestions based on your current input. If you move your cursor 
around the suggestions will change to reflect what you're focusing on.

If your cursor is in a place that the query interface expects a key's value, it will suggest value options that you
can enter, include actual data from the database that you might want to filter for.

### Troubleshooting and Tips

**Common Issues**:
* Ensure your query syntax is correct (e.g., use colons and ranges properly).
* Check for typos in tag names or values.

**Best Practices**:
* Start with simple queries and gradually add more criteria.
* Use tags for precise filtering and to avoid broad searches that return too many results.
