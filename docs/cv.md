---
title: Lebenslauf
hide:
  - navigation
---

<!--
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

PDF-Download: Nur ein PDF ohne private Angaben verwenden. PDF nach
docs/assets/cv/ legen und die Zeile unten einkommentieren.
-->

# Lebenslauf

<!-- [Als PDF herunterladen](assets/cv/lebenslauf-dodoe-mannale.pdf){ .md-button } -->

<p class="cv-lead">ICT System Engineer aus Zürich mit Fokus auf Automatisierung und AI. Mein Schwerpunkt ist der Betrieb und die Automatisierung von Infrastruktur rund um Microsoft 365 und Azure, zunehmend auch auf AWS. Daneben baue ich AI-Systeme, die im Alltag wirklich eingesetzt werden. Berufsbegleitend studiere ich an der TBZ zum dipl. Informatiker HF, Lehrgang Cloud-native Engineer.</p>

## Berufserfahrung

<ol class="cv-timeline cv-timeline--years">
<li><span class="cv-year">2025</span><h3>System Engineer</h3><p class="cv-meta">HEKS, Zürich | 02.2025 bis heute</p><ul><li>Betrieb und Ausbau von Server- (VMware) und Azure-Cloud-Infrastruktur an mehreren Standorten schweizweit</li><li>Administration von Microsoft 365 (SharePoint, Teams, Entra ID, Defender) und Device Management mit Intune</li><li>Prozessautomatisierung mit Azure Automation, PowerShell, Power Automate und Logic Apps</li><li>Projektleitung, u.a. Intune-Rollout und Aufbau eines internen KI-Systems (Open WebUI und vLLM)</li></ul></li>
<li><span class="cv-year">2023</span><h3>System Engineer</h3><p class="cv-meta">Vision Inside AG, Wetzikon | 08.2023 bis 01.2025</p><ul><li>Support und Beratung von Kunden (1st und 2nd Level)</li><li>Mitarbeit in Kunden-IT-Projekten, Testing und Einführung neuer Hard- und Software</li><li>Azure-Automatisierungstools, ChatGPT-Integration ins Ticketsystem</li></ul></li>
<li><span class="cv-year">2022</span><h3>System Engineer</h3><p class="cv-meta">Root Service AG, Bürglen TG | 08.2022 bis 07.2023</p><ul><li>PowerShell-Automatisierung von Cloud-Umgebungen (Swiss Cloud)</li><li>Betreuung und Organisation von Lehrlingsanlässen</li></ul></li>
<li><span class="cv-year">2018</span><h3>Lehre Betriebsinformatiker EFZ</h3><p class="cv-meta">Root Service AG, Bürglen TG | 08.2018 bis 08.2022</p><ul><li>1st-Level-Support, Assemblieren und Ausliefern von Hardware</li><li>Konzeption und Dokumentation von IT-Lösungen</li></ul></li>
</ol>

## Ausbildung

<ol class="cv-timeline">
<li><h3>Dipl. Informatiker/in HF, Cloud-native Engineer</h3><p class="cv-meta">Technische Berufsschule Zürich (TBZ), Klasse ITCNE25 | 02.2025 bis heute</p><p>Cloud-Infrastruktur und Infrastructure as Code, Container und Kubernetes, DevOps (CI/CD, Terraform), Datenbanksysteme, IT-Sicherheit. Die Arbeiten findest du unter <a href="../semesterarbeiten/">Semesterarbeiten</a>.</p></li>
<li><h3>Informatiker EFZ, Betriebsinformatik</h3><p class="cv-meta">Bildungszentrum für Technik Frauenfeld (BZTF) | 2018 bis 08.2022</p><p>Netzwerk, Programmierung, Server-Infrastrukturen, Cloud</p></li>
</ol>

## Skills

<p class="cv-legend"><span class="cv-chip cv-chip--core">Schwerpunkt</span> <span class="cv-chip">weitere Erfahrung</span></p>
<div class="cv-skillrows"><div class="cv-skillrow"><span class="cv-skillrow__cat">Cloud und Infrastruktur</span><span><span class="cv-chip cv-chip--core">Azure</span> <span class="cv-chip cv-chip--core">Microsoft 365</span> <span class="cv-chip">Entra ID</span> <span class="cv-chip cv-chip--core">Intune</span> <span class="cv-chip">VMware</span> <span class="cv-chip">AWS</span> <span class="cv-chip">Linux</span> <span class="cv-chip">Veeam</span> <span class="cv-chip">Synology</span></span></div><div class="cv-skillrow"><span class="cv-skillrow__cat">Automatisierung und Scripting</span><span><span class="cv-chip cv-chip--core">PowerShell</span> <span class="cv-chip cv-chip--core">Azure Automation</span> <span class="cv-chip">Logic Apps</span> <span class="cv-chip">Power Automate</span> <span class="cv-chip">Python</span> <span class="cv-chip">Ansible</span></span></div><div class="cv-skillrow"><span class="cv-skillrow__cat">Cloud Native und DevOps</span><span><span class="cv-chip cv-chip--core">Kubernetes</span> <span class="cv-chip">Docker</span> <span class="cv-chip cv-chip--core">Terraform</span> <span class="cv-chip">Helm</span> <span class="cv-chip">GitHub Actions</span> <span class="cv-chip">CI/CD</span> <span class="cv-chip">Argo CD</span></span></div><div class="cv-skillrow"><span class="cv-skillrow__cat">AI und Tools</span><span><span class="cv-chip cv-chip--core">Open WebUI</span> <span class="cv-chip">vLLM</span> <span class="cv-chip cv-chip--core">Claude Code</span> <span class="cv-chip">Claude</span> <span class="cv-chip">ChatGPT</span> <span class="cv-chip">AI-Integration</span></span></div><div class="cv-skillrow"><span class="cv-skillrow__cat">Netzwerk und Security</span><span><span class="cv-chip">Palo Alto</span> <span class="cv-chip">Cisco</span> <span class="cv-chip">UniFi</span> <span class="cv-chip">IT-Sicherheit</span></span></div><div class="cv-skillrow"><span class="cv-skillrow__cat">Monitoring</span><span><span class="cv-chip">Grafana</span> <span class="cv-chip">Prometheus</span> <span class="cv-chip">PRTG</span></span></div></div>

## Sprachen

<div class="cv-langs"><div class="cv-lang"><div class="cv-lang__name"><strong>Deutsch</strong><span>Muttersprache</span></div><div class="cv-lang__bar" aria-label="Muttersprache"><span class="cv-seg on native"></span><span class="cv-seg on native"></span><span class="cv-seg on native"></span><span class="cv-seg on native"></span><span class="cv-seg on native"></span><span class="cv-seg on native"></span></div></div><div class="cv-lang"><div class="cv-lang__name"><strong>Spanisch</strong><span>Muttersprache</span></div><div class="cv-lang__bar" aria-label="Muttersprache"><span class="cv-seg on native"></span><span class="cv-seg on native"></span><span class="cv-seg on native"></span><span class="cv-seg on native"></span><span class="cv-seg on native"></span><span class="cv-seg on native"></span></div></div><div class="cv-lang"><div class="cv-lang__name"><strong>Englisch</strong><span>Fliessend (B2)</span></div><div class="cv-lang__bar" aria-label="Fliessend (B2)"><span class="cv-seg on"></span><span class="cv-seg on"></span><span class="cv-seg on"></span><span class="cv-seg on"></span><span class="cv-seg"></span><span class="cv-seg"></span></div></div><div class="cv-lang"><div class="cv-lang__name"><strong>Französisch</strong><span>Grundkenntnisse (A1)</span></div><div class="cv-lang__bar" aria-label="Grundkenntnisse (A1)"><span class="cv-seg on"></span><span class="cv-seg"></span><span class="cv-seg"></span><span class="cv-seg"></span><span class="cv-seg"></span><span class="cv-seg"></span></div></div></div>
<p class="cv-legend">Sechs Stufen nach dem Gemeinsamen Europäischen Referenzrahmen, von A1 bis C2. Violett: Muttersprache.</p>

## Zertifikate

<div class="cv-certs"><div><strong>Fähigkeitszeugnis Informatiker EFZ</strong><span>BZTF Frauenfeld | 08.2022</span></div><div><strong>English B2 Technical</strong><span>telc | 10.2020</span></div></div>

## Interessen

Webdesign und 3D-Druck.

## Kontakt

<!-- kontakt: liste -->
