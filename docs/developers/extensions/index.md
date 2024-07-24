---
layout: default
title: Extensions
parent: Developers
nav_order: 10
has_children: true
---

# Extensions

Katalyst Tables uses an extensions architecture for customisations. The extensions documented here are available and
activated by default. The design philosophy is that, when possible, extensions should become active when they are
configured and quiescent otherwise.

If a particular extension is not desirable for your use case, you can disable extensions by altering
`Katalyst::Tables.config.component_extensions` before initialization.
