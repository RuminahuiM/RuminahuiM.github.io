"""MkDocs-Hook: Projektliste aus data/projects.yml als Karten rendern.

Platzhalter in einer Markdown-Seite:
    <!-- projekte -->                    alle Projekte, gruppiert nach Kategorie
    <!-- projekte: semesterarbeiten -->  nur eine Kategorie (ID aus categories)

Sortierung: neueste zuerst (nach "start", bei Gleichstand nach Titel).
Ungueltige Eintraege brechen den Build mit einer klaren Fehlermeldung ab,
damit ein Tippfehler in der YAML nicht still auf der Seite landet.

Kategorien mit einer eigenen Seite ("page") kommen automatisch in die
Navigation, sobald sie mindestens ein Projekt haben.

Zusaetzlich: Kontaktlinks aus mkdocs.yml (extra.kontakt), leere URLs werden
ausgeblendet.
    <!-- kontakt -->          inline: [LinkedIn](...) | [GitHub](...)
    <!-- kontakt: liste -->   als Aufzaehlung mit ausgeschriebener Adresse
"""

from __future__ import annotations

import html
import os
import re

import yaml
from mkdocs.exceptions import PluginError

DATA_FILE = os.path.join("data", "projects.yml")
PLACEHOLDER = re.compile(r"<!--\s*projekte(?:\s*:\s*([a-z0-9-]+))?\s*-->")
MONTH = re.compile(r"^\d{4}-(0[1-9]|1[0-2])$")
URL = re.compile(r"^https?://\S+$")

CONTACT = re.compile(r"<!--\s*kontakt(?:\s*:\s*(liste))?\s*-->")

_data: dict = {"categories": [], "projects": []}
_contacts: list = []


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
        for key in ("title", "category", "start", "summary"):
            if not p.get(key):
                _fail(f"{where}: Feld '{key}' fehlt")
        if p["category"] not in cat_ids:
            _fail(f"{where}: Kategorie '{p['category']}' unbekannt, erlaubt: {', '.join(cat_ids)}")
        for key in ("start", "end"):
            if p.get(key) and not MONTH.match(str(p[key])):
                _fail(f"{where}: '{key}' im Format JJJJ-MM angeben, in Anfuehrungszeichen, z.B. \"2026-10\"")
        if p.get("end") and str(p["end"]) < str(p["start"]):
            _fail(f"{where}: 'end' liegt vor 'start'")
        if not p.get("page") and not p.get("repo"):
            _fail(f"{where}: mindestens 'page' oder 'repo' angeben")
        for key in ("page", "repo"):
            if p.get(key) and not URL.match(str(p[key])):
                _fail(f"{where}: '{key}' muss eine vollstaendige URL sein (https://...)")
        topics = p.get("topics") or []
        if not isinstance(topics, list):
            _fail(f"{where}: 'topics' muss eine Liste sein")

    projects = sorted(projects, key=lambda p: str(p["title"]).lower())
    projects = sorted(projects, key=lambda p: str(p["start"]), reverse=True)
    return {"categories": categories, "projects": projects}


def _fmt_month(value) -> str:
    year, month = str(value).split("-")
    return f"{month}.{year}"


def _period(p: dict) -> str:
    if p.get("end"):
        return f"{_fmt_month(p['start'])} bis {_fmt_month(p['end'])}"
    return f"seit {_fmt_month(p['start'])}"


def _card(p: dict) -> str:
    title = str(p["title"]).replace("[", r"\[").replace("]", r"\]")
    target = p.get("page") or p.get("repo")

    meta = []
    if p.get("semester"):
        meta.append(f"Semester {p['semester']}")
    meta.append(_period(p))
    if p.get("status"):
        meta.append(str(p["status"]))
    meta_html = " | ".join(html.escape(m) for m in meta)

    summary = " ".join(str(p["summary"]).split())
    tags = " ".join(
        f'<span class="portfolio-tag">{html.escape(str(t))}</span>' for t in (p.get("topics") or [])
    )
    links = []
    if p.get("page"):
        links.append(f"[Projektseite]({p['page']})")
    if p.get("repo"):
        links.append(f"[Repository]({p['repo']})")

    lines = [
        f"-   __[{title}]({target})__",
        "",
        f'    <span class="portfolio-meta">{meta_html}</span>',
        "",
        "    ---",
        "",
        f"    {summary}",
        "",
    ]
    if tags:
        lines += [f'    <span class="portfolio-tags">{tags}</span>', ""]
    lines += [f"    {' | '.join(links)}", ""]
    return "\n".join(lines)


def _grid(projects: list) -> str:
    if not projects:
        return '<p class="portfolio-empty">Noch keine Einträge. Die Liste wird laufend ergänzt.</p>\n'
    cards = "\n".join(_card(p) for p in projects)
    return f'<div class="grid cards portfolio-cards" markdown>\n\n{cards}\n</div>\n'


def _render(category_id: str | None) -> str:
    projects = _data["projects"]
    if category_id:
        if category_id not in [c["id"] for c in _data["categories"]]:
            _fail(f"Platzhalter verweist auf unbekannte Kategorie '{category_id}'")
        return _grid([p for p in projects if p["category"] == category_id])

    parts = []
    for c in _data["categories"]:
        items = [p for p in projects if p["category"] == c["id"]]
        if items:
            parts.append(f"## {c['title']}\n\n{_grid(items)}")
    return "\n".join(parts) if parts else _grid([])


def _load_contacts(extra) -> list:
    items = (extra or {}).get("kontakt") or []
    result = []
    for c in items:
        if not isinstance(c, dict) or not c.get("name"):
            raise PluginError(f"mkdocs.yml extra.kontakt: Eintrag braucht 'name': {c!r}")
        url = str(c.get("url") or "").strip()
        if not url:
            continue
        if not URL.match(url):
            raise PluginError(f"mkdocs.yml extra.kontakt: '{c['name']}' braucht eine vollstaendige URL (https://...)")
        result.append({"name": str(c["name"]), "url": url})
    return result


def _render_contacts(as_list: bool) -> str:
    if as_list:
        return "\n".join(
            f"- {c['name']}: [{re.sub(r'^https?://(www\.)?', '', c['url']).rstrip('/')}]({c['url']})"
            for c in _contacts
        ) + "\n"
    return " | ".join(f"[{c['name']}]({c['url']})" for c in _contacts)


# --- MkDocs events ---------------------------------------------------------

def on_config(config, **kwargs):
    global _data, _contacts
    base = os.path.dirname(config.config_file_path)
    _data = _load(os.path.join(base, DATA_FILE))
    _contacts = _load_contacts(config.extra)

    nav = config.nav
    if nav is None:
        return config
    def nav_index(page: str):
        return next(
            (i for i, item in enumerate(nav) if isinstance(item, dict) and page in item.values()),
            None,
        )

    # Fehlende Kategorie-Seiten direkt hinter die vorherige Kategorie setzen
    # (Reihenfolge wie in categories), sonst hinter "Start".
    anchor = nav_index("index.md")
    for c in _data["categories"]:
        page = c.get("page")
        if not page:
            continue
        idx = nav_index(page)
        if idx is None and any(p["category"] == c["id"] for p in _data["projects"]):
            pos = (anchor + 1) if anchor is not None else len(nav)
            nav.insert(pos, {c["title"]: page})
            idx = pos
        if idx is not None:
            anchor = idx
    return config


def on_page_markdown(markdown, page, config, files, **kwargs):
    if "kontakt" in markdown:
        markdown = CONTACT.sub(lambda m: _render_contacts(bool(m.group(1))), markdown)
    if "projekte" in markdown:
        markdown = PLACEHOLDER.sub(lambda m: _render(m.group(1)), markdown)
    return markdown


def on_serve(server, config, builder, **kwargs):
    server.watch(os.path.join(os.path.dirname(config.config_file_path), DATA_FILE))
    return server
