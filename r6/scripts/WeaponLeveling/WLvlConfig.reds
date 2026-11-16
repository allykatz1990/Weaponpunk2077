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
  @runtimeProperty("ModSettings.category", "General")
  @runtimeProperty("ModSettings.displayName", "Enable weapon leveling")
  @runtimeProperty("ModSettings.description", "Turns XP gain and level bonuses on or off. Saved levels are kept.")
  public let enabled: Bool = true;

  @runtimeProperty("ModSettings.mod", "Weaponpunk 2077")
  @runtimeProperty("ModSettings.category", "General")
  @runtimeProperty("ModSettings.displayName", "Kill XP multiplier")
  @runtimeProperty("ModSettings.description", "Scales all XP earned from kills.")
  @runtimeProperty("ModSettings.step", "0.1")
  @runtimeProperty("ModSettings.min", "0.1")
  @runtimeProperty("ModSettings.max", "10.0")
  public let xpMultiplier: Float = 1.0;

  @runtimeProperty("ModSettings.mod", "Weaponpunk 2077")
  @runtimeProperty("ModSettings.category", "General")
  @runtimeProperty("ModSettings.displayName", "Damage bonus strength")
  @runtimeProperty("ModSettings.description", "How much damage each weapon level adds. Each level adds a little less than the one before. 0 turns the bonus off.")
  @runtimeProperty("ModSettings.step", "0.5")
  @runtimeProperty("ModSettings.min", "0.0")
  @runtimeProperty("ModSettings.max", "15.0")
  public let damageCoef: Float = 5.0;

  // Keyboard: two keys, one steps through the options and one carries out the chosen one. They work
  // with a weapon drawn and in the inventory. Controller: one button, tap to step and hold to use.
  // It works in the inventory only, because every button is already taken during play.
  @runtimeProperty("ModSettings.mod", "Weaponpunk 2077")
  @runtimeProperty("ModSettings.category", "Spending points")
  @runtimeProperty("ModSettings.displayName", "Next option (keyboard)")
  @runtimeProperty("ModSettings.description", "Steps through the spend menu: perk points x1, x5, x10, attribute points x1, x5, x10, relic point, refund. Works with a weapon drawn or highlighted in the inventory.")
  public let keyCycle: EInputKey = EInputKey.IK_NumPad1;

  @runtimeProperty("ModSettings.mod", "Weaponpunk 2077")
  @runtimeProperty("ModSettings.category", "Spending points")
  @runtimeProperty("ModSettings.displayName", "Confirm (keyboard)")
  @runtimeProperty("ModSettings.description", "Carries out the option shown on the card. Relic points and refunds ask for a second press.")
  public let keyConfirm: EInputKey = EInputKey.IK_NumPad2;

  @runtimeProperty("ModSettings.mod", "Weaponpunk 2077")
  @runtimeProperty("ModSettings.category", "Titles")
  @runtimeProperty("ModSettings.displayName", "Title shown after the gun's name")
  @runtimeProperty("ModSettings.description", "Which of a gun's titles appears in quotes after its name. Only the name changes: every title a gun has earned always works. If a gun has fewer titles than the choice needs, its strongest is shown.")
  @runtimeProperty("ModSettings.displayValues.Auto", "Strongest")
  @runtimeProperty("ModSettings.displayValues.Second", "Second strongest")
  @runtimeProperty("ModSettings.displayValues.Third", "Third strongest")
  @runtimeProperty("ModSettings.displayValues.Weakest", "Weakest")
  @runtimeProperty("ModSettings.displayValues.Newest", "Most recently earned")
  public let titleChoice: WLvlTitleChoice = WLvlTitleChoice.Auto;

  @runtimeProperty("ModSettings.mod", "Weaponpunk 2077")
  @runtimeProperty("ModSettings.category", "Spending points")
  @runtimeProperty("ModSettings.displayName", "Spend button (controller, inventory only)")
  @runtimeProperty("ModSettings.description", "Tap to step through the spend menu for the weapon highlighted in the inventory, hold and release to use the option shown. Default: Select / View button.")
  public let padButton: EInputKey = EInputKey.IK_Pad_Back_Select;

  @runtimeProperty("ModSettings.mod", "Weaponpunk 2077")
  @runtimeProperty("ModSettings.category", "Spending points")
  @runtimeProperty("ModSettings.displayName", "Hold time to confirm (seconds)")
  @runtimeProperty("ModSettings.description", "How long the controller spend button must be held to count as a confirm instead of a tap.")
  @runtimeProperty("ModSettings.step", "0.1")
  @runtimeProperty("ModSettings.min", "0.2")
  @runtimeProperty("ModSettings.max", "2.0")
  public let padHoldSeconds: Float = 0.5;

  @runtimeProperty("ModSettings.mod", "Weaponpunk 2077")
  @runtimeProperty("ModSettings.category", "Spending points")
  @runtimeProperty("ModSettings.displayName", "XP per perk point")
  @runtimeProperty("ModSettings.description", "How much weapon XP one perk point buys in the spend menu, before the point value below is applied.")
  @runtimeProperty("ModSettings.step", "50")
  @runtimeProperty("ModSettings.min", "50")
  @runtimeProperty("ModSettings.max", "5000")
  public let perkXP: Int32 = 500;

  @runtimeProperty("ModSettings.mod", "Weaponpunk 2077")
  @runtimeProperty("ModSettings.category", "Spending points")
  @runtimeProperty("ModSettings.displayName", "XP per attribute point")
  @runtimeProperty("ModSettings.description", "How much weapon XP one attribute point buys in the spend menu, before the point value below is applied.")
  @runtimeProperty("ModSettings.step", "50")
  @runtimeProperty("ModSettings.min", "50")
  @runtimeProperty("ModSettings.max", "10000")
  public let attributeXP: Int32 = 1500;

  @runtimeProperty("ModSettings.mod", "Weaponpunk 2077")
  @runtimeProperty("ModSettings.category", "Spending points")
  @runtimeProperty("ModSettings.displayName", "Automatic point value (Better Leveling)")
  @runtimeProperty("ModSettings.description", "With Better Leveling installed, works out what perk and attribute points are worth from its level cap and points per level, so a point is worth the same share of a playthrough as in the base game. Changes to Better Leveling's settings apply on the next launch. Turn off to use the manual value below.")
  public let autoPointScale: Bool = true;

  @runtimeProperty("ModSettings.mod", "Weaponpunk 2077")
  @runtimeProperty("ModSettings.category", "Spending points")
  @runtimeProperty("ModSettings.displayName", "Point value (percent)")
  @runtimeProperty("ModSettings.description", "Scales the XP from perk and attribute points. Used when the automatic value is off or Better Leveling is not installed.")
  @runtimeProperty("ModSettings.step", "1")
  @runtimeProperty("ModSettings.min", "1")
  @runtimeProperty("ModSettings.max", "500")
  public let pointScale: Int32 = 100;

  @runtimeProperty("ModSettings.mod", "Weaponpunk 2077")
  @runtimeProperty("ModSettings.category", "Spending points")
  @runtimeProperty("ModSettings.displayName", "Relic boost per point (percent)")
  @runtimeProperty("ModSettings.description", "Extra kill XP from each relic point spent. Stacks up to four times.")
  @runtimeProperty("ModSettings.step", "5")
  @runtimeProperty("ModSettings.min", "5")
  @runtimeProperty("ModSettings.max", "100")
  public let relicBoostPercent: Int32 = 25;

  @runtimeProperty("ModSettings.mod", "Weaponpunk 2077")
  @runtimeProperty("ModSettings.category", "Spending points")
  @runtimeProperty("ModSettings.displayName", "Relic boost length (kills)")
  @runtimeProperty("ModSettings.description", "How many kills a relic boost lasts. Points spent at full strength add this many more kills.")
  @runtimeProperty("ModSettings.step", "10")
  @runtimeProperty("ModSettings.min", "10")
  @runtimeProperty("ModSettings.max", "1000")
  public let relicBoostKills: Int32 = 200;

  @runtimeProperty("ModSettings.mod", "Weaponpunk 2077")
  @runtimeProperty("ModSettings.category", "Leveling")
  @runtimeProperty("ModSettings.displayName", "Handling improves with level")
  @runtimeProperty("ModSettings.description", "Fire rate, reload speed and recoil improve with weapon level, up to a ceiling at level 20 (10% faster fire, 15% faster reload, 20% less recoil). Applies the next time the weapon is drawn.")
  public let levelHandling: Bool = true;

  @runtimeProperty("ModSettings.mod", "Weaponpunk 2077")
  @runtimeProperty("ModSettings.category", "Leveling")
  @runtimeProperty("ModSettings.displayName", "Headshot kill XP bonus (percent)")
  @runtimeProperty("ModSettings.description", "Extra XP when the killing blow is a headshot.")
  @runtimeProperty("ModSettings.step", "5")
  @runtimeProperty("ModSettings.min", "0")
  @runtimeProperty("ModSettings.max", "200")
  public let headshotBonus: Int32 = 25;

  @runtimeProperty("ModSettings.mod", "Weaponpunk 2077")
  @runtimeProperty("ModSettings.category", "Leveling")
  @runtimeProperty("ModSettings.displayName", "Stealth kill XP bonus (percent)")
  @runtimeProperty("ModSettings.description", "Extra XP for killing an enemy who had not noticed you.")
  @runtimeProperty("ModSettings.step", "5")
  @runtimeProperty("ModSettings.min", "0")
  @runtimeProperty("ModSettings.max", "200")
  public let stealthBonus: Int32 = 25;

  @runtimeProperty("ModSettings.mod", "Weaponpunk 2077")
  @runtimeProperty("ModSettings.category", "Leveling")
  @runtimeProperty("ModSettings.displayName", "Less XP from low-level enemies")
  @runtimeProperty("ModSettings.description", "Enemies far below your level give half XP. Your level counts as 60 at most, so extended-level saves are not punished.")
  public let lowLevelReduction: Bool = true;

  @runtimeProperty("ModSettings.mod", "Weaponpunk 2077")
  @runtimeProperty("ModSettings.category", "Leveling")
  @runtimeProperty("ModSettings.displayName", "Low-level gap")
  @runtimeProperty("ModSettings.description", "How many levels below you an enemy has to be to give half XP.")
  @runtimeProperty("ModSettings.step", "1")
  @runtimeProperty("ModSettings.min", "5")
  @runtimeProperty("ModSettings.max", "50")
  public let lowLevelGap: Int32 = 20;

  @runtimeProperty("ModSettings.mod", "Weaponpunk 2077")
  @runtimeProperty("ModSettings.category", "Weapon card")
  @runtimeProperty("ModSettings.displayName", "Show card when drawing a weapon")
  @runtimeProperty("ModSettings.description", "Shows the weapon's level and XP when you draw or swap to it.")
  public let showCard: Bool = true;

  @runtimeProperty("ModSettings.mod", "Weaponpunk 2077")
  @runtimeProperty("ModSettings.category", "Weapon card")
  @runtimeProperty("ModSettings.displayName", "Card duration (seconds)")
  @runtimeProperty("ModSettings.description", "How long the card stays on screen.")
  @runtimeProperty("ModSettings.step", "0.5")
  @runtimeProperty("ModSettings.min", "1.0")
  @runtimeProperty("ModSettings.max", "10.0")
  public let cardSeconds: Float = 4.0;

  @runtimeProperty("ModSettings.mod", "Weaponpunk 2077")
  @runtimeProperty("ModSettings.category", "Weapon card")
  @runtimeProperty("ModSettings.displayName", "Compact card")
  @runtimeProperty("ModSettings.description", "When drawing a weapon, show only its name and level. The spend menu and level-ups still use the full card.")
  public let compactCard: Bool = false;

  @runtimeProperty("ModSettings.mod", "Weaponpunk 2077")
  @runtimeProperty("ModSettings.category", "Weapon card")
  @runtimeProperty("ModSettings.displayName", "Card side during play")
  @runtimeProperty("ModSettings.description", "1: left edge of the screen.  2: right edge. (In menus the card is always at the middle left.)")
  @runtimeProperty("ModSettings.step", "1")
  @runtimeProperty("ModSettings.min", "1")
  @runtimeProperty("ModSettings.max", "2")
  public let cardPosition: Int32 = 1;

  @runtimeProperty("ModSettings.mod", "Weaponpunk 2077")
  @runtimeProperty("ModSettings.category", "Weapon card")
  @runtimeProperty("ModSettings.displayName", "Card height during play")
  @runtimeProperty("ModSettings.description", "Where the card sits on the screen during play: 0 is the bottom, 100 the top. The card always stays fully on screen. Default 20 keeps it clear of the game's level-up message.")
  @runtimeProperty("ModSettings.step", "1")
  @runtimeProperty("ModSettings.min", "0")
  @runtimeProperty("ModSettings.max", "100")
  public let cardHeight: Int32 = 20;

  @runtimeProperty("ModSettings.mod", "Weaponpunk 2077")
  @runtimeProperty("ModSettings.category", "Debug")
  @runtimeProperty("ModSettings.displayName", "Debug log")
  @runtimeProperty("ModSettings.description", "Writes every counted kill and level change to the WeaponLeveling log for bug reports.")
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
