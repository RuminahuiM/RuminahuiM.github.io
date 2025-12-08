---
layout: default
title: 1. Projekmanagement
nav_order: 2
has_children: true
---

{: .no_toc }

# Einführung / Definition

## Ziele (SMART)

### 1. Hugo-Portfolio
Bis spätestens Ende Semesterarbeit (Abgabedatum) erstelle ich eine lauffähige Hugo-Portfolio-Website in einem Git-Repository, die ein gewähltes Template verwendet und mindestens zwei Projekte (können Mockups sein) mit Navigation und Startseite darstellt. Die Seite lässt sich lokal mit hugo server ohne Fehler starten.

### 2. AWS-Grundaufbau mit Ansible
Bis Ende Sprint 2 richte ich mit einem Ansible-Playbook die AWS-Infrastruktur für das Portfolio ein. Dazu gehören mindestens: ein privater S3-Bucket mit Versionierung, eine CloudFront-Distribution mit gültigem ACM-Zertifikat in us-east-1 und – falls eine eigene Domain genutzt wird – ein DNS-Eintrag (Route 53 oder externer Provider). Das Playbook kann ohne manuelles Nachklicken erneut ausgeführt werden, ohne dass Fehler auftreten.

### 3. CI/CD mit GitHub Actions
Bis Ende Sprint 3 implementiere ich eine CI/CD-Pipeline mit GitHub Actions, die bei einem Push auf den Hauptbranch die Hugo-Seite baut, die Artefakte in den S3-Bucket in einen Release-Pfad hochlädt, den current/-Stand aktualisiert und eine CloudFront-Invalidation auslöst. Eine Änderung im Content-Verzeichnis ist spätestens 5 Minuten nach erfolgreichem Pipeline-Lauf unter der produktiven Domain sichtbar, ohne manuelle Eingriffe.

### 4. Sicherheit / Best Practices
Bis zur Abgabe der Arbeit erfülle ich folgende Sicherheitsanforderungen:
(a) Der S3-Bucket ist nicht öffentlich zugänglich und wird ausschließlich über CloudFront (OAC oder vergleichbarer Mechanismus) erreicht.
(b) GitHub Actions verwendet eine OIDC-IAM-Rolle ohne feste AWS-Access Keys.
(c) Für das Projekt ist ein monatliches AWS-Budget mit mindestens einer Warnschwelle eingerichtet.
Diese Punkte sind in der Betriebs- bzw. Infrastrukturdokumentation nachvollziehbar beschrieben.

### 5. Dokumentation nach Vorgaben
Spätestens eine Woche vor Abgabetermin liegt eine vollständige Projektdokumentation vor, die:
– die von der TBZ vorgegebenen Kapitel (Projektdefinition, Planung, Umsetzung, Tests, Fazit) abdeckt,
– die Architektur (Hugo, Ansible, AWS, CI/CD) mit mindestens einem Diagramm beschreibt,
– im Umfang und Format den Richtlinien der Semesterarbeit entspricht (Umfang: X–Y Seiten gemäß Vorgabe).

Auch liegt eine vollständige Betriebsdoku für die Verwendung des Produkts vor.

---

## Architektur


## SWOT Analyse

## Stärken (Strengths)

- Ich habe ein klar abgegrenztes technisches Ziel:  
  Hugo-Portfolio + AWS (S3, CloudFront, ACM, DNS) + Ansible + GitHub Actions. Das ist modern, praxisnah und gut vorzeigbar.
- Das Projekt zeigt genau die Themen, die für spätere Arbeitgeber spannend sind:  
  Infrastructure as Code, Cloud-Grundlagen, CI/CD, Security (S3 privat, HTTPS, OIDC statt Keys).
- Reproduzierbarkeit ist bewusst als Ziel eingeplant:  
  Andere sollen mit wenigen Schritten ihr eigenes Portfolio damit aufbauen können.
- Der Scope ist technisch fokussiert:  
  Eine statische Seite, ein Repo, eine Pipeline. Keine unnötigen Backend- oder Datenbank-Baustellen.

## Schwächen (Weaknesses)

- Es sind viele Technologien gleichzeitig im Spiel (Hugo, Ansible, AWS, IAM/OIDC, DNS, GitHub Actions).  
  Das erhöht Komplexität und Fehlerrisiko.
- IAM, Zertifikate und DNS sind fehleranfällig, vor allem ohne viel Routine.  
  Kleinste Konfigurationsfehler können viel Zeit kosten.
- Reproduzierbarkeit ist ein Zusatz-Ziel, das zusätzlichen Aufwand erzeugt  
  (Playbooks aufräumen, Variablen zentralisieren, Getting-Started-Doku).
- Gefahr, sich in Details zu verlieren  
  (Theme-Tuning, Performance-Feinschliff, „nice to have“ Features).

## Chancen (Opportunities)

- Das Projekt eignet sich sehr gut als späteres Portfolio-Beispiel:  
  „Ich habe eine komplette Cloud-/DevOps-Lösung selbst aufgebaut.“
- Ich kann mich gezielt mit DevOps-/Cloud-Themen positionieren:  
  Security, Automatisierung, Deployment-Pipelines, reproducible Setup.
- Das Setup ist wiederverwendbar:  
  für mein eigenes Portfolio, andere Hugo-Seiten oder zukünftige Projekte.
- Es gibt reichlich Stoff für eine gute Dokumentation und Präsentation:  
  Architekturdiagramme, Abläufe, Screenshots, Erläuterungen zu IAM/OIDC/DNS.

## Risiken/Bedrohungen (Threats)

- Zeitdruck und Scope Creep:  
  Wenn ich immer neue Ideen einbaue (WAF, Multi-Stage, komplexe Rollbacks, fancy Themes), kann das MVP zu spät oder nur halb fertig werden.
- Abhängigkeit von AWS, DNS und Zertifikaten:  
  Probleme mit Validation, Propagation oder Limits können den Fortschritt ausbremsen.
- Kosten und Limits:  
  Falsche Konfiguration (z. B. viele CloudFront-Invalidations, unnötige Logs) kann unerwartete Kosten verursachen.
- Bewertungssicht der Schule:  
  Wenn ich zu stark ins Technische abdrifte und Projektmanagement/Dokumentation vernachlässige, wirkt das in der Bewertung negativ.

## Wichtige Massnahmen

- **Klares MVP definieren und zuerst umsetzen**  
  Hugo lokal → AWS-Infrastruktur → Domain/HTTPS → CI/CD → „Push → Live“.  
  Reproduzierbarkeit und Feinschliff kommen erst danach.
- **Scope bewusst begrenzen**  
  Keine zusätzlichen Features, solange das MVP nicht stabil läuft. Neue Ideen nur aufnehmen, wenn Zeit und Nutzen es rechtfertigen.
- **Zeitpuffer für AWS/IAM/DNS einplanen**  
  Kritische Themen (ACM, OIDC-Rolle, DNS) bewusst früh einplanen und mit Reservezeit versehen.
- **Kosten im Blick behalten**  
  Budget-Alarm in AWS einrichten und das im Bericht erwähnen, um Kostenrisiko und Verantwortungsbewusstsein zu zeigen.
- **Dokumentation laufend mitführen**  
  Wichtige Entscheidungen und Stolpersteine zeitnah festhalten, statt alles am Ende zu rekonstruieren.  
  So stützt die Doku die Bewertung und gleichzeitig mein eigenes Portfolio.

## Übersicht Projektvorgehen

---

# Projekmanagement

## Scrum Definitions - TODO Cleanup notes

Definitions:
Scrum‑Regeln, Schätzung, Definitionen

Sprint‑Länge: 2 Wochen.

Zeremonien (pro Sprint):
- Planung (45 min)
- Daily (10 min, alleine reicht kurzer Check)
- Review & Retro (30 min)

Story‑Points‑Skala: 1, 2, 3, 5, 8, 13
1–2 = sehr klein
3–5 = normal
8+ = groß → evtl. aufteilen

Definition of Ready (DoR):
Ziel klar, Akzeptanzkriterien notiert, nötige Zugangsdaten vorhanden.

Definition of Done (DoD):
umgesetzt, gebaut/getestet, PR gemergt (falls nötig), live geprüft, kurze Doku/Notiz aktualisiert.

Sontige Notes für Doku:Als MVP gilt basically HUGO site auf AWS, die auf git push aktualisiert wird.
Ansible zum ausrollen/aufbauen der infrastruktur hinzuzufügen, ist zusatz

---

## Tools
- Ansible für das einmalige Einrichten auf AWS.
- Hugo für die statische Seite (ein Repo für alle Projekte).
- GitHub Actions für automatische Builds & Uploads bei jedem Push.
- AWS: S3 (Dateien), CloudFront (Auslieferung, HTTPS).

---

## Zeitplan

Sprint 0 - Initial Planung und Setup
Datum: 17. Nov - 30. Nov

Sprint 1 - HUGO + CI MVP
Datum: 10. Dez - 24. Dez

Ferien - 24.12.2025 - 04.01.2026

Sprint 2 - 
Datum: 04. Jan - 18. Jan

Sprint 3 - Abschluss
Datum: 18. Jan - 28. Jan

---

## Zwischengespräche Ergebnisse

### Zwischengespräch 01

- Leider verpasst da falsch terminiert - TODO ausführen


---

# Scrum Sprints

## Sprint 0 

### Sprint Planing

### Sprint Review

### Sprint Retrospective

---

## Sprint 1 

### Sprint Planing

### Sprint Review

### Sprint Retrospective

---

## Sprint 2 

### Sprint Planing

### Sprint Review

### Sprint Retrospective

---

## Sprint 3 

### Sprint Planing

### Sprint Review

### Sprint Retrospective