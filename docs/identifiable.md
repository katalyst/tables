# Identifiable extension

The Identifiable extension adds default dom ids to the table and rows.

The extension can be enabled on a specific table instance or mixed in to a
table component class. In either case, the extension will add new functionality
to the table component and any nested row components.

## Usage

You can add the selectable extension to an existing table instance by calling
extend on the table instance:

```ruby
table = Katalyst::TableComponent.new(collection:)
table.extend(Katalyst::Table::Identifiable)
```

You can also include the extension in a table component class:

```ruby

class IdentifiableTableComponent < Katalyst::TableComponent
  include Katalyst::Table::Identifiable
```
