Weapon swing timer for Vanilla

Currently:
- Tracks player and target main hand

Todo:
- Offhand tracking

### Development notes

- Frame XML isn't so bad

#### Game events

*Event*                                   | *Global variable* | Description
----------------------------------------- | ----------------- | -----------
`CHAT_MSG_COMBAT_SELF_HITS`               |                   | When a player attack hits
                                          | `arg1`            | The combat log message
`CHAT_MSG_COMBAT_SELF_MISSES`             |                   | When a player attack misses/is dodged/is parried
                                          | `arg1`            | The combat log message
`CHAT_MSG_SPELL_SELF_DAMAGE`              |                   | When a player spell hits
                                          | `arg1`            | The combat log message
`CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS`   |                   | When a monster attack vs player hits
                                          | `arg1`            | The combat log message
`CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES` |                   | When a monster attack vs player hits/is dodged/is parried
                                          | `arg1`            | The combat log message

#### Frame events

*Event*    | *Global variable* | Description
---------- | ----------------- | -----------
`OnUpdate` |                   | Called every frame
           | `arg1`            | The delta time (frames elapsed since last update)
`OnEvent`  |                   | Called 