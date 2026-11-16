# Weaponpunk 2077 – SPOILERS

**Stop here if you want to discover the hidden system yourself.**

---

Individual guns earn hidden **titles**. A title belongs to that one copy of the gun, not the model. When a gun earns one, a NEW TITLE card appears. The gun's strongest title appears in quotes after its name, on the weapon card, in the inventory and in the tooltip (for example *D5 Copperhead "Doom Slayer"*). All of its titles are listed with what they do in the tooltip's bonus lines. **Every earned title's bonus always works**; the name only shows one. To show a different one, Mod Settings → Weaponpunk 2077 → Titles offers strongest, second or third strongest, weakest, or most recently earned (generic on purpose, so the menu doesn't name any titles).

The first title makes the gun an **iconic** weapon. Its titles are lost if it is sold or dismantled.

Quest characters never count toward faction or Karen Slayer counts.

## Faction titles

Kills with one gun. A higher tier replaces the lower one. The bonus is extra damage against that faction, on that gun's hits.

| Faction | Tier 1 | Tier 2 | Tier 3 |
|---|---|---|---|
| Arasaka | Suit Piercer | Saka Wrecker | Tower Toppler |
| Tyger Claws | Street Sweeper | Claw Clipper | Neon Requiem |
| Maelstrom | Chrome Crusher | Borg Shredder | Rust Maker |
| Scavengers | Vulture Killer | Harvester Hunter | Last Harvest |
| Voodoo Boys | Proxy Piercer | Daemon Slayer | Chapel Burner |
| 6th Street | Flag Burner | Militia Mauler | Patriot's End |
| Valentinos | Halo Breaker | Altar Stainer | Deicide |
| Animals | Juice Drainer | Behemoth Breaker | Apex Extinction |
| Militech | Flak Shredder | Convoy Crusher | The General's Grave |
| Barghest | Hound Hunter | Pack Breaker | Dogtown's Reckoning |
| Wraiths | Raffen Reaper | Shiv Snapper | Dust to Dust |
| NUSA / FIA | Spook Hunter | Agency Eraser | State of Disunion |
| NCPD | Siren Silencer | Badge Breaker | Precinct Purger |
| MaxTac | Mantis Clipper | Squad Wiper | Uncontainable |
| NetWatch | Trace Severer | Watcher Killer | The Blind Spot |
| Kang Tao | Smart Jammer | Dragon Slayer | Kang Tao's Collapse |

| Faction kind | Kills for tiers 1 / 2 / 3 | Damage bonus |
|---|---|---|
| Endless: NCPD, Arasaka, Militech | 25 / 250 / 1,500 | +10 / +15 / +18%, then +1% per 500 more kills |
| Gangs | 150 / 400 / 800 | +20 / +30 / +40% |
| Small: Barghest, Wraiths, NUSA, MaxTac, NetWatch, Kang Tao | 50 / 150 / 300 | +20 / +30 / +40% |

## Special titles

| Title | How (one gun) | Bonus |
|---|---|---|
| Carmageddon I / II / III | Destroy 50 / 100 / 200 vehicles | +10 / 20 / 30% damage to vehicles, mechs and drones |
| Psychosquad Leader I / II / III | Take 3 / 8 / 17 cyberpsychos down alive | +10 / 20 / 30% damage to cyberpsychos and MaxTac |
| Karen Slayer / II / III | Kill 5 / 20 / 50 civilians who attacked you first (needs a civilian-aggression mod; police never count) | +20 / 35 / 50% damage against anyone who hurt you before you hurt them; if one squad member starts it, the whole squad counts |

## Feat titles

Feat bonuses work while the titled gun sits in any weapon slot, drawn or not. While dual wielding, the left-hand gun gives none, and a gun moved into the right hand starts after 3 seconds. Each gun has to earn its own feats. A fight ends after 30 seconds without a kill.

| Title | Feat | Bonus |
|---|---|---|
| Lead Storm | 5 kills in 5 seconds | Berserker, up to 3 stacks |
| Reaper's Tempo | 10 kills in 5 seconds | Berserker, up to 4 stacks |
| Bullet Hell Sovereign | 15 kills in 5 seconds | Berserker, up to 5 stacks |
| Doom Slayer | 25 kills in one fight without reloading or swapping weapons | Kills heal 2% health |
| Smart Bomb | 5 kills from a single shot or blast | +25% explosion damage |
| Untouchable | 30 kills in one fight without taking damage | 10% less damage taken |
| Ghost Protocol | 10 kills in a row on enemies who never noticed you | +25% damage to unaware enemies |
| Tactical Espionage | 50 stealth kills with the gun | +50% weapon XP from stealth kills |
| Snake Eater | A fight of 15+ kills where you used 5+ healing items | Healing items heal an extra 5% health |

**Berserker:** once you land 5 kills within 5 seconds, each further kill adds +5% damage for 10 seconds. It shows in the buff bar as a samurai mask with the stack count.

## Trophy titles

Cosmetic. The gun that lands the killing blow gets the title and a tooltip note.

| Target | Title |
|---|---|
| Adam Smasher | Smashed |
| Kurt Hansen | Kingslayer |
| Sandayu Oda | Honor's Mercy |
| Royce | Maelstrom Interrupted |
| Woodman | Evelyn's Reckoning |
| Sasquatch | Cryptid Hunter |
| Solomon Reed | The Handler's Price |
| Jotaro Shobo | Sins of Kabuki |
| The Persson brothers | The Trauma Weavers |
| Placide | Loa's Last Rites |
| Bryce Mosley (NetWatch) | Firewall Breach |
| Dum Dum | Dumb Luck Ran Out |
| Nash (Raffen Shiv) | Wraith Exorcist |
| Fingers | Clouded Judgment |
| Anthony Harris | River's Justice |
| Chimera (Militech mech) | Myth Buster |
| Cerberus (Militech mech) | Gatekeeper's Fall |

## Johnny's gun

1. **The Board's Worst Nightmare.** Malorian Arms 3516 only: 1,500 Arasaka kills, 100 killing headshots on Arasaka elites or bosses, and at least one Arasaka heavy or mech. Bonus: +50% damage against all Arasaka.
2. **The shot.** With that Malorian, your first hit on Adam Smasher, if it's a headshot, drops him to 10–15% health. It doesn't kill him, so his fight plays out. Open any other way and the chance is gone until you reload the save. No prompt, no indicator.
3. **The Solo's Last Laugh.** Awarded for landing the shot. The Malorian kills ordinary enemies in one hit; bosses, named and quest characters take triple damage. In exchange it holds 3 rounds instead of 8, and reloads and fires a third slower.

## Console commands (testing)

Open the Cyber Engine Tweaks console:

```
Game.GetScriptableSystemsContainer():Get("WLvlSystem"):Report()        -- the drawn weapon's level
Game.GetScriptableSystemsContainer():Get("WLvlSystem"):CheatXP(5000)    -- add XP to the drawn weapon
Game.GetScriptableSystemsContainer():Get("WLvlSystem"):CheatJohnny()    -- grant stage 1 to the drawn Malorian
```
