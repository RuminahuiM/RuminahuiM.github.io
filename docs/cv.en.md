---
title: CV
hide:
  - navigation
---

<!--
English version of cv.md. Keep both files in sync.

Öffentliche Fassung des Lebenslaufs. NICHT hierhin: Adresse, Telefon,
Geburtsdatum, Zeugnisse, Referenzen mit Kontaktdaten. Alles, was hier
committet wird, bleibt in der Git-History öffentlich, auch nach dem Löschen.
Arbeitgeber werden auf Wunsch mit Namen genannt.

Aufbau: HTML-Bausteine mit den Klassen cv-* (Stil in stylesheets/extra.css).
- Zeitleiste: <ol class="cv-timeline cv-timeline--years">, ein <li> pro Station,
  Jahr in <span class="cv-year">. Die neueste Station steht oben.
- Skills: eine <div class="cv-skillrow"> pro Kategorie. Schwerpunkte mit
  <span class="cv-chip cv-chip--core">, weitere mit <span class="cv-chip">.
- Sprachen: 6 Segmente = A1 bis C2. Gefuellte Segmente bekommen "on",
  Muttersprachen zusaetzlich "native".

PDF-Download: Das PDF wird bei jedem Push aus dieser Seite erzeugt
(scripts/build_pdf.py im Workflow), es enthaelt also genau diesen Inhalt.
Im PDF ausgeblendet: Download-Button und E-Mail-Adresse (Schutz vor Crawlern).
Der Block cv-print-head erscheint nur im PDF bzw. beim Drucken.

Englische Fassung: cv.en.md. Aenderungen in beiden Dateien nachfuehren.
-->

<div class="cv-print-head"><strong>Dodoe Rumiñahui Mannale</strong><span>ICT System Engineer | Zurich | ruminahuim.github.io</span></div>

# CV

<div class="cv-intro" markdown>

![Dodoe Rumiñahui Mannale](assets/images/profil-cv.jpg){ .cv-photo width="150" height="188" }

<p class="cv-lead">ICT system engineer from Zurich, focused on automation and AI. My main focus is operating and automating infrastructure around Microsoft 365 and Azure, and more and more on AWS. On the side I build AI systems that I use day to day. Alongside work I am studying for the Dipl. Informatiker HF (Cloud-native Engineer) at TBZ.</p>

</div>

## Work experience

<ol class="cv-timeline cv-timeline--years">
<li><span class="cv-year">2025</span><h3>System Engineer</h3><p class="cv-meta">HEKS, Zurich | 02.2025 to present</p><ul><li>Operating and expanding server (VMware) and Azure cloud infrastructure across several sites in Switzerland</li><li>Administration of Microsoft 365 (SharePoint, Teams, Entra ID, Defender) and device management with Intune</li><li>Process automation with Azure Automation, PowerShell, Power Automate and Logic Apps</li><li>Project lead, including the Intune rollout and building an internal AI system (Open WebUI and vLLM)</li></ul></li>
<li><span class="cv-year">2023</span><h3>System Engineer</h3><p class="cv-meta">Vision Inside AG, Wetzikon | 08.2023 to 01.2025</p><ul><li>Customer support and consulting (1st and 2nd level)</li><li>Customer IT projects, testing and rollout of new hardware and software</li><li>Azure automation tools, ChatGPT integration into the ticketing system</li></ul></li>
<li><span class="cv-year">2022</span><h3>System Engineer</h3><p class="cv-meta">Root Service AG, Bürglen TG | 08.2022 to 07.2023</p><ul><li>PowerShell automation of cloud environments (Swiss Cloud)</li><li>Supervising and organising events for apprentices</li></ul></li>
<li><span class="cv-year">2018</span><h3>Apprenticeship, IT specialist in system engineering (EFZ)</h3><p class="cv-meta">Root Service AG, Bürglen TG | 08.2018 to 08.2022</p><ul><li>1st level support, assembling and delivering hardware</li><li>Designing and documenting IT solutions</li></ul></li>
</ol>

## Education

<ol class="cv-timeline">
<li><h3>Dipl. Informatiker/in HF, Cloud-native Engineer</h3><p class="cv-meta">Technische Berufsschule Zürich (TBZ), class ITCNE25 | 02.2025 to present</p><p>Swiss Federal Diploma of Higher Education in Computer Science. Cloud infrastructure and infrastructure as code, containers and Kubernetes, DevOps (CI/CD, Terraform), database systems, IT security. See my <a href="../semesterarbeiten/">semester projects</a>.</p></li>
<li><h3>IT specialist EFZ, system engineering</h3><p class="cv-meta">Bildungszentrum für Technik Frauenfeld (BZTF) | 2018 to 08.2022</p><p>Swiss Federal VET Diploma. Networking, programming, server infrastructure, cloud</p></li>
</ol>

## Skills

<p class="cv-legend"><span class="cv-chip cv-chip--core">Core skill</span> <span class="cv-chip">Further experience</span></p>
<div class="cv-skillrows"><div class="cv-skillrow"><span class="cv-skillrow__cat">Cloud and infrastructure</span><span><span class="cv-chip cv-chip--core">Azure</span> <span class="cv-chip cv-chip--core">Microsoft 365</span> <span class="cv-chip">Entra ID</span> <span class="cv-chip cv-chip--core">Intune</span> <span class="cv-chip">VMware</span> <span class="cv-chip">AWS</span> <span class="cv-chip">Linux</span> <span class="cv-chip">Veeam</span> <span class="cv-chip">Synology</span></span></div><div class="cv-skillrow"><span class="cv-skillrow__cat">Automation and scripting</span><span><span class="cv-chip cv-chip--core">PowerShell</span> <span class="cv-chip cv-chip--core">Azure Automation</span> <span class="cv-chip">Logic Apps</span> <span class="cv-chip">Power Automate</span> <span class="cv-chip">Python</span> <span class="cv-chip">Ansible</span></span></div><div class="cv-skillrow"><span class="cv-skillrow__cat">Cloud native and DevOps</span><span><span class="cv-chip cv-chip--core">Kubernetes</span> <span class="cv-chip">Docker</span> <span class="cv-chip cv-chip--core">Terraform</span> <span class="cv-chip">Helm</span> <span class="cv-chip">GitHub Actions</span> <span class="cv-chip">CI/CD</span> <span class="cv-chip">Argo CD</span></span></div><div class="cv-skillrow"><span class="cv-skillrow__cat">AI and tools</span><span><span class="cv-chip cv-chip--core">Open WebUI</span> <span class="cv-chip">vLLM</span> <span class="cv-chip cv-chip--core">Claude Code</span> <span class="cv-chip">Claude</span> <span class="cv-chip">ChatGPT</span> <span class="cv-chip">AI integration</span></span></div><div class="cv-skillrow"><span class="cv-skillrow__cat">Networking and security</span><span><span class="cv-chip">Palo Alto</span> <span class="cv-chip">Cisco</span> <span class="cv-chip">UniFi</span> <span class="cv-chip">IT security</span></span></div><div class="cv-skillrow"><span class="cv-skillrow__cat">Monitoring</span><span><span class="cv-chip">Grafana</span> <span class="cv-chip">Prometheus</span> <span class="cv-chip">PRTG</span></span></div></div>

## Languages

<div class="cv-langs"><div class="cv-lang"><div class="cv-lang__name"><strong>German</strong><span>Native</span></div><div class="cv-lang__bar" aria-label="Native"><span class="cv-seg on native"></span><span class="cv-seg on native"></span><span class="cv-seg on native"></span><span class="cv-seg on native"></span><span class="cv-seg on native"></span><span class="cv-seg on native"></span></div></div><div class="cv-lang"><div class="cv-lang__name"><strong>Spanish</strong><span>Native</span></div><div class="cv-lang__bar" aria-label="Native"><span class="cv-seg on native"></span><span class="cv-seg on native"></span><span class="cv-seg on native"></span><span class="cv-seg on native"></span><span class="cv-seg on native"></span><span class="cv-seg on native"></span></div></div><div class="cv-lang"><div class="cv-lang__name"><strong>English</strong><span>Advanced (C1)</span></div><div class="cv-lang__bar" aria-label="Advanced (C1)"><span class="cv-seg on"></span><span class="cv-seg on"></span><span class="cv-seg on"></span><span class="cv-seg on"></span><span class="cv-seg on"></span><span class="cv-seg"></span></div></div><div class="cv-lang"><div class="cv-lang__name"><strong>French</strong><span>Basic (A1)</span></div><div class="cv-lang__bar" aria-label="Basic (A1)"><span class="cv-seg on"></span><span class="cv-seg"></span><span class="cv-seg"></span><span class="cv-seg"></span><span class="cv-seg"></span><span class="cv-seg"></span></div></div></div>
<p class="cv-legend">Six levels of the Common European Framework of Reference, from A1 to C2. Purple: native language.</p>

## Certificates

<div class="cv-certs"><div><strong>Federal VET Diploma, IT specialist EFZ</strong><span>BZTF Frauenfeld | 08.2022</span></div><div><strong>English B2 Technical</strong><span>telc | 10.2020</span></div></div>

## Interests

AI systems, web design and 3D printing.

## Contact

<!-- kontakt: liste -->

<p class="cv-download"><a class="md-button" href="../downloads/cv-dodoe-mannale.pdf" download>Download CV as PDF</a></p>
