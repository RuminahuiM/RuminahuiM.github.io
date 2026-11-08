# RuminahuiM.github.io

Portfolio-Hauptseite von Dodoe Rumiñahui Mannale. Sie sammelt meine Semesterarbeiten (TBZ, Dipl. Informatiker/in HF, ITCNE25) und weitere Projekte. Jedes Projekt hat ein eigenes Repository mit eigener Pages-Seite, die Hauptseite verlinkt nur darauf.

**Lesen:** <https://ruminahuim.github.io/>

Gebaut mit Material for MkDocs, gleiche Version und gleiches Theme wie die Projektseiten (Referenz: [rdg-semesterarbeit](https://github.com/RuminahuiM/rdg-semesterarbeit)).

## Aufbau

| Pfad | Inhalt |
| --- | --- |
| `data/projects.yml` | Projektliste: Kategorien und ein Eintrag pro Projekt |
| `hooks/projects.py` | MkDocs-Hook: rendert Projektliste und Kontaktlinks, prüft die Einträge |
| `docs/index.md` | Startseite: Vorstellung und alle Projekte |
| `docs/semesterarbeiten.md` | Nur Semesterarbeiten |
| `docs/weitere-projekte.md` | Nur weitere Projekte, erscheint in der Navigation erst mit dem ersten Eintrag |
| `docs/cv.md` | Lebenslauf (öffentliche Fassung), erreichbar unter `/cv/`, mit PDF-Download |
| `docs/*.en.md` | Englische Fassung der Seiten, erreichbar unter `/en/` (siehe "Sprachen") |
| `scripts/build_pdf.py` | Erzeugt im Workflow die Lebenslauf-PDFs aus der gebauten Seite |
| `docs/ueber-mich.md` | Über mich |
| `docs/assets/images/` | Profilbild |
| `docs/stylesheets/extra.css` | Aussehen der Projektkarten |
| `docs/assets/brand/` | Farbpalette und Logo, zentral für alle Seiten des Portfolios |
| `docs/documents/` | Nur Weiterleitungen: alte URLs der Hugo-Doku (bis November 2026 direkt unter ruminahuim.github.io) auf `/hugo-portfolio-semesterarbeit/` |
| `.github/workflows/pages.yml` | Build mit `mkdocs build --strict`, Lebenslauf-PDFs, Deployment auf GitHub Pages |

## Neues Projekt hinzufügen

1. In `data/projects.yml` unter `projects:` einen Eintrag ergänzen. Die Vorlage steht am Ende der Datei. 

    ```yaml
    projects:
      - title: Titel des Projekts
        category: semesterarbeiten
        semester: 4
        topics: [DevOps, Projektmanagement]
        start: "2026-10"
        end: "2027-01"
        summary: >
          Ein bis zwei Sätze, worum es geht.
        page: https://ruminahuim.github.io/<repo-name>/
        repo: https://github.com/RuminahuiM/<repo-name>
        product: https://github.com/RuminahuiM/<produkt-repo>
    ```

2. Lokal prüfen (siehe unten). Bei einem Fehler in der YAML bricht der Build mit einer Meldung ab, die Projekt und Feld nennt.
3. Committen und pushen:

    ```powershell
    git add data/projects.yml
    git commit -m "Projekt <Name> ergänzt"
    git push
    ```

Die Reihenfolge in der Datei spielt keine Rolle. Die Seite sortiert nach `start`, neueste zuerst.

### Felder

| Feld | Pflicht | Beschreibung |
| --- | --- | --- |
| `title` | ja | Titel des Projekts |
| `category` | ja | ID einer Kategorie aus `categories`: `semesterarbeiten` oder `weitere-projekte` |
| `start` | nein | Beginn als `"JJJJ-MM"`, in Anführungszeichen. Ohne Datum steht das Projekt zuoberst und die Karte zeigt keinen Zeitraum |
| `summary` | ja | Ein bis zwei Sätze |
| `page`, `repo` oder `website` | mindestens eines | Vollständige URL der Projektseite bzw. des Doku-Repositorys |
| `product` | nein | Vollständige URL des Produkt-Repositorys, falls der Code in einem eigenen Repo liegt. Erscheint als Link "Produkt" |
| `website` | nein | Vollständige URL einer Website, z.B. einer Kundenseite. Erscheint als Link "Website" |
| `image` | nein | Bild oben auf der Karte, Pfad relativ zu `docs/`, z.B. `assets/projekte/name.webp`. Querformat, etwa 1200 x 690 px, WebP |
| `image_alt` | nein | Beschreibung des Bildes für Screenreader, sonst der Titel |
| `end` | nein | Ende als `"JJJJ-MM"`. Leer bedeutet laufend, die Karte zeigt dann "seit ..." |
| `semester` | nein | Nummer der Semesterarbeit |
| `topics` | nein | Themenfelder als Liste, z.B. `[Cloud, CI/CD]` |
| `status` | nein | Freier Text, z.B. `laufend` oder `abgeschlossen` |
| `en` | nein | Englische Fassung: Block mit `title`, `summary`, `topics`, `status`, `image_alt`. Nur angeben, was anders ist als auf Deutsch |

Beispiel für den Block `en`:

```yaml
    en:
      title: Automated Hugo portfolio
      topics: [AWS, Ansible, IaC]
      summary: >
        One or two sentences in English.
```

### Neue Kategorie

Unter `categories` einen Eintrag mit `id`, `title`, `page` und `en: {title: ...}` ergänzen, dazu eine Seite in `docs/` mit dem Platzhalter `<!-- projekte: <id> -->` und ihre englische Fassung `<name>.en.md`. Den deutschen Navigationstitel in `mkdocs.yml` unter `nav_translations` übersetzen. Die Startseite zeigt die neue Kategorie automatisch, die Navigation ebenfalls, sobald es einen Eintrag gibt.

## Profilbild, Lebenslauf und Kontakt

### Profilbild ersetzen

Aktuell ist ein Platzhalter mit dem Logo drin (`docs/assets/images/profil-platzhalter.svg`).

1. Foto quadratisch zuschneiden, etwa 400 x 400 px, als JPG unter 200 KB.
2. Metadaten entfernen (Handyfotos enthalten oft GPS-Koordinaten). In Windows: Rechtsklick auf die Datei > Eigenschaften > Details > "Eigenschaften und persönliche Informationen entfernen" > "Kopie erstellen, bei der alle möglichen Eigenschaften entfernt sind".
3. Die bereinigte Kopie als `docs/assets/images/profil.jpg` speichern.
4. In `docs/index.md` den Pfad `assets/images/profil-platzhalter.svg` durch `assets/images/profil.jpg` ersetzen und die Platzhalter-SVG löschen.

### Lebenslauf

`docs/cv.md` (Deutsch) und `docs/cv.en.md` (Englisch). Änderungen immer in beiden Dateien nachführen. Nur die öffentliche Fassung gehört hierhin, also keine Adresse, kein Telefon, kein Geburtsdatum, keine Zeugnisse und keine Referenzen mit Kontaktdaten. Was einmal committet ist, bleibt in der Git-History öffentlich, auch nach dem Löschen.

PDF-Download: Der Workflow druckt nach dem Build beide Seiten mit Chromium als PDF (`scripts/build_pdf.py`):

| Sprache | Datei |
| --- | --- |
| Deutsch | `/downloads/lebenslauf-dodoe-mannale.pdf` |
| Englisch | `/en/downloads/cv-dodoe-mannale.pdf` |

Das PDF enthält also immer genau den Stand der Seite. Was im PDF anders ist, steht in `docs/stylesheets/extra.css` unter `@media print`: Kopfzeile mit Name, ohne Download-Button und ohne E-Mail-Adresse (Schutz vor Crawlern, PDFs werden von Suchmaschinen indexiert). Bei `mkdocs serve` lokal führt der Button ins Leere, weil die PDFs erst im Workflow entstehen.

PDF lokal erzeugen (optional):

```powershell
pip install playwright
python -m playwright install chromium
mkdocs build
python scripts/build_pdf.py site cv/ lebenslauf.pdf en/cv/ cv-en.pdf
```

### Kontaktlinks (z.B. LinkedIn)

Die Links stehen zentral in `mkdocs.yml` unter `extra.kontakt` und erscheinen automatisch auf Startseite, Über mich und Lebenslauf. Ein leerer Wert wird ausgeblendet. LinkedIn aktivieren:

```yaml
extra:
  kontakt:
    - name: LinkedIn
      url: https://www.linkedin.com/in/<profil>/
```

## Farben und Logo

Alle Seiten des Portfolios nutzen dieselbe Palette "Anthrazit und Dunkelgelb" mit Aubergine als Zweitfarbe (Themen-Tags, Karten-Rahmen beim Überfahren) und dasselbe Logo. Beides liegt nur hier:

- `docs/assets/brand/palette.css`: Farben (heller und dunkler Modus), gelbe Linie, Buttons, Infoboxen
- `docs/assets/brand/logo.svg`: Logo, das Code-39-Symbol des Zeichens "R" (breit, schmal, schmal, breit, schmal), wie in der Figma-Datei "Rumi Designs". Auch als Favicon. Die Strichfarbe entspricht dem Gelb der Palette

Die Projektseiten laden die Dateien per URL von dieser Seite. Eine Änderung hier wirkt nach dem Deployment der Hauptseite auf allen Projektseiten, ohne dass dort etwas angepasst werden muss. Nachteil: `mkdocs serve` einer Projektseite zeigt die Farben nur mit Internetverbindung.

Einstellungen in der `mkdocs.yml` einer Projektseite:

```yaml
theme:
  name: material
  logo: https://ruminahuim.github.io/assets/brand/logo.svg
  favicon: https://ruminahuim.github.io/assets/brand/logo.svg
  palette:
    - media: "(prefers-color-scheme: light)"
      scheme: default
      primary: custom
      accent: custom
      # toggle wie bisher
    - media: "(prefers-color-scheme: dark)"
      scheme: slate
      primary: custom
      accent: custom
      # toggle wie bisher

extra_css:
  - https://ruminahuim.github.io/assets/brand/palette.css

extra:
  homepage: https://ruminahuim.github.io/   # Logo führt zurück zum Portfolio
```

Kontraste nach WCAG sind in `palette.css` dokumentiert. Dunkelgelb (`#e3a400`) nur für Linien und Flächen verwenden, nie als Schrift auf Weiss (Kontrast 2.2:1). Für Links im hellen Modus gibt es den Ockerton `#8a5f00`.

### E-Mail-Adresse (geschützt)

Eine E-Mail-Adresse wird als Eintrag mit `mail` statt `url` eingetragen:

```yaml
extra:
  kontakt:
    - name: E-Mail
      mail: dodoe.mannale@ruminahui.ch
```

Die Adresse steht dann nie im Klartext im HTML der Seite, sondern nur umgekehrt und Base64-kodiert in einem `data-m`-Attribut. Das Skript `docs/javascripts/kontakt.js` setzt im Browser daraus den `mailto:`-Link und die sichtbare Adresse zusammen. Das hält einfache Adress-Crawler ab, nicht aber jemanden, der gezielt das Repository liest. Deshalb eine eigene Kontaktadresse verwenden, nicht die private.

## Projektseiten und Hauptseite

- Ein Projekt-Repo mit eigener Pages-Seite ist unter `https://ruminahuim.github.io/<repo-name>/` erreichbar. Es hat Vorrang vor einem gleichnamigen Ordner dieser Hauptseite. Deshalb in `docs/` keine Ordner mit dem Namen eines Projekt-Repos anlegen.
- Neue Projektseite: `mkdocs.yml`, `requirements.txt` und `.github/workflows/pages.yml` aus [rdg-semesterarbeit](https://github.com/RuminahuiM/rdg-semesterarbeit) übernehmen, damit alles gleich aussieht. `site_url` auf `https://ruminahuim.github.io/<repo-name>/` setzen. Farben, Logo und Rücklink stehen im Abschnitt "Farben und Logo".

## Sprachen

Die Hauptseite ist zweisprachig (Deutsch und Englisch) mit dem Plugin [mkdocs-static-i18n](https://github.com/ultrabug/mkdocs-static-i18n). Die Projektseiten (Semesterarbeiten) bleiben einsprachig.

| Was | Wo |
| --- | --- |
| Deutsche Seite | `docs/<name>.md`, erreichbar unter `/` |
| Englische Seite | `docs/<name>.en.md`, erreichbar unter `/en/` |
| Navigation | `mkdocs.yml`, `plugins > i18n > languages > en > nav_translations` |
| Projekttexte | `data/projects.yml`, Block `en` pro Projekt und Kategorie |
| Feste Texte auf den Karten | `hooks/projects.py`, Tabelle `TEXT` |
| Kontaktnamen | `mkdocs.yml`, `extra.kontakt`, Block `en` |

Der Sprachumschalter oben im Header führt auf die gleiche Seite in der anderen Sprache. Fehlt eine `.en.md`, zeigt die englische Fassung den deutschen Text.

## Lokal ansehen und prüfen (PowerShell)

Einmalig im Repo-Ordner:

```powershell
py -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

Danach:

```powershell
.\.venv\Scripts\Activate.ps1
mkdocs serve          # Vorschau auf http://127.0.0.1:8000, lädt bei Änderungen neu
mkdocs build --strict # gleiche Prüfung wie im Workflow
```

## Deployment

Jeder Push auf `main` baut die Seite mit GitHub Actions und veröffentlicht sie. Voraussetzung ist die einmalige Einstellung im Repo unter **Settings > Pages > Build and deployment > Source: GitHub Actions**.

## Später: eigene Domain

Noch nicht umgesetzt. Was eine Custom Domain auf dieser Hauptseite bedeuten würde (Stand GitHub Docs, November 2026):

- Bekommt die Hauptseite eine eigene Domain, gilt sie automatisch für alle öffentlichen Projektseiten desselben Kontos. Aus `ruminahuim.github.io/rdg-semesterarbeit/` wird dann `<domain>/rdg-semesterarbeit/`.
- Ein einzelnes Projekt kann eine eigene Domain bekommen und überschreibt damit die geerbte. Die geerbte Domain lässt sich pro Projekt nicht abschalten, nur auf der Hauptseite ganz entfernen.
- Private Projektseiten sind nicht betroffen.
- Die Domain wird unter **Settings > Pages > Custom domain** gesetzt. Bei Deployment über einen eigenen Actions-Workflow wird eine `CNAME`-Datei ignoriert und ist nicht nötig.
- GitHub empfiehlt, die Domain vorher im Konto zu verifizieren, um Domain-Takeover zu verhindern.
- Nachziehen: `site_url` in allen `mkdocs.yml`, die URLs in `data/projects.yml` und Links in den Projekt-READMEs. Ob die alten `github.io`-Links weiterleiten, sagen die Docs nicht ausdrücklich, das nach der Umstellung testen.

Quellen: [About custom domains and GitHub Pages](https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site/about-custom-domains-and-github-pages), [Managing a custom domain](https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site/managing-a-custom-domain-for-your-github-pages-site)

## Hinweis zur Theme-Version

Material for MkDocs ist seit November 2025 im Maintenance-Modus, 9.7 ist die letzte Feature-Version. Die Versionen sind in `requirements.txt` fest gepinnt (`mkdocs==1.6.1`, `mkdocs-material==9.7.7`), damit Hauptseite und Projektseiten gleich bauen. Ein Wechsel, z.B. auf den Nachfolger Zensical, sollte für alle Repos gemeinsam erfolgen. Dabei prüfen, ob der Hook in `hooks/projects.py` weiter unterstützt wird.
