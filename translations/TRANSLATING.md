# Translating Weaponpunk 2077

Thank you for translating! Every piece of text the mod shows (the weapon card, tooltips, menus,
messages, title names and all Mod Settings options) can be translated with a single file.
You don't need to know how to code.

> **Spoiler warning:** the translation file contains the names and effects of everything in the
> mod's hidden system. Translating it means seeing all of it.

## What's in this kit

| File | What it is |
|---|---|
| `WeaponpunkLang_TEMPLATE.reds` | The file you translate. Every line of English text is in it. |
| `strings_en.tsv` | The same text as a table (key, English, where it appears). Open it in Excel, Google Sheets or LibreOffice if you prefer working in a spreadsheet, then copy your translations into the template. |
| `TRANSLATING.md` | This guide. |

## Requirements

- Weaponpunk 2077 **0.6beta or newer** (older versions can't load translations)
- Codeware (already required by the mod)

## Step by step

1. **Copy and rename the template** for your language, for example `WeaponpunkLang_fr_fr.reds`.
2. **Set your language code.** Open the file in a text editor (Notepad++, VS Code or Notepad) and replace
   both `xx_xx` with your code. It appears in the `module` line and in the class name:

   ```
   module WeaponpunkLang.fr_fr
   ...
   public class WLvlLang_fr_fr extends ModLocalizationPackage {
   ```

   | Language | Code | Language | Code |
   |---|---|---|---|
   | French | `fr_fr` | Japanese | `jp_jp` |
   | German | `de_de` | Korean | `kr_kr` |
   | Spanish (Spain) | `es_es` | Chinese (Simplified) | `zh_cn` |
   | Spanish (Latin America) | `es_mx` | Chinese (Traditional) | `zh_tw` |
   | Italian | `it_it` | Czech | `cz_cz` |
   | Polish | `pl_pl` | Hungarian | `hu_hu` |
   | Portuguese (Brazil) | `pt_br` | Turkish | `tr_tr` |
   | Russian | `ru_ru` | Thai | `th_th` |
   | Ukrainian | `ua_ua` | Arabic | `ar_ar` |

3. **Translate.** Each line looks like this:

   ```
   this.Text("WLvl-Card-LevelUp", "LEVEL UP");
   ```

   Change only the second text, the one after the comma. **Never change the key** (`"WLvl-..."`).

4. **Save the file as UTF-8** so accented letters and other alphabets display correctly. Notepad++ shows the
   encoding in the bottom-right corner.

5. **Install and test.** Put the file in

   ```
   Cyberpunk 2077\r6\scripts\WeaponpunkLang\
   ```

   Then start the game with its language set to yours (Settings → Language → On-screen).

## Rules that keep the mod working

- **Keep `{0}`, `{1}` and `{2}`.** The mod replaces them with numbers, weapon names or titles. You can move
  them anywhere in the sentence to suit your grammar:
  `"{0} reached weapon level {1}"` → `"{0} a atteint le niveau d'arme {1}"`
- **Quotes inside text** must be written as `\"`. For example, `"NEW TITLE: \"{0}\""`.
- **`WLvl-TitleQuote`** sets the quote marks around a title after a weapon's name. Change it to your
  language's quote marks if you like, for example `"«{0}»"` or `"„{0}“"`.
- **Leaving a line out is fine.** Any key you delete or don't translate is shown in English, so you can
  release a partial translation and finish it later.
- **Don't translate the `//` comment lines**. They only help you find your way around.
- Keep **spaces at the start or end** of a text if the English has them.

## If the game shows an error

If the game shows a script error popup after you add the file, the message names the file and line.
The usual causes are:

- a missing `"` or `\` before a quote inside the text
- a missing `;` at the end of a line
- `xx_xx` replaced in only one of the two places

Fix the line, or remove the file, and the game will start normally again.

## Sharing your translation

Upload your file as its own mod on Nexus. Name it something like **"Weaponpunk 2077 - French"**, add
Weaponpunk 2077 as a requirement, and tell players to put the file in `r6\scripts\WeaponpunkLang\`.
You're welcome to post a link in the Weaponpunk 2077 comments so it can be listed on the main page.

When a new Weaponpunk version adds text, its translation kit will include the new keys. Copy those
lines into your file. Until you do, the new text simply shows in English.
