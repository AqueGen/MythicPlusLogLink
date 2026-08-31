# Changelog

## [1.1.0](https://github.com/AqueGen/MythicPlusLogLink/compare/v1.0.0...v1.1.0) (2026-08-31)


### Features

* copy a Warcraft Logs link that opens on the Mythic+ season ([241d3d0](https://github.com/AqueGen/MythicPlusLogLink/commit/241d3d0e7bf41e3653413d7913c48b77c176cf5b))

## [1.0.0] - 2026-09-01

Initial release.

- Right-click any player and copy their Warcraft Logs link, opened on the Mythic+ season rather than the raid tab.
- `/wcl` for the current target, `/wcl Name-Realm` for anyone in or out of range.
- Carries the twenty-three EU realms whose Warcraft Logs slug cannot be derived from the realm's name, twenty of them Russian.
- Folds Cyrillic character names by arithmetic on the UTF-8 bytes, so the link comes out the same on every client locale.
