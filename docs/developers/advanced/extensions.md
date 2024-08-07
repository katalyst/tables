---
layout: default
title: Extensions
parent: Advanced
grand_parent: Developers
nav_order: 3
---

# TableComponent Mixins

Katalyst Tables is designed using mixins for separating concerns. Functionality such as sorting, pagination, and 
bulk actions are all implemented as extensions that are defined as Ruby modules and added to the base
`Katalyst::TableComponent` class via `include` during Rails initialization.

The design philosophy is that, when possible, extensions should become active when they are configured and quiescent
otherwise.

You can control the extensions that are loaded and add your own extensions by modifying
`Katalyst::Tables.config.component_extensions` before initialization.

The existing mixins should provide a good start for how to go about writing new extensions to the TableComponent.
You can also create a subclass for a specific purpose instead, and use the controller-based component setters to
alter which component is instantiated for your views.
