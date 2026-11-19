// Weaponpunk 2077 - Weapon Leveling Enhanced - core system: kill XP, levels per weapon model, damage bonus
// Copyright (C) 2026 the Weaponpunk 2077 authors. Written with AI assistance.
//
// This program is free software: you can redistribute it and/or modify it under the terms of the
// GNU General Public License as published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version. It is distributed WITHOUT ANY WARRANTY. See the
// GNU General Public License for details: https://www.gnu.org/licenses/
//
// How it works
//  - Every hit the player lands with a weapon is remembered for a few seconds (victim + weapon).
//  - A short repeating check looks at the remembered victims. One that has died gives XP to the
//    model of the weapon that hit it last. This also catches deaths from burn, bleed and falls.
//  - Shooting a vehicle or explosive device is remembered too: if it blows up, the weapon that shot
//    it is credited for everyone the blast kills, including each passenger of a destroyed vehicle.
//  - Levels are stored per weapon MODEL (all copies and tiers of a Lexington share one level).
//    A model is identified by its display name, so an iconic counts as its own model.
//  - The damage bonus is applied to the hit itself, so it only ever affects that weapon's hits.
//
// Console checks (Cyber Engine Tweaks):
//   Game.GetScriptableSystemsContainer():Get("WLvlSystem"):Report()
//   Game.GetScriptableSystemsContainer():Get("WLvlSystem"):CheatXP(5000)
//   Game.GetScriptableSystemsContainer():Get("WLvlSystem"):CheatJohnny()   (testing the Smasher shot)

public class WLvlPending {
  public let victim: wref<ScriptedPuppet>;
  public let victimID: EntityID;
  public let item: ItemID;
  public let time: Float;
  public let how: String;   // for the debug log: "hit", "blast" or "passenger"
  public let downed: Bool;  // a cyberpsycho seen knocked down but alive (Psychosquad Leader)
  public let unaware: Bool; // the victim had not noticed V when first hit (stealth feats)
  public let head: Bool;    // the latest hit was a headshot (Johnny's gun)
}

public class WLvlSweepCallback extends DelayCallback {
  public let sys: wref<WLvlSystem>;

  public func Call() -> Void {
    if IsDefined(this.sys) {
      this.sys.Sweep();
    }
  }
}

public class WLvlSystem extends ScriptableSystem {
  // ---- saved with the game save
  private persistent let m_models: array<TweakDBID>;   // first record seen for each model
  private persistent let m_levels: array<Int32>;
  private persistent let m_xp: array<Int32>;           // XP inside the current level
  private persistent let m_spentPerk: array<Int32>;    // perk points put into each model (for refunds)
  private persistent let m_spentAttr: array<Int32>;    // attribute points put into each model
  private persistent let m_boughtXP: array<Int32>;     // XP those points bought (taken back on refund)
  private persistent let m_boostStacks: Int32;         // relic XP boost: how many stacks are active
  private persistent let m_boostKills: Int32;          // relic XP boost: kills left
  private persistent let m_relicSpent: Int32;          // relic points spent on boosts so far
  // titles, per individual gun (see WLvlTitles.reds)
  private persistent let m_tItems: array<ItemID>;      // each gun that has started counting toward a title
  private persistent let m_tFaction: array<Int32>;     // kills per faction, 16 entries per gun
  private persistent let m_tVehicles: array<Int32>;    // vehicles destroyed (Carmageddon)
  private persistent let m_tPsychos: array<Int32>;     // cyberpsychos taken down alive (Psychosquad Leader)
  private persistent let m_tTrophies: array<Int32>;    // trophy titles earned, one bit per trophy
  private persistent let m_tShown: array<Int32>;       // title code shown in the gun's name, 0 for none
  private persistent let m_tKaren: array<Int32>;       // civilians killed who attacked V first (Karen Slayer)
  private persistent let m_tFeats: array<Int32>;       // feat titles earned, one bit per feat
  private persistent let m_tStealth: array<Int32>;     // stealth kills in total (Tactical Espionage)
  private persistent let m_tAraHeads: array<Int32>;    // Johnny's gun: headshot kills on Arasaka elites and bosses
  private persistent let m_tAraHeavy: array<Int32>;    // Johnny's gun: Arasaka heavies and mechs killed
  private persistent let m_tSecret: array<Int32>;      // Johnny's gun: bit 0 Board's Worst Nightmare, bit 1 Solo's Last Laugh

  // ---- rebuilt at runtime
  private let m_keys: array<CName>;                    // display-name key for each saved model
  private let m_pending: array<ref<WLvlPending>>;
  private let m_counted: array<EntityID>;              // recent victims already paid out
  private let m_objIDs: array<EntityID>;               // vehicles and devices the player shot recently...
  private let m_objItems: array<ItemID>;               // ...the weapon that shot each one...
  private let m_objTimes: array<Float>;                // ...and when
  private let m_sweepQueued: Bool;
  private let m_cardToken: Int32;                      // which card is on screen (see WLvlCard)
  private let m_menuIndex: Int32;                      // spend menu: which option is selected
  private let m_menuTime: Float;                       // spend menu: when a button was last pressed
  private let m_menuActive: Bool;
  private let m_menuArmed: Bool;                       // relic and refund need a second confirm
  private let m_hovered: ItemID;                       // weapon highlighted in the inventory, if any
  private let m_hasHovered: Bool;
  private let m_padDown: Bool;                         // controller spend button is held...
  private let m_padDownTime: Float;                    // ...since this engine time
  private let m_usingPad: Bool;                        // last spend-menu input came from the controller
  private let m_instanceID: Int32;
  private let m_icDone: array<ItemID>;
  private let m_namesSeen: array<ItemID>;                 // guns given the iconic stat this session                     // tells this copy apart from copies left over from earlier loads
  private let m_tooltipItem: ItemID;                   // items of the last two tooltips drawn (title swaps)
  private let m_tooltipPrev: ItemID;
  private let m_hitByMe: array<EntityID>;              // NPCs V has damaged (recent, capped)
  private let m_startedIt: array<EntityID>;            // NPCs that attacked V before V attacked them
  // feats, rebuilt at runtime
  private let m_rkItems: array<ItemID>;                // recent kills (last 5 seconds): weapon...
  private let m_rkTimes: array<Float>;                 // ...time...
  private let m_rkHit: array<Bool>;                    // ...and whether the weapon itself made it
  private let m_fgItems: array<ItemID>;                // per-gun fight trackers: weapon...
  private let m_fgLast: array<Float>;                  // ...last kill time (30 s gap ends a fight)...
  private let m_fgDoom: array<Int32>;                  // ...kills without reloading or holstering...
  private let m_fgMag: array<Int32>;                   // ...rounds in the magazine at the last hit...
  private let m_fgClean: array<Int32>;                 // ...kills without taking damage...
  private let m_fgGhost: array<Int32>;                 // ...kills in a row on unaware enemies
  private let m_fightKills: Int32;                     // Snake Eater: kills and healing items in the
  private let m_fightHeals: Int32;                     // current fight, any weapon
  private let m_fightLast: Float;
  private let m_berserkStacks: Int32;
  private let m_berserkUntil: Float;
  private let m_rightItem: ItemID;                     // gun in the right hand and since when
  private let m_rightSince: Float;
  private let m_smasherDone: array<EntityID>;          // Smashers whose one chance is already used
  private let m_lllStats: StatsObjectID;               // the Solo's Last Laugh: the gun its drawbacks sit on...
  private let m_lllMods: array<ref<gameStatModifierData>>; // ...and the drawbacks themselves
  private let m_lsItems: array<ItemID>;                // level handling bonuses: each drawn gun...
  private let m_lsStats: array<StatsObjectID>;         // ...its stats object...
  private let m_lsLevels: array<Int32>;                // ...the level they were built for...
  private let m_lsMods: array<ref<gameStatModifierData>>; // ...and the modifiers themselves...
  private let m_lsOwner: array<ItemID>;                // ...each tagged with its item
  private let m_menuListener: ref<CallbackHandle>;
  private let m_config: ref<WLvlConfig>;

  public static func Get(game: GameInstance) -> ref<WLvlSystem> {
    return GameInstance.GetScriptableSystemsContainer(game).Get(n"WLvlSystem") as WLvlSystem;
  }

  // Loading a save creates a fresh copy of this system, but listeners registered by earlier copies
  // keep firing. Only the live copy (the one the game hands out now) may act on them.
  private func IsLive() -> Bool {
    let live = WLvlSystem.Get(this.GetGameInstance());
    return IsDefined(live) && live.m_instanceID == this.m_instanceID;
  }

  public func Config() -> ref<WLvlConfig> {
    if !IsDefined(this.m_config) {
      this.m_config = new WLvlConfig();
      WLvlRegisterSettings(this.m_config);
    }
    return this.m_config;
  }

  public func NextCardToken() -> Int32 {
    this.m_cardToken += 1;
    return this.m_cardToken;
  }

  public func CardToken() -> Int32 {
    return this.m_cardToken;
  }

  public func DebugLog(text: String) -> Void {
    this.Log(text);
  }

  private func Log(text: String) -> Void {
    if this.Config().debugLog {
      ModLog(n"WeaponLeveling", text);
    }
  }

  // ================================================================ model identity
  public static func ModelKey(id: TweakDBID) -> CName {
    let rec = TweakDBInterface.GetItemRecord(id);
    if IsDefined(rec) {
      return rec.DisplayName();
    }
    return n"";
  }

  public static func ModelName(item: ItemID) -> String {
    let id = ItemID.GetTDBID(item);
    let rec = TweakDBInterface.GetItemRecord(id);
    if IsDefined(rec) {
      let text = GetLocalizedTextByKey(rec.DisplayName());
      if NotEquals(text, "") {
        return text;
      }
    }
    return TDBID.ToStringDEBUG(id);
  }

  // m_keys is not saved, so it is filled in again whenever it is shorter than the saved list
  private func BuildKeys() -> Void {
    if ArraySize(this.m_keys) > ArraySize(this.m_models) {
      ArrayClear(this.m_keys);
    }
    let i = ArraySize(this.m_keys);
    while i < ArraySize(this.m_models) {
      ArrayPush(this.m_keys, WLvlSystem.ModelKey(this.m_models[i]));
      i += 1;
    }
  }

  private func IndexOf(item: ItemID) -> Int32 {
    this.BuildKeys();
    let id = ItemID.GetTDBID(item);
    let key = WLvlSystem.ModelKey(id);
    let named = IsNameValid(key);
    let i = 0;
    while i < ArraySize(this.m_models) {
      if this.m_models[i] == id {
        return i;
      }
      if named && Equals(this.m_keys[i], key) {
        return i;
      }
      i += 1;
    }
    return -1;
  }

  private func IndexOrCreate(item: ItemID) -> Int32 {
    let i = this.IndexOf(item);
    if i >= 0 {
      return i;
    }
    let id = ItemID.GetTDBID(item);
    ArrayPush(this.m_models, id);
    ArrayPush(this.m_levels, 0);
    ArrayPush(this.m_xp, 0);
    ArrayPush(this.m_keys, WLvlSystem.ModelKey(id));
    return ArraySize(this.m_models) - 1;
  }

  // ================================================================ level curve
  // XP needed to go from `level` to `level + 1`.
  // The first five levels cost 2,000 / 3,000 / 4,000 / 5,000 / 6,000, so a new weapon rewards you
  // quickly. After that each level costs 15% more than the one before, with no cap.
  public static func CostOf(level: Int32) -> Int32 {
    if level < 5 {
      return 2000 + 1000 * level;
    }
    let cost = 6000.0 * PowF(1.15, Cast<Float>(level - 4));
    if cost > 2000000000.0 {
      return 2000000000;
    }
    return RoundF(cost);
  }

  public func LevelOf(item: ItemID) -> Int32 {
    let i = this.IndexOf(item);
    if i < 0 {
      return 0;
    }
    return this.m_levels[i];
  }

  public func XPOf(item: ItemID) -> Int32 {
    let i = this.IndexOf(item);
    if i < 0 {
      return 0;
    }
    return this.m_xp[i];
  }

  // Damage multiplier for a level. Grows forever, each level adding a little less than the last:
  // with the default strength of 5 it is about +3.5% at level 1, +9% at 5, +12% at 10, +17% at 30.
  public func DamageBonusPercent(level: Int32) -> Float {
    if level <= 0 {
      return 0.0;
    }
    return this.Config().damageCoef * LogF(1.0 + Cast<Float>(level));
  }

  public func DamageMultFor(item: ItemID) -> Float {
    if !this.Config().enabled {
      return 1.0;
    }
    return 1.0 + this.DamageBonusPercent(this.LevelOf(item)) / 100.0;
  }

  // Turns any XP beyond the current level's cost into levels. Needed when the curve changes
  // between versions and a saved weapon already holds more XP than its level now costs.
  public func Settle(item: ItemID) -> Void {
    let i = this.IndexOf(item);
    if i < 0 {
      return;
    }
    let cost = WLvlSystem.CostOf(this.m_levels[i]);
    while this.m_xp[i] >= cost {
      this.m_xp[i] -= cost;
      this.m_levels[i] += 1;
      cost = WLvlSystem.CostOf(this.m_levels[i]);
    }
  }

  // Adds XP to a weapon's model. Returns how many levels were gained.
  public func AddXP(item: ItemID, amount: Int32) -> Int32 {
    if amount <= 0 || !ItemID.IsValid(item) {
      return 0;
    }
    let i = this.IndexOrCreate(item);
    let gained = 0;
    let xp = this.m_xp[i] + amount;
    let level = this.m_levels[i];
    let cost = WLvlSystem.CostOf(level);
    while xp >= cost {
      xp -= cost;
      level += 1;
      gained += 1;
      cost = WLvlSystem.CostOf(level);
    }
    this.m_xp[i] = xp;
    this.m_levels[i] = level;
    if gained > 0 {
      this.RefreshLevelStats(item);
    }
    return gained;
  }

  // ================================================================ kill XP
  // Base XP by enemy rank.
  public static func RankXP(victim: ref<ScriptedPuppet>) -> Float {
    if victim.IsCharacterCyberpsycho() {
      return 500.0;
    }
    let rec = TweakDBInterface.GetCharacterRecord(victim.GetRecordID());
    if !IsDefined(rec) || !IsDefined(rec.Rarity()) {
      return 25.0;
    }
    let rarity = rec.Rarity().Type();
    if Equals(rarity, gamedataNPCRarity.Boss) {
      return 500.0;
    }
    // MaxTac respawn without end at high heat, so they are worth less than a true boss
    if Equals(rarity, gamedataNPCRarity.MaxTac) {
      return 250.0;
    }
    if Equals(rarity, gamedataNPCRarity.Elite) {
      return 100.0;
    }
    if Equals(rarity, gamedataNPCRarity.Officer) || Equals(rarity, gamedataNPCRarity.Rare) {
      return 50.0;
    }
    if Equals(rarity, gamedataNPCRarity.Trash) || Equals(rarity, gamedataNPCRarity.Weak) {
      return 15.0;
    }
    return 25.0;
  }

  // Multiplier by enemy type.
  public static func TypeMult(victim: ref<ScriptedPuppet>) -> Float {
    let npcType = victim.GetNPCType();
    if Equals(npcType, gamedataNPCType.Mech) || Equals(npcType, gamedataNPCType.Cerberus) || Equals(npcType, gamedataNPCType.Chimera) {
      return 3.0;
    }
    if Equals(npcType, gamedataNPCType.Drone) || Equals(npcType, gamedataNPCType.Spiderbot) || Equals(npcType, gamedataNPCType.Device) {
      return 0.5;
    }
    if Equals(npcType, gamedataNPCType.Android) {
      return 1.5;
    }
    let rec = TweakDBInterface.GetCharacterRecord(victim.GetRecordID());
    if !IsDefined(rec) || !IsDefined(rec.ArchetypeData()) || !IsDefined(rec.ArchetypeData().Type()) {
      return 1.0;
    }
    let arch = rec.ArchetypeData().Type().Type();
    if Equals(arch, gamedataArchetypeType.NetrunnerT1) || Equals(arch, gamedataArchetypeType.NetrunnerT2) || Equals(arch, gamedataArchetypeType.NetrunnerT3) {
      return 1.5;
    }
    if Equals(arch, gamedataArchetypeType.HeavyRangedT2) || Equals(arch, gamedataArchetypeType.HeavyRangedT3)
      || Equals(arch, gamedataArchetypeType.HeavyMeleeT2) || Equals(arch, gamedataArchetypeType.HeavyMeleeT3) {
      return 1.5;
    }
    if Equals(arch, gamedataArchetypeType.AndroidMeleeT1) || Equals(arch, gamedataArchetypeType.AndroidMeleeT2) || Equals(arch, gamedataArchetypeType.AndroidRangedT2) {
      return 1.5;
    }
    if Equals(arch, gamedataArchetypeType.SniperT2) || Equals(arch, gamedataArchetypeType.FastSniperT3)
      || Equals(arch, gamedataArchetypeType.ShotgunnerT2) || Equals(arch, gamedataArchetypeType.ShotgunnerT3)
      || Equals(arch, gamedataArchetypeType.FastShotgunnerT2) || Equals(arch, gamedataArchetypeType.FastShotgunnerT3) {
      return 1.25;
    }
    return 1.0;
  }

  public func KillXP(victim: ref<ScriptedPuppet>) -> Int32 {
    // Civilians give nothing, unless they attacked V first.
    if WLvlTitles.IsCivilian(victim) && !this.StartedIt(victim.GetEntityID()) {
      return 0;
    }
    let xp = WLvlSystem.RankXP(victim) * WLvlSystem.TypeMult(victim) * this.Config().xpMultiplier;
    return RoundF(xp);
  }

  // ================================================================ who started it
  private static func ListHas(list: array<EntityID>, id: EntityID) -> Bool {
    let i = 0;
    while i < ArraySize(list) {
      if list[i] == id {
        return true;
      }
      i += 1;
    }
    return false;
  }

  public func StartedIt(id: EntityID) -> Bool {
    return WLvlSystem.ListHas(this.m_startedIt, id);
  }

  private func MarkStartedIt(id: EntityID) -> Void {
    if WLvlSystem.ListHas(this.m_startedIt, id) {
      return;
    }
    ArrayPush(this.m_startedIt, id);
    if ArraySize(this.m_startedIt) > 256 {
      ArrayErase(this.m_startedIt, 0);
    }
  }

  // An NPC that hurts V before V hurt it started the fight, and so did its whole squad.
  // Quest characters are never marked.
  private func MarkAggressor(npc: ref<ScriptedPuppet>) -> Void {
    if !IsDefined(npc) || npc.IsQuest() || WLvlSystem.ListHas(this.m_hitByMe, npc.GetEntityID()) {
      return;
    }
    // police and MaxTac answer V's crimes, so they never count as starting it
    if npc.IsCharacterPolice() || npc.IsPrevention() || WLvlTitles.FactionOf(npc) == 13 {
      return;
    }
    if !this.StartedIt(npc.GetEntityID()) {
      this.Log("they started it: " + npc.GetDisplayName());
    }
    this.MarkStartedIt(npc.GetEntityID());
    let mates: array<EntityID>;
    AISquadHelper.GetSquadmatesID(npc, mates);
    let i = 0;
    while i < ArraySize(mates) {
      if !WLvlSystem.ListHas(this.m_hitByMe, mates[i]) {
        this.MarkStartedIt(mates[i]);
      }
      i += 1;
    }
  }

  // Called for every hit on V.
  public func OnPlayerDamaged(hitEvent: ref<gameHitEvent>) -> Void {
    if !this.Config().enabled || hitEvent.attackData.HasFlag(hitFlag.DealNoDamage) {
      return;
    }
    let attacker = hitEvent.attackData.GetInstigator() as ScriptedPuppet;
    if IsDefined(attacker) && !attacker.IsPlayer() {
      this.MarkAggressor(attacker);
    }
    // Untouchable: any damage ends the clean run, and the title's bonus cuts damage taken
    let i = 0;
    while i < ArraySize(this.m_fgClean) {
      this.m_fgClean[i] = 0;
      i += 1;
    }
    if this.FeatActive(5) {
      hitEvent.attackComputed.MultAttackValue(0.9);
    }
  }

  // Remembers that V hurt this NPC. The first time, a civilian who already has a weapon out and is
  // hostile counts as having started it (they drew on V).
  private func NoteHitByMe(target: wref<GameObject>) -> Void {
    let npc = target as ScriptedPuppet;
    if !IsDefined(npc) {
      return;
    }
    let id = npc.GetEntityID();
    if WLvlSystem.ListHas(this.m_hitByMe, id) {
      return;
    }
    if WLvlTitles.IsCivilian(npc) && IsDefined(ScriptedPuppet.GetActiveWeapon(npc)) && IsHostileTowardsPlayer(npc) {
      this.MarkAggressor(npc);
    }
    ArrayPush(this.m_hitByMe, id);
    if ArraySize(this.m_hitByMe) > 256 {
      ArrayErase(this.m_hitByMe, 0);
    }
  }

  // ---------------------------------------------------------------- which gun fired a hit
  // DUAL-WIELD FIX (0.6.2). Bug report on Nexus (Nov 2026): while dual wielding, kills made with the
  // LEFT-hand gun earned no XP.
  //
  // Background: every XP, title and feat decision starts from the weapon a hit is credited to. Up to
  // 0.6.1 that was only attackData.GetWeapon(). That works with one gun, but with two guns the game
  // appears to fill GetWeapon() with the right-hand (main) weapon, or leave it empty, for shots from
  // the left hand. A left-hand kill was then paid to the right-hand gun, or to nobody.
  //
  // The fix: attackData.GetSource() is the object the attack physically came from, which for a
  // gunshot is the gun itself. When the source is a weapon and it is not the one GetWeapon()
  // reports, the source wins. With a single gun the two always agree, so nothing changes there.
  //
  // NOT CONFIRMED IN GAME YET when this was written (we had no access to the 2.5 game scripts at
  // the time). With "Debug log" on, every dual-wield hit writes a "dual-wield hit" line to the
  // WeaponLeveling log showing what the game reported. If left-hand kills still earn nothing, that
  // line shows which case we are in:
  //   - source = the left gun          -> this fix works; look elsewhere.
  //   - source = right gun or "none"   -> the game gives no way to tell the hands apart from the
  //                                       hit, and the next step is to remember which hand last
  //                                       fired (a hook on the shooting code) and use that here.
  private func HitWeapon(hitEvent: ref<gameHitEvent>) -> wref<WeaponObject> {
    let reported = hitEvent.attackData.GetWeapon();
    let source = hitEvent.attackData.GetSource() as WeaponObject;
    let chosen = reported;
    if IsDefined(source) && (!IsDefined(reported) || source.GetItemID() != reported.GetItemID()) {
      chosen = source;
    }
    if this.Config().debugLog && this.DualWielding() {
      this.Log("dual-wield hit: reported " + this.WeaponLabel(reported) + ", source " + this.WeaponLabel(source)
        + ", credited " + this.WeaponLabel(chosen));
    }
    return chosen;
  }

  // True when there is a gun in the left-hand slot, which only happens while dual wielding.
  private func DualWielding() -> Bool {
    let player = GetPlayer(this.GetGameInstance());
    if !IsDefined(player) {
      return false;
    }
    let left = GameInstance.GetTransactionSystem(this.GetGameInstance()).GetItemInSlot(player, t"AttachmentSlots.WeaponLeft");
    return IsDefined(left);
  }

  // For the debug log only: "Model name (left)" / "(right)" / "(holstered)", or "none".
  private func WeaponLabel(w: wref<WeaponObject>) -> String {
    if !IsDefined(w) {
      return "none";
    }
    return WLvlSystem.ModelName(w.GetItemID()) + " (" + this.HandOf(w.GetItemID()) + ")";
  }

  // Called for every hit the player lands. Applies the level bonus and remembers the victim.
  public func OnPlayerHit(hitEvent: ref<gameHitEvent>) -> Void {
    if !this.Config().enabled {
      return;
    }
    let game = this.GetGameInstance();
    let now = EngineTime.ToFloat(GameInstance.GetSimTime(game));
    let victim = hitEvent.target as ScriptedPuppet;
    // Which gun fired this hit decides who gets the kill XP, the title progress and the feat
    // checks below. Don't read attackData.GetWeapon() directly here: see HitWeapon for why.
    let weapon = this.HitWeapon(hitEvent);
    if IsDefined(victim) && this.SmasherShot(hitEvent, victim, weapon) {
      return;
    }
    let featMult = this.FeatHitMult(hitEvent, victim, now);
    if featMult > 1.0 {
      hitEvent.attackComputed.MultAttackValue(featMult);
    }
    if IsDefined(weapon) {
      this.NoteMagazine(weapon, now);
    }
    if !IsDefined(weapon) {
      // No weapon on this hit: an explosion or similar. If it came from a vehicle or device that one
      // of the player's weapons shot a moment ago, that weapon gets the credit for anyone it kills.
      this.OnIndirectHit(game, hitEvent, victim, now);
      this.NoteHitByMe(hitEvent.target);
      return;
    }
    let item = weapon.GetItemID();
    if !ItemID.IsValid(item) {
      return;
    }
    // the level's damage bonus is a stat on the weapon itself (see LevelMods); titles and the
    // Malorian's reward are per target, so they stay here
    this.EnsureLevelStats(item);
    let mult = this.TitleDamageMult(item, hitEvent.target) * this.LastLaughMult(item, victim);
    if mult > 1.0 {
      hitEvent.attackComputed.MultAttackValue(mult);
    }
    if !IsDefined(victim) {
      // not a person: remember which weapon shot this vehicle or device
      if IsDefined(hitEvent.target) {
        this.RememberObject(hitEvent.target.GetEntityID(), item, now);
      }
      return;
    }
    this.NoteHitByMe(victim);
    this.AddPending(game, victim, item, now, "hit", WLvlSystem.IsHeadHit(hitEvent));
  }

  // ================================================================ Johnny's gun (SPOILERS)
  // Stage 1, The Board's Worst Nightmare: one Malorian reaches the top Arasaka tier, lands 100 killing
  //   headshots on Arasaka elites or bosses, and kills at least one Arasaka heavy or mech.
  //   Bonus: +50% damage against all Arasaka.
  // Stage 2, the shot: with that Malorian, the first hit V lands on Adam Smasher in a fight, if it is a
  //   headshot, drops him to 10-15% health. Not a kill, so his fight plays out. Any other opening
  //   (another weapon, a body shot, a grenade) uses up the chance until the save is reloaded.
  // Stage 3, The Solo's Last Laugh, awarded for landing the shot: that Malorian kills ordinary enemies
  //   in one hit (bosses, named and quest characters take triple damage instead). In exchange its
  //   magazine holds 3 rounds instead of 8, and it reloads and fires a third slower.
  public static func IsMalorian(item: ItemID) -> Bool {
    let id = ItemID.GetTDBID(item);
    if id == t"Items.Preset_Silverhand_3516" {
      return true;
    }
    let key = WLvlSystem.ModelKey(id);
    return IsNameValid(key) && Equals(key, WLvlSystem.ModelKey(t"Items.Preset_Silverhand_3516"));
  }

  public static func IsHeadHit(hitEvent: ref<gameHitEvent>) -> Bool {
    if hitEvent.attackData.HasFlag(hitFlag.Headshot) {
      return true;
    }
    // bosses can be immune to headshot damage, which hides the flag: check the body part hit
    let shapes = hitEvent.hitRepresentationResult.hitShapes;
    if ArraySize(shapes) > 0 {
      let data = DamageSystemHelper.GetHitShapeUserDataBase(shapes[0]);
      return IsDefined(data) && HitShapeUserDataBase.IsHitReactionZoneHead(data);
    }
    return false;
  }

  private func HasSecret(item: ItemID, b: Int32) -> Bool {
    let i = this.TitleIndex(item);
    return i >= 0 && WLvlSystem.HasBit(this.m_tSecret[i], b);
  }

  // Counts toward stage 1 on every Arasaka kill made with a Malorian.
  private func OnJohnnyKill(game: GameInstance, p: ref<WLvlPending>, i: Int32) -> Void {
    if !WLvlSystem.IsMalorian(p.item) || WLvlSystem.HasBit(this.m_tSecret[i], 0) {
      return;
    }
    let victim = p.victim;
    let rec = TweakDBInterface.GetCharacterRecord(victim.GetRecordID());
    let rarity = gamedataNPCRarity.Normal;
    if IsDefined(rec) && IsDefined(rec.Rarity()) {
      rarity = rec.Rarity().Type();
    }
    if p.head && (Equals(rarity, gamedataNPCRarity.Elite) || Equals(rarity, gamedataNPCRarity.Boss)) {
      this.m_tAraHeads[i] += 1;
    }
    let heavy = Equals(victim.GetNPCType(), gamedataNPCType.Mech);
    if !heavy && IsDefined(rec) && IsDefined(rec.ArchetypeData()) && IsDefined(rec.ArchetypeData().Type()) {
      let arch = rec.ArchetypeData().Type().Type();
      heavy = Equals(arch, gamedataArchetypeType.HeavyRangedT2) || Equals(arch, gamedataArchetypeType.HeavyRangedT3)
        || Equals(arch, gamedataArchetypeType.HeavyMeleeT2) || Equals(arch, gamedataArchetypeType.HeavyMeleeT3);
    }
    if heavy {
      this.m_tAraHeavy[i] += 1;
    }
    let kills = this.FactionKills(i, 0);
    this.Log("johnny: arasaka kills " + IntToString(kills) + " / 1500, elite headshots " + IntToString(this.m_tAraHeads[i])
      + " / 100, heavies " + IntToString(this.m_tAraHeavy[i]));
    if kills >= 1500 && this.m_tAraHeads[i] >= 100 && this.m_tAraHeavy[i] >= 1 {
      this.m_tSecret[i] = this.m_tSecret[i] + WLvlSystem.Bit(0);
      this.Award(game, p.item, i, WLvlTitles.SecretCode(0), WLvlTitles.SecretNote(0));
    }
  }

  // Stage 2. Returns true when the shot happened (the hit itself then does nothing more).
  private func SmasherShot(hitEvent: ref<gameHitEvent>, victim: ref<ScriptedPuppet>, weapon: ref<WeaponObject>) -> Bool {
    if WLvlTitles.TrophyOf(victim) != 0 || !ScriptedPuppet.IsAlive(victim) {
      return false;
    }
    let id = victim.GetEntityID();
    if WLvlSystem.ListHas(this.m_smasherDone, id) {
      return false;
    }
    ArrayPush(this.m_smasherDone, id);   // one chance per fight, whatever happens next
    if !IsDefined(weapon) {
      this.Log("johnny: Smasher opened on without a weapon, chance gone");
      return false;
    }
    let item = weapon.GetItemID();
    if !WLvlSystem.IsMalorian(item) || !this.HasSecret(item, 0) || !WLvlSystem.IsHeadHit(hitEvent) {
      this.Log("johnny: Smasher's first hit was not the shot, chance gone");
      return false;
    }
    let game = this.GetGameInstance();
    let player = GetPlayer(game);
    let pools = GameInstance.GetStatPoolsSystem(game);
    let sid = Cast<StatsObjectID>(id);
    let before = pools.GetStatPoolValue(sid, gamedataStatPoolType.Health, true);
    let target = RandRangeF(10.0, 15.0);
    if before > target {
      pools.RequestChangingStatPoolValue(sid, gamedataStatPoolType.Health, target - before, player, false, true);
    }
    hitEvent.attackComputed.MultAttackValue(0.01);
    this.Log("johnny: THE SHOT. Smasher health " + FloatToStringPrec(before, 1) + "% -> " + FloatToStringPrec(pools.GetStatPoolValue(sid, gamedataStatPoolType.Health, true), 1) + "%");
    let i = this.TitleIndexOrCreate(item);
    if !WLvlSystem.HasBit(this.m_tSecret[i], 1) {
      this.m_tSecret[i] = this.m_tSecret[i] + WLvlSystem.Bit(1);
      this.Award(game, item, i, WLvlTitles.SecretCode(1), WLvlTitles.SecretNote(1));
      this.ApplyLastLaugh(weapon);
    }
    return true;
  }

  // Stage 3 damage: one-hit kills on ordinary enemies, triple damage on bosses and named characters.
  private func LastLaughMult(item: ItemID, victim: ref<ScriptedPuppet>) -> Float {
    if !IsDefined(victim) || !this.HasSecret(item, 1) {
      return 1.0;
    }
    if victim.IsBoss() || victim.IsQuest() || WLvlTitles.TrophyOf(victim) >= 0 {
      return 3.0;
    }
    return 1000.0;
  }

  // Stage 3 drawbacks, put on the gun whenever it is drawn (they are not saved with the item).
  public func ApplyLastLaugh(weapon: ref<WeaponObject>) -> Void {
    if !IsDefined(weapon) || !this.HasSecret(weapon.GetItemID(), 1) {
      return;
    }
    let data = weapon.GetItemData();
    if !IsDefined(data) {
      return;
    }
    let stats = GameInstance.GetStatsSystem(this.GetGameInstance());
    let sid = data.GetStatsObjectID();
    let k = 0;
    while k < ArraySize(this.m_lllMods) {
      stats.RemoveModifier(this.m_lllStats, this.m_lllMods[k]);
      k += 1;
    }
    ArrayClear(this.m_lllMods);
    this.m_lllStats = sid;
    ArrayPush(this.m_lllMods, RPGManager.CreateStatModifier(gamedataStatType.MagazineCapacity, gameStatModifierType.Multiplier, 0.375));
    ArrayPush(this.m_lllMods, RPGManager.CreateStatModifier(gamedataStatType.ReloadTime, gameStatModifierType.Multiplier, 1.33));
    ArrayPush(this.m_lllMods, RPGManager.CreateStatModifier(gamedataStatType.CycleTime, gameStatModifierType.Multiplier, 1.33));
    k = 0;
    while k < ArraySize(this.m_lllMods) {
      stats.AddModifier(sid, this.m_lllMods[k]);
      k += 1;
    }
    this.Log("johnny: The Solo's Last Laugh drawbacks applied");
  }

  private func OnIndirectHit(game: GameInstance, hitEvent: ref<gameHitEvent>, victim: ref<ScriptedPuppet>, now: Float) -> Void {
    if !IsDefined(victim) {
      return;
    }
    let source = hitEvent.attackData.GetSource();
    if !IsDefined(source) {
      return;
    }
    let slot = this.ObjectSlot(source.GetEntityID(), now);
    if slot < 0 {
      return;
    }
    this.AddPending(game, victim, this.m_objItems[slot], now, "blast");
  }

  // Remembers that `item` shot a vehicle or device. Kept short: the oldest entry is dropped.
  private func RememberObject(id: EntityID, item: ItemID, now: Float) -> Void {
    let i = 0;
    while i < ArraySize(this.m_objIDs) {
      if this.m_objIDs[i] == id {
        this.m_objItems[i] = item;
        this.m_objTimes[i] = now;
        return;
      }
      i += 1;
    }
    ArrayPush(this.m_objIDs, id);
    ArrayPush(this.m_objItems, item);
    ArrayPush(this.m_objTimes, now);
    if ArraySize(this.m_objIDs) > 32 {
      ArrayErase(this.m_objIDs, 0);
      ArrayErase(this.m_objItems, 0);
      ArrayErase(this.m_objTimes, 0);
    }
  }

  // Index of the remembered vehicle or device, or -1 if it was not shot in the last 60 seconds.
  private func ObjectSlot(id: EntityID, now: Float) -> Int32 {
    let i = 0;
    while i < ArraySize(this.m_objIDs) {
      if this.m_objIDs[i] == id && now - this.m_objTimes[i] < 60.0 {
        return i;
      }
      i += 1;
    }
    return -1;
  }

  // A vehicle the player destroyed is about to kill everyone inside it. Those deaths are not hits,
  // so each passenger is remembered here and paid out by the usual check a moment later.
  public func OnVehiclePassengersKilled(vehicle: wref<VehicleObject>) -> Void {
    if !this.Config().enabled || !IsDefined(vehicle) {
      return;
    }
    let game = this.GetGameInstance();
    let now = EngineTime.ToFloat(GameInstance.GetSimTime(game));
    let slot = this.ObjectSlot(vehicle.GetEntityID(), now);
    if slot < 0 {
      return;
    }
    let item = this.m_objItems[slot];
    this.OnVehicleDestroyed(game, item);
    let passengers: array<wref<GameObject>>;
    VehicleComponent.GetAllPassengers(game, vehicle.GetEntityID(), false, passengers);
    let i = 0;
    while i < ArraySize(passengers) {
      let passenger = passengers[i] as ScriptedPuppet;
      if IsDefined(passenger) && !passenger.IsPlayer() {
        this.AddPending(game, passenger, item, now, "passenger");
      }
      i += 1;
    }
  }

  // One entry per victim: a new hit replaces the older one, so the last weapon to hit gets the kill.
  private func AddPending(game: GameInstance, victim: ref<ScriptedPuppet>, item: ItemID, now: Float, how: String, opt head: Bool) -> Void {
    if !ScriptedPuppet.IsAlive(victim) {
      return;
    }
    let id = victim.GetEntityID();
    let i = 0;
    let found = false;
    while i < ArraySize(this.m_pending) {
      if this.m_pending[i].victimID == id {
        this.m_pending[i].item = item;
        this.m_pending[i].time = now;
        this.m_pending[i].how = how;
        this.m_pending[i].head = head;
        found = true;
      }
      i += 1;
    }
    if !found {
      let p = new WLvlPending();
      p.victim = victim;
      p.victimID = id;
      p.item = item;
      p.time = now;
      p.how = how;
      p.unaware = WLvlSystem.IsUnaware(victim);
      p.head = head;
      ArrayPush(this.m_pending, p);
    }
    this.QueueSweep(game);
  }

  private func QueueSweep(game: GameInstance) -> Void {
    if this.m_sweepQueued {
      return;
    }
    let cb = new WLvlSweepCallback();
    cb.sys = this;
    GameInstance.GetDelaySystem(game).DelayCallback(cb, 0.25, false);
    this.m_sweepQueued = true;
  }

  private func AlreadyCounted(id: EntityID) -> Bool {
    let i = 0;
    while i < ArraySize(this.m_counted) {
      if this.m_counted[i] == id {
        return true;
      }
      i += 1;
    }
    return false;
  }

  // Looks at every remembered victim: pays out the dead ones, forgets the ones hit too long ago.
  public func Sweep() -> Void {
    this.m_sweepQueued = false;
    let game = this.GetGameInstance();
    let now = EngineTime.ToFloat(GameInstance.GetSimTime(game));
    let keep: array<ref<WLvlPending>>;
    let i = 0;
    while i < ArraySize(this.m_pending) {
      let p = this.m_pending[i];
      // a victim whose body is already gone is dropped: there is nothing left to look at
      if IsDefined(p.victim) {
        if !ScriptedPuppet.IsAlive(p.victim) {
          this.OnKill(game, p);
        } else {
          if WLvlSystem.IsTruePsycho(p.victim) && (ScriptedPuppet.IsDefeated(p.victim) || ScriptedPuppet.IsUnconscious(p.victim)) {
            p.downed = true;
          }
          if now - p.time < 6.0 {
            ArrayPush(keep, p);
          } else {
            if p.downed {
              // still alive six seconds after the last hit: taken down, not killed
              this.OnPsychoDown(game, p);
            }
          }
        }
      }
      i += 1;
    }
    this.m_pending = keep;
    if ArraySize(this.m_pending) > 0 {
      this.QueueSweep(game);
    }
  }

  private func OnKill(game: GameInstance, p: ref<WLvlPending>) -> Void {
    if this.AlreadyCounted(p.victimID) {
      return;
    }
    ArrayPush(this.m_counted, p.victimID);
    if ArraySize(this.m_counted) > 64 {
      ArrayErase(this.m_counted, 0);
    }
    let xp = this.KillXP(p.victim);
    if xp <= 0 {
      this.Log("kill gave no XP (civilian or crowd) [" + p.how + "]");
      this.OnTitleKill(game, p);
      return;
    }
    xp = this.XPExtras(p, xp);
    xp = this.UseBoost(xp);
    if p.unaware && this.FeatActive(7) {
      xp = RoundF(Cast<Float>(xp) * 1.5);   // Tactical Espionage
    }
    let gained = this.AddXP(p.item, xp);
    this.Log(WLvlSystem.ModelName(p.item) + ": +" + IntToString(xp) + " XP, level " + IntToString(this.LevelOf(p.item))
      + ", " + IntToString(this.XPOf(p.item)) + " / " + IntToString(WLvlSystem.CostOf(this.LevelOf(p.item))) + " [" + p.how + "]");
    if gained > 0 {
      WLvlCard.Show(game, this, p.item, WLvlT("WLvl-Card-LevelUp"));
      this.Notify(WLvlF2("WLvl-Msg-ReachedLevel", WLvlSystem.ModelName(p.item), IntToString(this.LevelOf(p.item))));
    }
    this.OnTitleKill(game, p);
    this.OnFeatKill(game, p);
  }

  // ================================================================ XP extras
  // Headshot and stealth kills are worth more; enemies far below V's level are worth less.
  private func XPExtras(p: ref<WLvlPending>, xp: Int32) -> Int32 {
    let cfg = this.Config();
    let mult = 1.0;
    if p.head {
      mult += Cast<Float>(cfg.headshotBonus) / 100.0;
    }
    if p.unaware {
      mult += Cast<Float>(cfg.stealthBonus) / 100.0;
    }
    if cfg.lowLevelReduction && IsDefined(p.victim) {
      let game = this.GetGameInstance();
      let player = GetPlayer(game);
      if IsDefined(player) {
        let stats = GameInstance.GetStatsSystem(game);
        // the comparison stops at level 60, the game's own cap, so extended-level saves are not punished
        let mine = MinF(60.0, stats.GetStatValue(Cast<StatsObjectID>(player.GetEntityID()), gamedataStatType.Level));
        let theirs = stats.GetStatValue(Cast<StatsObjectID>(p.victim.GetEntityID()), gamedataStatType.PowerLevel);
        if theirs > 0.0 && mine - theirs >= Cast<Float>(cfg.lowLevelGap) {
          mult *= 0.5;
          this.Log("low-level enemy (level " + FloatToStringPrec(theirs, 0) + "): half XP");
        }
      }
    }
    return Max(1, RoundF(Cast<Float>(xp) * mult));
  }

  // The game's own on-screen message (used for weapon level-ups).
  public func Notify(text: String) -> Void {
    let game = this.GetGameInstance();
    let msg: SimpleScreenMessage;
    msg.isShown = true;
    msg.duration = 3.0;
    msg.message = text;
    let bb = GameInstance.GetBlackboardSystem(game).Get(GetAllBlackboardDefs().UI_Notifications);
    if IsDefined(bb) {
      bb.SetVariant(GetAllBlackboardDefs().UI_Notifications.OnscreenMessage, ToVariant(msg), true);
    }
  }

  // ================================================================ level bonuses as real weapon stats
  // Each weapon's level bonuses are stat modifiers on the item itself, so they show in the inventory
  // numbers (damage, DPS, reload, recoil) and act in combat:
  //   damage   +strength x ln(1 + level) percent, no cap
  //   handling up to a ceiling at level 20: 10% faster fire, 15% faster reload, 20% less recoil
  // Modifiers are not saved with the item, so they are put back whenever a menu opens, a weapon is
  // drawn or hovered, and after a level-up. Each item keeps one set; a refresh replaces it.
  private func LevelMods(level: Int32) -> array<ref<gameStatModifierData>> {
    let mods: array<ref<gameStatModifierData>>;
    let cfg = this.Config();
    if !cfg.enabled || level <= 0 {
      return mods;
    }
    let dmg = 1.0 + this.DamageBonusPercent(level) / 100.0;
    if dmg > 1.0 {
      ArrayPush(mods, RPGManager.CreateStatModifier(gamedataStatType.DamagePerHit, gameStatModifierType.Multiplier, dmg));
    }
    if cfg.levelHandling {
      let f = MinF(1.0, Cast<Float>(level) / 20.0);
      ArrayPush(mods, RPGManager.CreateStatModifier(gamedataStatType.CycleTime, gameStatModifierType.Multiplier, 1.0 - 0.10 * f));
      ArrayPush(mods, RPGManager.CreateStatModifier(gamedataStatType.ReloadTime, gameStatModifierType.Multiplier, 1.0 - 0.15 * f));
      ArrayPush(mods, RPGManager.CreateStatModifier(gamedataStatType.RecoilKickMax, gameStatModifierType.Multiplier, 1.0 - 0.20 * f));
      ArrayPush(mods, RPGManager.CreateStatModifier(gamedataStatType.RecoilKickMin, gameStatModifierType.Multiplier, 1.0 - 0.20 * f));
    }
    return mods;
  }

  // A gun with a title becomes iconic. When it earns the title the stat is saved with the gun;
  // refreshes only add a temporary copy (for guns titled before this was added).
  public func ApplyIconicData(data: wref<gameItemData>, keep: Bool) -> Void {
    if !IsDefined(data) || !this.Config().enabled || !RPGManager.IsItemWeapon(data.GetID()) || !this.HasTitles(data.GetID()) {
      return;
    }
    // did this mod already add the stat to this gun this session?
    let mine = false;
    let n = 0;
    while n < ArraySize(this.m_icDone) {
      if WLvlSystem.SameGun(this.m_icDone[n], data.GetID()) {
        mine = true;
      }
      n += 1;
    }
    let iconic = data.GetStatValueByType(gamedataStatType.IsItemIconic) > 0.0;
    if iconic && !mine {
      return;   // iconic already (by the game or another mod): leave it alone
    }
    let stats = GameInstance.GetStatsSystem(this.GetGameInstance());
    let sid = data.GetStatsObjectID();
    let mod = RPGManager.CreateStatModifier(gamedataStatType.IsItemIconic, gameStatModifierType.Additive, 1.0);
    if keep {
      // saved with the item, the way Upgrade Weapons Unlocked makes weapons iconic at Tier 5++
      stats.AddSavedModifier(sid, mod);
    } else {
      if mine {
        return;
      }
      stats.AddModifier(sid, mod);
    }
    if !mine {
      ArrayPush(this.m_icDone, data.GetID());
    }
    this.Log("now iconic" + (keep ? " (saved)" : "") + ": " + WLvlSystem.IdText(data.GetID()) + " shows " + this.ShownTitleName(data.GetID()));
  }

  // Called when a gun earns its first title: the iconic stat is saved with that gun for good.
  public func EnsureIconic(item: ItemID) -> Void {
    let game = this.GetGameInstance();
    let player = GetPlayer(game);
    if IsDefined(player) {
      this.ApplyIconicData(GameInstance.GetTransactionSystem(game).GetItemData(player, item), true);
    }
  }

  public func ApplyLevelStatsData(data: wref<gameItemData>) -> Void {
    if !IsDefined(data) {
      return;
    }
    this.ApplyIconicData(data, false);
    let item = data.GetID();
    if !this.IsLevelable(item) {
      return;
    }
    let level = this.LevelOf(item);
    let stats = GameInstance.GetStatsSystem(this.GetGameInstance());
    let i = 0;
    while i < ArraySize(this.m_lsItems) {
      if this.m_lsItems[i] == item {
        if this.m_lsLevels[i] == level {
          return;   // already current
        }
        this.RemoveLevelStats(i);
        i = ArraySize(this.m_lsItems);
      }
      i += 1;
    }
    let mods = this.LevelMods(level);
    if ArraySize(mods) == 0 {
      return;
    }
    let sid = data.GetStatsObjectID();
    let m = 0;
    while m < ArraySize(mods) {
      stats.AddModifier(sid, mods[m]);
      ArrayPush(this.m_lsMods, mods[m]);
      ArrayPush(this.m_lsOwner, item);
      m += 1;
    }
    ArrayPush(this.m_lsItems, item);
    ArrayPush(this.m_lsStats, sid);
    ArrayPush(this.m_lsLevels, level);
  }

  private func RemoveLevelStats(i: Int32) -> Void {
    let item = this.m_lsItems[i];
    let sid = this.m_lsStats[i];
    let stats = GameInstance.GetStatsSystem(this.GetGameInstance());
    let m = ArraySize(this.m_lsMods) - 1;
    while m >= 0 {
      if this.m_lsOwner[m] == item {
        stats.RemoveModifier(sid, this.m_lsMods[m]);
        ArrayErase(this.m_lsMods, m);
        ArrayErase(this.m_lsOwner, m);
      }
      m -= 1;
    }
    ArrayErase(this.m_lsItems, i);
    ArrayErase(this.m_lsStats, i);
    ArrayErase(this.m_lsLevels, i);
  }

  public func ApplyLevelStats(weapon: ref<WeaponObject>) -> Void {
    if IsDefined(weapon) {
      this.ApplyLevelStatsData(weapon.GetItemData());
    }
  }

  public func EnsureLevelStats(item: ItemID) -> Void {
    let game = this.GetGameInstance();
    let player = GetPlayer(game);
    if IsDefined(player) && this.IsLevelable(item) {
      this.ApplyLevelStatsData(GameInstance.GetTransactionSystem(game).GetItemData(player, item));
    }
  }

  // Every levelable item V carries, refreshed when a menu opens.
  public func RefreshAllLevelStats() -> Void {
    let game = this.GetGameInstance();
    let player = GetPlayer(game);
    if !IsDefined(player) || !this.Config().enabled {
      return;
    }
    let list: array<wref<gameItemData>>;
    GameInstance.GetTransactionSystem(game).GetItemList(player, list);
    let i = 0;
    while i < ArraySize(list) {
      if IsDefined(list[i]) && (this.IsLevelable(list[i].GetID()) || this.HasTitles(list[i].GetID())) {
        this.ApplyLevelStatsData(list[i]);
      }
      i += 1;
    }
  }

  public static func IdText(item: ItemID) -> String {
    return WLvlSystem.ModelName(item) + " [" + TDBID.ToStringDEBUG(ItemID.GetTDBID(item)) + " seed " + ToString(ItemID.GetRngSeed(item)) + "]";
  }

  // Diagnostic: what the mod has stored, written to the log each time a menu opens.
  public func DumpTitles() -> Void {
    this.PadTitles();
    this.Log("DUMP: " + IntToString(ArraySize(this.m_tItems)) + " guns stored, faction list " + IntToString(ArraySize(this.m_tFaction)) + ", instance " + IntToString(this.m_instanceID));
    let i = 0;
    while i < ArraySize(this.m_tItems) {
      let earned = this.EarnedTitles(this.m_tItems[i]);
      let names = "";
      let j = 0;
      while j < ArraySize(earned) {
        names = names + WLvlTitles.Name(earned[j]) + "; ";
        j += 1;
      }
      this.Log("DUMP " + IntToString(i) + ": " + WLvlSystem.IdText(this.m_tItems[i]) + " -> " + names);
      i += 1;
    }
  }

  // Diagnostic: one line per weapon the first time its inventory name is asked for.
  public func NoteNameAsked(item: ItemID, name: String, result: String) -> Void {
    let n = 0;
    while n < ArraySize(this.m_namesSeen) {
      if this.m_namesSeen[n] == item {
        return;
      }
      n += 1;
    }
    ArrayPush(this.m_namesSeen, item);
    this.Log("NAME asked: " + WLvlSystem.IdText(item) + " '" + name + "' -> '" + result + "'");
  }

  protected cb func OnMenuChanged(inMenu: Bool) -> Bool {
    if inMenu && this.IsLive() {
      this.DumpTitles();
      this.RefreshAllLevelStats();
    }
    return true;
  }

  // After a level-up, refresh that item's bonuses.
  private func RefreshLevelStats(item: ItemID) -> Void {
    this.EnsureLevelStats(item);
  }

  // ================================================================ feats
  public static func IsUnaware(victim: ref<ScriptedPuppet>) -> Bool {
    return IsDefined(victim) && Equals(victim.GetHighLevelStateFromBlackboard(), gamedataNPCHighLevelState.Relaxed);
  }

  private func Now() -> Float {
    return EngineTime.ToFloat(GameInstance.GetSimTime(this.GetGameInstance()));
  }

  // Guns whose feat bonuses count right now: every gun in a weapon slot, drawn or not. While dual
  // wielding, the left-hand gun is left out, and a gun just moved into the right hand waits 3 s.
  private func FeatGuns() -> array<ItemID> {
    let out: array<ItemID>;
    let game = this.GetGameInstance();
    let player = GetPlayer(game);
    if !IsDefined(player) {
      return out;
    }
    let data = EquipmentSystem.GetData(player);
    if !IsDefined(data) {
      return out;
    }
    let ts = GameInstance.GetTransactionSystem(game);
    let none: ItemID;
    let left = none;
    let leftObj = ts.GetItemInSlot(player, t"AttachmentSlots.WeaponLeft");
    if IsDefined(leftObj) {
      left = leftObj.GetItemID();
    }
    let right = none;
    let rightObj = ts.GetItemInSlot(player, t"AttachmentSlots.WeaponRight");
    if IsDefined(rightObj) {
      right = rightObj.GetItemID();
    }
    let now = this.Now();
    if right != this.m_rightItem {
      this.m_rightItem = right;
      this.m_rightSince = now;
    }
    let dual = ItemID.IsValid(left);
    let n = data.GetNumberOfSlots(gamedataEquipmentArea.Weapon);
    let slot = 0;
    while slot < n {
      let id = data.GetItemInEquipSlot(gamedataEquipmentArea.Weapon, slot);
      let skip = !ItemID.IsValid(id);
      if !skip && dual {
        if id == left {
          skip = true;
        }
        if id == right && now - this.m_rightSince < 3.0 {
          skip = true;
        }
      }
      if !skip {
        ArrayPush(out, id);
      }
      slot += 1;
    }
    return out;
  }

  public func FeatActive(k: Int32) -> Bool {
    if !this.Config().enabled {
      return false;
    }
    let guns = this.FeatGuns();
    let g = 0;
    while g < ArraySize(guns) {
      let ti = this.TitleIndex(guns[g]);
      if ti >= 0 && WLvlSystem.HasBit(this.m_tFeats[ti], k) {
        return true;
      }
      g += 1;
    }
    return false;
  }

  // Berserker stacks allowed by the best streak title on an active gun (0 = no Berserker).
  private func BerserkMax() -> Int32 {
    if this.FeatActive(2) {
      return 5;
    }
    if this.FeatActive(1) {
      return 4;
    }
    if this.FeatActive(0) {
      return 3;
    }
    return 0;
  }

  // The buff bar icon (samurai mask) with the current stack count. Each kill rebuilds it, which also
  // restarts its 10 second timer. Needs TweakXL (WeaponLeveling.yaml); without it nothing shows.
  private func ShowBerserkIcon() -> Void {
    let id = t"WLvl.Berserker";
    if !IsDefined(TweakDBInterface.GetStatusEffectRecord(id)) {
      return;
    }
    let player = GetPlayer(this.GetGameInstance());
    if !IsDefined(player) {
      return;
    }
    StatusEffectHelper.RemoveStatusEffect(player, id, Cast<Uint32>(10));
    let k = 0;
    while k < this.m_berserkStacks {
      StatusEffectHelper.ApplyStatusEffect(player, id, player.GetEntityID());
      k += 1;
    }
  }

  // Extra damage on V's hit from active feats: Berserker, Smart Bomb, Ghost Protocol.
  private func FeatHitMult(hitEvent: ref<gameHitEvent>, victim: ref<ScriptedPuppet>, now: Float) -> Float {
    let mult = 1.0;
    if this.m_berserkStacks > 0 && now < this.m_berserkUntil {
      mult *= 1.0 + 0.05 * Cast<Float>(this.m_berserkStacks);
    }
    if Equals(hitEvent.attackData.GetAttackType(), gamedataAttackType.Explosion) && this.FeatActive(4) {
      mult *= 1.25;
    }
    if IsDefined(victim) && WLvlSystem.IsUnaware(victim) && this.FeatActive(6) {
      mult *= 1.25;
    }
    return mult;
  }

  private func FightSlot(item: ItemID, now: Float) -> Int32 {
    let i = 0;
    while i < ArraySize(this.m_fgItems) {
      if this.m_fgItems[i] == item {
        if now - this.m_fgLast[i] > 30.0 {
          this.m_fgDoom[i] = 0;
          this.m_fgClean[i] = 0;
          this.m_fgGhost[i] = 0;
        }
        this.m_fgLast[i] = now;
        return i;
      }
      i += 1;
    }
    ArrayPush(this.m_fgItems, item);
    ArrayPush(this.m_fgLast, now);
    ArrayPush(this.m_fgDoom, 0);
    ArrayPush(this.m_fgMag, -1);
    ArrayPush(this.m_fgClean, 0);
    ArrayPush(this.m_fgGhost, 0);
    if ArraySize(this.m_fgItems) > 8 {
      ArrayErase(this.m_fgItems, 0);
      ArrayErase(this.m_fgLast, 0);
      ArrayErase(this.m_fgDoom, 0);
      ArrayErase(this.m_fgMag, 0);
      ArrayErase(this.m_fgClean, 0);
      ArrayErase(this.m_fgGhost, 0);
    }
    return ArraySize(this.m_fgItems) - 1;
  }

  // A magazine that holds more rounds than at the last hit was reloaded: Doom Slayer starts over.
  private func NoteMagazine(weapon: ref<WeaponObject>, now: Float) -> Void {
    let item = weapon.GetItemID();
    let i = 0;
    while i < ArraySize(this.m_fgItems) {
      if this.m_fgItems[i] == item {
        let mag = Cast<Int32>(WeaponObject.GetMagazineAmmoCount(weapon));
        if this.m_fgMag[i] >= 0 && mag > this.m_fgMag[i] {
          this.m_fgDoom[i] = 0;
        }
        this.m_fgMag[i] = mag;
        return;
      }
      i += 1;
    }
  }

  // For the debug log: which hand a gun is in.
  private func HandOf(item: ItemID) -> String {
    let game = this.GetGameInstance();
    let player = GetPlayer(game);
    if !IsDefined(player) {
      return "?";
    }
    let ts = GameInstance.GetTransactionSystem(game);
    let r = ts.GetItemInSlot(player, t"AttachmentSlots.WeaponRight");
    if IsDefined(r) && r.GetItemID() == item {
      return "right";
    }
    let l = ts.GetItemInSlot(player, t"AttachmentSlots.WeaponLeft");
    if IsDefined(l) && l.GetItemID() == item {
      return "left";
    }
    return "holstered";
  }

  // A reload started: Doom Slayer starts over for that gun.
  public func OnReload(item: ItemID) -> Void {
    let i = 0;
    while i < ArraySize(this.m_fgItems) {
      if this.m_fgItems[i] == item {
        if this.m_fgDoom[i] > 0 {
          this.Log("reload: Doom Slayer count reset (was " + IntToString(this.m_fgDoom[i]) + ")");
        }
        this.m_fgDoom[i] = 0;
        this.m_fgMag[i] = -1;
        return;
      }
      i += 1;
    }
  }

  // Drawing or swapping a weapon counts as holstering for Doom Slayer.
  public func OnWeaponSwap() -> Void {
    let i = 0;
    while i < ArraySize(this.m_fgDoom) {
      this.m_fgDoom[i] = 0;
      this.m_fgMag[i] = -1;
      i += 1;
    }
  }

  private func HealPercent(pct: Float) -> Void {
    let player = GetPlayer(this.GetGameInstance());
    if !IsDefined(player) {
      return;
    }
    GameInstance.GetStatPoolsSystem(this.GetGameInstance()).RequestChangingStatPoolValue(Cast<StatsObjectID>(player.GetEntityID()), gamedataStatPoolType.Health, pct, player, false, true);
  }

  // A healing item was used: counts for Snake Eater, and Snake Eater's bonus heals a little more.
  public func OnHealUsed() -> Void {
    if !this.Config().enabled {
      return;
    }
    let now = this.Now();
    if now - this.m_fightLast > 30.0 {
      this.m_fightKills = 0;
      this.m_fightHeals = 0;
    }
    this.m_fightHeals += 1;
    this.m_fightLast = now;
    if this.FeatActive(8) {
      this.HealPercent(5.0);
    }
  }

  private func EarnFeat(game: GameInstance, item: ItemID, k: Int32) -> Void {
    let i = this.TitleIndexOrCreate(item);
    if WLvlSystem.HasBit(this.m_tFeats[i], k) {
      return;
    }
    // a lower streak title is not awarded to a gun that already has a higher one
    if k <= 1 && (WLvlSystem.HasBit(this.m_tFeats[i], 2) || (k == 0 && WLvlSystem.HasBit(this.m_tFeats[i], 1))) {
      return;
    }
    this.m_tFeats[i] = this.m_tFeats[i] + WLvlSystem.Bit(k);
    this.Award(game, item, i, WLvlTitles.FeatCode(k), WLvlTitles.FeatNote(k));
  }

  // Called for every enemy kill (not civilians, unless they started it).
  private func OnFeatKill(game: GameInstance, p: ref<WLvlPending>) -> Void {
    if !ItemID.IsValid(p.item) {
      return;
    }
    let now = this.Now();
    let byWeapon = Equals(p.how, "hit");

    // recent kills, kept for 5 seconds
    ArrayPush(this.m_rkItems, p.item);
    ArrayPush(this.m_rkTimes, now);
    ArrayPush(this.m_rkHit, byWeapon);
    while ArraySize(this.m_rkTimes) > 0 && now - this.m_rkTimes[0] > 5.0 {
      ArrayErase(this.m_rkItems, 0);
      ArrayErase(this.m_rkTimes, 0);
      ArrayErase(this.m_rkHit, 0);
    }
    let anyGun = ArraySize(this.m_rkTimes);
    let sameGunHits = 0;
    let sameMoment = 0;
    let r = 0;
    while r < ArraySize(this.m_rkItems) {
      if this.m_rkItems[r] == p.item {
        if this.m_rkHit[r] {
          sameGunHits += 1;
        }
        if now - this.m_rkTimes[r] <= 0.3 {
          sameMoment += 1;
        }
      }
      r += 1;
    }

    // Berserker: once 5 kills land within 5 s, each kill adds a stack and restarts the 10 s timer
    let maxStacks = this.BerserkMax();
    if maxStacks > 0 && anyGun >= 5 {
      if now >= this.m_berserkUntil {
        this.m_berserkStacks = 0;
      }
      this.m_berserkStacks = Min(maxStacks, this.m_berserkStacks + 1);
      this.m_berserkUntil = now + 10.0;
      this.Log("Berserker x" + IntToString(this.m_berserkStacks));
      this.ShowBerserkIcon();
    }

    // streak titles: kills by the weapon itself within 5 s
    if byWeapon {
      if sameGunHits >= 15 {
        this.EarnFeat(game, p.item, 2);
      } else {
        if sameGunHits >= 10 {
          this.EarnFeat(game, p.item, 1);
        } else {
          if sameGunHits >= 5 {
            this.EarnFeat(game, p.item, 0);
          }
        }
      }
    }

    // Smart Bomb: kills from one shot or one blast land together
    if sameMoment >= 5 {
      this.EarnFeat(game, p.item, 4);
    }

    let f = this.FightSlot(p.item, now);
    if byWeapon {
      this.m_fgDoom[f] += 1;
      if this.m_fgDoom[f] >= 25 {
        this.EarnFeat(game, p.item, 3);
      }
    }
    this.m_fgClean[f] += 1;
    if this.m_fgClean[f] >= 30 {
      this.EarnFeat(game, p.item, 5);
    }
    if p.unaware {
      this.m_fgGhost[f] += 1;
      if this.m_fgGhost[f] >= 10 {
        this.EarnFeat(game, p.item, 6);
      }
      let i = this.TitleIndexOrCreate(p.item);
      this.m_tStealth[i] += 1;
      if this.m_tStealth[i] >= 50 {
        this.EarnFeat(game, p.item, 7);
      }
    } else {
      this.m_fgGhost[f] = 0;
    }

    // Snake Eater: a fight of 15+ kills (any weapon) with 5+ healing items used
    if now - this.m_fightLast > 30.0 {
      this.m_fightKills = 0;
      this.m_fightHeals = 0;
    }
    this.m_fightKills += 1;
    this.m_fightLast = now;
    if this.m_fightKills >= 15 && this.m_fightHeals >= 5 {
      this.EarnFeat(game, p.item, 8);
    }

    this.Log("feats " + WLvlSystem.ModelName(p.item) + " (" + this.HandOf(p.item) + "): streak " + IntToString(sameGunHits)
      + ", same moment " + IntToString(sameMoment) + ", no reload " + IntToString(this.m_fgDoom[f])
      + ", no damage " + IntToString(this.m_fgClean[f]) + ", unaware " + IntToString(this.m_fgGhost[f])
      + ", fight " + IntToString(this.m_fightKills) + " kills / " + IntToString(this.m_fightHeals) + " heals");

    // Doom Slayer's bonus: kills heal
    if this.FeatActive(3) {
      this.HealPercent(2.0);
    }
  }

  // ================================================================ titles (per individual gun)
  // Lists added in later versions are shorter in older saves; this lines them up again.
  private func PadTitles() -> Void {
    // every per-gun list must be as long as the gun list (saves from older versions can be short)
    while ArraySize(this.m_tFaction) < ArraySize(this.m_tItems) * WLvlTitles.FactionCount() {
      ArrayPush(this.m_tFaction, 0);
    }
    while ArraySize(this.m_tVehicles) < ArraySize(this.m_tItems) {
      ArrayPush(this.m_tVehicles, 0);
    }
    while ArraySize(this.m_tPsychos) < ArraySize(this.m_tItems) {
      ArrayPush(this.m_tPsychos, 0);
    }
    while ArraySize(this.m_tTrophies) < ArraySize(this.m_tItems) {
      ArrayPush(this.m_tTrophies, 0);
    }
    while ArraySize(this.m_tShown) < ArraySize(this.m_tItems) {
      ArrayPush(this.m_tShown, 0);
    }
    while ArraySize(this.m_tKaren) < ArraySize(this.m_tItems) {
      ArrayPush(this.m_tKaren, 0);
    }
    while ArraySize(this.m_tFeats) < ArraySize(this.m_tItems) {
      ArrayPush(this.m_tFeats, 0);
    }
    while ArraySize(this.m_tStealth) < ArraySize(this.m_tItems) {
      ArrayPush(this.m_tStealth, 0);
    }
    while ArraySize(this.m_tAraHeads) < ArraySize(this.m_tItems) {
      ArrayPush(this.m_tAraHeads, 0);
    }
    while ArraySize(this.m_tAraHeavy) < ArraySize(this.m_tItems) {
      ArrayPush(this.m_tAraHeavy, 0);
    }
    while ArraySize(this.m_tSecret) < ArraySize(this.m_tItems) {
      ArrayPush(this.m_tSecret, 0);
    }
  }

  // The same physical gun can be handed to scripts with slightly different item ids (the
  // inventory list, the tooltip and the drawn weapon don't always agree on the extra fields),
  // so a gun is matched by its weapon record and random seed, which never change.
  public static func SameGun(a: ItemID, b: ItemID) -> Bool {
    let ra = ItemID.GetTDBID(a);
    let rb = ItemID.GetTDBID(b);
    if NotEquals(ra, rb) {
      return false;
    }
    let sa = ItemID.GetRngSeed(a);
    let sb = ItemID.GetRngSeed(b);
    return Equals(sa, sb);
  }

  private func TitleIndex(item: ItemID) -> Int32 {
    this.PadTitles();
    if !ItemID.IsValid(item) {
      return -1;
    }
    let i = 0;
    while i < ArraySize(this.m_tItems) {
      if WLvlSystem.SameGun(this.m_tItems[i], item) {
        return i;
      }
      i += 1;
    }
    return -1;
  }

  private func TitleIndexOrCreate(item: ItemID) -> Int32 {
    let i = this.TitleIndex(item);
    if i >= 0 {
      return i;
    }
    ArrayPush(this.m_tItems, item);
    this.Log("title record started for " + WLvlSystem.ModelName(item) + " (" + IntToString(ArraySize(this.m_tItems)) + " guns)");
    let f = 0;
    while f < WLvlTitles.FactionCount() {
      ArrayPush(this.m_tFaction, 0);
      f += 1;
    }
    ArrayPush(this.m_tVehicles, 0);
    ArrayPush(this.m_tPsychos, 0);
    ArrayPush(this.m_tTrophies, 0);
    ArrayPush(this.m_tShown, 0);
    ArrayPush(this.m_tKaren, 0);
    ArrayPush(this.m_tFeats, 0);
    ArrayPush(this.m_tStealth, 0);
    ArrayPush(this.m_tAraHeads, 0);
    ArrayPush(this.m_tAraHeavy, 0);
    ArrayPush(this.m_tSecret, 0);
    return ArraySize(this.m_tItems) - 1;
  }

  // trophy flags: bit k of the stored number
  public static func Bit(k: Int32) -> Int32 {
    let v = 1;
    let n = 0;
    while n < k {
      v = v * 2;
      n += 1;
    }
    return v;
  }

  public static func HasBit(mask: Int32, k: Int32) -> Bool {
    return (mask / WLvlSystem.Bit(k)) % 2 == 1;
  }

  private func FactionKills(i: Int32, f: Int32) -> Int32 {
    return this.m_tFaction[i * WLvlTitles.FactionCount() + f];
  }

  // Every title this gun holds, as codes. Only the top tier of each family is listed.
  public func EarnedTitles(item: ItemID) -> array<Int32> {
    let out: array<Int32>;
    let i = this.TitleIndex(item);
    if i < 0 {
      return out;
    }
    let f = 0;
    while f < WLvlTitles.FactionCount() {
      let tier = WLvlTitles.FactionTier(f, this.FactionKills(i, f));
      if tier > 0 {
        ArrayPush(out, WLvlTitles.FactionCode(f, tier));
      }
      f += 1;
    }
    let carma = WLvlTitles.CarmaTier(this.m_tVehicles[i]);
    if carma > 0 {
      ArrayPush(out, WLvlTitles.CarmaCode(carma));
    }
    let psycho = WLvlTitles.PsychoTier(this.m_tPsychos[i]);
    if psycho > 0 {
      ArrayPush(out, WLvlTitles.PsychoCode(psycho));
    }
    let karen = WLvlTitles.KarenTier(this.m_tKaren[i]);
    if karen > 0 {
      ArrayPush(out, WLvlTitles.KarenCode(karen));
    }
    // feats: of the three streak titles only the highest is listed
    let streak = -1;
    let k = 0;
    while k <= 2 {
      if WLvlSystem.HasBit(this.m_tFeats[i], k) {
        streak = k;
      }
      k += 1;
    }
    if streak >= 0 {
      ArrayPush(out, WLvlTitles.FeatCode(streak));
    }
    k = 3;
    while k < WLvlTitles.FeatCount() {
      if WLvlSystem.HasBit(this.m_tFeats[i], k) {
        ArrayPush(out, WLvlTitles.FeatCode(k));
      }
      k += 1;
    }
    let b = 0;
    while b <= 1 {
      if WLvlSystem.HasBit(this.m_tSecret[i], b) {
        ArrayPush(out, WLvlTitles.SecretCode(b));
      }
      b += 1;
    }
    let t = 0;
    while t < WLvlTitles.TrophyCount() {
      if WLvlSystem.HasBit(this.m_tTrophies[i], t) {
        ArrayPush(out, WLvlTitles.TrophyCode(t));
      }
      t += 1;
    }
    return out;
  }

  // The title shown in the gun's name: the one picked in the spend menu, or the newest one.
  // The title shown after the gun's name, chosen by the Mod Settings option. Every earned title's
  // bonus works either way.
  public func ShownTitle(item: ItemID) -> Int32 {
    let earned = this.EarnedTitles(item);
    let count = ArraySize(earned);
    if count == 0 {
      return 0;
    }
    // strongest first (simple sort: the lists are short)
    let a = 0;
    while a < count {
      let b = a + 1;
      while b < count {
        if WLvlTitles.Weight(earned[b]) > WLvlTitles.Weight(earned[a]) {
          let t = earned[a];
          earned[a] = earned[b];
          earned[b] = t;
        }
        b += 1;
      }
      a += 1;
    }
    let pick = EnumInt(this.Config().titleChoice);
    if pick == 1 && count >= 2 { return earned[1]; }
    if pick == 2 && count >= 3 { return earned[2]; }
    if pick == 3 { return earned[count - 1]; }
    if pick == 4 {
      let i = this.TitleIndex(item);
      let last = this.m_tShown[i];
      let k = 0;
      while k < count {
        if WLvlTitles.Family(earned[k]) == WLvlTitles.Family(last) {
          return earned[k];
        }
        k += 1;
      }
    }
    return earned[0];
  }

  // The earned title with the highest weight (rarest, strongest effect).
  public func BestTitle(item: ItemID) -> Int32 {
    let earned = this.EarnedTitles(item);
    let best = 0;
    let j = 0;
    while j < ArraySize(earned) {
      if best == 0 || WLvlTitles.Weight(earned[j]) > WLvlTitles.Weight(best) {
        best = earned[j];
      }
      j += 1;
    }
    return best;
  }

  // The chosen title, shown on its own line under the gun's name (card) or item type (tooltip).
  public func ShownTitleName(item: ItemID) -> String {
    if !this.Config().enabled || !ItemID.IsValid(item) {
      return "";
    }
    let code = this.ShownTitle(item);
    if code == 0 {
      return "";
    }
    return WLvlTitles.Name(code);
  }

  public func ShownTitleLine(item: ItemID) -> String {
    let name = this.ShownTitleName(item);
    if Equals(name, "") {
      return "";
    }
    return "\n" + WLvlF("WLvl-TitleQuote", name);
  }

  // Tooltip lines: the gun's other titles, the feat bonuses and trophy notes, and the sell warning.
  public func TitleLines(item: ItemID) -> String {
    let earned = this.EarnedTitles(item);
    if ArraySize(earned) == 0 {
      return "";
    }
    let shown = this.ShownTitle(item);
    let others = "";
    let notes = "";
    let j = 0;
    while j < ArraySize(earned) {
      let code = earned[j];
      if code != shown {
        if NotEquals(others, "") {
          others = others + ", ";
        }
        others = others + WLvlTitles.Name(code);
      }
      if code >= 300 {
        notes = notes + "\n" + WLvlTitles.TrophyNote(code - 300);
      } else {
        if code >= 230 && code < 230 + WLvlTitles.FeatCount() {
          notes = notes + "\n" + WLvlTitles.Name(code) + ": " + WLvlTitles.FeatNote(code - 230);
        }
        if code >= 250 && code <= 251 {
          notes = notes + "\n" + WLvlTitles.SecretNote(code - 250);
        }
      }
      j += 1;
    }
    let text = "";
    if NotEquals(others, "") {
      text = "\n" + WLvlF("WLvl-Tip-Also", others);
    }
    if Equals(this.HandOf(item), "left") {
      notes = notes + "\n" + WLvlT("WLvl-Tip-LeftHandFeats");
    }
    return text + notes + "\n" + WLvlT("WLvl-Tip-LostOnSale");
  }

  // Extra damage from all of the gun's titles against what it just hit.
  public func TitleDamageMult(item: ItemID, target: wref<GameObject>) -> Float {
    if !this.Config().enabled || !IsDefined(target) {
      return 1.0;
    }
    let i = this.TitleIndex(item);
    if i < 0 {
      return 1.0;
    }
    let earned = this.EarnedTitles(item);
    let bonus = 0.0;
    let e = 0;
    while e < ArraySize(earned) {
      bonus += this.TitleBonusAgainst(i, earned[e], target);
      e += 1;
    }
    return 1.0 + bonus / 100.0;
  }

  private func TitleBonusAgainst(i: Int32, code: Int32, target: wref<GameObject>) -> Float {
    let bonus = 0.0;
    let victim = target as ScriptedPuppet;
    if IsDefined(victim) {
      let f = WLvlTitles.FactionOf(victim);
      if code >= 100 && code < 200 && f == (code - 100) / 3 {
        bonus += WLvlTitles.FactionBonus(f, this.FactionKills(i, f));
      }
      if WLvlTitles.Family(code) == 200 && WLvlTitles.IsMachine(victim) {
        bonus += WLvlTitles.CarmaBonus(this.m_tVehicles[i]);
      }
      if WLvlTitles.Family(code) == 210 && (victim.IsCharacterCyberpsycho() || f == 13) {
        bonus += WLvlTitles.PsychoBonus(this.m_tPsychos[i]);
      }
      if WLvlTitles.Family(code) == 220 && this.StartedIt(victim.GetEntityID()) {
        bonus += WLvlTitles.KarenBonus(this.m_tKaren[i]);
      }
      if code == 250 && f == 0 {
        bonus += 50.0;   // The Board's Worst Nightmare
      }
    } else {
      if WLvlTitles.Family(code) == 200 && IsDefined(target as VehicleObject) {
        bonus += WLvlTitles.CarmaBonus(this.m_tVehicles[i]);
      }
    }
    return bonus;
  }

  // What the gun's title does, for the tooltip.
  public func TitleEffect(item: ItemID, code: Int32) -> String {
    let i = this.TitleIndex(item);
    if i < 0 {
      return "";
    }
    if code >= 100 && code < 200 {
      let f = (code - 100) / 3;
      return WLvlF2("WLvl-Effect-Faction", FloatToStringPrec(WLvlTitles.FactionBonus(f, this.FactionKills(i, f)), 0), WLvlTitles.FactionName(f));
    }
    if WLvlTitles.Family(code) == 200 {
      return WLvlF("WLvl-Effect-Carma", FloatToStringPrec(WLvlTitles.CarmaBonus(this.m_tVehicles[i]), 0));
    }
    if WLvlTitles.Family(code) == 210 {
      return WLvlF("WLvl-Effect-Psycho", FloatToStringPrec(WLvlTitles.PsychoBonus(this.m_tPsychos[i]), 0));
    }
    if WLvlTitles.Family(code) == 220 {
      return WLvlF("WLvl-Effect-Karen", FloatToStringPrec(WLvlTitles.KarenBonus(this.m_tKaren[i]), 0));
    }
    if code >= 230 && code < 230 + WLvlTitles.FeatCount() {
      return WLvlTitles.FeatNote(code - 230);
    }
    if code == 250 || code == 251 {
      return WLvlTitles.SecretNote(code - 250);
    }
    if code >= 300 {
      return WLvlTitles.TrophyNote(code - 300);
    }
    return "";
  }

  // The tooltip's list of titles, one line each, for the bonus lines at the bottom.
  public func TitleLineList(item: ItemID) -> array<String> {
    let out: array<String>;
    let earned = this.EarnedTitles(item);
    if ArraySize(earned) == 0 || !this.Config().enabled {
      return out;
    }
    let shown = this.ShownTitle(item);
    ArrayPush(out, WLvlTitles.Name(shown) + ": " + this.TitleEffect(item, shown));
    let j = 0;
    while j < ArraySize(earned) {
      if earned[j] != shown {
        ArrayPush(out, WLvlTitles.Name(earned[j]) + ": " + this.TitleEffect(item, earned[j]));
      }
      j += 1;
    }
    if Equals(this.HandOf(item), "left") {
      ArrayPush(out, WLvlT("WLvl-Tip-LeftHandTitles"));
    }
    ArrayPush(out, WLvlT("WLvl-Tip-LostOnSale"));
    return out;
  }

  public static func KeyName(key: EInputKey) -> String {
    let name = EnumValueToString("EInputKey", Cast<Int64>(EnumInt(key)));
    return StrReplace(name, "IK_", "");
  }

  // Shows the new title and makes it the shown one, unless the player picked a title from
  // another family (then their choice stays and the new one is listed in the tooltip).
  private func Award(game: GameInstance, item: ItemID, i: Int32, code: Int32, note: String) -> Void {
    // The first title makes the gun an iconic weapon.
    this.EnsureIconic(item);
    this.m_tShown[i] = code;   // remembered for "Most recently earned"
    this.Log("title earned: " + WLvlTitles.Name(code) + " on " + WLvlSystem.ModelName(item));
    WLvlCard.ShowEx(game, this, item, WLvlF("WLvl-Card-NewTitle", WLvlTitles.Name(code)), note);
  }

  private func OnTitleKill(game: GameInstance, p: ref<WLvlPending>) -> Void {
    if !ItemID.IsValid(p.item) || !IsDefined(p.victim) {
      return;
    }
    let victim = p.victim;
    let f = WLvlTitles.FactionOf(victim);
    let trophy = WLvlTitles.TrophyOf(victim);
    if victim.IsBoss() || trophy >= 0 {
      this.Log("named kill: " + victim.GetDisplayName() + " (trophy " + IntToString(trophy) + ")");
    }
    // quest characters never count toward the hidden counters (trophies are quest characters by nature)
    let karen = false;
    if victim.IsQuest() {
      f = -1;
    } else {
      karen = WLvlTitles.IsCivilian(victim) && this.StartedIt(p.victimID);
    }
    if f < 0 && trophy < 0 && !karen {
      return;
    }
    let i = this.TitleIndexOrCreate(p.item);
    if karen {
      let kBefore = WLvlTitles.KarenTier(this.m_tKaren[i]);
      this.m_tKaren[i] += 1;
      let kAfter = WLvlTitles.KarenTier(this.m_tKaren[i]);
      this.Log("they started it: civilian killed with " + WLvlSystem.ModelName(p.item) + ": " + IntToString(this.m_tKaren[i]));
      if kAfter > kBefore {
        this.Award(game, p.item, i, WLvlTitles.KarenCode(kAfter), "");
      }
    }
    if f >= 0 {
      let slot = i * WLvlTitles.FactionCount() + f;
      let before = WLvlTitles.FactionTier(f, this.m_tFaction[slot]);
      this.m_tFaction[slot] += 1;
      let after = WLvlTitles.FactionTier(f, this.m_tFaction[slot]);
      if after > before {
        this.Award(game, p.item, i, WLvlTitles.FactionCode(f, after), "");
      }
    }
    if f == 0 {
      this.OnJohnnyKill(game, p, i);
    }
    if trophy >= 0 && !WLvlSystem.HasBit(this.m_tTrophies[i], trophy) {
      this.m_tTrophies[i] = this.m_tTrophies[i] + WLvlSystem.Bit(trophy);
      this.Award(game, p.item, i, WLvlTitles.TrophyCode(trophy), WLvlTitles.TrophyNote(trophy));
    }
  }

  private func OnVehicleDestroyed(game: GameInstance, item: ItemID) -> Void {
    if !ItemID.IsValid(item) {
      return;
    }
    let i = this.TitleIndexOrCreate(item);
    let before = WLvlTitles.CarmaTier(this.m_tVehicles[i]);
    this.m_tVehicles[i] += 1;
    let after = WLvlTitles.CarmaTier(this.m_tVehicles[i]);
    this.Log("vehicle destroyed by " + WLvlSystem.ModelName(item) + ": " + IntToString(this.m_tVehicles[i]));
    if after > before {
      this.Award(game, item, i, WLvlTitles.CarmaCode(after), "");
    }
  }

  // A real cyberpsycho: tagged as one, and not police or MaxTac (some mods tag those too).
  public static func IsTruePsycho(npc: ref<ScriptedPuppet>) -> Bool {
    if !IsDefined(npc) || !npc.IsCharacterCyberpsycho() || npc.IsCharacterPolice() || npc.IsPrevention() {
      return false;
    }
    let f = WLvlTitles.FactionOf(npc);
    return f != 12 && f != 13;
  }

  private func OnPsychoDown(game: GameInstance, p: ref<WLvlPending>) -> Void {
    if this.AlreadyCounted(p.victimID) || !ItemID.IsValid(p.item) {
      return;
    }
    ArrayPush(this.m_counted, p.victimID);
    // a cyberpsycho taken alive is worth the same XP as a kill
    let xp = this.UseBoost(this.XPExtras(p, this.KillXP(p.victim)));
    if xp > 0 {
      let gained = this.AddXP(p.item, xp);
      this.Log(WLvlSystem.ModelName(p.item) + ": +" + IntToString(xp) + " XP for a cyberpsycho taken alive");
      if gained > 0 {
        WLvlCard.Show(game, this, p.item, WLvlT("WLvl-Card-LevelUp"));
        this.Notify(WLvlF2("WLvl-Msg-ReachedLevel", WLvlSystem.ModelName(p.item), IntToString(this.LevelOf(p.item))));
      }
    }
    let i = this.TitleIndexOrCreate(p.item);
    let before = WLvlTitles.PsychoTier(this.m_tPsychos[i]);
    this.m_tPsychos[i] += 1;
    let after = WLvlTitles.PsychoTier(this.m_tPsychos[i]);
    this.Log("cyberpsycho taken down alive (" + p.victim.GetDisplayName() + ") with " + WLvlSystem.ModelName(p.item) + ": " + IntToString(this.m_tPsychos[i]));
    if after > before {
      this.Award(game, p.item, i, WLvlTitles.PsychoCode(after), "");
    }
  }

  // Spend menu: steps the name to the gun's next title. Returns the line for the card.
  private func CycleShown(item: ItemID) -> String {
    let i = this.TitleIndex(item);
    let earned = this.EarnedTitles(item);
    if i < 0 || ArraySize(earned) == 0 {
      return "This weapon has no titles yet";
    }
    let current = this.ShownTitle(item);
    let j = 0;
    while j < ArraySize(earned) && earned[j] != current {
      j += 1;
    }
    let next = earned[(j + 1) % ArraySize(earned)];
    this.m_tShown[i] = next;
    return WLvlF("WLvl-Card-NowShowing", WLvlTitles.Name(next));
  }

  // A titled gun with the same weapon record (model) as this item, if there is one.
  public func TitledCopyOf(item: ItemID) -> ItemID {
    let none: ItemID;
    let rec = ItemID.GetTDBID(item);
    let i = 0;
    while i < ArraySize(this.m_tItems) {
      if ItemID.GetTDBID(this.m_tItems[i]) == rec && this.HasTitles(this.m_tItems[i]) {
        return this.m_tItems[i];
      }
      i += 1;
    }
    // record ids can differ between tier versions of a model, so compare names too
    let model = WLvlSystem.ModelName(item);
    i = 0;
    while i < ArraySize(this.m_tItems) {
      if Equals(WLvlSystem.ModelName(this.m_tItems[i]), model) && this.HasTitles(this.m_tItems[i]) {
        return this.m_tItems[i];
      }
      i += 1;
    }
    return none;
  }

  public func HasTitles(item: ItemID) -> Bool {
    // (stored in a variable first: taking the size of the returned list directly gave junk numbers)
    let earned = this.EarnedTitles(item);
    return ArraySize(earned) > 0;
  }

  // ================================================================ relic XP boost
  public func BoostPercent() -> Int32 {
    if this.m_boostKills <= 0 {
      return 0;
    }
    return this.m_boostStacks * this.Config().relicBoostPercent;
  }

  public func BoostKillsLeft() -> Int32 {
    return this.m_boostKills;
  }

  // Applies the boost to one kill's XP and uses up one of its kills.
  private func UseBoost(xp: Int32) -> Int32 {
    let percent = this.BoostPercent();
    if percent <= 0 {
      return xp;
    }
    this.m_boostKills -= 1;
    if this.m_boostKills <= 0 {
      this.m_boostKills = 0;
      this.m_boostStacks = 0;
    }
    return RoundF(Cast<Float>(xp) * (1.0 + Cast<Float>(percent) / 100.0));
  }

  // One relic point: a stronger boost up to four stacks, then a longer one.
  // All stacks share one kill counter.
  private func AddBoost() -> Void {
    let kills = this.Config().relicBoostKills;
    if this.m_boostKills <= 0 {
      this.m_boostStacks = 0;
    }
    if this.m_boostStacks < 4 {
      this.m_boostStacks += 1;
      if this.m_boostKills < kills {
        this.m_boostKills = kills;
      }
    } else {
      this.m_boostKills += kills;
    }
    this.m_relicSpent += 1;
  }

  // ================================================================ spending points
  // The spend menu: one button steps through the options, the other carries out the chosen one.
  //   0-2  perk points x1 / x5 / x10        3-5  attribute points x1 / x5 / x10
  //   6    relic point (kill XP boost)      7    refund this weapon's perk and attribute points
  private func OnAttach() -> Void {
    this.m_instanceID = RandRange(1, 2000000000);
    GameInstance.GetCallbackSystem().RegisterCallback(n"Input/Key", this, n"OnKeyInput");
    let defs = GetAllBlackboardDefs();
    let bb = GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(defs.UI_System);
    if IsDefined(bb) {
      this.m_menuListener = bb.RegisterListenerBool(defs.UI_System.IsInMenu, this, n"OnMenuChanged");
    }
  }

  // The item whose tooltip was drawn last: what the player is looking at in the inventory.
  // Two are kept, because a comparison tooltip (the equipped gun) can be drawn right after.
  public func SetTooltipItem(item: ItemID) -> Void {
    if item != this.m_tooltipItem {
      this.m_tooltipPrev = this.m_tooltipItem;
      this.m_tooltipItem = item;
    }
  }

  public func SetHovered(item: ItemID) -> Void {
    this.m_hovered = item;
    this.m_hasHovered = ItemID.IsValid(item);
  }

  public func ClearHovered() -> Void {
    this.m_hasHovered = false;
  }

  public func InMenu() -> Bool {
    let defs = GetAllBlackboardDefs();
    return GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(defs.UI_System).GetBool(defs.UI_System.IsInMenu);
  }

  // True for anything this mod levels: weapons, plus arm cyberware once it has earned XP.
  public func IsLevelable(item: ItemID) -> Bool {
    if !ItemID.IsValid(item) {
      return false;
    }
    return RPGManager.IsItemWeapon(item) || this.IndexOf(item) >= 0;
  }

  // Keyboard: one key steps through the options, the other carries out the chosen one.
  // Controller: one button does both. A tap steps to the next option; holding it for the set
  // time and letting go carries out the chosen one. The choice is made on release, because
  // timers do not run while the game is paused in a menu.
  private cb func OnKeyInput(evt: ref<KeyInputEvent>) {
    if !this.IsLive() {
      return;
    }
    let action = evt.GetAction();
    let isPress = Equals(action, EInputAction.IACT_Press);
    let isRelease = Equals(action, EInputAction.IACT_Release);
    if !isPress && !isRelease {
      return;
    }
    let key = evt.GetKey();
    if Equals(key, EInputKey.IK_None) {
      return;
    }
    let cfg = this.Config();
    if !cfg.enabled {
      this.m_padDown = false;
      return;
    }
    let isCycle = Equals(key, cfg.keyCycle);
    let isConfirm = Equals(key, cfg.keyConfirm);
    let isPad = Equals(key, cfg.padButton);
    if !isCycle && !isConfirm && !isPad {
      return;
    }
    let game = this.GetGameInstance();
    if !IsDefined(GetPlayer(game)) {
      this.m_padDown = false;
      return;
    }
    let now = EngineTime.ToFloat(GameInstance.GetEngineTime(game));

    // controller button: note the press, decide on release
    let padConfirm = false;
    if isPad {
      if isPress {
        // repeats while held are ignored; the first press starts the timer
        if !this.m_padDown {
          this.m_padDown = true;
          this.m_padDownTime = now;
        }
        return;
      }
      if !this.m_padDown {
        // a release with no press seen (the button was already down when a menu opened)
        return;
      }
      this.m_padDown = false;
      padConfirm = now - this.m_padDownTime >= cfg.padHoldSeconds;
    } else {
      if !isPress {
        return;
      }
    }

    let inMenu = this.InMenu();
    // the controller button is only read in menus
    if !inMenu && isPad {
      return;
    }
    let item: ItemID;
    if inMenu {
      if !this.m_hasHovered {
        return;
      }
      item = this.m_hovered;
    } else {
      item = this.HeldItem();
    }
    if !this.IsLevelable(item) {
      return;
    }
    this.m_usingPad = isPad;
    if isCycle || (isPad && !padConfirm) {
      this.MenuNext(game, item);
    } else {
      this.MenuConfirm(game, item);
    }
  }

  // Steps the weapon highlighted in the inventory to its next title, which switches the active effect.
  // The help line under the spend menu, worded for whichever input was used last.
  private func HintChange() -> String {
    if this.m_usingPad {
      return WLvlT("WLvl-Hint-ChangePad");
    }
    return WLvlT("WLvl-Hint-ChangeKeys");
  }

  private func HintFirst() -> String {
    if this.m_usingPad {
      return WLvlT("WLvl-Hint-FirstPad");
    }
    return WLvlT("WLvl-Hint-FirstKeys");
  }

  private func HintSure() -> String {
    if this.m_usingPad {
      return WLvlT("WLvl-Hint-SurePad");
    }
    return WLvlT("WLvl-Hint-SureKeys");
  }

  private func MenuIsLive(game: GameInstance) -> Bool {
    let now = EngineTime.ToFloat(GameInstance.GetEngineTime(game));
    return this.m_menuActive && now - this.m_menuTime < 8.0;
  }

  private func MenuTouch(game: GameInstance) -> Void {
    this.m_menuActive = true;
    this.m_menuTime = EngineTime.ToFloat(GameInstance.GetEngineTime(game));
  }

  private static func MenuKind(index: Int32) -> Int32 {
    if index < 3 {
      return 0;
    }
    if index < 6 {
      return 1;
    }
    if index == 6 {
      return 2;
    }
    if index == 8 {
      return 4;
    }
    return 3;
  }

  private static func MenuAmount(index: Int32) -> Int32 {
    if index >= 6 {
      return 1;
    }
    let step = index % 3;
    if step == 1 {
      return 5;
    }
    if step == 2 {
      return 10;
    }
    return 1;
  }

  private func MenuLabel(index: Int32) -> String {
    let kind = WLvlSystem.MenuKind(index);
    let amount = WLvlSystem.MenuAmount(index);
    if kind == 2 {
      return WLvlF2("WLvl-Menu-Relic", IntToString(this.Config().relicBoostPercent), IntToString(this.Config().relicBoostKills));
    }
    if kind == 3 {
      return WLvlT("WLvl-Menu-Refund");
    }
    if kind == 4 {
      return WLvlT("WLvl-Menu-Title");
    }
    let gain = WLvlCard.Commas(amount * this.PointXP(kind));
    if kind == 1 {
      return WLvlF2("WLvl-Menu-Attr", IntToString(amount), gain);
    }
    return WLvlF2("WLvl-Menu-Perk", IntToString(amount), gain);
  }

  // "Next option": the first press shows the current option, later presses step to the next one.
  private func MenuNext(game: GameInstance, item: ItemID) -> Void {
    if this.MenuIsLive(game) {
      this.m_menuIndex = (this.m_menuIndex + 1) % 9;
      // the title option only appears on guns that have a title
      if this.m_menuIndex == 8 && !this.HasTitles(item) {
        this.m_menuIndex = 0;
      }
    }
    this.m_menuArmed = false;
    this.MenuTouch(game);
    WLvlCard.ShowEx(game, this, item, "> " + this.MenuLabel(this.m_menuIndex), this.HintChange());
  }

  private func MenuConfirm(game: GameInstance, item: ItemID) -> Void {
    if !this.MenuIsLive(game) {
      // nothing chosen yet: show the menu first so a stray press never spends anything
      this.m_menuArmed = false;
      this.MenuTouch(game);
      WLvlCard.ShowEx(game, this, item, "> " + this.MenuLabel(this.m_menuIndex), this.HintFirst());
      return;
    }
    this.MenuTouch(game);
    let kind = WLvlSystem.MenuKind(this.m_menuIndex);
    let label = "> " + this.MenuLabel(this.m_menuIndex);
    // the costly ones ask every time
    if (kind == 2 || kind == 3) && !this.m_menuArmed {
      this.m_menuArmed = true;
      WLvlCard.ShowEx(game, this, item, label, this.HintSure());
      return;
    }
    this.m_menuArmed = false;
    let result = "";
    if kind == 4 {
      result = this.CycleShown(item);
    } else {
      if kind == 3 {
        result = this.Refund(game, item);
      } else {
        result = this.Spend(game, item, kind, WLvlSystem.MenuAmount(this.m_menuIndex));
      }
    }
    WLvlCard.ShowEx(game, this, item, label, result);
  }

  private static func PointType(kind: Int32) -> gamedataDevelopmentPointType {
    if kind == 0 {
      return gamedataDevelopmentPointType.Primary;     // perk points
    }
    if kind == 1 {
      return gamedataDevelopmentPointType.Attribute;
    }
    return gamedataDevelopmentPointType.Espionage;     // relic points
  }

  private static func PointName(kind: Int32, amount: Int32) -> String {
    let name = "relic point";
    if kind == 0 {
      name = "perk point";
    }
    if kind == 1 {
      name = "attribute point";
    }
    if amount != 1 {
      name = name + "s";
    }
    return name;
  }

  // XP one point of this kind is worth, after the "Point value" setting.
  public func PointXP(kind: Int32) -> Int32 {
    let cfg = this.Config();
    let base = cfg.perkXP;
    if kind == 1 {
      base = cfg.attributeXP;
    }
    return RoundF(Cast<Float>(base) * this.PointPercent(kind) / 100.0);
  }

  // How much a point is worth, in percent of the base XP above. Worked out from Better Leveling's
  // settings when it is installed and the auto option is on, otherwise the manual setting.
  public func PointPercent(kind: Int32) -> Float {
    let cfg = this.Config();
    if cfg.autoPointScale && WLvlBLInstalled() {
      return WLvlBLPointPercent(this.GetGameInstance(), kind);
    }
    return Cast<Float>(cfg.pointScale);
  }

  // Keeps the per-model point lists as long as the model list (older saves do not have them).
  private func PadSpent() -> Void {
    while ArraySize(this.m_spentPerk) < ArraySize(this.m_models) {
      ArrayPush(this.m_spentPerk, 0);
    }
    while ArraySize(this.m_spentAttr) < ArraySize(this.m_models) {
      ArrayPush(this.m_spentAttr, 0);
    }
    while ArraySize(this.m_boughtXP) < ArraySize(this.m_models) {
      ArrayPush(this.m_boughtXP, 0);
    }
  }

  // Spends points on a weapon. Returns the line to show on the card.
  private func Spend(game: GameInstance, item: ItemID, kind: Int32, wanted: Int32) -> String {
    let data = PlayerDevelopmentSystem.GetData(GetPlayer(game));
    if !IsDefined(data) {
      return WLvlT("WLvl-Msg-NoRead");
    }
    let type = WLvlSystem.PointType(kind);
    let have = data.GetDevPoints(type);
    if have <= 0 {
      if kind == 0 {
        return WLvlT("WLvl-Msg-NoPerk");
      }
      if kind == 1 {
        return WLvlT("WLvl-Msg-NoAttr");
      }
      return WLvlT("WLvl-Msg-NoRelic");
    }
    let amount = wanted;
    if amount > have {
      amount = have;
    }
    // the points come out of the unspent pool; the mod keeps its own count so they can be refunded
    data.AddDevelopmentPoints(-amount, type);
    let left = WLvlF("WLvl-Msg-Left", WLvlCard.Commas(have - amount));
    if kind == 2 {
      this.AddBoost();
      this.Log("spent 1 relic point: boost +" + IntToString(this.BoostPercent()) + "% for " + IntToString(this.m_boostKills) + " kills");
      return WLvlF("WLvl-Msg-BoostBought", left);
    }
    let xp = amount * this.PointXP(kind);
    let gained = this.AddXP(item, xp);
    let i = this.IndexOf(item);
    this.PadSpent();
    if i >= 0 {
      if kind == 0 {
        this.m_spentPerk[i] += amount;
      } else {
        this.m_spentAttr[i] += amount;
      }
      this.m_boughtXP[i] += xp;
    }
    this.Log(WLvlSystem.ModelName(item) + ": spent " + IntToString(amount) + " " + WLvlSystem.PointName(kind, amount) + " for +" + IntToString(xp)
      + " XP, level " + IntToString(this.LevelOf(item)));
    let result = WLvlF2("WLvl-Msg-XPGained", WLvlCard.Commas(xp), left);
    if gained > 0 {
      result = WLvlF("WLvl-Msg-LevelUpPrefix", result);
    }
    return result;
  }

  // Takes XP away from a model, stepping back down through levels as needed.
  private func RemoveXP(i: Int32, amount: Int32) -> Void {
    let left = amount;
    while left > 0 {
      if this.m_xp[i] >= left {
        this.m_xp[i] -= left;
        left = 0;
      } else {
        left -= this.m_xp[i];
        if this.m_levels[i] <= 0 {
          this.m_xp[i] = 0;
          left = 0;
        } else {
          this.m_levels[i] -= 1;
          this.m_xp[i] = WLvlSystem.CostOf(this.m_levels[i]);
        }
      }
    }
  }

  // Gives back every perk and attribute point put into this weapon's model and removes the XP
  // they bought. XP earned from kills stays. Relic points are not refunded: the boost is used up.
  private func Refund(game: GameInstance, item: ItemID) -> String {
    let i = this.IndexOf(item);
    this.PadSpent();
    if i < 0 || (this.m_spentPerk[i] <= 0 && this.m_spentAttr[i] <= 0) {
      return WLvlT("WLvl-Msg-NothingSpent");
    }
    let data = PlayerDevelopmentSystem.GetData(GetPlayer(game));
    if !IsDefined(data) {
      return WLvlT("WLvl-Msg-NoRead");
    }
    let perk = this.m_spentPerk[i];
    let attr = this.m_spentAttr[i];
    let xp = this.m_boughtXP[i];
    if xp <= 0 {
      // points spent before the mod recorded bought XP: work it out from the current settings
      xp = perk * this.PointXP(0) + attr * this.PointXP(1);
    }
    this.RemoveXP(i, xp);
    if perk > 0 {
      data.AddDevelopmentPoints(perk, gamedataDevelopmentPointType.Primary);
    }
    if attr > 0 {
      data.AddDevelopmentPoints(attr, gamedataDevelopmentPointType.Attribute);
    }
    this.m_spentPerk[i] = 0;
    this.m_spentAttr[i] = 0;
    this.m_boughtXP[i] = 0;
    this.Log(WLvlSystem.ModelName(item) + ": refunded " + IntToString(perk) + " perk and " + IntToString(attr) + " attribute points, removed "
      + IntToString(xp) + " XP, now level " + IntToString(this.m_levels[i]));
    this.RefreshLevelStats(item);
    return WLvlF2("WLvl-Msg-Refunded", WLvlCard.Commas(perk), WLvlCard.Commas(attr));
  }

  // Points spent on a weapon's model, for the tooltip.
  public func SpentPerk(item: ItemID) -> Int32 {
    let i = this.IndexOf(item);
    this.PadSpent();
    if i < 0 {
      return 0;
    }
    return this.m_spentPerk[i];
  }

  public func SpentAttribute(item: ItemID) -> Int32 {
    let i = this.IndexOf(item);
    this.PadSpent();
    if i < 0 {
      return 0;
    }
    return this.m_spentAttr[i];
  }

  // ================================================================ console helpers for testing
  private func HeldItem() -> ItemID {
    let game = this.GetGameInstance();
    let player = GameInstance.GetPlayerSystem(game).GetLocalPlayerControlledGameObject();
    let none: ItemID;
    if !IsDefined(player) {
      return none;
    }
    let weapon = GameInstance.GetTransactionSystem(game).GetItemInSlot(player, t"AttachmentSlots.WeaponRight") as WeaponObject;
    if !IsDefined(weapon) {
      return none;
    }
    return weapon.GetItemID();
  }

  public func Report() -> String {
    let item = this.HeldItem();
    if !ItemID.IsValid(item) {
      return "Weapon Leveling: no weapon in the right hand. Models tracked: " + IntToString(ArraySize(this.m_models));
    }
    let level = this.LevelOf(item);
    return WLvlSystem.ModelName(item) + ": level " + IntToString(level) + ", " + IntToString(this.XPOf(item)) + " / "
      + IntToString(WLvlSystem.CostOf(level)) + " XP, damage +" + FloatToStringPrec(this.DamageBonusPercent(level), 1)
      + "%. Models tracked: " + IntToString(ArraySize(this.m_models));
  }

  // Testing only: gives the Malorian in V's right hand The Board's Worst Nightmare.
  public func CheatJohnny() -> String {
    let item = this.HeldItem();
    if !ItemID.IsValid(item) || !WLvlSystem.IsMalorian(item) {
      return "Weapon Leveling: draw the Malorian Arms 3516 first";
    }
    let i = this.TitleIndexOrCreate(item);
    if !WLvlSystem.HasBit(this.m_tSecret[i], 0) {
      this.m_tSecret[i] = this.m_tSecret[i] + WLvlSystem.Bit(0);
      this.Award(this.GetGameInstance(), item, i, WLvlTitles.SecretCode(0), WLvlTitles.SecretNote(0));
    }
    return "Weapon Leveling: The Board's Worst Nightmare granted for testing";
  }

  public func CheatXP(amount: Int32) -> String {
    let item = this.HeldItem();
    if !ItemID.IsValid(item) {
      return "Weapon Leveling: draw a weapon first";
    }
    this.AddXP(item, amount);
    WLvlCard.Show(this.GetGameInstance(), this, item, "");
    return this.Report();
  }
}

// ==================================================================== hooks into the game
// All hooks wrap the original function, so other mods' changes to the same function still run.

@wrapMethod(DamageSystem)
private final func ProcessLocalizedDamage(hitEvent: ref<gameHitEvent>) -> Void {
  wrappedMethod(hitEvent);
  let target = hitEvent.target;
  if IsDefined(target) && target.IsPlayer() {
    let psys = WLvlSystem.Get(target.GetGame());
    if IsDefined(psys) {
      psys.OnPlayerDamaged(hitEvent);
    }
    return;
  }
  let instigator = hitEvent.attackData.GetInstigator();
  if !IsDefined(instigator) || !instigator.IsPlayer() {
    return;
  }
  let sys = WLvlSystem.Get(instigator.GetGame());
  if IsDefined(sys) {
    sys.OnPlayerHit(hitEvent);
  }
}

@wrapMethod(PlayerPuppet)
protected cb func OnWeaponEquipEvent(evt: ref<WeaponEquipEvent>) -> Bool {
  let result = wrappedMethod(evt);
  let weapon = evt.item as WeaponObject;
  if IsDefined(weapon) {
    let sys = WLvlSystem.Get(this.GetGame());
    if IsDefined(sys) && sys.Config().enabled {
      sys.OnWeaponSwap();
      sys.ApplyLevelStats(weapon);
      sys.ApplyLastLaugh(weapon);
      WLvlCard.Show(this.GetGame(), sys, weapon.GetItemID(), "");
    }
  }
  return result;
}

// A destroyed vehicle kills its passengers without hitting them, so the kills are reported here.
@wrapMethod(VehicleComponent)
protected final func KillPassengers(instigator: wref<GameObject>) -> Void {
  if IsDefined(instigator) && instigator.IsPlayer() {
    let sys = WLvlSystem.Get(instigator.GetGame());
    if IsDefined(sys) {
      sys.OnVehiclePassengersKilled(this.GetVehicle());
    }
  }
  wrappedMethod(instigator);
}

// A healing item (MaxDoc, Bounce Back and the like) was used.
@wrapMethod(UseHealChargeAction)
public func CompleteAction(gameInstance: GameInstance) -> Void {
  wrappedMethod(gameInstance);
  let sys = WLvlSystem.Get(gameInstance);
  if IsDefined(sys) {
    sys.OnHealUsed();
  }
}

// The reload state of the player's weapon (Doom Slayer).
@wrapMethod(ReloadEvents)
protected final func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
  wrappedMethod(stateContext, scriptInterface);
  let weapon = this.GetWeaponObject(scriptInterface);
  if IsDefined(weapon) {
    let sys = WLvlSystem.Get(weapon.GetGame());
    if IsDefined(sys) {
      sys.OnReload(weapon.GetItemID());
    }
  }
}
