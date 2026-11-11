---
title: Lebenslauf
layout: cv
description: "Lebenslauf von Dodoe Rumiñahui Mannale, ICT System Engineer in Zürich."
---

<!--
Öffentliche Fassung des Lebenslaufs. NICHT hierhin: Adresse, Telefon,
Geburtsdatum, Zeugnisse, Referenzen mit Kontaktdaten. Alles, was hier
committet wird, bleibt in der Git-History öffentlich, auch nach dem Löschen.
Arbeitgeber werden auf Wunsch mit Namen genannt.

Aufbau: zwei Spalten (Stil in stylesheets/extra.css, Abschnitt "Lebenslauf").
- Links <aside class="cv-side">: Foto, Name, Kurztext, PDF-Button, Kontakt,
  Sprachen, Zertifikate, Interessen. Bleibt beim Scrollen stehen.
- Rechts <div class="cv-main">: Berufserfahrung, Ausbildung, Skills.
- Stationen: <div class="cv-item"> mit Jahr in <span class="cv-year">,
  die neueste oben. Optional Endjahr darunter: <small>bis 2028</small>.
- Skills: eine <div class="cv-skillrow"> pro Kategorie. Schwerpunkte mit
  <span class="cv-chip cv-chip--core">, weitere mit <span class="cv-chip">.
- Sprachen: 6 Segmente = A1 bis C2. Gefuellte Segmente bekommen "on",
  Muttersprachen zusaetzlich "native".

PDF-Download: Das PDF wird bei jedem Push aus dieser Seite erzeugt
(scripts/build_pdf.py im Workflow), es enthaelt also genau diesen Inhalt.
Im PDF ausgeblendet: Download-Button und E-Mail-Adresse (Schutz vor Crawlern).
Im PDF beginnt ein Abschnitt mit { .cv-newpage } auf einer neuen Seite.

Englische Fassung: cv.en.md. Aenderungen in beiden Dateien nachfuehren.
-->

<div class="cv-layout" markdown>
<aside class="cv-side" markdown>

![Dodoe Rumiñahui Mannale](assets/images/profil.jpg){ .cv-photo width="896" height="1195" }

<div class="cv-side__in" markdown>

# Dodoe Rumiñahui Mannale

ICT System Engineer, Zürich
{: .cv-role }

Mein Schwerpunkt ist der Betrieb und die Automatisierung von Infrastruktur rund um Microsoft 365 und Azure, zunehmend auch auf AWS. Daneben baue ich AI-Systeme, die ich im Alltag einsetze. Berufsbegleitend studiere ich an der TBZ zum dipl. Informatiker HF, Lehrgang Cloud-native Engineer.
{: .cv-lead }

<p class="cv-download"><a class="md-button md-button--primary" href="../downloads/lebenslauf-dodoe-mannale.pdf" download>Als PDF herunterladen</a></p>

<!-- kontakt -->
{: .pf-contact }

## Sprachen

<div class="cv-langs"><div class="cv-lang"><div><strong>Deutsch</strong> <span>Muttersprache</span></div><div class="cv-lang__bar" role="img" aria-label="Muttersprache"><i class="cv-seg on native"></i><i class="cv-seg on native"></i><i class="cv-seg on native"></i><i class="cv-seg on native"></i><i class="cv-seg on native"></i><i class="cv-seg on native"></i></div></div><div class="cv-lang"><div><strong>Spanisch</strong> <span>Muttersprache</span></div><div class="cv-lang__bar" role="img" aria-label="Muttersprache"><i class="cv-seg on native"></i><i class="cv-seg on native"></i><i class="cv-seg on native"></i><i class="cv-seg on native"></i><i class="cv-seg on native"></i><i class="cv-seg on native"></i></div></div><div class="cv-lang"><div><strong>Englisch</strong> <span>Verhandlungssicher (C1)</span></div><div class="cv-lang__bar" role="img" aria-label="Verhandlungssicher (C1)"><i class="cv-seg on"></i><i class="cv-seg on"></i><i class="cv-seg on"></i><i class="cv-seg on"></i><i class="cv-seg on"></i><i class="cv-seg"></i></div></div><div class="cv-lang"><div><strong>Französisch</strong> <span>Grundkenntnisse (A1)</span></div><div class="cv-lang__bar" role="img" aria-label="Grundkenntnisse (A1)"><i class="cv-seg on"></i><i class="cv-seg"></i><i class="cv-seg"></i><i class="cv-seg"></i><i class="cv-seg"></i><i class="cv-seg"></i></div></div></div>
<p class="cv-note">Stufen A1 bis C2 nach dem Europäischen Referenzrahmen. Violett: Muttersprache.</p>

## Zertifikate

<div class="cv-certs"><div><strong>Fähigkeitszeugnis Informatiker EFZ</strong><span>BZTF Frauenfeld, 08.2022</span></div><div><strong>English B2 Technical</strong><span>telc, 10.2020</span></div></div>

## Interessen

AI-Systeme, Webdesign und 3D-Druck.

</div>
</aside>
<div class="cv-main" markdown>

## Berufserfahrung

<div class="cv-items">
<div class="cv-item"><span class="cv-year">2025</span><div><h3>System Engineer</h3><p class="cv-meta">HEKS, Zürich <span>02.2025 bis heute</span></p><ul><li>Betrieb und Ausbau von Server- (VMware) und Azure-Cloud-Infrastruktur an mehreren Standorten schweizweit</li><li>Administration von Microsoft 365 (SharePoint, Teams, Entra ID, Defender) und Device Management mit Intune</li><li>Prozessautomatisierung mit Azure Automation, PowerShell, Power Automate und Logic Apps</li><li>Projektleitung, u.a. Intune-Rollout und Aufbau eines internen KI-Systems (Open WebUI und vLLM)</li></ul></div></div>
<div class="cv-item"><span class="cv-year">2023</span><div><h3>System Engineer</h3><p class="cv-meta">Vision Inside AG, Wetzikon <span>08.2023 bis 01.2025</span></p><ul><li>Support und Beratung von Kunden (1st und 2nd Level)</li><li>Mitarbeit in Kunden-IT-Projekten, Testing und Einführung neuer Hard- und Software</li><li>Azure-Automatisierungstools, ChatGPT-Integration ins Ticketsystem</li></ul></div></div>
<div class="cv-item"><span class="cv-year">2022</span><div><h3>System Engineer</h3><p class="cv-meta">Root Service AG, Bürglen TG <span>08.2022 bis 07.2023</span></p><ul><li>PowerShell-Automatisierung von Cloud-Umgebungen (Swiss Cloud)</li><li>Betreuung und Organisation von Lehrlingsanlässen</li></ul></div></div>
<div class="cv-item"><span class="cv-year">2018</span><div><h3>Lehre Betriebsinformatiker EFZ</h3><p class="cv-meta">Root Service AG, Bürglen TG <span>08.2018 bis 08.2022</span></p><ul><li>1st-Level-Support, Assemblieren und Ausliefern von Hardware</li><li>Konzeption und Dokumentation von IT-Lösungen</li></ul></div></div>
</div>

## Ausbildung { .cv-newpage }

<div class="cv-items">
<div class="cv-item"><span class="cv-year">2025<small>bis 2028</small></span><div><h3>Dipl. Informatiker/in HF, Cloud-native Engineer</h3><p class="cv-meta">Technische Berufsschule Zürich (TBZ), Klasse ITCNE25 <span>02.2025 bis 02.2028, laufend</span></p><p>Cloud-Infrastruktur und Infrastructure as Code, Container und Kubernetes, DevOps (CI/CD, Terraform), Datenbanksysteme, IT-Sicherheit. Die Semesterarbeiten findest du unter <a href="../projekte/">Projekte</a>.</p></div></div>
<div class="cv-item"><span class="cv-year">2018<small>bis 2022</small></span><div><h3>Informatiker EFZ, Betriebsinformatik</h3><p class="cv-meta">Bildungszentrum für Technik Frauenfeld (BZTF) <span>08.2018 bis 08.2022</span></p><p>Netzwerk, Programmierung, Server-Infrastrukturen, Cloud</p></div></div>
</div>

## Skills

<p class="cv-legend"><span class="cv-chip cv-chip--core">Schwerpunkt</span> <span class="cv-chip">weitere Erfahrung</span></p>
<div class="cv-skillrows"><div class="cv-skillrow"><span class="cv-skillrow__cat">Cloud und Infrastruktur</span><span><span class="cv-chip cv-chip--core">Azure</span> <span class="cv-chip cv-chip--core">Microsoft 365</span> <span class="cv-chip">Entra ID</span> <span class="cv-chip cv-chip--core">Intune</span> <span class="cv-chip">VMware</span> <span class="cv-chip">AWS</span> <span class="cv-chip">Linux</span> <span class="cv-chip">Veeam</span> <span class="cv-chip">Synology</span></span></div><div class="cv-skillrow"><span class="cv-skillrow__cat">Automatisierung und Scripting</span><span><span class="cv-chip cv-chip--core">PowerShell</span> <span class="cv-chip cv-chip--core">Azure Automation</span> <span class="cv-chip">Logic Apps</span> <span class="cv-chip">Power Automate</span> <span class="cv-chip">Python</span> <span class="cv-chip">Ansible</span></span></div><div class="cv-skillrow"><span class="cv-skillrow__cat">Cloud Native und DevOps</span><span><span class="cv-chip cv-chip--core">Kubernetes</span> <span class="cv-chip">Docker</span> <span class="cv-chip cv-chip--core">Terraform</span> <span class="cv-chip">Helm</span> <span class="cv-chip">GitHub Actions</span> <span class="cv-chip">CI/CD</span> <span class="cv-chip">Argo CD</span></span></div><div class="cv-skillrow"><span class="cv-skillrow__cat">AI und Tools</span><span><span class="cv-chip cv-chip--core">Open WebUI</span> <span class="cv-chip">vLLM</span> <span class="cv-chip cv-chip--core">Claude Code</span> <span class="cv-chip">Claude</span> <span class="cv-chip">ChatGPT</span> <span class="cv-chip">AI-Integration</span></span></div><div class="cv-skillrow"><span class="cv-skillrow__cat">Netzwerk und Security</span><span><span class="cv-chip">Palo Alto</span> <span class="cv-chip">Cisco</span> <span class="cv-chip">UniFi</span> <span class="cv-chip">IT-Sicherheit</span></span></div><div class="cv-skillrow"><span class="cv-skillrow__cat">Monitoring</span><span><span class="cv-chip">Grafana</span> <span class="cv-chip">Prometheus</span> <span class="cv-chip">PRTG</span></span></div></div>

</div>
</div>
