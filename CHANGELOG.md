# Changelog

Notes for players and for anyone who maintains this mod later. Each entry says what changed,
why, and where in the code to look.

## 0.6.2 beta: Dual Wielding QoL patch (Nov 2026)

### Added: "Card size (percent)" setting
- **Why:** a player reported the weapon card was too large (Nexus comments, Nov 2026).
- **What:** Mod Settings → Weapon Card → *Card size (percent)*, 50–150, default 100 (100 is the
  old size, so nothing changes for anyone who doesn't touch it). In menus the card is drawn at
  80% of this, as before.
- **Code:** `cardScale` in `WLvlConfig.reds`; read at the top of `WLvlCard.ShowEx` in
  `WLvlCard.reds`, where it becomes the scale factor `s` that every size on the card is
  multiplied by. Text for the setting: `WLvl-Set-cardScale` / `WLvl-SetDesc-cardScale` in
  `WLvlLang.reds` and the translation kit.

### Added: both cards while dual wielding
- **Why:** a player reported "dual wield left handgun doesn't count XP". Testing showed the XP
  *was* counted (see below); the card only ever showed the right-hand gun, so it looked broken.
  Stacked cards were the mod author's idea.
- **What:** while dual wielding during play, drawing a weapon or a level-up shows both guns'
  cards in one column: the right-hand (main) card in the usual spot, the left-hand card directly
  on top of it. Each carries a RIGHT HAND / LEFT HAND tag on its level line, and only the gun
  that levelled gets the LEVEL UP line. The column moves as one block with "Card height" and
  "Card side", and always stays on screen. Menus and the spend menu still show one card (the
  spend-menu card also gets a hand tag while dual wielding). New setting "Both cards when dual
  wielding" (on by default) turns it off.
- **Code:** `WLvlCard.reds`: `Show` decides single vs dual; `ShowDual` builds the column;
  `ShowEx`'s old drawing body is now `Build` (returns an unplaced card) plus `PlaceInPlay`,
  `Scale` and `StartHideTimer`; `AddTextRight` draws the hand tag. The left card is a second
  widget named `WLvlCard2`, removed by `RemoveFrom` together with `WLvlCard`. Hand lookups:
  `RightHandItem` / `LeftHandItem` in `WLvlSystem.reds`. Setting: `dualCards` in
  `WLvlConfig.reds`.
- **Gotcha found in testing:** the first version read each card's height from the widget
  (`GetSize`), which is 0 until the game lays the widget out, so both cards landed in the same
  spot. Heights now come from `WLvlCard.UnscaledHeight`, used by both `Build` and the placement.
  Any new line added to the card must be counted there too.

### Investigated: left-hand kill XP while dual wielding (no bug found)
- Tested on game 2.5 + Expanded Dual Wielding 3.8: `attackData.GetWeapon()` reports the correct
  gun for each hand and the left gun earns kill XP. `attackData.GetSource()` is always empty for
  gunshots. Two fallbacks tried during this (source, and comparing magazine counts) were removed:
  not needed, and the ammo one could misfire.
- Kept: `HitWeapon` in `WLvlSystem.reds` as the one place a hit's weapon is decided, with a
  "dual-wield hit" debug log line, in case another dual-wield mod or patch reports the wrong hand.
