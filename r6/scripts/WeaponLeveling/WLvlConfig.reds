// Weaponpunk 2077 - Weapon Leveling Enhanced - settings
// Copyright (C) 2026 the Weaponpunk 2077 authors. Written with AI assistance.
//
// This program is free software: you can redistribute it and/or modify it under the terms of the
// GNU General Public License as published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version. It is distributed WITHOUT ANY WARRANTY. See the
// GNU General Public License for details: https://www.gnu.org/licenses/
//
// Settings appear in Mod Settings when that mod is installed. Without it the defaults below apply.
// Every number here is a starting value to be tuned in testing.

public class WLvlConfig {
  @runtimeProperty("ModSettings.mod", "Weaponpunk 2077")
  @runtimeProperty("ModSettings.category", "WLvl-Cat-General")
  @runtimeProperty("ModSettings.displayName", "WLvl-Set-enabled")
  @runtimeProperty("ModSettings.description", "WLvl-SetDesc-enabled")
  public let enabled: Bool = true;

  @runtimeProperty("ModSettings.mod", "Weaponpunk 2077")
  @runtimeProperty("ModSettings.category", "WLvl-Cat-General")
  @runtimeProperty("ModSettings.displayName", "WLvl-Set-xpMultiplier")
  @runtimeProperty("ModSettings.description", "WLvl-SetDesc-xpMultiplier")
  @runtimeProperty("ModSettings.step", "0.1")
  @runtimeProperty("ModSettings.min", "0.1")
  @runtimeProperty("ModSettings.max", "10.0")
  public let xpMultiplier: Float = 1.0;

  @runtimeProperty("ModSettings.mod", "Weaponpunk 2077")
  @runtimeProperty("ModSettings.category", "WLvl-Cat-General")
  @runtimeProperty("ModSettings.displayName", "WLvl-Set-damageCoef")
  @runtimeProperty("ModSettings.description", "WLvl-SetDesc-damageCoef")
  @runtimeProperty("ModSettings.step", "0.5")
  @runtimeProperty("ModSettings.min", "0.0")
  @runtimeProperty("ModSettings.max", "15.0")
  public let damageCoef: Float = 5.0;

  // Keyboard: two keys, one steps through the options and one carries out the chosen one. They work
  // with a weapon drawn and in the inventory. Controller: one button, tap to step and hold to use.
  // It works in the inventory only, because every button is already taken during play.
  @runtimeProperty("ModSettings.mod", "Weaponpunk 2077")
  @runtimeProperty("ModSettings.category", "WLvl-Cat-SpendingPoints")
  @runtimeProperty("ModSettings.displayName", "WLvl-Set-keyCycle")
  @runtimeProperty("ModSettings.description", "WLvl-SetDesc-keyCycle")
  public let keyCycle: EInputKey = EInputKey.IK_NumPad1;

  @runtimeProperty("ModSettings.mod", "Weaponpunk 2077")
  @runtimeProperty("ModSettings.category", "WLvl-Cat-SpendingPoints")
  @runtimeProperty("ModSettings.displayName", "WLvl-Set-keyConfirm")
  @runtimeProperty("ModSettings.description", "WLvl-SetDesc-keyConfirm")
  public let keyConfirm: EInputKey = EInputKey.IK_NumPad2;

  @runtimeProperty("ModSettings.mod", "Weaponpunk 2077")
  @runtimeProperty("ModSettings.category", "WLvl-Cat-Titles")
  @runtimeProperty("ModSettings.displayName", "WLvl-Set-titleChoice")
  @runtimeProperty("ModSettings.description", "WLvl-SetDesc-titleChoice")
  @runtimeProperty("ModSettings.displayValues.Auto", "WLvl-Val-titleChoice-Auto")
  @runtimeProperty("ModSettings.displayValues.Second", "WLvl-Val-titleChoice-Second")
  @runtimeProperty("ModSettings.displayValues.Third", "WLvl-Val-titleChoice-Third")
  @runtimeProperty("ModSettings.displayValues.Weakest", "WLvl-Val-titleChoice-Weakest")
  @runtimeProperty("ModSettings.displayValues.Newest", "WLvl-Val-titleChoice-Newest")
  public let titleChoice: WLvlTitleChoice = WLvlTitleChoice.Auto;

  @runtimeProperty("ModSettings.mod", "Weaponpunk 2077")
  @runtimeProperty("ModSettings.category", "WLvl-Cat-SpendingPoints")
  @runtimeProperty("ModSettings.displayName", "WLvl-Set-padButton")
  @runtimeProperty("ModSettings.description", "WLvl-SetDesc-padButton")
  public let padButton: EInputKey = EInputKey.IK_Pad_Back_Select;

  @runtimeProperty("ModSettings.mod", "Weaponpunk 2077")
  @runtimeProperty("ModSettings.category", "WLvl-Cat-SpendingPoints")
  @runtimeProperty("ModSettings.displayName", "WLvl-Set-padHoldSeconds")
  @runtimeProperty("ModSettings.description", "WLvl-SetDesc-padHoldSeconds")
  @runtimeProperty("ModSettings.step", "0.1")
  @runtimeProperty("ModSettings.min", "0.2")
  @runtimeProperty("ModSettings.max", "2.0")
  public let padHoldSeconds: Float = 0.5;

  @runtimeProperty("ModSettings.mod", "Weaponpunk 2077")
  @runtimeProperty("ModSettings.category", "WLvl-Cat-SpendingPoints")
  @runtimeProperty("ModSettings.displayName", "WLvl-Set-perkXP")
  @runtimeProperty("ModSettings.description", "WLvl-SetDesc-perkXP")
  @runtimeProperty("ModSettings.step", "50")
  @runtimeProperty("ModSettings.min", "50")
  @runtimeProperty("ModSettings.max", "5000")
  public let perkXP: Int32 = 500;

  @runtimeProperty("ModSettings.mod", "Weaponpunk 2077")
  @runtimeProperty("ModSettings.category", "WLvl-Cat-SpendingPoints")
  @runtimeProperty("ModSettings.displayName", "WLvl-Set-attributeXP")
  @runtimeProperty("ModSettings.description", "WLvl-SetDesc-attributeXP")
  @runtimeProperty("ModSettings.step", "50")
  @runtimeProperty("ModSettings.min", "50")
  @runtimeProperty("ModSettings.max", "10000")
  public let attributeXP: Int32 = 1500;

  @runtimeProperty("ModSettings.mod", "Weaponpunk 2077")
  @runtimeProperty("ModSettings.category", "WLvl-Cat-SpendingPoints")
  @runtimeProperty("ModSettings.displayName", "WLvl-Set-autoPointScale")
  @runtimeProperty("ModSettings.description", "WLvl-SetDesc-autoPointScale")
  public let autoPointScale: Bool = true;

  @runtimeProperty("ModSettings.mod", "Weaponpunk 2077")
  @runtimeProperty("ModSettings.category", "WLvl-Cat-SpendingPoints")
  @runtimeProperty("ModSettings.displayName", "WLvl-Set-pointScale")
  @runtimeProperty("ModSettings.description", "WLvl-SetDesc-pointScale")
  @runtimeProperty("ModSettings.step", "1")
  @runtimeProperty("ModSettings.min", "1")
  @runtimeProperty("ModSettings.max", "500")
  public let pointScale: Int32 = 100;

  @runtimeProperty("ModSettings.mod", "Weaponpunk 2077")
  @runtimeProperty("ModSettings.category", "WLvl-Cat-SpendingPoints")
  @runtimeProperty("ModSettings.displayName", "WLvl-Set-relicBoostPercent")
  @runtimeProperty("ModSettings.description", "WLvl-SetDesc-relicBoostPercent")
  @runtimeProperty("ModSettings.step", "5")
  @runtimeProperty("ModSettings.min", "5")
  @runtimeProperty("ModSettings.max", "100")
  public let relicBoostPercent: Int32 = 25;

  @runtimeProperty("ModSettings.mod", "Weaponpunk 2077")
  @runtimeProperty("ModSettings.category", "WLvl-Cat-SpendingPoints")
  @runtimeProperty("ModSettings.displayName", "WLvl-Set-relicBoostKills")
  @runtimeProperty("ModSettings.description", "WLvl-SetDesc-relicBoostKills")
  @runtimeProperty("ModSettings.step", "10")
  @runtimeProperty("ModSettings.min", "10")
  @runtimeProperty("ModSettings.max", "1000")
  public let relicBoostKills: Int32 = 200;

  @runtimeProperty("ModSettings.mod", "Weaponpunk 2077")
  @runtimeProperty("ModSettings.category", "WLvl-Cat-Leveling")
  @runtimeProperty("ModSettings.displayName", "WLvl-Set-levelHandling")
  @runtimeProperty("ModSettings.description", "WLvl-SetDesc-levelHandling")
  public let levelHandling: Bool = true;

  @runtimeProperty("ModSettings.mod", "Weaponpunk 2077")
  @runtimeProperty("ModSettings.category", "WLvl-Cat-Leveling")
  @runtimeProperty("ModSettings.displayName", "WLvl-Set-headshotBonus")
  @runtimeProperty("ModSettings.description", "WLvl-SetDesc-headshotBonus")
  @runtimeProperty("ModSettings.step", "5")
  @runtimeProperty("ModSettings.min", "0")
  @runtimeProperty("ModSettings.max", "200")
  public let headshotBonus: Int32 = 25;

  @runtimeProperty("ModSettings.mod", "Weaponpunk 2077")
  @runtimeProperty("ModSettings.category", "WLvl-Cat-Leveling")
  @runtimeProperty("ModSettings.displayName", "WLvl-Set-stealthBonus")
  @runtimeProperty("ModSettings.description", "WLvl-SetDesc-stealthBonus")
  @runtimeProperty("ModSettings.step", "5")
  @runtimeProperty("ModSettings.min", "0")
  @runtimeProperty("ModSettings.max", "200")
  public let stealthBonus: Int32 = 25;

  @runtimeProperty("ModSettings.mod", "Weaponpunk 2077")
  @runtimeProperty("ModSettings.category", "WLvl-Cat-Leveling")
  @runtimeProperty("ModSettings.displayName", "WLvl-Set-lowLevelReduction")
  @runtimeProperty("ModSettings.description", "WLvl-SetDesc-lowLevelReduction")
  public let lowLevelReduction: Bool = true;

  @runtimeProperty("ModSettings.mod", "Weaponpunk 2077")
  @runtimeProperty("ModSettings.category", "WLvl-Cat-Leveling")
  @runtimeProperty("ModSettings.displayName", "WLvl-Set-lowLevelGap")
  @runtimeProperty("ModSettings.description", "WLvl-SetDesc-lowLevelGap")
  @runtimeProperty("ModSettings.step", "1")
  @runtimeProperty("ModSettings.min", "5")
  @runtimeProperty("ModSettings.max", "50")
  public let lowLevelGap: Int32 = 20;

  @runtimeProperty("ModSettings.mod", "Weaponpunk 2077")
  @runtimeProperty("ModSettings.category", "WLvl-Cat-WeaponCard")
  @runtimeProperty("ModSettings.displayName", "WLvl-Set-showCard")
  @runtimeProperty("ModSettings.description", "WLvl-SetDesc-showCard")
  public let showCard: Bool = true;

  @runtimeProperty("ModSettings.mod", "Weaponpunk 2077")
  @runtimeProperty("ModSettings.category", "WLvl-Cat-WeaponCard")
  @runtimeProperty("ModSettings.displayName", "WLvl-Set-cardSeconds")
  @runtimeProperty("ModSettings.description", "WLvl-SetDesc-cardSeconds")
  @runtimeProperty("ModSettings.step", "0.5")
  @runtimeProperty("ModSettings.min", "1.0")
  @runtimeProperty("ModSettings.max", "10.0")
  public let cardSeconds: Float = 4.0;

  @runtimeProperty("ModSettings.mod", "Weaponpunk 2077")
  @runtimeProperty("ModSettings.category", "WLvl-Cat-WeaponCard")
  @runtimeProperty("ModSettings.displayName", "WLvl-Set-compactCard")
  @runtimeProperty("ModSettings.description", "WLvl-SetDesc-compactCard")
  public let compactCard: Bool = false;

  @runtimeProperty("ModSettings.mod", "Weaponpunk 2077")
  @runtimeProperty("ModSettings.category", "WLvl-Cat-WeaponCard")
  @runtimeProperty("ModSettings.displayName", "WLvl-Set-cardPosition")
  @runtimeProperty("ModSettings.description", "WLvl-SetDesc-cardPosition")
  @runtimeProperty("ModSettings.step", "1")
  @runtimeProperty("ModSettings.min", "1")
  @runtimeProperty("ModSettings.max", "2")
  public let cardPosition: Int32 = 1;

  @runtimeProperty("ModSettings.mod", "Weaponpunk 2077")
  @runtimeProperty("ModSettings.category", "WLvl-Cat-WeaponCard")
  @runtimeProperty("ModSettings.displayName", "WLvl-Set-cardHeight")
  @runtimeProperty("ModSettings.description", "WLvl-SetDesc-cardHeight")
  @runtimeProperty("ModSettings.step", "1")
  @runtimeProperty("ModSettings.min", "0")
  @runtimeProperty("ModSettings.max", "100")
  public let cardHeight: Int32 = 20;

  // Card size as a percent of the original design (added in 0.6.2 after a player reported the card
  // was too large). 100 = the size the card had before this setting existed, so updating the mod
  // changes nothing for anyone who liked it. WLvlCard.ShowEx turns this into the scale factor `s`
  // that every rectangle and text size on the card is multiplied by; in menus it is multiplied
  // again by 0.8 (the menu card was always drawn smaller). The 50-150 range is a guess at sensible
  // limits, not a tested one: if text gets unreadable at 50 on low resolutions, raise the minimum
  // here and in the clamp in WLvlCard.ShowEx.
  @runtimeProperty("ModSettings.mod", "Weaponpunk 2077")
  @runtimeProperty("ModSettings.category", "WLvl-Cat-WeaponCard")
  @runtimeProperty("ModSettings.displayName", "WLvl-Set-cardScale")
  @runtimeProperty("ModSettings.description", "WLvl-SetDesc-cardScale")
  @runtimeProperty("ModSettings.step", "5")
  @runtimeProperty("ModSettings.min", "50")
  @runtimeProperty("ModSettings.max", "150")
  public let cardScale: Int32 = 100;

  // Dual-wield card column (added in 0.6.2, see WLvlCard.ShowDual): while dual wielding, drawing
  // a weapon or a level-up shows both hands' cards stacked, left-hand card on top, each tagged with
  // its hand. Off = the old behaviour (one card, for the gun the event was about).
  @runtimeProperty("ModSettings.mod", "Weaponpunk 2077")
  @runtimeProperty("ModSettings.category", "WLvl-Cat-WeaponCard")
  @runtimeProperty("ModSettings.displayName", "WLvl-Set-dualCards")
  @runtimeProperty("ModSettings.description", "WLvl-SetDesc-dualCards")
  public let dualCards: Bool = true;

  @runtimeProperty("ModSettings.mod", "Weaponpunk 2077")
  @runtimeProperty("ModSettings.category", "WLvl-Cat-Debug")
  @runtimeProperty("ModSettings.displayName", "WLvl-Set-debugLog")
  @runtimeProperty("ModSettings.description", "WLvl-SetDesc-debugLog")
  public let debugLog: Bool = false;
}

// Mod Settings is optional: these two versions are picked at compile time.
@if(ModuleExists("ModSettingsModule"))
public func WLvlRegisterSettings(config: ref<WLvlConfig>) -> Void {
  ModSettings.RegisterListenerToClass(config);
}

@if(!ModuleExists("ModSettingsModule"))
public func WLvlRegisterSettings(config: ref<WLvlConfig>) -> Void {}

// Which title the name shows (Mod Settings). Generic on purpose: the menu must not name titles.
enum WLvlTitleChoice {
  Auto = 0,
  Second = 1,
  Third = 2,
  Weakest = 3,
  Newest = 4,
}
