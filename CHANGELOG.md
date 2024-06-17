## [3.2.0]
- Enum columns

## [3.1.0]
- Introduce summary tables
- Update ruby requirement >= 3.3

## [3.0.0]

- Breaking change: remove Turbo Streams from table and pagination components,
  focus preservation is handled via Turbo Morph
- Improve spec coverage
- Re-write internals to make it easier to extend and customize
- Update examples in [README](README.md) and [docs](/docs) to reflect changes

If you're upgrading from 2.x, you'll need to change your controllers to use
the recommendations from the README. The changes should be straightforward,
but you will need to enable morphing to allow focus preservation.

In general, we don't recommend using row partials anymore, as it's easier to
read the code when the row is defined in the index view.

## [2.6.0]

- Added table row selection
  - See [[docs/selectable.md]] for examples

## [2.5.0]

- Breaking change: use Rails' object lookup path to find row partials
  Previously: Nested::ResourceController would have looked for Nested::Model in
  the controller directory:
    app/views/nested/resources/_nested_model.html+row.erb
  After this change, uses Rails' polymorphic partials logic and looks in the
  model views directory:
    app/views/nested/models/_model.html+row.erb

## [2.4.0]

- Internal refactor of filters to make it easier to add custom extensions
  and define nested attributes.

## [2.3.0]

- Remove support for Ruby < 3.0 (no longer used at Katalyst)

## [2.2.0]

- Add support for ordinal columns with batch updating
  - See [[docs/ordinal.md]] for examples

## [2.1.0]

- Add Collection model for building collections in a controller from params.
  - See [[README.md]] for examples
- Add turbo entry points for table and pagy_nav
  - See [[README.md]] for examples
- Add support for row partials when content is not provided
  - See [[README.md]] for examples
- Add messages when table is empty, off by default (caption: true)
- Add PagyNavComponent for rendering `pagy_nav` from a collection.
- Replaces internal references to SortForm to use `sorting` instead
  - No changes required to existing code unless you were using the internal
    classes directly
  - Change allows sort param and sorting model to co-exist

## [2.0.0]

- Replaces builders with view_components 
  We want view components to be the way to build custom tables, and add more
  complete features to the gem. This will be a breaking change, but we have
  tried hard to retain compatibility with existing code. Unless you are using
  a custom builder then it's unlikely that you will see any changes.
- If you are using custom builders, then you will need to update them to use
  view components. See [[README.md]] for examples.

## [1.1.0] - 2023-07-18

- Replaces `param_key` with `i18n_key` for attribute lookup in locale file
- Remove controller and url helpers from backend
  - No changes required to existing code unless you were using the internal
    classes directly

## [1.0.0] - 2022-03-23

- Initial release
