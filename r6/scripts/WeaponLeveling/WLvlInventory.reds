// Weaponpunk 2077 - Weapon Leveling Enhanced - inventory hooks: which weapon is highlighted, and the tooltip line
// Copyright (C) 2026 the Weaponpunk 2077 authors. Written with AI assistance.
//
// This program is free software: you can redistribute it and/or modify it under the terms of the
// GNU General Public License as published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version. It is distributed WITHOUT ANY WARRANTY. See the
// GNU General Public License for details: https://www.gnu.org/licenses/
//
// All hooks wrap the original function, so other mods' changes to the same function still run.

// ---- which item is highlighted (mouse hover or controller selection), for the spend menu
@wrapMethod(InventoryItemDisplayController)
protected cb func OnDelayedHoverOver(proxy: ref<inkAnimProxy>) -> Bool {
  // make sure the item carries its level bonuses before the tooltip reads its stats
  let pre = WLvlSystem.Get(GetGameInstance());
  if IsDefined(pre) {
    pre.EnsureLevelStats(this.GetItemID());
  }
  let result = wrappedMethod(proxy);
  let sys = WLvlSystem.Get(GetGameInstance());
  if IsDefined(sys) {
    let item = this.GetItemID();
    let uiItem = this.GetUIInventoryItem();
    if IsDefined(uiItem) {
      item = uiItem.GetID();
    }
    sys.SetHovered(item);
  }
  return result;
}

@wrapMethod(InventoryItemDisplayController)
protected cb func OnDisplayHoverOut(evt: ref<inkPointerEvent>) -> Bool {
  let result = wrappedMethod(evt);
  let sys = WLvlSystem.Get(GetGameInstance());
  if IsDefined(sys) {
    sys.ClearHovered();
  }
  return result;
}

// ---- the tooltip: weapon level and XP go on their own line under the item type
public abstract class WLvlTooltip {
  // The tooltip's name line gets the gun's shown title after it, for example: D5 Copperhead "Doom Slayer".
  public static func AddTitle(nameText: inkTextRef, item: ItemID) -> Void {
    let sys = WLvlSystem.Get(GetGameInstance());
    if !IsDefined(sys) {
      return;
    }
    sys.SetTooltipItem(item);
    let title = sys.ShownTitleName(item);
    if Equals(title, "") {
      return;
    }
    let name = inkTextRef.GetText(nameText);
    let quoted = WLvlF("WLvl-TitleQuote", title);
    if !StrContains(name, quoted) {
      inkTextRef.SetText(nameText, name + " " + quoted);
    }
  }
  // "" when the item is not something this mod levels
  public static func Suffix(item: ItemID) -> String {
    let sys = WLvlSystem.Get(GetGameInstance());
    if !IsDefined(sys) || !sys.Config().enabled || !sys.IsLevelable(item) {
      return "";
    }
    sys.Settle(item);
    let level = sys.LevelOf(item);
    let text = "\n" + WLvlF3("WLvl-Tip-Level", IntToString(level), WLvlCard.Commas(sys.XPOf(item)), WLvlCard.Commas(WLvlSystem.CostOf(level)));
    let perk = sys.SpentPerk(item);
    let attr = sys.SpentAttribute(item);
    if perk > 0 || attr > 0 {
      text = text + "\n" + WLvlF2("WLvl-Tip-Spent", WLvlCard.Commas(perk), WLvlCard.Commas(attr));
    }
    return text;
  }
}

@wrapMethod(NewItemTooltipHeaderController)
public func Update(data: ref<MinimalItemTooltipData>) -> Void {
  wrappedMethod(data);
  if !IsDefined(data) || data.isBroken || Equals(data.itemType, gamedataItemType.Wea_Fists) {
    return;
  }
  WLvlTooltip.AddTitle(this.m_itemNameText, data.itemID);
  let suffix = WLvlTooltip.Suffix(data.itemID);
  if Equals(suffix, "") {
    return;
  }
  let key = UIItemsHelper.GetItemTypeKey(data.itemData, data.equipmentArea, data.itemTweakID, data.itemType, data.itemEvolution);
  inkTextRef.SetText(this.m_itemTypeText, GetLocalizedText(key) + suffix);
}

@wrapMethod(NewItemTooltipHeaderController)
public final func NEW_Update(data: wref<UIInventoryItem>, comparisonData: wref<UIInventoryItemComparisonManager>) -> Void {
  wrappedMethod(data, comparisonData);
  if !IsDefined(data) || data.IsBroken() || Equals(data.GetItemType(), gamedataItemType.Wea_Fists) {
    return;
  }
  WLvlTooltip.AddTitle(this.m_itemNameText, data.GetID());
  let suffix = WLvlTooltip.Suffix(data.GetID());
  if Equals(suffix, "") {
    return;
  }
  let key = UIItemsHelper.GetItemTypeKey(data.GetRealItemData(), data.GetEquipmentArea(), data.GetTweakDBID(), data.GetItemType(), data.GetWeaponEvolution());
  inkTextRef.SetText(this.m_itemTypeText, GetLocalizedText(key) + suffix);
}

// The gun's titles and what they do, as extra lines in the tooltip's bonus list (where the weapon's
// own bonuses like headshot damage are listed).
@addMethod(ItemTooltipStatController)
public func WLvlSetLine(text: String) -> Void {
  inkTextRef.SetText(this.m_statName, text);
  inkTextRef.SetText(this.m_statValue, "");
  inkWidgetRef.SetVisible(this.m_statComparedContainer, false);
  inkWidgetRef.SetVisible(this.m_arrow, false);
}

@addMethod(NewItemTooltipDetailsStatsModule)
private func WLvlAddTitleLines(item: ItemID) -> Void {
  let sys = WLvlSystem.Get(GetGameInstance());
  if !IsDefined(sys) {
    return;
  }
  let lines = sys.TitleLineList(item);
  let i = 0;
  while i < ArraySize(lines) {
    let widget = this.SpawnFromLocal(inkWidgetRef.Get(this.m_statsContainer), n"itemDetailsStat");
    let controller = widget.GetController() as ItemTooltipStatController;
    if IsDefined(controller) {
      controller.WLvlSetLine(lines[i]);
    }
    i += 1;
  }
}

@wrapMethod(NewItemTooltipDetailsStatsModule)
public func NEW_Update(data: wref<UIInventoryItem>) -> Void {
  wrappedMethod(data);
  if IsDefined(data) {
    this.WLvlAddTitleLines(data.GetID());
  }
}

@wrapMethod(NewItemTooltipDetailsStatsModule)
public func Update(data: ref<MinimalItemTooltipData>) -> Void {
  wrappedMethod(data);
  if IsDefined(data) {
    this.WLvlAddTitleLines(data.itemID);
  }
}
