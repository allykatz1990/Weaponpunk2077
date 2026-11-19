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
- **Supporting evidence:** Expanded Dual Wielding (mod 35626) notes in its code that many vanilla
  systems pick "the weapon" with a right-hand-first helper; its firing code doesn't touch hit data.
- **What:** two checks decide which gun a hit is credited to while dual wielding:
  1. `attackData.GetSource()`, when it is a weapon that differs from `GetWeapon()`;
  2. failing that, ammo: if the left gun's magazine dropped since the last hit and the right
     gun's did not, the left gun fired. Pellets of the same shot reuse the last decision.
  Single-gun play is unaffected. Known limit: when both guns fire at once, the game's answer is kept.
- **Code:** `HitWeapon`, `AmmoSaysLeft`, `DualWielding` and `WeaponLabel` (plus the `m_dw*`
  fields) just above `OnPlayerHit` in
  `WLvlSystem.reds`. The comment there explains how to read the new `dual-wield hit` debug
  log line and what to try next if the fix doesn't work.
