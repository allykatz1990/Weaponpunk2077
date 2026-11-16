// Weaponpunk 2077 - Weapon Leveling Enhanced - titles: the fixed tables and rules
// Copyright (C) 2026 the Weaponpunk 2077 authors. Written with AI assistance.
//
// This program is free software: you can redistribute it and/or modify it under the terms of the
// GNU General Public License as published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version. It is distributed WITHOUT ANY WARRANTY. See the
// GNU General Public License for details: https://www.gnu.org/licenses/
//
// SPOILERS: this file lists every hidden title.
//
// Titles belong to one individual gun, not to the model. The counters and earned titles are kept
// in WLvlSystem; this file only holds the tables and the rules for reading them.
//
// Title codes (stored in saves, so never renumber):
//   100 + faction * 3 + (tier - 1)   faction titles (factions 0-15, tiers 1-3)
//   200 + (tier - 1)                 Carmageddon I-III
//   210 + (tier - 1)                 Psychosquad Leader I-III
//   220 + (tier - 1)                 Karen Slayer I-III
//   230 + feat                       feat titles (0-8, see FeatTitle)
//   250 / 251                        Johnny's gun: The Board's Worst Nightmare / The Solo's Last Laugh
//   300 + trophy                     trophy titles (0-16)
// Every number here is a starting value to be tuned in testing.

public abstract class WLvlTitles {
  public static func FactionCount() -> Int32 { return 16; }
  public static func TrophyCount() -> Int32 { return 17; }

  // ================================================================ factions
  //  0 Arasaka      1 Tyger Claws  2 Maelstrom   3 Scavengers   4 Voodoo Boys  5 6th Street
  //  6 Valentinos   7 Animals      8 Militech    9 Barghest    10 Wraiths     11 NUSA / FIA
  // 12 NCPD        13 MaxTac      14 NetWatch   15 Kang Tao
  public static func FactionOf(victim: ref<ScriptedPuppet>) -> Int32 {
    let rec = TweakDBInterface.GetCharacterRecord(victim.GetRecordID());
    if !IsDefined(rec) {
      return -1;
    }
    if IsDefined(rec.Rarity()) && Equals(rec.Rarity().Type(), gamedataNPCRarity.MaxTac) {
      return 13;
    }
    if !IsDefined(rec.Affiliation()) {
      return -1;
    }
    switch rec.Affiliation().Type() {
      case gamedataAffiliation.Arasaka: return 0;
      case gamedataAffiliation.TygerClaws: return 1;
      case gamedataAffiliation.Maelstrom: return 2;
      case gamedataAffiliation.MaelstromAndroid: return 2;
      case gamedataAffiliation.Scavengers: return 3;
      case gamedataAffiliation.ScavengersAndroid: return 3;
      case gamedataAffiliation.VoodooBoys: return 4;
      case gamedataAffiliation.SixthStreet: return 5;
      case gamedataAffiliation.SixthStreetAndroid: return 5;
      case gamedataAffiliation.Valentinos: return 6;
      case gamedataAffiliation.Animals: return 7;
      case gamedataAffiliation.Militech: return 8;
      case gamedataAffiliation.Barghest: return 9;
      case gamedataAffiliation.Wraiths: return 10;
      case gamedataAffiliation.WraithsAndroid: return 10;
      case gamedataAffiliation.Wraiths_Former: return 10;
      case gamedataAffiliation.NUSA: return 11;
      case gamedataAffiliation.NCPD: return 12;
      case gamedataAffiliation.NetWatch: return 14;
      case gamedataAffiliation.KangTao: return 15;
    }
    return -1;
  }

  public static func FactionName(f: Int32) -> String {
    switch f {
      case 0: return "Arasaka";
      case 1: return "the Tyger Claws";
      case 2: return "Maelstrom";
      case 3: return "the Scavengers";
      case 4: return "the Voodoo Boys";
      case 5: return "the 6th Street";
      case 6: return "the Valentinos";
      case 7: return "the Animals";
      case 8: return "Militech";
      case 9: return "the Barghest";
      case 10: return "the Wraiths";
      case 11: return "NUSA and the FIA";
      case 12: return "the NCPD";
      case 13: return "MaxTac";
      case 14: return "NetWatch";
      case 15: return "Kang Tao";
    }
    return "";
  }

  // 0: endlessly spawning (NCPD, Arasaka, Militech)   1: regular gang   2: small faction
  public static func FactionKind(f: Int32) -> Int32 {
    if f == 0 || f == 8 || f == 12 {
      return 0;
    }
    if f >= 1 && f <= 7 {
      return 1;
    }
    return 2;
  }

  public static func FactionThreshold(f: Int32, tier: Int32) -> Int32 {
    let kind = WLvlTitles.FactionKind(f);
    if kind == 0 {
      if tier == 1 { return 25; }
      if tier == 2 { return 250; }
      return 1500;
    }
    if kind == 1 {
      if tier == 1 { return 150; }
      if tier == 2 { return 400; }
      return 800;
    }
    if tier == 1 { return 50; }
    if tier == 2 { return 150; }
    return 300;
  }

  public static func FactionTier(f: Int32, kills: Int32) -> Int32 {
    let tier = 0;
    while tier < 3 && kills >= WLvlTitles.FactionThreshold(f, tier + 1) {
      tier += 1;
    }
    return tier;
  }

  // Damage bonus in percent against that faction. Endless factions: +10 / +15 / +18, then +1 per
  // 500 further kills. Gangs and small factions: +20 / +30 / +40.
  public static func FactionBonus(f: Int32, kills: Int32) -> Float {
    let tier = WLvlTitles.FactionTier(f, kills);
    if tier == 0 {
      return 0.0;
    }
    if WLvlTitles.FactionKind(f) == 0 {
      if tier == 1 { return 10.0; }
      if tier == 2 { return 15.0; }
      return 18.0 + Cast<Float>((kills - 1500) / 500);
    }
    return 10.0 + 10.0 * Cast<Float>(tier);
  }

  public static func FactionTitle(f: Int32, tier: Int32) -> String {
    switch f {
      case 0: return WLvlTitles.Pick(tier, "Suit Piercer", "Saka Wrecker", "Tower Toppler");
      case 1: return WLvlTitles.Pick(tier, "Street Sweeper", "Claw Clipper", "Neon Requiem");
      case 2: return WLvlTitles.Pick(tier, "Chrome Crusher", "Borg Shredder", "Rust Maker");
      case 3: return WLvlTitles.Pick(tier, "Vulture Killer", "Harvester Hunter", "Last Harvest");
      case 4: return WLvlTitles.Pick(tier, "Proxy Piercer", "Daemon Slayer", "Chapel Burner");
      case 5: return WLvlTitles.Pick(tier, "Flag Burner", "Militia Mauler", "Patriot's End");
      case 6: return WLvlTitles.Pick(tier, "Halo Breaker", "Altar Stainer", "Deicide");
      case 7: return WLvlTitles.Pick(tier, "Juice Drainer", "Behemoth Breaker", "Apex Extinction");
      case 8: return WLvlTitles.Pick(tier, "Flak Shredder", "Convoy Crusher", "The General's Grave");
      case 9: return WLvlTitles.Pick(tier, "Hound Hunter", "Pack Breaker", "Dogtown's Reckoning");
      case 10: return WLvlTitles.Pick(tier, "Raffen Reaper", "Shiv Snapper", "Dust to Dust");
      case 11: return WLvlTitles.Pick(tier, "Spook Hunter", "Agency Eraser", "State of Disunion");
      case 12: return WLvlTitles.Pick(tier, "Siren Silencer", "Badge Breaker", "Precinct Purger");
      case 13: return WLvlTitles.Pick(tier, "Mantis Clipper", "Squad Wiper", "Uncontainable");
      case 14: return WLvlTitles.Pick(tier, "Trace Severer", "Watcher Killer", "The Blind Spot");
      case 15: return WLvlTitles.Pick(tier, "Smart Jammer", "Dragon Slayer", "Kang Tao's Collapse");
    }
    return "";
  }

  private static func Pick(tier: Int32, a: String, b: String, c: String) -> String {
    if tier == 1 { return a; }
    if tier == 2 { return b; }
    return c;
  }

  // ================================================================ Carmageddon
  // Vehicles destroyed by one gun: 50 / 100 / 200. Bonus against vehicles, mechs and drones.
  public static func CarmaTier(count: Int32) -> Int32 {
    if count >= 200 { return 3; }
    if count >= 100 { return 2; }
    if count >= 50 { return 1; }
    return 0;
  }

  public static func CarmaBonus(count: Int32) -> Float {
    return 10.0 * Cast<Float>(WLvlTitles.CarmaTier(count));
  }

  // True for the targets Carmageddon's bonus applies to (people only; vehicles are checked by type).
  public static func IsMachine(victim: ref<ScriptedPuppet>) -> Bool {
    let t = victim.GetNPCType();
    return Equals(t, gamedataNPCType.Mech) || Equals(t, gamedataNPCType.Cerberus) || Equals(t, gamedataNPCType.Chimera)
      || Equals(t, gamedataNPCType.Drone) || Equals(t, gamedataNPCType.Spiderbot);
  }

  // ================================================================ Psychosquad Leader
  // Cyberpsychos taken down alive with one weapon: 3 / 8 / 17. In the lore, the cyberpsychos V
  // spares can end up in MaxTac, so the bonus is against cyberpsychos and MaxTac.
  public static func PsychoTier(count: Int32) -> Int32 {
    if count >= 17 { return 3; }
    if count >= 8 { return 2; }
    if count >= 3 { return 1; }
    return 0;
  }

  public static func PsychoBonus(count: Int32) -> Float {
    return 10.0 * Cast<Float>(WLvlTitles.PsychoTier(count));
  }

  // ================================================================ Karen Slayer
  // Civilians killed after they attacked V first (damaged V or drew a weapon on V): 5 / 20 / 50.
  // Bonus +20 / +35 / +50% damage against anyone who damaged V before V damaged them, gangs too.
  // Needs a mod that makes civilians fight back, so it never triggers without one.
  public static func KarenTier(count: Int32) -> Int32 {
    if count >= 50 { return 3; }
    if count >= 20 { return 2; }
    if count >= 5 { return 1; }
    return 0;
  }

  public static func KarenBonus(count: Int32) -> Float {
    let tier = WLvlTitles.KarenTier(count);
    if tier == 1 { return 20.0; }
    if tier == 2 { return 35.0; }
    if tier == 3 { return 50.0; }
    return 0.0;
  }

  public static func IsCivilian(victim: ref<ScriptedPuppet>) -> Bool {
    return victim.IsCharacterCivilian() || victim.IsCrowd();
  }

  // ================================================================ feats
//  0 Lead Storm             5 kills in 5 seconds              } the streak titles replace each other
//  1 Reaper's Tempo        10 kills in 5 seconds              } and grant the Berserker buff
//  2 Bullet Hell Sovereign 15 kills in 5 seconds              } (max stacks 3 / 4 / 5)
//  3 Doom Slayer           25 kills in one fight without reloading or holstering: kills heal 2% health
//  4 Smart Bomb             5 kills from one shot or blast: +25% explosion damage
//  5 Untouchable           30 kills in one fight without taking damage: 10% less damage taken
//  6 Ghost Protocol        10 kills in a row on enemies who never noticed V: +25% damage to unaware enemies
//  7 Tactical Espionage    50 stealth kills with one weapon in total: +50% weapon XP from stealth kills
//  8 Snake Eater           a fight of 15+ kills using 5+ healing items: healing items heal 5% more health
// Feat bonuses work while the titled gun sits in a weapon slot, drawn or not. While dual wielding,
// a gun in the left hand gives none, and a gun moved into the right hand starts after 3 seconds.
  public static func FeatCount() -> Int32 { return 9; }
  public static func FeatCode(k: Int32) -> Int32 { return 230 + k; }

  public static func FeatTitle(k: Int32) -> String {
    switch k {
      case 0: return "Lead Storm";
      case 1: return "Reaper's Tempo";
      case 2: return "Bullet Hell Sovereign";
      case 3: return "Doom Slayer";
      case 4: return "Smart Bomb";
      case 5: return "Untouchable";
      case 6: return "Ghost Protocol";
      case 7: return "Tactical Espionage";
      case 8: return "Snake Eater";
    }
    return "";
  }

  public static func FeatNote(k: Int32) -> String {
    switch k {
      case 0: return "Berserker: 5 kills in 5 s, +5% damage per stack (3 max)";
      case 1: return "Berserker: 5 kills in 5 s, +5% damage per stack (4 max)";
      case 2: return "Berserker: 5 kills in 5 s, +5% damage per stack (5 max)";
      case 3: return "Kills heal 2% health";
      case 4: return "+25% explosion damage";
      case 5: return "10% less damage taken";
      case 6: return "+25% damage to unaware enemies";
      case 7: return "+50% weapon XP from stealth kills";
      case 8: return "Healing items heal 5% more health";
    }
    return "";
  }

  // ================================================================ trophies
  // The gun that lands the killing blow on a named character. Cosmetic only.
  // Matched by character record first, then by the character's English display name.
  public static func TrophyOf(victim: ref<ScriptedPuppet>) -> Int32 {
    let id = victim.GetRecordID();
    if id == t"Character.Smasher" { return 0; }
    if id == t"Character.kurtz" { return 1; }
    if id == t"Character.Cyberninja_Oda" || id == t"Character.Cyberninja_Oda_Follower" { return 2; }
    if id == t"Character.Royce" || id == t"Character.main_boss_royce" { return 3; }
    if id == t"Character.sq026_woodman" { return 4; }
    if id == t"Character.main_boss_sasquatch" { return 5; }
    if id == t"Character.reed" { return 6; }
    if id == t"Character.sts_wat_kab_07_jotaro" { return 7; }
    if id == t"Character.sts_wat_nid_04_gottfrid" || id == t"Character.sts_wat_nid_04_fredrik" { return 8; }
    if id == t"Character.Placide" { return 9; }
    if id == t"Character.q110_netwatch_agent" { return 10; }
    if id == t"Character.DumDum" { return 11; }
    if id == t"Character.q103_raffen_nash" { return 12; }
    if id == t"Character.Fingers" { return 13; }
    if id == t"Character.sq021_meatman" { return 14; }
    if id == t"Character.q302_militech_chimera" || Equals(victim.GetNPCType(), gamedataNPCType.Chimera) { return 15; }
    if id == t"Character.q305_cerberus_robot" { return 16; }

    // fight versions of a character can use a different record than the one listed above
    let name = victim.GetDisplayName();
    if Equals(name, "Adam Smasher") { return 0; }
    if Equals(name, "Kurt Hansen") { return 1; }
    if Equals(name, "Oda") || Equals(name, "Sandayu Oda") { return 2; }
    if Equals(name, "Royce") { return 3; }
    if Equals(name, "Woodman") { return 4; }
    if Equals(name, "Sasquatch") { return 5; }
    if Equals(name, "Solomon Reed") { return 6; }
    if Equals(name, "Jotaro Shobo") { return 7; }
    if Equals(name, "Gottfrid Persson") || Equals(name, "Fredrik Persson") { return 8; }
    if Equals(name, "Placide") { return 9; }
    if Equals(name, "Dum Dum") { return 11; }
    if Equals(name, "Nash") { return 12; }
    if Equals(name, "Fingers") { return 13; }
    if Equals(name, "Anthony Harris") { return 14; }
    return -1;
  }

  public static func TrophyTitle(k: Int32) -> String {
    switch k {
      case 0: return "Smashed";
      case 1: return "Kingslayer";
      case 2: return "Honor's Mercy";
      case 3: return "Maelstrom Interrupted";
      case 4: return "Evelyn's Reckoning";
      case 5: return "Cryptid Hunter";
      case 6: return "The Handler's Price";
      case 7: return "Sins of Kabuki";
      case 8: return "The Trauma Weavers";
      case 9: return "Loa's Last Rites";
      case 10: return "Firewall Breach";
      case 11: return "Dumb Luck Ran Out";
      case 12: return "Wraith Exorcist";
      case 13: return "Clouded Judgment";
      case 14: return "River's Justice";
      case 15: return "Myth Buster";
      case 16: return "Gatekeeper's Fall";
    }
    return "";
  }

  // The tooltip note under a trophy title.
  public static func TrophyNote(k: Int32) -> String {
    switch k {
      case 0: return "Killed Adam Smasher";
      case 1: return "Killed Kurt Hansen";
      case 2: return "Killed Sandayu Oda";
      case 3: return "Killed Royce";
      case 4: return "Killed Woodman";
      case 5: return "Killed Sasquatch";
      case 6: return "Killed Solomon Reed";
      case 7: return "Killed Jotaro Shobo";
      case 8: return "Killed a Persson brother";
      case 9: return "Killed Placide";
      case 10: return "Killed Bryce Mosley";
      case 11: return "Killed Dum Dum";
      case 12: return "Killed Nash";
      case 13: return "Killed Fingers";
      case 14: return "Killed Anthony Harris";
      case 15: return "Destroyed the Chimera";
      case 16: return "Destroyed Cerberus";
    }
    return "";
  }

  // ================================================================ codes
  public static func FactionCode(f: Int32, tier: Int32) -> Int32 { return 100 + f * 3 + tier - 1; }
  public static func CarmaCode(tier: Int32) -> Int32 { return 200 + tier - 1; }
  public static func PsychoCode(tier: Int32) -> Int32 { return 210 + tier - 1; }
  public static func TrophyCode(k: Int32) -> Int32 { return 300 + k; }
  public static func KarenCode(tier: Int32) -> Int32 { return 220 + tier - 1; }
  public static func SecretCode(b: Int32) -> Int32 { return 250 + b; }

  public static func SecretNote(b: Int32) -> String {
    if b == 0 {
      return "+50% damage against Arasaka. Smasher has a weak spot, once.";
    }
    return "Kills in one shot. 3-round magazine, slower reload and fire rate.";
  }

  // Codes in the same family replace each other (a higher faction tier replaces the lower one).
  public static func Family(code: Int32) -> Int32 {
    if code >= 100 && code < 200 {
      return 100 + (code - 100) / 3;
    }
    if code >= 200 && code < 210 {
      return 200;
    }
    if code >= 210 && code < 220 {
      return 210;
    }
    if code >= 220 && code < 230 {
      return 220;
    }
    if code >= 230 && code <= 232 {
      return 230;
    }
    return code;
  }

  // How rare and strong a title is. When a gun earns a title that outweighs its active one, the new
  // one becomes active automatically. Trophies are cosmetic, so they never take over.
  public static func Weight(code: Int32) -> Int32 {
    if code == 251 { return 1000; }             // The Solo's Last Laugh
    if code == 250 { return 900; }              // The Board's Worst Nightmare
    if code >= 230 && code < 239 {
      switch code - 230 {
        case 2: return 800;                     // Bullet Hell Sovereign
        case 5: return 750;                     // Untouchable
        case 3: return 700;                     // Doom Slayer
        case 1: return 650;                     // Reaper's Tempo
        case 6: return 600;                     // Ghost Protocol
        case 8: return 550;                     // Snake Eater
        case 7: return 500;                     // Tactical Espionage
        case 4: return 450;                     // Smart Bomb
        case 0: return 400;                     // Lead Storm
      }
    }
    if code >= 220 && code < 223 { return 220 + 80 * (code - 220); }   // Karen Slayer 220 / 300 / 380
    if code >= 210 && code < 213 { return 210 + 80 * (code - 210); }   // Psychosquad Leader 210 / 290 / 370
    if code >= 200 && code < 203 { return 200 + 80 * (code - 200); }   // Carmageddon 200 / 280 / 360
    if code >= 100 && code < 200 {
      let tier = (code - 100) % 3 + 1;
      let f = (code - 100) / 3;
      if WLvlTitles.FactionKind(f) == 0 && tier == 1 {
        return 100;                             // the quick first tier of NCPD, Arasaka, Militech
      }
      return 70 + 80 * tier;                    // 150 / 230 / 310
    }
    return 10;                                  // trophies
  }

  // Whether an earned title is the one picked in Mod Settings (WLvlTitleChoice).
  public static func MatchesChoice(code: Int32, pick: Int32) -> Bool {
    if pick >= 1 && pick <= 9 { return code == 230 + pick - 1; }
    if pick == 10 { return WLvlTitles.Family(code) == 200; }
    if pick == 11 { return WLvlTitles.Family(code) == 210; }
    if pick == 12 { return WLvlTitles.Family(code) == 220; }
    if pick >= 13 && pick <= 28 { return code >= 100 && code < 200 && (code - 100) / 3 == pick - 13; }
    if pick == 29 { return code == 250; }
    if pick == 30 { return code == 251; }
    if pick == 31 { return code >= 300; }
    return false;
  }

  public static func Name(code: Int32) -> String {
    if code >= 100 && code < 200 {
      return WLvlTitles.FactionTitle((code - 100) / 3, (code - 100) % 3 + 1);
    }
    if code >= 200 && code < 210 {
      return WLvlTitles.Pick(code - 199, "Carmageddon I", "Carmageddon II", "Carmageddon III");
    }
    if code >= 210 && code < 220 {
      return WLvlTitles.Pick(code - 209, "Psychosquad Leader I", "Psychosquad Leader II", "Psychosquad Leader III");
    }
    if code >= 220 && code < 230 {
      return WLvlTitles.Pick(code - 219, "Karen Slayer", "Karen Slayer II", "Karen Slayer III");
    }
    if code >= 230 && code < 230 + WLvlTitles.FeatCount() {
      return WLvlTitles.FeatTitle(code - 230);
    }
    if code == 250 {
      return "The Board's Worst Nightmare";
    }
    if code == 251 {
      return "The Solo's Last Laugh";
    }
    if code >= 300 && code < 300 + WLvlTitles.TrophyCount() {
      return WLvlTitles.TrophyTitle(code - 300);
    }
    return "";
  }
}

// A weapon's name with its shown title in quotes after it, like the game's own named weapons,
// for example: D5 Copperhead "Doom Slayer". Other items and untitled guns are left alone.
public func WLvlNameWithTitle(name: String, item: ItemID) -> String {
  if !ItemID.IsValid(item) || !RPGManager.IsItemWeapon(item) {
    return name;
  }
  let sys = WLvlSystem.Get(GetGameInstance());
  if !IsDefined(sys) {
    return name;
  }
  let title = sys.ShownTitleName(item);
  sys.NoteNameAsked(item, name, title);
  if Equals(title, "") {
    return name;
  }
  let quoted = "\"" + title + "\"";
  if StrContains(name, quoted) {
    return name;
  }
  // a different title from earlier may still be attached: keep only the part before it
  let cut = StrFindFirst(name, " \"");
  if cut > 0 {
    name = StrLeft(name, cut);
  }
  return name + " " + quoted;
}

// Item names for the inventory grids (Inventory Adjustments Hub shows these on weapon tiles)
// and the newer inventory screens.
@wrapMethod(UIInventoryItem)
public final func GetName() -> String {
  let name = wrappedMethod();
  let full = WLvlNameWithTitle(name, this.GetID());
  if NotEquals(full, name) {
    this.m_data.Name = full;
  }
  return full;
}

// Item names for the older inventory screens (the weapon slot chooser, vendors, stash).
@wrapMethod(InventoryItemData)
public final static func GetName(const self: script_ref<InventoryItemData>) -> String {
  let name = wrappedMethod(self);
  return WLvlNameWithTitle(name, Deref(self).ID);
}

// Titled guns count as iconic in the inventory.
@wrapMethod(UIInventoryItem)
public final func IsIconic() -> Bool {
  if wrappedMethod() {
    return true;
  }
  let sys = WLvlSystem.Get(GetGameInstance());
  if IsDefined(sys) && sys.Config().enabled && sys.HasTitles(this.GetID()) {
    this.m_data.IsIconicItem = true;
    return true;
  }
  return false;
}

// Older-style item tiles (vendors, stash) set their name label here.
@wrapMethod(InventoryItemDisplayController)
protected func UpdateItemName() -> Void {
  wrappedMethod();
  if !IsDefined(inkWidgetRef.Get(this.m_itemName)) {
    return;
  }
  let sys = WLvlSystem.Get(GetGameInstance());
  if !IsDefined(sys) {
    return;
  }
  let item: ItemID;
  if IsDefined(this.m_tooltipData) {
    item = this.m_tooltipData.itemID;
  }
  if !ItemID.IsValid(item) {
    let data = this.GetItemData();
    item = InventoryItemData.GetID(data);
  }
  let title = sys.ShownTitleName(item);
  if Equals(title, "") {
    return;
  }
  let quoted = "\"" + title + "\"";
  let name = inkTextRef.GetText(this.m_itemName);
  if !StrContains(name, quoted) {
    inkTextRef.SetText(this.m_itemName, name + " " + quoted);
    WLvlSystem.Get(GetGameInstance()).DebugLog("tile name set: " + name + " " + quoted);
  }
}

// Weapon tiles: Inventory Adjustments Hub (and similar mods) write the weapon's name into the
// tile's type label. After the tile is drawn, the shown title is added to that label directly.
public func WLvlTileTitle(label: inkTextRef, item: ItemID) -> Void {
  if !ItemID.IsValid(item) || !inkWidgetRef.IsValid(label) {
    return;
  }
  let text = inkTextRef.GetText(label);
  if Equals(text, "") {
    return;
  }
  let full = WLvlNameWithTitle(text, item);
  if NotEquals(full, text) {
    inkTextRef.SetText(label, full);
  }
}

@wrapMethod(InventoryWeaponDisplayController)
protected func NewRefreshUI(itemData: ref<UIInventoryItem>) -> Void {
  wrappedMethod(itemData);
  if IsDefined(itemData) {
    WLvlTileTitle(this.m_weaponType, itemData.GetID());
  }
}

@wrapMethod(InventoryWeaponDisplayController)
protected func RefreshUI() -> Void {
  wrappedMethod();
  WLvlTileTitle(this.m_weaponType, InventoryItemData.GetID(this.m_itemData));
}

