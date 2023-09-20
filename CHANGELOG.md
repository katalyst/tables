## [Unreleased]

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
