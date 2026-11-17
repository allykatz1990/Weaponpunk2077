// Weaponpunk 2077 - Weapon Leveling Enhanced - the on-screen weapon card
// Copyright (C) 2026 the Weaponpunk 2077 authors. Written with AI assistance.
//
// This program is free software: you can redistribute it and/or modify it under the terms of the
// GNU General Public License as published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version. It is distributed WITHOUT ANY WARRANTY. See the
// GNU General Public License for details: https://www.gnu.org/licenses/
//
// A small panel drawn on the game's HUD layer (through Codeware) when a weapon is drawn or levels up.
// It uses only the game's own font and plain rectangles: no custom art.

public class WLvlCardHide extends DelayCallback {
  public let sys: wref<WLvlSystem>;
  public let token: Int32;

  public func Call() -> Void {
    if IsDefined(this.sys) {
      WLvlCard.Hide(this.sys, this.token);
    }
  }
}

public abstract class WLvlCard {
  // Layout is in the HUD layer's own units (the layer is 3840 x 2160 at every resolution).
  public static func Width() -> Float { return 820.0; }
  public static func Height() -> Float { return 196.0; }

  public static func Color(r: Float, g: Float, b: Float, a: Float) -> HDRColor {
    let c: HDRColor;
    c.Red = r;
    c.Green = g;
    c.Blue = b;
    c.Alpha = a;
    return c;
  }

  // The HUD layer is hidden while a menu is open, so the card moves to the menu layer there.
  public static func Window(inMenu: Bool) -> wref<inkCompoundWidget> {
    let layer = GameInstance.GetInkSystem().GetLayer(n"inkHUDLayer");
    if inMenu {
      let menuLayer = GameInstance.GetInkSystem().GetLayer(n"inkMenuLayer");
      if IsDefined(menuLayer) {
        layer = menuLayer;
      }
    }
    if !IsDefined(layer) {
      return null;
    }
    return layer.GetVirtualWindow();
  }

  private static func RemoveFrom(win: wref<inkCompoundWidget>) -> Void {
    if !IsDefined(win) {
      return;
    }
    let old = win.GetWidgetByPathName(n"WLvlCard");
    if IsDefined(old) {
      win.RemoveChild(old);
    }
  }

  // s: overall scale of the card (it is drawn smaller in menus)
  private static func AddRect(parent: wref<inkCompoundWidget>, s: Float, x: Float, y: Float, w: Float, h: Float, c: HDRColor) -> Void {
    let r = new inkRectangle();
    r.SetAnchor(inkEAnchor.TopLeft);
    r.SetMargin(x * s, y * s, 0.0, 0.0);
    r.SetSize(w * s, h * s);
    r.SetTintColor(c);
    r.SetOpacity(c.Alpha);
    r.Reparent(parent);
  }

  private static func AddText(parent: wref<inkCompoundWidget>, s: Float, x: Float, y: Float, text: String, size: Int32, style: CName, c: HDRColor) -> Void {
    let t = new inkText();
    t.SetAnchor(inkEAnchor.TopLeft);
    t.SetMargin(x * s, y * s, 0.0, 0.0);
    t.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
    t.SetFontStyle(style);
    t.SetFontSize(RoundF(Cast<Float>(size) * s));
    t.SetTintColor(c);
    t.SetFitToContent(true);
    t.SetText(text);
    t.Reparent(parent);
  }

  // 12345 -> "12,345"
  public static func Commas(value: Int32) -> String {
    let s = IntToString(value);
    let out = "";
    let len = StrLen(s);
    let i = 0;
    while i < len {
      if i > 0 && (len - i) % 3 == 0 {
        out = out + ",";
      }
      out = out + StrMid(s, i, 1);
      i += 1;
    }
    return out;
  }

  // notice: an optional extra line at the bottom ("LEVEL UP", ...). "" for none.
  public static func Show(game: GameInstance, sys: ref<WLvlSystem>, item: ItemID, notice: String) -> Void {
    if !IsDefined(sys) || !sys.Config().showCard {
      return;
    }
    WLvlCard.ShowEx(game, sys, item, notice, "");
  }

  // The full version, used by the spend menu: a highlighted line plus a smaller line under it.
  // Always shown, even with the draw card switched off, since it is the menu's only feedback.
  public static func ShowEx(game: GameInstance, sys: ref<WLvlSystem>, item: ItemID, notice: String, hint: String) -> Void {
    if !IsDefined(sys) || !ItemID.IsValid(item) {
      return;
    }
    let inMenu = sys.InMenu();
    // smaller in menus, where space is tight, and solid so nothing shows through it
    let s = 1.0;
    let backAlpha = 0.95;
    if inMenu {
      s = 0.8;
    }
    WLvlCard.RemoveFrom(WLvlCard.Window(false));
    WLvlCard.RemoveFrom(WLvlCard.Window(true));
    let win = WLvlCard.Window(inMenu);
    if !IsDefined(win) {
      return;
    }

    sys.Settle(item);
    let level = sys.LevelOf(item);
    let xp = sys.XPOf(item);
    let cost = WLvlSystem.CostOf(level);
    let cfg = sys.Config();
    let compact = cfg.compactCard && Equals(notice, "") && Equals(hint, "");
    let w = WLvlCard.Width();
    let h = WLvlCard.Height();
    if compact {
      h = 122.0;
    }
    let boost = sys.BoostPercent();
    if compact {
      boost = 0;
    }
    if boost > 0 {
      h += 40.0;
    }
    // the shown title goes after the name at the top, in quotes
    let title = sys.ShownTitleName(item);
    let nameLine = WLvlSystem.ModelName(item);
    if NotEquals(title, "") {
      nameLine = nameLine + " " + WLvlF("WLvl-TitleQuote", title);
    }
    let nameSize = 44;
    if StrLen(nameLine) > 30 {
      nameSize = 36;
    }
    title = "";
    if NotEquals(notice, "") {
      h += 44.0;
    }
    if NotEquals(hint, "") {
      h += 40.0;
    }

    let root = new inkCanvas();
    root.SetName(n"WLvlCard");
    if inMenu {
      // left edge, halfway down: a clear spot in both the inventory and the item select screen
      root.SetAnchor(inkEAnchor.CenterLeft);
      root.SetAnchorPoint(0.0, 0.5);
      root.SetMargin(60.0, 0.0, 0.0, 0.0);
    } else {
      // during play: left or right edge, at the height set in Mod Settings (0 = bottom, 100 = top).
      // The card always stays fully on screen (the game's HUD is laid out on a 2160-pixel-tall canvas).
      let pct = Cast<Float>(Max(0, Min(100, cfg.cardHeight))) / 100.0;
      let room = MaxF(0.0, 2160.0 - h * s);
      let top = (1.0 - pct) * room;
      if cfg.cardPosition == 2 {
        root.SetAnchor(inkEAnchor.TopRight);
        root.SetAnchorPoint(1.0, 0.0);
        root.SetMargin(0.0, top, 96.0, 0.0);
      } else {
        root.SetAnchor(inkEAnchor.TopLeft);
        root.SetAnchorPoint(0.0, 0.0);
        root.SetMargin(96.0, top, 0.0, 0.0);
      }
    }
    root.SetSize(w * s, h * s);
    root.Reparent(win);

    let yellow = WLvlCard.Color(0.99, 0.93, 0.04, 1.0);
    let white = WLvlCard.Color(0.95, 0.95, 0.95, 1.0);
    let grey = WLvlCard.Color(0.62, 0.65, 0.70, 1.0);

    WLvlCard.AddRect(root, s, 0.0, 0.0, w, h, WLvlCard.Color(0.03, 0.03, 0.04, backAlpha));
    WLvlCard.AddRect(root, s, 0.0, 0.0, 8.0, h, yellow);

    WLvlCard.AddText(root, s, 30.0, 12.0, nameLine, nameSize, n"Semi-Bold", white);

    let line = WLvlF("WLvl-Card-Level", IntToString(level));
    let bonus = sys.DamageBonusPercent(level);
    if bonus > 0.0 {
      line = line + "    " + WLvlF("WLvl-Card-Damage", FloatToStringPrec(bonus, 1));
    }
    WLvlCard.AddText(root, s, 30.0, 70.0, line, 36, n"Medium", yellow);

    if !compact {
      WLvlCard.AddDetails(root, s, sys, item, xp, cost, w, title, boost, notice, hint, yellow, white, grey);
    }

    // the token changes with every card shown, so an old timer never removes a newer card
    let cb = new WLvlCardHide();
    cb.sys = sys;
    cb.token = sys.NextCardToken();
    GameInstance.GetDelaySystem(game).DelayCallback(cb, sys.Config().cardSeconds, false);
  }

  // Everything below the level line: XP bar, title, relic boost, notice and hint.
  private static func AddDetails(root: ref<inkCanvas>, s: Float, sys: ref<WLvlSystem>, item: ItemID, xp: Int32, cost: Int32, w: Float,
      title: String, boost: Int32, notice: String, hint: String, yellow: HDRColor, white: HDRColor, grey: HDRColor) -> Void {
    // XP bar
    let barW = w - 60.0;
    let fill = 0.0;
    if cost > 0 {
      fill = Cast<Float>(xp) / Cast<Float>(cost);
    }
    if fill > 1.0 {
      fill = 1.0;
    }
    WLvlCard.AddRect(root, s, 30.0, 124.0, barW, 10.0, WLvlCard.Color(0.25, 0.26, 0.29, 1.0));
    if fill > 0.0 {
      WLvlCard.AddRect(root, s, 30.0, 124.0, barW * fill, 10.0, yellow);
    }
    WLvlCard.AddText(root, s, 30.0, 142.0, WLvlF2("WLvl-Card-XP", WLvlCard.Commas(xp), WLvlCard.Commas(cost)), 30, n"Medium", grey);

    let y = 186.0;
    if NotEquals(title, "") {
      WLvlCard.AddText(root, s, 30.0, y, WLvlF("WLvl-TitleQuote", title), 30, n"Semi-Bold", yellow);
      y += 40.0;
    }
    if boost > 0 {
      WLvlCard.AddText(root, s, 30.0, y, WLvlF2("WLvl-Card-Boost", IntToString(boost), WLvlCard.Commas(sys.BoostKillsLeft())), 30, n"Medium", white);
      y += 40.0;
    }
    if NotEquals(notice, "") {
      WLvlCard.AddText(root, s, 30.0, y, notice, 32, n"Semi-Bold", yellow);
      y += 44.0;
    }
    if NotEquals(hint, "") {
      WLvlCard.AddText(root, s, 30.0, y, hint, 28, n"Medium", grey);
    }
  }

  public static func Hide(sys: wref<WLvlSystem>, token: Int32) -> Void {
    if sys.CardToken() != token {
      return;
    }
    WLvlCard.RemoveFrom(WLvlCard.Window(false));
    WLvlCard.RemoveFrom(WLvlCard.Window(true));
  }
}
