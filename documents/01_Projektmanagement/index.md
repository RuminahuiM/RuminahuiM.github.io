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

TODO - Skizze erstellen und einfügen

### Entscheidungen - TODO

- HUGO in generall
- HUGO Theme: Stack https://github.com/CaiJimmy/hugo-theme-stack
- Hosting Provider / Cloud : AWS
- CI handler: Github Actions
- why Ansible for Deployment / Reproducibility 


---

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

 TODO - Projektvorgehen detailiert beschreiben

---

# Projekmanagement

## Scrum Definitions - TODO Cleanup notes

Definitions:
Scrum‑Regeln, Schätzung, Definitionen

Sprint‑Länge: 2 Wochen.

Zeremonien (pro Sprint):
- Planung (45 min)
- Daily (kurzer check und nur an Tagen, an denen am Projekt weitergearbeitet wird)
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

Struktur Sprint Review:
- welcome & rules
- what will and will not be demonstrated?
- list all items from the sprint. will it be demoed? Status?
- Do the demos (solicit feedback while going down the list)
- Discuss problems and  opotunities
- share product backlog
- next sprint -> wich items will we take over to it?
- conclude, thanks and praise

Struktur Retrospective:
- what went well?
- what went wrong?
- How can this be improved?
- What problems did i encounter and how were the resolved?

---

## Tools
- Ansible für das einmalige Einrichten auf AWS.
- Hugo für die statische Seite (ein Repo für alle Projekte).
- GitHub Actions für automatische Builds & Uploads bei jedem Push.
- AWS: S3 (Dateien), CloudFront (Auslieferung, HTTPS).

---

## Zeitplan

**Sprint 0 - Initial Planung und Setup** <br>
**Datum:** 17. Nov - 30. Nov

**Sprint 1 - HUGO + CI MVP** <br>
**Datum:** 10. Dez - 24. Dez

**Ferien** <br>
**Datum:** 24.12.2025 - 04.01.2026

**Sprint 2 -** <br>
**Datum:** 04. Jan - 18. Jan

**Sprint 3 - Abschluss** <br>
**Datum:** 18. Jan - 28. Jan

---

## Zwischengespräche Ergebnisse

### Zwischengespräch 01

- Leider verpasst da falsch terminiert - TODO ausführen

### Zwischengespräch 02

### Zwischengespräch 03


---

# Scrum Sprints

## Sprint 0 - Setup
Im ersten Sprint, bzw. im Sprint 0, ging es darum den Porjektplan zu erstellen und die Entwicklungsumgebung einzurichten.
Da es in meinen Augen eher Vorbereitung für ein funktionierendes Scrum Projekt ist und noch kein richtiger Sprint, werde ich in diesem Sprint keine vollständige Sprint Review machen.
Jedenfalls keine mit Videoaufnahme und auch grundsätzlich eine gekürztere Version.

### Sprint Planing
Am Anfang dieses Sprints, gab es noch kein Product Backlog, weshalb ich Theoretisch innerhalb des Sprints die entsprechenden Backlog Items in den Sprint eingefügt habe.

Folgende Backlog items habe ich für den Sprint 0 eingeplant:
- Initialen Projektplan in JIRA erstellen [SCRUM-119](https://rumidesigns.atlassian.net/browse/SCRUM-119)
- PRJ Doku erstellen (github pages initial) [SCRUM-120](https://rumidesigns.atlassian.net/browse/SCRUM-120)
- Als Projektleiter möchte ich ein zentrales GitHub‑Repo mit Branchenschutz, damit ich sauber arbeiten kann [SCRUM-12](https://rumidesigns.atlassian.net/browse/SCRUM-12)
- Als TBZ Schüler benötige ich eine Projektdokumentation gemäss den Vorgaben der TBZ [SCRUM-15](https://rumidesigns.atlassian.net/browse/SCRUM-15)
- Als Entwickler möchte ich meine lokale Umgebung bereit haben, damit Builds/CLI funktionieren [SCRUM-17](https://rumidesigns.atlassian.net/browse/SCRUM-17)

![Planned Sprint 0](..\..\resources\images\Sprint_0_Plan.png)

### Sprint Review

Da ich wie erwähnt, für den Sprint 0 keine vollständige Sprint Review machen werde, wird es in diesem Sprint Review keine Demos geben. Ich werde allerdings kurz die Backlog Items sowie dessen Status hier schriftlich durchgehen und aufgetretene Probleme erläutern.

| Eingeplante Backlog Items | Demo | Status |
|----------|----------|----------|
| [SCRUM-119](https://rumidesigns.atlassian.net/browse/SCRUM-119) | NO DEMO | Erledigt. JIRA umgebung ist ersstellt und User stories eingeplant |
| [SCRUM-120](https://rumidesigns.atlassian.net/browse/SCRUM-120) | NO DEMO | Erledigt. Github Pages Projektdoku erstellt und Struktur erstellt |
| [SCRUM-12](https://rumidesigns.atlassian.net/browse/SCRUM-12) | NO DEMO | Erledigt. Github Repository für das zu erstellende Produkt ist erstellt |
| [SCRUM-15](https://rumidesigns.atlassian.net/browse/SCRUM-15) | NO DEMO | In Arbeit. Ich habe die Initiale Dokumentationsstruktur vorbereitet und angefangen die Dokumentation auszufüllen. Allerdings kann diese Story erst als abgeschlossen gelten, wenn die Doku fertig ist. |
| [SCRUM-17](https://rumidesigns.atlassian.net/browse/SCRUM-17) | NO DEMO | In Arbeit. Ich habe angefangen meine Dev-Umgebung einzurichten, allerdings sind noch viele Subtasks offen geblieben |

#### Herausforderungen & Lösungen
1. **Zeitplanung:** In dieser Zeitspanne kamen in meinem Privatleben viele Dinge zusammen, was mir wenig Zeit für das Projekt lies. Ich hatte leider die Zeitplanung auch noch nicht gemacht, was das ganze erschwerte und wodurch ich in diesem Sprint nicht so richtig vorran kam.
Um das in zuukunft zu verhindern, habe ich die Grobe Zeitplanung der Sprints abgeschlossen und mir entsprechend Zeit für die nächsten zwei Wochen eingeplant. Ich möchte nun jede Woche kurz einplanen, wann ich mir Zeit für das Projekt nehme.

2. **Verpasste besprechung:** Leider habe ich die erste Porjektbesprechung mit Parisi Corrado verpasst. Diese hätte mir wahrscheinlich sehr geholfen, da es mir etwas schwer fällt die Vorbereitungen für ein Scrum Porjekt richtig zu machen und ich da eine zweite Meinung gebrauchen könnte.
Ich habe vor diese Besprechung noch vor Ende Dezember nachzuholen, warte allerdings noch auf eine Rückmeldung ob das möglich ist.

3. **Ungewisse Komplexität:** Da ich viele verschiedene Tools für dieses Projekt einsetze und ich die meisten davon noch nicht richtig kenne, fällt mir die Planung der Tasks etwas schwer. Vorallem wenn es um sowas wie CloudFront geht, das ich erst durch die Recherche für dieses Projekt entdeckt habe und noch nicht so richtig anschauen konnte.
Hierbei hat mir die Planung zusammen mit ChatGPT sehr geholfen, da es bereits 'weiss' welche Tasks z.B. zur Einrichtung von CloudFront gehören. Ich habe nun die Tasks so übernommen, werde aber erst wenn es soweit ist, feststellen können, ob ChatGPT mir das korrekt angegeben hat. Ich muss also damit rechnen, evtl. mehr Zeit investieren zu müssen als erwartet bei solchen Tasks.

#### Next Sprint

**Ziel:**
Ziel für den nächsten Sprint, ist es ein MVP zu erstellen. Dabei werde ich mich darauf fokusieren, das HUGO Template vorzubereiten und Github Actions einzurichten.
Für dieses Projekt ist das Wichtigste nämlich, am Schluss ein öffentliches Portfolio zu haben, welches sich nach jedem Commit aktualisiert. Die zusätzlichen Features sind weniger Relevant.

**Tasks die übernommen werden:**
- [SCRUM-15](https://rumidesigns.atlassian.net/browse/SCRUM-15) wird erstmal übernommen. Ich kläre noch ob es nötig ist, das in jeden Sprint mitzunehmen, oder ob es mehr Sinn macht, dies ander hanzuhaben.
- [SCRUM-17](https://rumidesigns.atlassian.net/browse/SCRUM-17) wird übernommen und hat nun die höchste Priorität.

**Neue Inputs:**
- Was auch wichtig sein wird, ist im nächsten Sprint die Architektur des Pordukts zu skizzieren und die Skizze in der Dokumentation nachzutragen. Das ist bereits ein SubTask von [SCRUM-15](https://rumidesigns.atlassian.net/browse/SCRUM-15), aber ich möchte einfach nochmals besonderen Fokus darauf setzen. Ich habe die Priorisierung des Tasks entsprechend erhöht.

### Sprint Retrospective

**Was war gut?**
Die Initiale Planung des Projekts ist abgeschlossen. Die Dokumentation ist live verfügbar und die Struktur der Dokumentation ist vorgegeben.
Dadurch ist das wichtigste vorbereitet um das Projekt sauber durchzuführen, auch wenn noch einige Details fehlen.

**Was war nicht gut?**
Die Zeitplanung war in diesem Sprint nicht gut. Ich habe mir nicht richtig eingeplant, wann ich an dem Projekt arbeite und so wurde das Projekt stark verzögert.
Ausserdem habe ich die Zwischenbesprechung auf ein falsches Datum eingeplant und diese dadurch verpasst. Wenn man den PRJ-Leiter als Stakeholder für dieses Projekt ansieht, habe ich somit ein sehr wichtiges Meeting verpasst. Das wäre in einem echten Projekt nicht aktzeptabel und darf deshalb nicht nochmals vorkommen.

**Welche Massnahmen können ergriffen werden?**
Von nun an Plane ich jede Woche, sowie am beginn jedes Sprints, meine Zeit ein, welche ich für das Projekt verwenden möchte. Ausserdem plane ich für den nächsten Sprint mehr Zeit ein als üblich, da ich verlorene Zeit aufholen muss, um das Projekt rechtzeitig abschliessen zu können.

---

## Sprint 1 - MVP
In diesem Sprint werde ich ein MVP erstellen, welches eine HUGO-Website & Github Actions beinhaltet, wodurch die Seite auf Commit aktualisiert werden soll. Den Einsatz von Ansible und AWS lasse ich noch aussen vor. Falls allerdings Hugo und Github Actions weniger Zeit beanspruchen als erwartet, werde ich das MVP mit ansible und AWS erweitern.

Ansible und AWS sollen verwendet werden, um das Projekt öffentlich verfügbar und reproduzierbar zu machen. Beides ist weniger relevant, da das Hauptziel des ganzen Projekts, ist ein Portfolio zu haben, welches sich bei Commits automatisch aktualisiert.

### Sprint Planing
Folgende Backlog items habe ich für den Sprint 1 eingeplant:

- Als Entwickler möchte ich meine lokale Umgebung bereit haben, damit Builds/CLI funktionieren. [SCRUM-17](https://rumidesigns.atlassian.net/browse/SCRUM-17)
- MVP Workflow um die HUGO Site lokal zu bauen definieren [SCRUM-132](https://rumidesigns.atlassian.net/browse/SCRUM-132)
- Als Besucher möchte ich eine startfähige Hugo‑Seite sehen, damit ich einen ersten Eindruck bekomme [SCRUM-18](https://rumidesigns.atlassian.net/browse/SCRUM-18)
- Als Besucher möchte ich Navigation und 2–3 Projektseiten, damit Inhalte auffindbar sind. [SCRUM-19](https://rumidesigns.atlassian.net/browse/SCRUM-19)
- Als TBZ Schüler benötige ich eine Projektdokumentation gemäss den Vorgaben der TBZ [SCRUM-15](https://rumidesigns.atlassian.net/browse/SCRUM-15)

![Planned Sprint 1](..\..\resources\images\Sprint_1_Plan.png)

### Sprint Review

### Sprint Retrospective

---

## Sprint 2 

### Sprint Planing
Folgende Backlog items habe ich für den Sprint 2 eingeplant:
-  [SCRUM-]()
-  [SCRUM-]()

![Planned Sprint 2](..\..\resources\images\Sprint_2_Plan.png)

### Sprint Review

### Sprint Retrospective

---

## Sprint 3 

### Sprint Planing
Folgende Backlog items habe ich für den Sprint 3 eingeplant:
-  [SCRUM-]()
-  [SCRUM-]()

![Planned Sprint 2](..\..\resources\images\Sprint_3_Plan.png)

### Sprint Review

### Sprint Retrospective