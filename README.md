## Held Hostile Wishlist

A World of Warcraft Classic addon for marking loot preference to be shared within a guild with the goal to improve loot planning.

### TODO

#### Data
- Loot per instance
  - Include AtlasLootClassic
- Loot actions
  - Priority
  - Upgrade
  - Nice-to-have
  - Aquired

````lua
players = {
  ["playerName"] = {
    version = 123, -- Some way to compare ordering
    items = {
      ["itemID"] = "lootAction"
    }
  }
},
requests = {
  ["player"] = "version"
}
````

#### Comms
When a player logs in they announce a `HAVE` message to the `guild` channel with the state of their own local database.

When a player receives a `HAVE` message they compare it to their local database. They compile a list of player entries that are older than the local db for their own `HAVE` message. Then they compile a list of entries that were newer than the local db into a `WANT` message. Both messages are sent as a `whisper` to the source of the original `HAVE`.

When a player receives a `WANT` message they compile the requested player data and returns with an `UPDATE` message as a `whisper` to the source player.

When a player makes changes to their own data they compile the changes into a new `UPDATE` message that gets sent to the `guild` channel.

---

**`HAVE`**
````lua
{
  ["playerName"] = "version",
  -- ...
}
````
Send on login to `guild` channel or as a `whisper` response to another players `HAVE` message if they have newer entries for any players.

---

**`WANT`** (player)
````lua
{
  ["playerName"] = "version",
  -- ...
}
````
Send request for data to a specific player via the `whisper` channel.

---

**`UPDATE`**
````lua
{
  ["playerName"] = {
    version = "version",
    items = {
      ["itemID"] = "lootAction"
    }
  },
}
````
Send wishlist data for a list of players. Can be sent as a response to a `WANT` message directly to the requester. Can also be broadcasted with updates of the personal wishlist to the `guild` channel.

#### UI
- Main window
- Loot list per instance
  - Instance select
  - Sorted per source
  - Item icon, name, type, drop chance, wishlist summary
- Personal wishlist
  - Sorted per slot or source?
  - Item icon, name, type, drop chance, wishlist summary
- Loot details
  - Icon and name
  - Item type
  - Drop chance
  - Wishlist
    - Action buttons
    - Priority
    - Upgrade
    - Interested


#### Comm - Old thoughts

When a player logs in they announce a `QUERY` to the guild channel with the state of their own local database.

Online players compare the `QUERY` to their db and compile a `requests` queue of newer entries that they have locally. Then they set a wait timer for random duration. Players present in local db but missing in the `QUERY` should be added to `requests` queue.

If while waiting, someone else sends an `UPDATE`, compare the data with the local `requests` queue and remove entries with equal or newer versions. If queue become empty, remove timer. Also update local db with newer versions.

When timer runs out send `UPDATE` with local data for players still in the `requests` queue.

If received `QUERY` includes entries newer than local db data. - Send personal request? Or complement with another `QUERY` to guild with those.

Should I include a delay after `QUERY_ALL` to gather information from respondants before requesting updates? Also, do I realy need the `HAVE` message? Could just respond directly with the data I have? Would mean multiple players spamming a response but if the data package is small it might not matter?

Since updates when logging in is not time critical everyone could start a random timer before responding. Then if responses are sent over `GUILD` everyone can cancel unnecessary updates.
