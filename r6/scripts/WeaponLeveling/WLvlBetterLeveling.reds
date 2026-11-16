// Weaponpunk 2077 - Weapon Leveling Enhanced - automatic point values from Better Leveling
// Copyright (C) 2026 the Weaponpunk 2077 authors. Written with AI assistance.
//
// This program is free software: you can redistribute it and/or modify it under the terms of the
// GNU General Public License as published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version. It is distributed WITHOUT ANY WARRANTY. See the
// GNU General Public License for details: https://www.gnu.org/licenses/
//
// Better Leveling keeps its settings as functions in BetterLevelingConfig.Settings, edited in its
// own file. This file reads them when the scripts compile, so a change there is picked up on the
// next launch. Without Better Leveling installed, the second set of functions below is used and the
// manual "Point value (percent)" setting applies.
//
// The idea: a point should be worth the same share of a full playthrough as in the base game.
// Base game: level cap 60, one perk point and one attribute point per level, 7 starting attribute
// points. If Better Leveling hands out ten times as many points, each one is worth a tenth.

@if(ModuleExists("BetterLevelingConfig"))
import BetterLevelingConfig.*

public abstract class WLvlBL {
  public static func VanillaLevelCap() -> Float { return 60.0; }
  public static func VanillaStartingAttributes() -> Float { return 7.0; }

  // Percent bounds, so an odd config can never make points worthless or wildly valuable.
  public static func Clamp(pct: Float) -> Float {
    if pct < 1.0 {
      return 1.0;
    }
    if pct > 500.0 {
      return 500.0;
    }
    return pct;
  }

  public static func PlayerLevel(game: GameInstance) -> Float {
    let player = GetPlayer(game);
    if !IsDefined(player) {
      return 0.0;
    }
    return GameInstance.GetStatsSystem(game).GetStatValue(Cast<StatsObjectID>(player.GetEntityID()), gamedataStatType.Level);
  }
}

@if(ModuleExists("BetterLevelingConfig"))
public func WLvlBLInstalled() -> Bool { return true; }

@if(!ModuleExists("BetterLevelingConfig"))
public func WLvlBLInstalled() -> Bool { return false; }

// kind 0: perk points, kind 1: attribute points. Returns the point value in percent.
@if(ModuleExists("BetterLevelingConfig"))
public func WLvlBLPointPercent(game: GameInstance, kind: Int32) -> Float {
  // With the level cap turned off there is no end point, so the player's own level stands in.
  let cap = WLvlBL.VanillaLevelCap();
  if Settings.EnableLevelCap() {
    cap = Cast<Float>(Settings.NewLevelCap());
  } else {
    cap = MaxF(cap, WLvlBL.PlayerLevel(game));
  }
  if cap < 1.0 {
    cap = 1.0;
  }

  if kind == 1 {
    let perLevel = 1.0;
    if Settings.EnableMoreAttrPerLevel() {
      perLevel = MaxF(1.0, Cast<Float>(Settings.AttrPointsPerLevel()));
    }
    let start = WLvlBL.VanillaStartingAttributes();
    if Settings.EnableStartingAttr() {
      start = Cast<Float>(Settings.StartingAttributePoints());
    }
    let vanilla = WLvlBL.VanillaLevelCap() + WLvlBL.VanillaStartingAttributes();
    return WLvlBL.Clamp(100.0 * vanilla / (cap * perLevel + start));
  }

  let perLevel = 1.0;
  if Settings.EnableMorePerkPerLevel() {
    perLevel = MaxF(1.0, Cast<Float>(Settings.PerkPointsPerLevel()));
  }
  return WLvlBL.Clamp(100.0 * WLvlBL.VanillaLevelCap() / (cap * perLevel));
}

@if(!ModuleExists("BetterLevelingConfig"))
public func WLvlBLPointPercent(game: GameInstance, kind: Int32) -> Float { return 100.0; }
