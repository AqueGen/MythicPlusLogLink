# Mythic Plus LogLink

Right-click a player, copy their Warcraft Logs link, and land on the **Mythic+ season** instead of the raid tab.

## Why

Archon and Raider.IO both copy a character link already. Both of them land on the raid page, and if what you wanted was the keys, you switch the zone by hand every time.

That is the whole addon. It builds one URL and puts it in a box you can copy.

## What it does

- **Right-click any player** - unit frame, target, party, raid, chat name, friends list, guild roster - and pick `Warcraft Logs / Mythic+ Season 2`.
- **`/wcl`** copies the link for your current target.
- **`/wcl Name-Realm`** copies it for anyone, in or out of range.

A window opens with the link already selected. Ctrl+C, Escape.

## What it does not do

**It cannot open your browser.** No addon can: the WoW Lua sandbox has no `io`, no `os.execute`, and no way to start another program. That is why every addon that offers a link offers a box to copy from, this one included.

It also ships no data, makes no network calls, and stores nothing. It is a URL builder.

## The realm problem

Warcraft Logs addresses a character as `/character/<region>/<realm>/<name>`, and that realm is the site's own slug, not the realm's name. Most of them are derivable - lowercase, drop apostrophes, hyphen the spaces - but twenty-three in EU are not, and twenty of those are Russian realms whose Cyrillic name maps to a Latin slug with no relationship to its letters:

| Realm | Slug |
|---|---|
| Дракономор | `fordragon` |
| Пиратская бухта | `booty-bay` |
| Термоштепсель | `thermaplugg` |
| Свежеватель Душ | `soulflayer` |

Nothing in the game client knows those pairs, so the addon carries the list. It also folds Cyrillic character names to lowercase by arithmetic on the UTF-8 bytes rather than through `string.lower`, which is the C library applied byte by byte and behaves differently depending on the client's locale.

## Season

The zone id is one number, `Link.ZONE`, changed once per season. There is no API that maps "the current Mythic+ season" to a Warcraft Logs zone, and guessing wrong sends you to an empty page rather than to no page.

## Tests

```
busted
```

Lua 5.1. Covers realm slugs, the exception table, Cyrillic folding, URL shape, and that every shipped file compiles and is listed in the `.toc`.

## Licence

All rights reserved - see [LICENSE](LICENSE).
