---
layout: default
title: Width and wrapping
parent: Frontend
grand_parent: Developers
nav_order: 11
---

# Width and wrapping

Tables assumes `table-layout: auto` by default which lets cells stretch to fit their content, wrapping their content
if necessary.

Tables provides some utilities in the form of [CUBE CSS exceptions](https://cube.fyi/exception.html)
that allow you to control the width, wrapping, and overflow behaviour of table cells:

## `[data-width={value}]`

Width values can be `tiny` (1/12), `small` (1/6), `medium` (1/4) or `large` (1/3), implemented as fractions of the
table's container query inline size (cqi). On browsers that support it you can also use numerical values which will
be interpreted as cqi, but this is currently (2025) limited to Chrome.

## `[data-nowrap]`

Disables wrapping and sets `overflow: hidden` with text ellipses.

## `[data-scroll]`

Sets `overflow: scroll` to override the `hidden` behaviour or `data-width` and `data-nowrap`.
