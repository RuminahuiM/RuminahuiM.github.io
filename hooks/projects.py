"""MkDocs-Hook: Projektliste aus data/projects.yml als Karussell rendern.

Platzhalter in einer Markdown-Seite:
    <!-- projekte -->                    alle Projekte, mit Filter nach Kategorie
    <!-- projekte: semesterarbeiten -->  nur eine Kategorie (ID aus categories)

Ausgabe: reines HTML (Filter, Karten, Pfeile, Fortschrittsbalken). Das
Verhalten (Blaettern, Filtern) steckt in docs/javascripts/projekte.js, das
Aussehen in docs/stylesheets/extra.css (Abschnitt "Projekte"). Ohne
JavaScript laesst sich die Kartenreihe trotzdem seitlich scrollen.

Sortierung: Projekte ohne Startdatum zuerst, dann neueste zuerst (nach
"start", bei Gleichstand nach Titel).
Ungueltige Eintraege brechen den Build mit einer klaren Fehlermeldung ab,
damit ein Tippfehler in der YAML nicht still auf der Seite landet.

Zusaetzlich: Kontaktlinks aus mkdocs.yml (extra.kontakt), leere URLs werden
ausgeblendet.

Sprachen: Die Seite wird mit mkdocs-static-i18n pro Sprache gebaut. Die
Sprache des aktuellen Builds steht in theme.language. Projekte, Kategorien
und Kontakte koennen einen Block "en:" mit uebersetzten Feldern haben
(title, summary, topics, status, image_alt bzw. name). Fehlt ein Feld, gilt Deutsch.
    <!-- kontakt -->          inline: [LinkedIn](...) [GitHub](...)
    <!-- kontakt: liste -->   als Aufzaehlung mit ausgeschriebener Adresse
"""

from __future__ import annotations

import base64
import html
import os
import re
import zlib

import yaml
from mkdocs.exceptions import PluginError

DATA_FILE = os.path.join("data", "projects.yml")
PLACEHOLDER = re.compile(r"<!--\s*projekte(?:\s*:\s*([a-z0-9-]+))?\s*-->")
MONTH = re.compile(r"^\d{4}-(0[1-9]|1[0-2])$")
URL = re.compile(r"^https?://\S+$")

CONTACT = re.compile(r"<!--\s*kontakt(?:\s*:\s*(liste))?\s*-->")

_data: dict = {"categories": [], "projects": []}
_contacts: list = []

DEFAULT_LANG = "de"
TRANSLATABLE = ("title", "summary", "topics", "status", "image_alt", "name", "kind")
SHORT = re.compile(r"^[A-Za-z0-9]{1,4}$")

# Feste Texte auf den Karten und bei den Kontakten, pro Sprache
TEXT = {
    "de": {
        "semester": "Semester {n}",
        "range": "{start} bis {end}",
        "since": "seit {start}",
        "page": "Projektseite",
        "repo": "Repository",
        "product": "Produkt",
        "website": "Website",
        "empty": "Noch keine Einträge. Die Liste wird laufend ergänzt.",
        "mail": "E-Mail schreiben",
        "all": "Alle",
        "filter": "Projekte filtern",
        "list": "Projekte",
        "prev": "Vorheriges Projekt",
        "next": "Nächstes Projekt",
        "count": "{i} von {n}",
    },
    "en": {
        "semester": "Semester {n}",
        "range": "{start} to {end}",
        "since": "since {start}",
        "page": "Project page",
        "repo": "Repository",
        "product": "Product",
        "website": "Website",
        "empty": "No entries yet. The list is updated regularly.",
        "mail": "Send an email",
        "all": "All",
        "filter": "Filter projects",
        "list": "Projects",
        "prev": "Previous project",
        "next": "Next project",
        "count": "{i} of {n}",
    },
}


def _lang(config) -> str:
    lang = str(config.theme.get("language") or DEFAULT_LANG)
    return lang if lang in TEXT else DEFAULT_LANG


def _t(lang: str, key: str, **kw) -> str:
    return TEXT[lang][key].format(**kw)


def _loc(item: dict, lang: str) -> dict:
    """Eintrag in der gewuenschten Sprache: Felder aus dem Block <lang>:
    ueberschreiben die deutschen Werte."""
    if lang == DEFAULT_LANG or not isinstance(item.get(lang), dict):
        return item
    merged = dict(item)
    merged.update({k: v for k, v in item[lang].items() if v})
    return merged


def _fail(msg: str) -> None:
    raise PluginError(f"{DATA_FILE}: {msg}")


def _load(path: str) -> dict:
    if not os.path.isfile(path):
        _fail("Datei fehlt")
    with open(path, encoding="utf-8") as fh:
        raw = yaml.safe_load(fh) or {}

    categories = raw.get("categories") or []
    projects = raw.get("projects") or []
    if not isinstance(categories, list) or not categories:
        _fail("'categories' muss eine nicht leere Liste sein")
    if not isinstance(projects, list):
        _fail("'projects' muss eine Liste sein")

    cat_ids = []
    for c in categories:
        if not isinstance(c, dict) or not c.get("id") or not c.get("title"):
            _fail(f"Kategorie braucht 'id' und 'title': {c!r}")
        cat_ids.append(c["id"])

    for i, p in enumerate(projects, start=1):
        where = f"Projekt {i} ({p.get('title', 'ohne Titel') if isinstance(p, dict) else p!r})"
        if not isinstance(p, dict):
            _fail(f"{where}: Eintrag muss ein Objekt sein")
        for key in ("title", "category", "summary"):
            if not p.get(key):
                _fail(f"{where}: Feld '{key}' fehlt")
        if p["category"] not in cat_ids:
            _fail(f"{where}: Kategorie '{p['category']}' unbekannt, erlaubt: {', '.join(cat_ids)}")
        for key in ("start", "end"):
            if p.get(key) and not MONTH.match(str(p[key])):
                _fail(f"{where}: '{key}' im Format JJJJ-MM angeben, in Anfuehrungszeichen, z.B. \"2026-10\"")
        if p.get("end") and not p.get("start"):
            _fail(f"{where}: 'end' ohne 'start'")
        if p.get("end") and str(p["end"]) < str(p["start"]):
            _fail(f"{where}: 'end' liegt vor 'start'")
        if not (p.get("page") or p.get("repo") or p.get("website")):
            _fail(f"{where}: mindestens 'page', 'repo' oder 'website' angeben")
        for key in ("page", "repo", "product", "website"):
            if p.get(key) and not URL.match(str(p[key])):
                _fail(f"{where}: '{key}' muss eine vollstaendige URL sein (https://...)")
        if p.get("short") and not SHORT.match(str(p["short"])):
            _fail(f"{where}: 'short' sind 1 bis 4 Buchstaben oder Ziffern, z.B. RDG")
        if p.get("gradient") is not None and (not isinstance(p["gradient"], int) or not 1 <= p["gradient"] <= GRADIENTS):
            _fail(f"{where}: 'gradient' ist eine Zahl von 1 bis {GRADIENTS}")
        topics = p.get("topics") or []
        if not isinstance(topics, list):
            _fail(f"{where}: 'topics' muss eine Liste sein")
        for lang in TEXT:
            if lang == DEFAULT_LANG or lang not in p:
                continue
            block = p[lang]
            if not isinstance(block, dict):
                _fail(f"{where}: '{lang}' muss ein Block mit uebersetzten Feldern sein")
            unknown = set(block) - set(TRANSLATABLE)
            if unknown:
                _fail(f"{where}: '{lang}' kennt nur {', '.join(TRANSLATABLE)}, nicht {', '.join(sorted(unknown))}")
            if block.get("topics") is not None and not isinstance(block["topics"], list):
                _fail(f"{where}: '{lang}.topics' muss eine Liste sein")

    projects = sorted(projects, key=lambda p: str(p["title"]).lower())
    # Projekte ohne Startdatum zuerst (gelten als aktuell), sonst neueste zuerst
    projects = sorted(projects, key=lambda p: str(p.get("start") or "9999"), reverse=True)
    return {"categories": categories, "projects": projects}


def _fmt_month(value) -> str:
    year, month = str(value).split("-")
    return f"{month}.{year}"


def _period(p: dict, lang: str) -> str:
    if not p.get("start"):
        return ""
    if p.get("end"):
        return _t(lang, "range", start=_fmt_month(p["start"]), end=_fmt_month(p["end"]))
    return _t(lang, "since", start=_fmt_month(p["start"]))


def _esc(value) -> str:
    return html.escape(" ".join(str(value).split()), quote=True)


def _short(p: dict) -> str:
    """Kuerzel auf dem Kartenbild ohne Foto: Feld 'short', sonst Initialen."""
    if p.get("short"):
        return str(p["short"])
    return "".join(w[0] for w in re.findall(r"[A-Za-z0-9]+", str(p["title"])))[:3].upper()


GRADIENTS = 6   # Anzahl Farbverlaeufe in extra.css (.pf-grad--1 bis --6)


def _gradient(p: dict) -> int:
    """Farbverlauf fuer Karten ohne Bild: Feld 'gradient', sonst stabil aus dem Titel."""
    if p.get("gradient"):
        return int(p["gradient"])
    return zlib.crc32(str(p["title"]).encode()) % GRADIENTS + 1


def _card(p: dict, lang: str, prefix: str) -> str:
    cat = _loc(next(c for c in _data["categories"] if c["id"] == p["category"]), lang)
    p = _loc(p, lang)
    target = p.get("page") or p.get("website") or p.get("repo")

    kind = str(cat.get("kind") or cat["title"])
    if p.get("semester"):
        kind = f"{kind} {p['semester']}"
    when = [x for x in (_period(p, lang), str(p.get("status") or "")) if x]

    if p.get("image"):
        alt = _esc(p.get("image_alt") or p["title"])
        thumb = (f'<div class="pf-card__thumb pf-card__thumb--img">'
                 f'<img src="{prefix}{_esc(p["image"])}" alt="{alt}" loading="lazy"></div>')
    else:
        thumb = (f'<div class="pf-card__thumb pf-grad--{_gradient(p)}" aria-hidden="true"><span class="pf-card__bars"></span>'
                 f'<span class="pf-card__short">{_esc(_short(p))}</span></div>')

    tags = "".join(f'<span class="pf-tag">{_esc(t)}</span>' for t in (p.get("topics") or []))
    links = "".join(
        f'<a href="{_esc(p[key])}">{_t(lang, key)}</a>'
        for key in ("page", "repo", "product", "website") if p.get(key)
    )
    return (
        f'<article class="pf-card" data-cat="{_esc(p["category"])}">{thumb}'
        f'<div class="pf-card__body">'
        f'<p class="pf-card__kind">{_esc(kind)}'
        + (f' <span>{_esc(", ".join(when))}</span>' if when else "")
        + f'</p><h2 class="pf-card__title"><a href="{_esc(target)}">{_esc(p["title"])}</a></h2>'
        f'<p class="pf-card__text">{_esc(p["summary"])}</p>'
        + (f'<p class="pf-card__tags">{tags}</p>' if tags else "")
        + f'<p class="pf-card__links">{links}</p></div></article>'
    )


def _render(category_id: str | None, lang: str, prefix: str) -> str:
    projects = _data["projects"]
    cats = _data["categories"]
    if category_id:
        if category_id not in [c["id"] for c in cats]:
            _fail(f"Platzhalter verweist auf unbekannte Kategorie '{category_id}'")
        projects = [p for p in projects if p["category"] == category_id]
    if not projects:
        return f'<p class="pf-empty">{_t(lang, "empty")}</p>\n'

    used = [c for c in cats if any(p["category"] == c["id"] for p in projects)]
    filt = ""
    if len(used) > 1:
        pills = [f'<button type="button" class="pf-pill" data-filter="all" aria-pressed="true">{_t(lang, "all")}</button>']
        pills += [
            f'<button type="button" class="pf-pill" data-filter="{_esc(c["id"])}" aria-pressed="false">'
            f'{_esc(_loc(c, lang)["title"])}</button>'
            for c in used
        ]
        filt = f'<div class="pf-carousel__filter" role="group" aria-label="{_t(lang, "filter")}">{"".join(pills)}</div>'

    cards = "".join(_card(p, lang, prefix) for p in projects)
    arrow = '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="{d}"/></svg>'
    ctrl = (
        '<div class="pf-carousel__ctrl">'
        f'<button type="button" class="pf-arrow" data-dir="-1" aria-label="{_t(lang, "prev")}">'
        + arrow.format(d="M15 5l-7 7 7 7") + '</button>'
        f'<button type="button" class="pf-arrow" data-dir="1" aria-label="{_t(lang, "next")}">'
        + arrow.format(d="M9 5l7 7-7 7") + '</button>'
        '<div class="pf-progress" aria-hidden="true"><i></i></div>'
        f'<span class="pf-count" aria-live="polite">{_t(lang, "count", i=1, n=len(projects))}</span>'
        '</div>'
    )
    return (
        f'<div class="pf-carousel" data-count="{_esc(TEXT[lang]["count"])}">{filt}'
        f'<div class="pf-carousel__track" tabindex="0" role="region" aria-label="{_t(lang, "list")}">{cards}</div>'
        f'{ctrl}</div>\n'
    )


MAIL = re.compile(r"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$")


def _load_contacts(extra) -> list:
    """Kontakte aus extra.kontakt. Ein Eintrag hat entweder 'url' (Link) oder
    'mail' (E-Mail-Adresse). Leere Werte werden ausgeblendet."""
    items = (extra or {}).get("kontakt") or []
    result = []
    for c in items:
        if not isinstance(c, dict) or not c.get("name"):
            raise PluginError(f"mkdocs.yml extra.kontakt: Eintrag braucht 'name': {c!r}")
        mail = str(c.get("mail") or "").strip()
        url = str(c.get("url") or "").strip()
        if mail:
            if not MAIL.match(mail):
                raise PluginError(f"mkdocs.yml extra.kontakt: '{c['name']}' ist keine gueltige E-Mail-Adresse")
            result.append({**c, "name": str(c["name"]), "mail": mail})
            continue
        if not url:
            continue
        if not URL.match(url):
            raise PluginError(f"mkdocs.yml extra.kontakt: '{c['name']}' braucht eine vollstaendige URL (https://...)")
        result.append({**c, "name": str(c["name"]), "url": url})
    return result


def _mail_link(c: dict, label: str, show: bool) -> str:
    """Adresse steht nie im Klartext im HTML: nur umgekehrt und Base64-kodiert
    in einem data-Attribut. docs/javascripts/kontakt.js setzt im Browser den
    mailto-Link zusammen und zeigt bei .js-mail--show die Adresse als Text."""
    token = base64.b64encode(c["mail"][::-1].encode()).decode()
    cls = ".js-mail .js-mail--show" if show else ".js-mail"
    return f'[{label}](#){{ {cls} data-m="{token}" }}'


def _render_contacts(as_list: bool, lang: str) -> str:
    contacts = [_loc(c, lang) for c in _contacts]

    def link(c, long):
        if "mail" in c:
            return _mail_link(c, _t(lang, "mail") if long else c["name"], show=long)
        if long:
            return f"[{re.sub(r'^https?://(www\.)?', '', c['url']).rstrip('/')}]({c['url']})"
        return f"[{c['name']}]({c['url']})"
    if as_list:
        return "\n".join(f"- {c['name']}: {link(c, True)}" for c in contacts) + "\n"
    return " ".join(link(c, False) for c in contacts)


# --- MkDocs events ---------------------------------------------------------

def on_config(config, **kwargs):
    global _data, _contacts
    base = os.path.dirname(config.config_file_path)
    _data = _load(os.path.join(base, DATA_FILE))
    for p in _data["projects"]:
        if p.get("image") and not os.path.isfile(os.path.join(config.docs_dir, str(p["image"]))):
            _fail(f"Projekt '{p['title']}': Bild '{p['image']}' nicht gefunden (Pfad relativ zu docs/)")
    _contacts = _load_contacts(config.extra)

    return config


def on_page_markdown(markdown, page, config, files, **kwargs):
    lang = _lang(config)
    if "kontakt" in markdown:
        markdown = CONTACT.sub(lambda m: _render_contacts(bool(m.group(1)), lang), markdown)
    if "projekte" in markdown:
        # Bildpfade im HTML relativ zur Seite (z.B. projekte/ -> ../assets/...)
        prefix = "../" * page.url.count("/")
        markdown = PLACEHOLDER.sub(lambda m: _render(m.group(1), lang, prefix), markdown)
    return markdown


def on_serve(server, config, builder, **kwargs):
    server.watch(os.path.join(os.path.dirname(config.config_file_path), DATA_FILE))
    return server
