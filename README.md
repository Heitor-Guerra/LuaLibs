# LuaLibs

LuaLibs is a collection of reusable libraries written entirely in Lua. The project aims to provide useful functionality without relying on external libraries. All libraries are made without the usage of Lua's C api, as a challenge.

---------------------

## Design

Each library is intended to be independent: a library should depend only on Lua’s built-in features.

File naming indicates the module’s focus:

- PascalCase filenames are class-focused.
- camelCase filenames are function-focused.

---------------------

## Libraries

- Container — Deque, heap, queue, and stack implementations.
- Math — Calculus, complex numbers, and linear algebra.
- Temporal — Date, date-time, and time utilities.
- Utils — Argument parsing, CSV, JSON, and logging utilities.
- Http — HTTP client and server; currently partial. See Http/README.md [blocked] for details.

---------------------

## Status

The following libraries are implemented or in progress:

- Temporal
- Container
- Math
- Utils
- Http — partial; see Http/README.md
