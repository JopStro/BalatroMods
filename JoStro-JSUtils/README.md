# JSUtils: A configuration framework for Balatro
JSUtils is a mod that allows mods to define additional item prototypes, item descriptions and sprite atli using a collection of json configuration files. Additional patches for giving items custom atli and correctly adding items into the collection pages are also included.

# Usage
The JSON configuration files must be placed directly in a folder named `js_utils` inside of the appropriate mod's folder.

The following files are supported:
- `centers.json`, `blinds.json`, `tags.json` and `seals.json`: Each contain a table that is added to the appropriate item prototype table in `Game:init_item_prototypes`, for example `centers.json` is added to `G.P_CENTERS`.
- `descriptions.json`: contains a table of various custom localizations that are added to the descriptions section of the game's localization object. `en-us` is required as it is defaulted to when a language is not included.
- `asset_atli.json`, `animation_atli.json`: Each contain a list of atlas objects, that are inserted directly into the appropriate lists in `Game:set_render_settings`. Paths are extrapolated to be relative to `<mod_dir>/textures/{1,2}x`

# Examples

A basic joker added in `centers.json`. `order` is currently set automatically, and pos is defaulted to `{x = 0, y = 0}` when none is provided. The `atlas` property is also supported for custom atli. 
```json
{
  "j_example_joker": {
    "name": "Example Joker",
    "unlocked": true,
    "discovered": true,
    "blueprint_compat": true,
    "eternal_compat": true,
    "rarity": 1,
    "cost": 2,
    "effect": "",
    "cost_mult": 1.0,
    "config": {},
    "atlas": "Example"
  }
}
```

A simple english joker description added in `descriptions.json`.
```json
{
  "en-us": {
    "Joker": {
      "j_example_joker": {
        "name": "Example Joker",
        "text": [
          "Does nothing special",
          "but it's a mod so that's cool"
        ]
      }
    }
  }
}
```

A custom atlas added in `asset_atli.json`, requires a file called example.png located in `textures/1x` and `textures/2x` in the mod's folder
```json
[
  {"name":"Example","example.png","px":71,"py":95}
]
```
