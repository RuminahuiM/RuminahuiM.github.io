"""PDFs aus Seiten der gebauten Website erzeugen (headless Chromium).

Wird im Workflow nach `mkdocs build` aufgerufen, z.B. fuer den Lebenslauf:

    python scripts/build_pdf.py site \
        cv/ site/downloads/lebenslauf-dodoe-mannale.pdf \
        en/cv/ site/en/downloads/cv-dodoe-mannale.pdf

Argumente: Site-Ordner, danach beliebig viele Paare aus Seitenpfad und
Zieldatei. Die Seite wird lokal ausgeliefert, damit CSS und Skripte laufen.
Gedruckt wird im hellen Farbschema; was im PDF fehlen soll (Buttons,
E-Mail), regelt @media print in docs/stylesheets/extra.css.
"""

from __future__ import annotations

import functools
import http.server
import os
import sys
import threading

from playwright.sync_api import sync_playwright

FOOTER = (
    '<div style="width:100%;font-size:8px;color:#666;padding:0 15mm;'
    'display:flex;justify-content:space-between;font-family:sans-serif">'
    '<span class="title"></span>'
    '<span><span class="pageNumber"></span> / <span class="totalPages"></span></span></div>'
)


class QuietHandler(http.server.SimpleHTTPRequestHandler):
    def log_message(self, *args):
        pass


def main(site_dir: str, jobs: list[tuple[str, str]]) -> None:
    handler = functools.partial(QuietHandler, directory=site_dir)
    httpd = http.server.ThreadingHTTPServer(("127.0.0.1", 0), handler)
    threading.Thread(target=httpd.serve_forever, daemon=True).start()
    base = f"http://127.0.0.1:{httpd.server_address[1]}/"

    with sync_playwright() as p:
        browser = p.chromium.launch()
        for page_path, out in jobs:
            tab = browser.new_page(color_scheme="light")
            tab.goto(base + page_path, wait_until="networkidle", timeout=120_000)
            tab.wait_for_timeout(1500)  # Schriften und Skripte fertig
            tab.emulate_media(media="print", color_scheme="light")
            os.makedirs(os.path.dirname(out) or ".", exist_ok=True)
            tab.pdf(
                path=out,
                format="A4",
                print_background=True,
                scale=0.76,  # kompakter als die Bildschirmansicht
                display_header_footer=True,
                header_template="<span></span>",
                footer_template=FOOTER,
                margin={"top": "14mm", "bottom": "16mm", "left": "14mm", "right": "14mm"},
            )
            tab.close()
            print(f"PDF erzeugt: {out}")
        browser.close()
    httpd.shutdown()


if __name__ == "__main__":
    args = sys.argv[1:]
    if len(args) < 3 or len(args) % 2 == 0:
        sys.exit("Aufruf: build_pdf.py <site_dir> <seite> <ziel.pdf> [<seite> <ziel.pdf> ...]")
    main(args[0], list(zip(args[1::2], args[2::2])))
