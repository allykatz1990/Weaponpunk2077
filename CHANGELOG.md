# Changelog

Notes for players and for anyone who maintains this mod later. Each entry says what changed,
why, and where in the code to look.

## 0.6.2 beta (in testing)

### Added: "Card size (percent)" setting
- **Why:** a player reported the weapon card was too large (Nexus comments, Nov 2026).
- **What:** Mod Settings → Weapon Card → *Card size (percent)*, 50–150, default 100 (100 is the
  old size, so nothing changes for anyone who doesn't touch it). In menus the card is drawn at
  80% of this, as before.
- **Code:** `cardScale` in `WLvlConfig.reds`; read at the top of `WLvlCard.ShowEx` in
  `WLvlCard.reds`, where it becomes the scale factor `s` that every size on the card is
  multiplied by. Text for the setting: `WLvl-Set-cardScale` / `WLvl-SetDesc-cardScale` in
  `WLvlLang.reds` and the translation kit.

### Fixed (needs in-game confirmation): left-hand gun earned no XP while dual wielding
- **Why:** reported on Nexus (Nov 2026).
- **Cause (likely):** kill credit came only from `attackData.GetWeapon()`, which with two guns
  seems to report the right-hand gun (or nothing) for left-hand shots.
- **What:** the gun a hit is credited to now prefers `attackData.GetSource()` when that is a
  weapon and differs from `GetWeapon()`. Single-gun play is unaffected.
- **Code:** `HitWeapon`, `DualWielding` and `WeaponLabel` just above `OnPlayerHit` in
  `WLvlSystem.reds`. The comment there explains how to read the new `dual-wield hit` debug
  log line and what to try next if the fix doesn't work.
