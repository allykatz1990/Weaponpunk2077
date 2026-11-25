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
    // both the main card and the dual-wield left-hand card (see ShowDual)
    let old = win.GetWidgetByPathName(n"WLvlCard");
    if IsDefined(old) {
      win.RemoveChild(old);
    }
    let old2 = win.GetWidgetByPathName(n"WLvlCard2");
    if IsDefined(old2) {
      win.RemoveChild(old2);
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

  // ================================================================ showing cards
  // Two widgets can be on screen at once: "WLvlCard" (the main card) and "WLvlCard2" (the
  // left-hand card while dual wielding, see ShowDual). Every Show / ShowEx call first removes both,
  // so there is never a stale card left behind, and one shared hide timer removes both.

  // Draw card / level-up card. notice: an optional extra line at the bottom ("LEVEL UP", ...),
  // "" for none.
  // While dual wielding during play (and with the "Both cards when dual wielding" setting on),
  // this shows BOTH hands' cards stacked instead of one: see ShowDual.
  public static func Show(game: GameInstance, sys: ref<WLvlSystem>, item: ItemID, notice: String) -> Void {
    if !IsDefined(sys) {
      return;
    }
    // CARD DIAGNOSTICS (0.6.3, debug log only). Added after players on 0.6.2 reported that XP and
    // tooltips work but the card never appears, even on a level-up. A level-up calls Show straight
    // from the kill code, so the request does happen; until now nothing on the card path wrote to
    // the log, so a player's log could not say where it stopped. Every exit point now logs a
    // "card:" line. When a report comes in, the last "card:" line before the gap is the culprit:
    //   - "card: skipped, showCard is off"      -> setting
    //   - "inMenu true" during play            -> UI_System.IsInMenu is stuck/true, so the card goes
    //                                             to the menu layer, which is hidden in gameplay
    //   - "no HUD/menu window"                  -> Codeware could not hand us the ink layer
    //   - "attached ... children N"             -> the card WAS added; the problem is position/size
    sys.DebugLog("card: show requested for " + WLvlSystem.ModelName(item) + " notice '" + notice + "', showCard "
      + ToString(sys.Config().showCard) + ", inMenu " + ToString(sys.InMenu()));
    if !sys.Config().showCard {
      sys.DebugLog("card: skipped, showCard is off");
      return;
    }
    if !sys.InMenu() && sys.Config().dualCards {
      let right = sys.RightHandItem();
      let left = sys.LeftHandItem();
      // only when the card is about one of the two guns in V's hands (a level-up from an
      // explosion credited to a holstered gun still gets the plain single card)
      if ItemID.IsValid(right) && ItemID.IsValid(left) && (item == right || item == left) {
        sys.DebugLog("card: dual-wield path (right " + WLvlSystem.ModelName(right) + ", left " + WLvlSystem.ModelName(left) + ")");
        WLvlCard.ShowDual(game, sys, right, left, item, notice);
        return;
      }
    }
    WLvlCard.ShowEx(game, sys, item, notice, "");
  }

  // DUAL-WIELD CARDS (0.6.2, requested by the mod author after a player could not see the left
  // gun's XP; see WLvlSystem.HitWeapon for that investigation).
  // Shows two cards in one column: the right-hand (main) card where the single card normally sits,
  // and the left-hand card directly ON TOP of it. Each card carries a "RIGHT HAND" / "LEFT HAND"
  // tag. `item` is the gun the card was triggered for; only its card gets the `notice` line (so
  // "LEVEL UP" appears on the gun that actually levelled, not on both).
  // Never used in menus (there the card is about the one item under the cursor) or by the spend
  // menu (which works on one weapon at a time and calls ShowEx directly).
  public static func ShowDual(game: GameInstance, sys: ref<WLvlSystem>, right: ItemID, left: ItemID, item: ItemID, notice: String) -> Void {
    WLvlCard.RemoveFrom(WLvlCard.Window(false));
    WLvlCard.RemoveFrom(WLvlCard.Window(true));
    let win = WLvlCard.Window(false);
    if !IsDefined(win) {
      sys.DebugLog("card: dual, no HUD window (inkHUDLayer or its virtual window missing), nothing drawn");
      return;
    }
    let s = WLvlCard.Scale(sys, false);
    let rightNotice = "";
    let leftNotice = "";
    if item == right {
      rightNotice = notice;
    } else {
      leftNotice = notice;
    }
    let rightCard = WLvlCard.Build(sys, right, rightNotice, "", s, WLvlT("WLvl-Card-RightHand"));
    let leftCard = WLvlCard.Build(sys, left, leftNotice, "", s, WLvlT("WLvl-Card-LeftHand"));
    rightCard.SetName(n"WLvlCard");
    leftCard.SetName(n"WLvlCard2");
    // The column is placed as one block, so the "Card height" setting moves both cards together
    // and the whole stack always stays on screen.
    // Heights come from UnscaledHeight, NOT from the widgets (see there for why).
    let gap = 16.0 * s;
    let rightH = WLvlCard.UnscaledHeight(sys, rightNotice, "") * s;
    let leftH = WLvlCard.UnscaledHeight(sys, leftNotice, "") * s;
    WLvlCard.PlaceInPlay(leftCard, sys.Config(), leftH + gap + rightH, 0.0);
    WLvlCard.PlaceInPlay(rightCard, sys.Config(), leftH + gap + rightH, leftH + gap);
    leftCard.Reparent(win);
    rightCard.Reparent(win);
    WLvlCard.LogPlaced(sys, "dual", win, rightCard, s);
    WLvlCard.StartHideTimer(game, sys);
  }

  // The full single card, used by Show (one gun) and directly by the spend menu and title awards:
  // a highlighted line plus a smaller line under it. Always shown, even with the draw card switched
  // off, since it is the spend menu's only feedback. While dual wielding the card still gets a hand
  // tag, so it's clear which of the two guns it is about.
  public static func ShowEx(game: GameInstance, sys: ref<WLvlSystem>, item: ItemID, notice: String, hint: String) -> Void {
    if !IsDefined(sys) || !ItemID.IsValid(item) {
      return;
    }
    let inMenu = sys.InMenu();
    WLvlCard.RemoveFrom(WLvlCard.Window(false));
    WLvlCard.RemoveFrom(WLvlCard.Window(true));
    let win = WLvlCard.Window(inMenu);
    if !IsDefined(win) {
      sys.DebugLog("card: no " + (inMenu ? "menu" : "HUD") + " window (ink layer or its virtual window missing), nothing drawn");
      return;
    }
    let hand = "";
    if !inMenu && ItemID.IsValid(sys.LeftHandItem()) {
      if item == sys.LeftHandItem() {
        hand = WLvlT("WLvl-Card-LeftHand");
      } else if item == sys.RightHandItem() {
        hand = WLvlT("WLvl-Card-RightHand");
      }
    }
    let s = WLvlCard.Scale(sys, inMenu);
    let root = WLvlCard.Build(sys, item, notice, hint, s, hand);
    root.SetName(n"WLvlCard");
    if inMenu {
      // left edge, halfway down: a clear spot in both the inventory and the item select screen
      root.SetAnchor(inkEAnchor.CenterLeft);
      root.SetAnchorPoint(0.0, 0.5);
      root.SetMargin(60.0, 0.0, 0.0, 0.0);
    } else {
      WLvlCard.PlaceInPlay(root, sys.Config(), WLvlCard.UnscaledHeight(sys, notice, hint) * s, 0.0);
    }
    root.Reparent(win);
    WLvlCard.LogPlaced(sys, inMenu ? "single/menu layer" : "single/HUD layer", win, root, s);
    WLvlCard.StartHideTimer(game, sys);
  }

  // Diagnostic (0.6.3): one log line after a card is attached, with where it went. If this line
  // shows up but the player still sees nothing, the widget exists and the problem is placement,
  // size or the layer being hidden, not the trigger. Debug log only (DebugLog checks the setting).
  private static func LogPlaced(sys: ref<WLvlSystem>, path: String, win: wref<inkCompoundWidget>, root: ref<inkCanvas>, s: Float) -> Void {
    if !sys.Config().debugLog {
      return;
    }
    let m = root.GetMargin();
    let size = root.GetSize();
    sys.DebugLog("card: attached (" + path + "), window children " + IntToString(win.GetNumChildren())
      + ", margin L" + FloatToStringPrec(m.left, 0) + " T" + FloatToStringPrec(m.top, 0) + " R" + FloatToStringPrec(m.right, 0)
      + ", size " + FloatToStringPrec(size.X, 0) + "x" + FloatToStringPrec(size.Y, 0) + ", scale " + FloatToStringPrec(s, 2)
      + ", visible " + ToString(win.IsVisible()) + ", hide in " + FloatToStringPrec(sys.Config().cardSeconds, 1) + "s");
  }

  // `s`, the card's overall scale. Every size in Build is written for s = 1.0 and multiplied by s
  // when drawn (see AddRect / AddText), so changing s resizes the whole card evenly.
  // It starts from the player's "Card size" setting (cardScale, a percent, clamped here in case
  // the config was edited by hand); menus draw the card at 80% of that, where space is tight.
  private static func Scale(sys: ref<WLvlSystem>, inMenu: Bool) -> Float {
    let s = Cast<Float>(Max(50, Min(150, sys.Config().cardScale))) / 100.0;
    if inMenu {
      s *= 0.8;
    }
    return s;
  }

  // Places a card during play: left or right edge (cardPosition), at the height set in Mod
  // Settings (cardHeight: 0 = bottom, 100 = top).
  // stackH: total height (already scaled) of everything placed as one block: the card's own height
  //   for a single card, both cards plus the gap for the dual-wield column.
  // offsetY: how far below the top of that block this card goes (0 for the top card).
  // The block always stays fully on screen (the game's HUD is laid out on a 2160-pixel-tall
  // canvas).
  private static func PlaceInPlay(root: ref<inkCanvas>, cfg: ref<WLvlConfig>, stackH: Float, offsetY: Float) -> Void {
    let pct = Cast<Float>(Max(0, Min(100, cfg.cardHeight))) / 100.0;
    let room = MaxF(0.0, 2160.0 - stackH);
    let top = (1.0 - pct) * room;
    if cfg.cardPosition == 2 {
      root.SetAnchor(inkEAnchor.TopRight);
      root.SetAnchorPoint(1.0, 0.0);
      root.SetMargin(0.0, top + offsetY, 96.0, 0.0);
    } else {
      root.SetAnchor(inkEAnchor.TopLeft);
      root.SetAnchorPoint(0.0, 0.0);
      root.SetMargin(96.0, top + offsetY, 0.0, 0.0);
    }
  }

  // The hide timer. The token changes with every card shown, so an old timer never removes a
  // newer card; Hide removes both card widgets.
  private static func StartHideTimer(game: GameInstance, sys: ref<WLvlSystem>) -> Void {
    let cb = new WLvlCardHide();
    cb.sys = sys;
    cb.token = sys.NextCardToken();
    GameInstance.GetDelaySystem(game).DelayCallback(cb, sys.Config().cardSeconds, false);
  }

  // A card's height in unscaled units (multiply by s for screen units). Kept in its own function
  // so Build and the dual-wield column use exactly the same number.
  // Why not just ask the built widget (GetSize)? Tested in 0.6.2: a widget that has not been
  // through the game's layout pass yet reports a height of 0, so both dual-wield cards ended up
  // in the same spot, overlapping. Always compute the height here instead.
  // If you add a line to the card in Build or AddDetails, add its height here too.
  public static func UnscaledHeight(sys: ref<WLvlSystem>, notice: String, hint: String) -> Float {
    let cfg = sys.Config();
    let compact = cfg.compactCard && Equals(notice, "") && Equals(hint, "");
    let h = WLvlCard.Height();
    if compact {
      return 122.0;   // name + level line only (compact never has a notice or hint)
    }
    if sys.BoostPercent() > 0 {
      h += 40.0;      // relic XP boost line
    }
    if NotEquals(notice, "") {
      h += 44.0;      // notice line ("LEVEL UP", ...)
    }
    if NotEquals(hint, "") {
      h += 40.0;      // hint line (spend menu)
    }
    return h;
  }

  // Builds one card (not yet placed or attached to a window) and returns it, sized to its content.
  // This is the old body of ShowEx, split out in 0.6.2 so the dual-wield column can build two.
  // hand: "" for no hand tag, otherwise the text shown at the right end of the level line.
  private static func Build(sys: ref<WLvlSystem>, item: ItemID, notice: String, hint: String, s: Float, hand: String) -> ref<inkCanvas> {
    let backAlpha = 0.95;   // solid, so nothing shows through the card
    sys.Settle(item);
    let level = sys.LevelOf(item);
    let xp = sys.XPOf(item);
    let cost = WLvlSystem.CostOf(level);
    let cfg = sys.Config();
    let compact = cfg.compactCard && Equals(notice, "") && Equals(hint, "");
    let w = WLvlCard.Width();
    let h = WLvlCard.UnscaledHeight(sys, notice, hint);
    let boost = sys.BoostPercent();
    if compact {
      boost = 0;
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

    let root = new inkCanvas();
    root.SetSize(w * s, h * s);

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

    // hand tag: right-aligned on the level line, which leaves room even for long gun names on
    // the name line above. Grey, so it reads as a label rather than a stat.
    if NotEquals(hand, "") {
      WLvlCard.AddTextRight(root, s, 30.0, 76.0, hand, 28, n"Semi-Bold", grey);
    }

    if !compact {
      WLvlCard.AddDetails(root, s, sys, item, xp, cost, w, title, boost, notice, hint, yellow, white, grey);
    }
    return root;
  }

  // Like AddText, but measured from the card's RIGHT edge: x is the gap between the text's right
  // end and the card's right edge. Used for the hand tag (0.6.2).
  private static func AddTextRight(parent: wref<inkCompoundWidget>, s: Float, x: Float, y: Float, text: String, size: Int32, style: CName, c: HDRColor) -> Void {
    let t = new inkText();
    t.SetAnchor(inkEAnchor.TopRight);
    t.SetAnchorPoint(1.0, 0.0);
    t.SetMargin(0.0, y * s, x * s, 0.0);
    t.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
    t.SetFontStyle(style);
    t.SetFontSize(RoundF(Cast<Float>(size) * s));
    t.SetTintColor(c);
    t.SetFitToContent(true);
    t.SetText(text);
    t.Reparent(parent);
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
    sys.DebugLog("card: hidden by timer (token " + IntToString(token) + ")");
    WLvlCard.RemoveFrom(WLvlCard.Window(false));
    WLvlCard.RemoveFrom(WLvlCard.Window(true));
  }
}
