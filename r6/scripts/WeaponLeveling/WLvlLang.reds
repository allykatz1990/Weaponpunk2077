// Weaponpunk 2077 - Weapon Leveling Enhanced - text and translations
// Copyright (C) 2026 the Weaponpunk 2077 authors. Written with AI assistance. GPL-3.0-or-later.
//
// Every piece of text the mod shows goes through a key (for example "WLvl-Card-LevelUp"), so it
// can be translated. English is below. Translations are separate add-on files: see TRANSLATING.md
// in the translation kit. Any key a translation leaves out is shown in English.
//
// Placeholders: {0}, {1} and {2} are filled in by the mod (numbers, names, titles). Keep them.

import Codeware.Localization.*

@if(ModuleExists("WeaponpunkLang.fr_fr"))
import WeaponpunkLang.fr_fr.*

@if(ModuleExists("WeaponpunkLang.de_de"))
import WeaponpunkLang.de_de.*

@if(ModuleExists("WeaponpunkLang.es_es"))
import WeaponpunkLang.es_es.*

@if(ModuleExists("WeaponpunkLang.es_mx"))
import WeaponpunkLang.es_mx.*

@if(ModuleExists("WeaponpunkLang.it_it"))
import WeaponpunkLang.it_it.*

@if(ModuleExists("WeaponpunkLang.pl_pl"))
import WeaponpunkLang.pl_pl.*

@if(ModuleExists("WeaponpunkLang.pt_br"))
import WeaponpunkLang.pt_br.*

@if(ModuleExists("WeaponpunkLang.ru_ru"))
import WeaponpunkLang.ru_ru.*

@if(ModuleExists("WeaponpunkLang.ua_ua"))
import WeaponpunkLang.ua_ua.*

@if(ModuleExists("WeaponpunkLang.jp_jp"))
import WeaponpunkLang.jp_jp.*

@if(ModuleExists("WeaponpunkLang.kr_kr"))
import WeaponpunkLang.kr_kr.*

@if(ModuleExists("WeaponpunkLang.zh_cn"))
import WeaponpunkLang.zh_cn.*

@if(ModuleExists("WeaponpunkLang.zh_tw"))
import WeaponpunkLang.zh_tw.*

@if(ModuleExists("WeaponpunkLang.cz_cz"))
import WeaponpunkLang.cz_cz.*

@if(ModuleExists("WeaponpunkLang.hu_hu"))
import WeaponpunkLang.hu_hu.*

@if(ModuleExists("WeaponpunkLang.tr_tr"))
import WeaponpunkLang.tr_tr.*

@if(ModuleExists("WeaponpunkLang.th_th"))
import WeaponpunkLang.th_th.*

@if(ModuleExists("WeaponpunkLang.ar_ar"))
import WeaponpunkLang.ar_ar.*

// ------------------------------------------------------------------ text lookup

// The text for a key in the player's language (English if there is no translation).
public func WLvlT(key: String) -> String {
  let loc = LocalizationSystem.GetInstance(GetGameInstance());
  if IsDefined(loc) {
    let text = loc.GetText(key);
    if NotEquals(text, key) && StrLen(text) > 0 {
      return text;
    }
  }
  // before Codeware's system is ready: the game's own lookup, then the built-in English
  let native = GetLocalizedTextByKey(StringToName(key));
  if StrLen(native) > 0 {
    return native;
  }
  return WLvlLang_en_us.English(key);
}

public func WLvlF(key: String, a: String) -> String {
  return StrReplace(WLvlT(key), "{0}", a);
}

public func WLvlF2(key: String, a: String, b: String) -> String {
  return StrReplace(StrReplace(WLvlT(key), "{0}", a), "{1}", b);
}

public func WLvlF3(key: String, a: String, b: String, c: String) -> String {
  return StrReplace(StrReplace(StrReplace(WLvlT(key), "{0}", a), "{1}", b), "{2}", c);
}

// ------------------------------------------------------------------ languages

// Tells Codeware which package holds each language. English is the fallback for anything missing.
public class WLvlLangProvider extends ModLocalizationProvider {
  public func GetPackage(language: CName) -> ref<ModLocalizationPackage> {
    switch language {
      case n"en-us": return new WLvlLang_en_us();
      case n"fr-fr": return WLvlPack_fr_fr();   // French
      case n"de-de": return WLvlPack_de_de();   // German
      case n"es-es": return WLvlPack_es_es();   // Spanish (Spain)
      case n"es-mx": return WLvlPack_es_mx();   // Spanish (Latin America)
      case n"it-it": return WLvlPack_it_it();   // Italian
      case n"pl-pl": return WLvlPack_pl_pl();   // Polish
      case n"pt-br": return WLvlPack_pt_br();   // Portuguese (Brazil)
      case n"ru-ru": return WLvlPack_ru_ru();   // Russian
      case n"ua-ua": return WLvlPack_ua_ua();   // Ukrainian
      case n"jp-jp": return WLvlPack_jp_jp();   // Japanese
      case n"kr-kr": return WLvlPack_kr_kr();   // Korean
      case n"zh-cn": return WLvlPack_zh_cn();   // Chinese (Simplified)
      case n"zh-tw": return WLvlPack_zh_tw();   // Chinese (Traditional)
      case n"cz-cz": return WLvlPack_cz_cz();   // Czech
      case n"hu-hu": return WLvlPack_hu_hu();   // Hungarian
      case n"tr-tr": return WLvlPack_tr_tr();   // Turkish
      case n"th-th": return WLvlPack_th_th();   // Thai
      case n"ar-ar": return WLvlPack_ar_ar();   // Arabic
    }
    return null;
  }

  public func GetFallback() -> CName {
    return n"en-us";
  }
}

// A translation add-on is found when it is installed (its module exists); otherwise there is none.
@if(ModuleExists("WeaponpunkLang.fr_fr"))
public func WLvlPack_fr_fr() -> ref<ModLocalizationPackage> { return new WLvlLang_fr_fr(); }
@if(!ModuleExists("WeaponpunkLang.fr_fr"))
public func WLvlPack_fr_fr() -> ref<ModLocalizationPackage> { return null; }
@if(ModuleExists("WeaponpunkLang.de_de"))
public func WLvlPack_de_de() -> ref<ModLocalizationPackage> { return new WLvlLang_de_de(); }
@if(!ModuleExists("WeaponpunkLang.de_de"))
public func WLvlPack_de_de() -> ref<ModLocalizationPackage> { return null; }
@if(ModuleExists("WeaponpunkLang.es_es"))
public func WLvlPack_es_es() -> ref<ModLocalizationPackage> { return new WLvlLang_es_es(); }
@if(!ModuleExists("WeaponpunkLang.es_es"))
public func WLvlPack_es_es() -> ref<ModLocalizationPackage> { return null; }
@if(ModuleExists("WeaponpunkLang.es_mx"))
public func WLvlPack_es_mx() -> ref<ModLocalizationPackage> { return new WLvlLang_es_mx(); }
@if(!ModuleExists("WeaponpunkLang.es_mx"))
public func WLvlPack_es_mx() -> ref<ModLocalizationPackage> { return null; }
@if(ModuleExists("WeaponpunkLang.it_it"))
public func WLvlPack_it_it() -> ref<ModLocalizationPackage> { return new WLvlLang_it_it(); }
@if(!ModuleExists("WeaponpunkLang.it_it"))
public func WLvlPack_it_it() -> ref<ModLocalizationPackage> { return null; }
@if(ModuleExists("WeaponpunkLang.pl_pl"))
public func WLvlPack_pl_pl() -> ref<ModLocalizationPackage> { return new WLvlLang_pl_pl(); }
@if(!ModuleExists("WeaponpunkLang.pl_pl"))
public func WLvlPack_pl_pl() -> ref<ModLocalizationPackage> { return null; }
@if(ModuleExists("WeaponpunkLang.pt_br"))
public func WLvlPack_pt_br() -> ref<ModLocalizationPackage> { return new WLvlLang_pt_br(); }
@if(!ModuleExists("WeaponpunkLang.pt_br"))
public func WLvlPack_pt_br() -> ref<ModLocalizationPackage> { return null; }
@if(ModuleExists("WeaponpunkLang.ru_ru"))
public func WLvlPack_ru_ru() -> ref<ModLocalizationPackage> { return new WLvlLang_ru_ru(); }
@if(!ModuleExists("WeaponpunkLang.ru_ru"))
public func WLvlPack_ru_ru() -> ref<ModLocalizationPackage> { return null; }
@if(ModuleExists("WeaponpunkLang.ua_ua"))
public func WLvlPack_ua_ua() -> ref<ModLocalizationPackage> { return new WLvlLang_ua_ua(); }
@if(!ModuleExists("WeaponpunkLang.ua_ua"))
public func WLvlPack_ua_ua() -> ref<ModLocalizationPackage> { return null; }
@if(ModuleExists("WeaponpunkLang.jp_jp"))
public func WLvlPack_jp_jp() -> ref<ModLocalizationPackage> { return new WLvlLang_jp_jp(); }
@if(!ModuleExists("WeaponpunkLang.jp_jp"))
public func WLvlPack_jp_jp() -> ref<ModLocalizationPackage> { return null; }
@if(ModuleExists("WeaponpunkLang.kr_kr"))
public func WLvlPack_kr_kr() -> ref<ModLocalizationPackage> { return new WLvlLang_kr_kr(); }
@if(!ModuleExists("WeaponpunkLang.kr_kr"))
public func WLvlPack_kr_kr() -> ref<ModLocalizationPackage> { return null; }
@if(ModuleExists("WeaponpunkLang.zh_cn"))
public func WLvlPack_zh_cn() -> ref<ModLocalizationPackage> { return new WLvlLang_zh_cn(); }
@if(!ModuleExists("WeaponpunkLang.zh_cn"))
public func WLvlPack_zh_cn() -> ref<ModLocalizationPackage> { return null; }
@if(ModuleExists("WeaponpunkLang.zh_tw"))
public func WLvlPack_zh_tw() -> ref<ModLocalizationPackage> { return new WLvlLang_zh_tw(); }
@if(!ModuleExists("WeaponpunkLang.zh_tw"))
public func WLvlPack_zh_tw() -> ref<ModLocalizationPackage> { return null; }
@if(ModuleExists("WeaponpunkLang.cz_cz"))
public func WLvlPack_cz_cz() -> ref<ModLocalizationPackage> { return new WLvlLang_cz_cz(); }
@if(!ModuleExists("WeaponpunkLang.cz_cz"))
public func WLvlPack_cz_cz() -> ref<ModLocalizationPackage> { return null; }
@if(ModuleExists("WeaponpunkLang.hu_hu"))
public func WLvlPack_hu_hu() -> ref<ModLocalizationPackage> { return new WLvlLang_hu_hu(); }
@if(!ModuleExists("WeaponpunkLang.hu_hu"))
public func WLvlPack_hu_hu() -> ref<ModLocalizationPackage> { return null; }
@if(ModuleExists("WeaponpunkLang.tr_tr"))
public func WLvlPack_tr_tr() -> ref<ModLocalizationPackage> { return new WLvlLang_tr_tr(); }
@if(!ModuleExists("WeaponpunkLang.tr_tr"))
public func WLvlPack_tr_tr() -> ref<ModLocalizationPackage> { return null; }
@if(ModuleExists("WeaponpunkLang.th_th"))
public func WLvlPack_th_th() -> ref<ModLocalizationPackage> { return new WLvlLang_th_th(); }
@if(!ModuleExists("WeaponpunkLang.th_th"))
public func WLvlPack_th_th() -> ref<ModLocalizationPackage> { return null; }
@if(ModuleExists("WeaponpunkLang.ar_ar"))
public func WLvlPack_ar_ar() -> ref<ModLocalizationPackage> { return new WLvlLang_ar_ar(); }
@if(!ModuleExists("WeaponpunkLang.ar_ar"))
public func WLvlPack_ar_ar() -> ref<ModLocalizationPackage> { return null; }

// ------------------------------------------------------------------ English

public class WLvlLang_en_us extends ModLocalizationPackage {
  // The English text for a key, without Codeware (used only before its system is ready).
  public static func English(key: String) -> String {
    let pack = new WLvlLang_en_us();
    let values = pack.GetEntriesList(EntryType.Interface);
    for value in values {
      let entry = value as LocalizationEntry;
      if Equals(entry.GetKey(), key) {
        return entry.GetVariant(PlayerGender.Default);
      }
    }
    return key;
  }

  protected func DefineTexts() -> Void {
    // ---- Weapon card
    this.Text("WLvl-Card-LevelUp", "LEVEL UP");
    this.Text("WLvl-Card-NewTitle", "NEW TITLE: \"{0}\"");
    this.Text("WLvl-Card-Level", "LEVEL {0}");
    this.Text("WLvl-Card-LeftHand", "LEFT HAND");
    this.Text("WLvl-Card-RightHand", "RIGHT HAND");
    this.Text("WLvl-Card-Damage", "+{0}% damage");
    this.Text("WLvl-Card-XP", "{0} / {1} XP");
    this.Text("WLvl-Card-Boost", "XP BOOST +{0}%    {1} kills left");

    // ---- Messages on the card when spending or refunding points
    this.Text("WLvl-Msg-ReachedLevel", "{0} reached weapon level {1}");
    this.Text("WLvl-Msg-NoRead", "Could not read your points");
    this.Text("WLvl-Msg-NoPerk", "No perk points to spend");
    this.Text("WLvl-Msg-NoAttr", "No attribute points to spend");
    this.Text("WLvl-Msg-NoRelic", "No relic points to spend");
    this.Text("WLvl-Msg-Left", "{0} left");
    this.Text("WLvl-Msg-BoostBought", "XP boost bought  ({0})");
    this.Text("WLvl-Msg-XPGained", "+{0} XP  ({1})");
    this.Text("WLvl-Msg-LevelUpPrefix", "LEVEL UP   {0}");
    this.Text("WLvl-Msg-NothingSpent", "No points have been spent on this weapon");
    this.Text("WLvl-Msg-Refunded", "Refunded {0} perk, {1} attribute points");

    // ---- Spend menu options
    this.Text("WLvl-Menu-Relic", "Relic point  (+{0}% kill XP, {1} kills)");
    this.Text("WLvl-Menu-Refund", "Refund this weapon's points");
    this.Text("WLvl-Menu-Attr", "Attribute points x{0}  (+{1} XP)");
    this.Text("WLvl-Menu-Perk", "Perk points x{0}  (+{1} XP)");

    // ---- Help line under the spend menu
    this.Text("WLvl-Hint-ChangePad", "Tap to change, hold to use");
    this.Text("WLvl-Hint-ChangeKeys", "Next option to change, Confirm to use");
    this.Text("WLvl-Hint-FirstPad", "Hold again to use, tap to change");
    this.Text("WLvl-Hint-FirstKeys", "Confirm again to use, Next option to change");
    this.Text("WLvl-Hint-SurePad", "Are you sure? Hold again to confirm");
    this.Text("WLvl-Hint-SureKeys", "Are you sure? Press Confirm again");

    // ---- Inventory tooltip
    this.Text("WLvl-Tip-Also", "Also: {0}");
    this.Text("WLvl-Tip-LeftHandFeats", "In the left hand: feat bonuses are off");
    this.Text("WLvl-Tip-LostOnSale", "Titles are lost if sold or dismantled.");
    this.Text("WLvl-Tip-LeftHandTitles", "In the left hand: title bonuses are off");
    this.Text("WLvl-Tip-Level", "LVL {0}   {1} / {2} XP");
    this.Text("WLvl-Tip-Spent", "({0} perk, {1} attribute pts)");

    // ---- Quote marks around a title after a gun's name ({0} = the title)
    this.Text("WLvl-TitleQuote", "\"{0}\"");

    // ---- What a title does (tooltip)
    this.Text("WLvl-Effect-Faction", "+{0}% damage against {1}");
    this.Text("WLvl-Effect-Carma", "+{0}% damage to vehicles, mechs and drones");
    this.Text("WLvl-Effect-Psycho", "+{0}% damage to cyberpsychos and MaxTac");
    this.Text("WLvl-Effect-Karen", "+{0}% damage against anyone who hurt you first");

    // ---- Faction names, used in "+{0}% damage against {1}"
    this.Text("WLvl-Faction-0", "Arasaka");
    this.Text("WLvl-Faction-1", "the Tyger Claws");
    this.Text("WLvl-Faction-2", "Maelstrom");
    this.Text("WLvl-Faction-3", "the Scavengers");
    this.Text("WLvl-Faction-4", "the Voodoo Boys");
    this.Text("WLvl-Faction-5", "the 6th Street");
    this.Text("WLvl-Faction-6", "the Valentinos");
    this.Text("WLvl-Faction-7", "the Animals");
    this.Text("WLvl-Faction-8", "Militech");
    this.Text("WLvl-Faction-9", "the Barghest");
    this.Text("WLvl-Faction-10", "the Wraiths");
    this.Text("WLvl-Faction-11", "NUSA and the FIA");
    this.Text("WLvl-Faction-12", "the NCPD");
    this.Text("WLvl-Faction-13", "MaxTac");
    this.Text("WLvl-Faction-14", "NetWatch");
    this.Text("WLvl-Faction-15", "Kang Tao");

    // ---- Faction titles: tier 1, 2, 3 for each faction (same order as the faction names)
    this.Text("WLvl-FactionTitle-0-1", "Suit Piercer");
    this.Text("WLvl-FactionTitle-0-2", "Saka Wrecker");
    this.Text("WLvl-FactionTitle-0-3", "Tower Toppler");
    this.Text("WLvl-FactionTitle-1-1", "Street Sweeper");
    this.Text("WLvl-FactionTitle-1-2", "Claw Clipper");
    this.Text("WLvl-FactionTitle-1-3", "Neon Requiem");
    this.Text("WLvl-FactionTitle-2-1", "Chrome Crusher");
    this.Text("WLvl-FactionTitle-2-2", "Borg Shredder");
    this.Text("WLvl-FactionTitle-2-3", "Rust Maker");
    this.Text("WLvl-FactionTitle-3-1", "Vulture Killer");
    this.Text("WLvl-FactionTitle-3-2", "Harvester Hunter");
    this.Text("WLvl-FactionTitle-3-3", "Last Harvest");
    this.Text("WLvl-FactionTitle-4-1", "Proxy Piercer");
    this.Text("WLvl-FactionTitle-4-2", "Daemon Slayer");
    this.Text("WLvl-FactionTitle-4-3", "Chapel Burner");
    this.Text("WLvl-FactionTitle-5-1", "Flag Burner");
    this.Text("WLvl-FactionTitle-5-2", "Militia Mauler");
    this.Text("WLvl-FactionTitle-5-3", "Patriot's End");
    this.Text("WLvl-FactionTitle-6-1", "Halo Breaker");
    this.Text("WLvl-FactionTitle-6-2", "Altar Stainer");
    this.Text("WLvl-FactionTitle-6-3", "Deicide");
    this.Text("WLvl-FactionTitle-7-1", "Juice Drainer");
    this.Text("WLvl-FactionTitle-7-2", "Behemoth Breaker");
    this.Text("WLvl-FactionTitle-7-3", "Apex Extinction");
    this.Text("WLvl-FactionTitle-8-1", "Flak Shredder");
    this.Text("WLvl-FactionTitle-8-2", "Convoy Crusher");
    this.Text("WLvl-FactionTitle-8-3", "The General's Grave");
    this.Text("WLvl-FactionTitle-9-1", "Hound Hunter");
    this.Text("WLvl-FactionTitle-9-2", "Pack Breaker");
    this.Text("WLvl-FactionTitle-9-3", "Dogtown's Reckoning");
    this.Text("WLvl-FactionTitle-10-1", "Raffen Reaper");
    this.Text("WLvl-FactionTitle-10-2", "Shiv Snapper");
    this.Text("WLvl-FactionTitle-10-3", "Dust to Dust");
    this.Text("WLvl-FactionTitle-11-1", "Spook Hunter");
    this.Text("WLvl-FactionTitle-11-2", "Agency Eraser");
    this.Text("WLvl-FactionTitle-11-3", "State of Disunion");
    this.Text("WLvl-FactionTitle-12-1", "Siren Silencer");
    this.Text("WLvl-FactionTitle-12-2", "Badge Breaker");
    this.Text("WLvl-FactionTitle-12-3", "Precinct Purger");
    this.Text("WLvl-FactionTitle-13-1", "Mantis Clipper");
    this.Text("WLvl-FactionTitle-13-2", "Squad Wiper");
    this.Text("WLvl-FactionTitle-13-3", "Uncontainable");
    this.Text("WLvl-FactionTitle-14-1", "Trace Severer");
    this.Text("WLvl-FactionTitle-14-2", "Watcher Killer");
    this.Text("WLvl-FactionTitle-14-3", "The Blind Spot");
    this.Text("WLvl-FactionTitle-15-1", "Smart Jammer");
    this.Text("WLvl-FactionTitle-15-2", "Dragon Slayer");
    this.Text("WLvl-FactionTitle-15-3", "Kang Tao's Collapse");

    // ---- Vehicle titles
    this.Text("WLvl-Carma-1", "Carmageddon I");
    this.Text("WLvl-Carma-2", "Carmageddon II");
    this.Text("WLvl-Carma-3", "Carmageddon III");

    // ---- Cyberpsycho titles
    this.Text("WLvl-Psycho-1", "Psychosquad Leader I");
    this.Text("WLvl-Psycho-2", "Psychosquad Leader II");
    this.Text("WLvl-Psycho-3", "Psychosquad Leader III");

    // ---- "Who started it" titles
    this.Text("WLvl-Karen-1", "Karen Slayer");
    this.Text("WLvl-Karen-2", "Karen Slayer II");
    this.Text("WLvl-Karen-3", "Karen Slayer III");

    // ---- Feat titles
    this.Text("WLvl-Feat-0", "Lead Storm");
    this.Text("WLvl-Feat-1", "Reaper's Tempo");
    this.Text("WLvl-Feat-2", "Bullet Hell Sovereign");
    this.Text("WLvl-Feat-3", "Doom Slayer");
    this.Text("WLvl-Feat-4", "Smart Bomb");
    this.Text("WLvl-Feat-5", "Untouchable");
    this.Text("WLvl-Feat-6", "Ghost Protocol");
    this.Text("WLvl-Feat-7", "Tactical Espionage");
    this.Text("WLvl-Feat-8", "Snake Eater");

    // ---- What each feat does (same order as the feat titles)
    this.Text("WLvl-FeatNote-0", "Berserker: 5 kills in 5 s, +5% damage per stack (3 max)");
    this.Text("WLvl-FeatNote-1", "Berserker: 5 kills in 5 s, +5% damage per stack (4 max)");
    this.Text("WLvl-FeatNote-2", "Berserker: 5 kills in 5 s, +5% damage per stack (5 max)");
    this.Text("WLvl-FeatNote-3", "Kills heal 2% health");
    this.Text("WLvl-FeatNote-4", "+25% explosion damage");
    this.Text("WLvl-FeatNote-5", "10% less damage taken");
    this.Text("WLvl-FeatNote-6", "+25% damage to unaware enemies");
    this.Text("WLvl-FeatNote-7", "+50% weapon XP from stealth kills");
    this.Text("WLvl-FeatNote-8", "Healing items heal 5% more health");

    // ---- Trophy titles for named enemies
    this.Text("WLvl-Trophy-0", "Smashed");
    this.Text("WLvl-Trophy-1", "Kingslayer");
    this.Text("WLvl-Trophy-2", "Honor's Mercy");
    this.Text("WLvl-Trophy-3", "Maelstrom Interrupted");
    this.Text("WLvl-Trophy-4", "Evelyn's Reckoning");
    this.Text("WLvl-Trophy-5", "Cryptid Hunter");
    this.Text("WLvl-Trophy-6", "The Handler's Price");
    this.Text("WLvl-Trophy-7", "Sins of Kabuki");
    this.Text("WLvl-Trophy-8", "The Trauma Weavers");
    this.Text("WLvl-Trophy-9", "Loa's Last Rites");
    this.Text("WLvl-Trophy-10", "Firewall Breach");
    this.Text("WLvl-Trophy-11", "Dumb Luck Ran Out");
    this.Text("WLvl-Trophy-12", "Wraith Exorcist");
    this.Text("WLvl-Trophy-13", "Clouded Judgment");
    this.Text("WLvl-Trophy-14", "River's Justice");
    this.Text("WLvl-Trophy-15", "Myth Buster");
    this.Text("WLvl-Trophy-16", "Gatekeeper's Fall");

    // ---- Trophy notes (same order as the trophy titles)
    this.Text("WLvl-TrophyNote-0", "Killed Adam Smasher");
    this.Text("WLvl-TrophyNote-1", "Killed Kurt Hansen");
    this.Text("WLvl-TrophyNote-2", "Killed Sandayu Oda");
    this.Text("WLvl-TrophyNote-3", "Killed Royce");
    this.Text("WLvl-TrophyNote-4", "Killed Woodman");
    this.Text("WLvl-TrophyNote-5", "Killed Sasquatch");
    this.Text("WLvl-TrophyNote-6", "Killed Solomon Reed");
    this.Text("WLvl-TrophyNote-7", "Killed Jotaro Shobo");
    this.Text("WLvl-TrophyNote-8", "Killed a Persson brother");
    this.Text("WLvl-TrophyNote-9", "Killed Placide");
    this.Text("WLvl-TrophyNote-10", "Killed Bryce Mosley");
    this.Text("WLvl-TrophyNote-11", "Killed Dum Dum");
    this.Text("WLvl-TrophyNote-12", "Killed Nash");
    this.Text("WLvl-TrophyNote-13", "Killed Fingers");
    this.Text("WLvl-TrophyNote-14", "Killed Anthony Harris");
    this.Text("WLvl-TrophyNote-15", "Destroyed the Chimera");
    this.Text("WLvl-TrophyNote-16", "Destroyed Cerberus");

    // ---- Secret titles
    this.Text("WLvl-Secret-0", "The Board's Worst Nightmare");
    this.Text("WLvl-Secret-1", "The Solo's Last Laugh");

    // ---- What each secret title does
    this.Text("WLvl-SecretNote-0", "+50% damage against Arasaka. Smasher has a weak spot, once.");
    this.Text("WLvl-SecretNote-1", "Kills in one shot. 3-round magazine, slower reload and fire rate.");

    // ---- Mod Settings: category names
    this.Text("WLvl-Cat-General", "General");
    this.Text("WLvl-Cat-SpendingPoints", "Spending points");
    this.Text("WLvl-Cat-Titles", "Titles");
    this.Text("WLvl-Cat-Leveling", "Leveling");
    this.Text("WLvl-Cat-WeaponCard", "Weapon card");
    this.Text("WLvl-Cat-Debug", "Debug");

    // ---- Mod Settings: setting names
    this.Text("WLvl-Set-enabled", "Enable weapon leveling");
    this.Text("WLvl-Set-xpMultiplier", "Kill XP multiplier");
    this.Text("WLvl-Set-damageCoef", "Damage bonus strength");
    this.Text("WLvl-Set-keyCycle", "Next option (keyboard)");
    this.Text("WLvl-Set-keyConfirm", "Confirm (keyboard)");
    this.Text("WLvl-Set-titleChoice", "Title shown after the gun's name");
    this.Text("WLvl-Set-padButton", "Spend button (controller, inventory only)");
    this.Text("WLvl-Set-padHoldSeconds", "Hold time to confirm (seconds)");
    this.Text("WLvl-Set-perkXP", "XP per perk point");
    this.Text("WLvl-Set-attributeXP", "XP per attribute point");
    this.Text("WLvl-Set-autoPointScale", "Automatic point value (Better Leveling)");
    this.Text("WLvl-Set-pointScale", "Point value (percent)");
    this.Text("WLvl-Set-relicBoostPercent", "Relic boost per point (percent)");
    this.Text("WLvl-Set-relicBoostKills", "Relic boost length (kills)");
    this.Text("WLvl-Set-levelHandling", "Handling improves with level");
    this.Text("WLvl-Set-headshotBonus", "Headshot kill XP bonus (percent)");
    this.Text("WLvl-Set-stealthBonus", "Stealth kill XP bonus (percent)");
    this.Text("WLvl-Set-lowLevelReduction", "Less XP from low-level enemies");
    this.Text("WLvl-Set-lowLevelGap", "Low-level gap");
    this.Text("WLvl-Set-showCard", "Show card when drawing a weapon");
    this.Text("WLvl-Set-cardSeconds", "Card duration (seconds)");
    this.Text("WLvl-Set-compactCard", "Compact card");
    this.Text("WLvl-Set-cardPosition", "Card side during play");
    this.Text("WLvl-Set-cardHeight", "Card height during play");
    this.Text("WLvl-Set-cardScale", "Card size (percent)");
    this.Text("WLvl-Set-dualCards", "Both cards when dual wielding");
    this.Text("WLvl-Set-debugLog", "Debug log");

    // ---- Mod Settings: setting descriptions
    this.Text("WLvl-SetDesc-enabled", "Turns XP gain and level bonuses on or off. Saved levels are kept.");
    this.Text("WLvl-SetDesc-xpMultiplier", "Scales all XP earned from kills.");
    this.Text("WLvl-SetDesc-damageCoef", "How much damage each weapon level adds. Each level adds a little less than the one before. 0 turns the bonus off.");
    this.Text("WLvl-SetDesc-keyCycle", "Steps through the spend menu: perk points x1, x5, x10, attribute points x1, x5, x10, relic point, refund. Works with a weapon drawn or highlighted in the inventory.");
    this.Text("WLvl-SetDesc-keyConfirm", "Carries out the option shown on the card. Relic points and refunds ask for a second press.");
    this.Text("WLvl-SetDesc-titleChoice", "Which of a gun's titles appears in quotes after its name. Only the name changes: every title a gun has earned always works. If a gun has fewer titles than the choice needs, its strongest is shown.");
    this.Text("WLvl-SetDesc-padButton", "Tap to step through the spend menu for the weapon highlighted in the inventory, hold and release to use the option shown. Default: Select / View button.");
    this.Text("WLvl-SetDesc-padHoldSeconds", "How long the controller spend button must be held to count as a confirm instead of a tap.");
    this.Text("WLvl-SetDesc-perkXP", "How much weapon XP one perk point buys in the spend menu, before the point value below is applied.");
    this.Text("WLvl-SetDesc-attributeXP", "How much weapon XP one attribute point buys in the spend menu, before the point value below is applied.");
    this.Text("WLvl-SetDesc-autoPointScale", "With Better Leveling installed, works out what perk and attribute points are worth from its level cap and points per level, so a point is worth the same share of a playthrough as in the base game. Changes to Better Leveling's settings apply on the next launch. Turn off to use the manual value below.");
    this.Text("WLvl-SetDesc-pointScale", "Scales the XP from perk and attribute points. Used when the automatic value is off or Better Leveling is not installed.");
    this.Text("WLvl-SetDesc-relicBoostPercent", "Extra kill XP from each relic point spent. Stacks up to four times.");
    this.Text("WLvl-SetDesc-relicBoostKills", "How many kills a relic boost lasts. Points spent at full strength add this many more kills.");
    this.Text("WLvl-SetDesc-levelHandling", "Fire rate, reload speed and recoil improve with weapon level, up to a ceiling at level 20 (10% faster fire, 15% faster reload, 20% less recoil). Applies the next time the weapon is drawn.");
    this.Text("WLvl-SetDesc-headshotBonus", "Extra XP when the killing blow is a headshot.");
    this.Text("WLvl-SetDesc-stealthBonus", "Extra XP for killing an enemy who had not noticed you.");
    this.Text("WLvl-SetDesc-lowLevelReduction", "Enemies far below your level give half XP. Your level counts as 60 at most, so extended-level saves are not punished.");
    this.Text("WLvl-SetDesc-lowLevelGap", "How many levels below you an enemy has to be to give half XP.");
    this.Text("WLvl-SetDesc-showCard", "Shows the weapon's level and XP when you draw or swap to it.");
    this.Text("WLvl-SetDesc-cardSeconds", "How long the card stays on screen.");
    this.Text("WLvl-SetDesc-compactCard", "When drawing a weapon, show only its name and level. The spend menu and level-ups still use the full card.");
    this.Text("WLvl-SetDesc-cardPosition", "1: left edge of the screen.  2: right edge. (In menus the card is always at the middle left.)");
    this.Text("WLvl-SetDesc-cardHeight", "Where the card sits on the screen during play: 0 is the bottom, 100 the top. The card always stays fully on screen. Default 20 keeps it clear of the game's level-up message.");
    this.Text("WLvl-SetDesc-cardScale", "Makes the whole card bigger or smaller. 100 is the original size; lower it if the card covers too much of the screen. In menus the card is always drawn a little smaller than this.");
    this.Text("WLvl-SetDesc-dualCards", "While dual wielding, show both guns' cards stacked (left hand on top), each marked with its hand.");
    this.Text("WLvl-SetDesc-debugLog", "Writes every counted kill and level change to the WeaponLeveling log for bug reports.");

    // ---- Mod Settings: dropdown choices
    this.Text("WLvl-Val-titleChoice-Auto", "Strongest");
    this.Text("WLvl-Val-titleChoice-Second", "Second strongest");
    this.Text("WLvl-Val-titleChoice-Third", "Third strongest");
    this.Text("WLvl-Val-titleChoice-Weakest", "Weakest");
    this.Text("WLvl-Val-titleChoice-Newest", "Most recently earned");
  }
}
