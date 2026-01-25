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
Im folgenden Bild, seht ihr eine vereinfachte Darstellung der geplanten Architektur für dieses Produkt:

[Architektur Skizze](../../resources/images/architektur.png)

Wie ihr sehen könnt, ist das Ziel eine Repository zu haben, welche bei einem Push die Hugo Seite erstellt (build) und diese auf einen S3 Bucket hochlädt. Dieser S3 Bucket wird von CloudFront als Datenablage verwendet. CloudFront stellt vereinfach gesagt einen Webserver dar, welcher die Seite zur Verfügung stellt. 

> Note: Die Funktionsweise von CloudFront ist etwas komplizierter als ein normaler Webserver. Es bietet viele Vorteile wie schnelleren Zugriff durch chaching und weiteres. 

### Entscheidungen

**Warum HUGO?**
Hugo ist ein modernes Tool, um aus simplen Markdown, statische Websiten zu generieren, die modernen Standards entsprechen.
Es wird von vielen für Dokumentation, Blogs, etc. verwendet und wird aktiv weiter entwickelt.

**HUGO Theme: Stack**
Es gibt sehr viele verschiedene Themes für Hugo. Ihr könnt diese [hier](https://themes.gohugo.io) nachschauen.

Stack fand ich persönlich am ansprechendsten was Ästethik und Funktionalität angeht. Es scheint mir die beste Option für ein Portfolio das auf Hugo basiert.

> Source Link: https://github.com/CaiJimmy/hugo-theme-stack

**Hosting Provider AWS**
Für das Hosting verwende ich AWS aus diversen gründen.

- Automatisierung über Ansible scheint einfach, bzw. es gibt viele Resourcen zu diesem Thema
- Durch die TBZ haben wir ein Test Lab und man kann auch ein eigenen Test-Account als Entwickler erstellen. (Keine Entwicklungskosten)
- Das Hosting einer solchen Seite auf AWS ist auch Kostengünstig, nachdem das Test-Budget aufgebraucht ist. Wodurch es langfristig als günstiges Hosting verwendet werden kann.
- Dieses Setup beinhaltet diverse Themen aus den letzten Modulen AWS, Ansible, CI

**Ansible für Deployment**
Hierbei ging es hauptsächlich um den Lerneffekt.

Ansible kann zwar genutzt werden um Ressourcen zu deployen, wie ich es in diesem Fall nutze, allerdings ist es eigentlich dazu gedacht diverse Ressourcen zentral zu verwalten.

Es ist nicht dazu gedacht Ressourcen einmalig zu erstellen. Für sowas sollte eigentlich sowas wie Terraform verwendet werden.

Ich wollte aber Ansible besser kennenlernen und habe mich deshalb dafür entschieden, dass Projekt damit umzusetzen.

**Github Actions** 
Dies ist die einfachste Lösung, um auf Push einer Repository eine Aktion auszuführen.

Github Actions ist genau für solche Automatisierungen gebaut. Die CI Scripts über einen anderen Handler zu handhaben, hätte das ganze komplizierter gemacht und evtl. auch Zusatzkosten erzeugt.

---

## SWOT Analyse

### Stärken (Strengths)

- Ich habe ein klar abgegrenztes technisches Ziel:  
  Hugo-Portfolio + AWS (S3, CloudFront, ACM, DNS) + Ansible + GitHub Actions. Das ist modern, praxisnah und gut vorzeigbar.
- Das Projekt zeigt genau die Themen, die für spätere Arbeitgeber spannend sind:  
  Infrastructure as Code, Cloud-Grundlagen, CI/CD, Security (S3 privat, HTTPS, OIDC statt Keys).
- Reproduzierbarkeit ist bewusst als Ziel eingeplant:  
  Andere sollen mit wenigen Schritten ihr eigenes Portfolio damit aufbauen können.
- Der Scope ist technisch fokussiert:  
  Eine statische Seite, ein Repo, eine Pipeline. Keine unnötigen Backend- oder Datenbank-Baustellen.

### Schwächen (Weaknesses)

- Es sind viele Technologien gleichzeitig im Spiel (Hugo, Ansible, AWS, IAM/OIDC, DNS, GitHub Actions).  
  Das erhöht Komplexität und Fehlerrisiko.
- IAM, Zertifikate und DNS sind fehleranfällig, vor allem ohne viel Routine.  
  Kleinste Konfigurationsfehler können viel Zeit kosten.
- Reproduzierbarkeit ist ein Zusatz-Ziel, das zusätzlichen Aufwand erzeugt  
  (Playbooks aufräumen, Variablen zentralisieren, Getting-Started-Doku).
- Gefahr, sich in Details zu verlieren  
  (Theme-Tuning, Performance-Feinschliff, „nice to have“ Features).

### Chancen (Opportunities)

- Das Projekt eignet sich sehr gut als späteres Portfolio-Beispiel:  
  „Ich habe eine komplette Cloud-/DevOps-Lösung selbst aufgebaut.“
- Ich kann mich gezielt mit DevOps-/Cloud-Themen positionieren:  
  Security, Automatisierung, Deployment-Pipelines, reproducible Setup.
- Das Setup ist wiederverwendbar:  
  für mein eigenes Portfolio, andere Hugo-Seiten oder zukünftige Projekte.
- Es gibt reichlich Stoff für eine gute Dokumentation und Präsentation:  
  Architekturdiagramme, Abläufe, Screenshots, Erläuterungen zu IAM/OIDC/DNS.

### Risiken/Bedrohungen (Threats)

- Zeitdruck und Scope Creep:  
  Wenn ich immer neue Ideen einbaue (WAF, Multi-Stage, komplexe Rollbacks, fancy Themes), kann das MVP zu spät oder nur halb fertig werden.
- Abhängigkeit von AWS, DNS und Zertifikaten:  
  Probleme mit Validation, Propagation oder Limits können den Fortschritt ausbremsen.
- Kosten und Limits:  
  Falsche Konfiguration (z. B. viele CloudFront-Invalidations, unnötige Logs) kann unerwartete Kosten verursachen.
- Bewertungssicht der Schule:  
  Wenn ich zu stark ins Technische abdrifte und Projektmanagement/Dokumentation vernachlässige, wirkt das in der Bewertung negativ.

### Wichtige Massnahmen

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
---

# Projekmanagement Methodik

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

- TODO: besprechung beschreiben -> vorallem Tasks in JIRA sollten anders erstellt und besser getracked werden

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

In diesem Sprint ging es darum ein MVP zu erstellen. Dafür hatte ich geplant ein Template Portfolio zu erstellen und ein Workflow für Github Actions zu erstellen, welches die Seite baut und aktualisiert. Dabei habe ich allerdings rausgefunden, dass Hugo bzw das Stack Template, das meiste bereits abgdeckt. Genaueres dazu aber später.

| Eingeplante Backlog Items | Demo | Status |
|----------|----------|----------|
| [SCRUM-18](https://rumidesigns.atlassian.net/browse/SCRUM-18) | DEMO | Grösstenteils erledigt. Technische Dokumentation muss noch ausgeführt werden |
| [SCRUM-19](https://rumidesigns.atlassian.net/browse/SCRUM-19) | DEMO | Erledigt. Template Portfolio erstellt |
| [SCRUM-15](https://rumidesigns.atlassian.net/browse/SCRUM-15) | NO DEMO | Ongoing Task. Architektur skizze erstellt & Doku erweitert |
| [SCRUM-17](https://rumidesigns.atlassian.net/browse/SCRUM-17) | NO DEMO | Erledigt. Dev Umgebung vollständig eingerichtet |
| [SCRUM-17](https://rumidesigns.atlassian.net/browse/SCRUM-17) | NO DEMO | Canceled. Github Actions Workflow bereits gegeben |

#### DEMO - SCRUM-18 & SCRUM-19

In dieser kurzen Demo zeige ich die Live-Seite die aus dem bearbeitetem Template erstellt wird. Dies stellt den MVP dar. Das Endprodukt wird ähnlich aussehen, nur anders gehostet werden. Ihr könnt auch die Live-Seite selbst auschecken unter [https://ruminahuim.github.io/portfolio/](https://ruminahuim.github.io/portfolio/).

<video controls playsinline preload="metadata" width="100%">
  <source src="{{ '/resources/videos/SCRUM-59_lokaleVorschauTest.mp4' | relative_url }}" type="video/mp4">
  Your browser does not support the video tag.
</video>

> [Source Video File](../../resources/videos/SCRUM-59_lokaleVorschauTest.mp4)

#### Herausforderungen & Lösungen

1. **Mangeldende Recherche im Vorhinein:**
Ich habe in diesem Sprint festgestellt, dass ich nicht genug Informationen über die Funktionsweise von HUGO gesammelt hattte. Es hat sich rausgestellt das HUGO bereits so gebaut ist, dass bei einem Git Push, automatisch durch vordefinierte Github Actions Workflows, die Seite gebaut wird. Wenn diese über Github Pages gehostet wird, was eigentlich der Standard ist, wird die Live-Seite sommit auch automatisch aktualisiert. Dadurch Schien mir das Projekt nicht mehr so relevant. Was auch einen Einfluss auf meine Motivation in dem Projekt hatte.

Ich habe mich entschieden das Projekt trotzdem wie geplant weiterzuführen. Mein Projekt beinhaltet das Hosting auf AWS und das aufbauen der Hosting Umgebung mittels Ansible-Code, weshalb es als Lernprojekt trotzdem wirkungsvoll ist, obwohl das eigentliche Produkt, welches daraus entsteht, nicht unbedingt für die effektive Verwendung in der Realtität relevant ist. 

2. **Organisation:**
Ich hatte bisher noch kein Richtiges System/Vorgehen für mich definiert, um solche Projekte bzw. spezifisch die Schulprojekte durchzuführen. Dadurch ist der Ablauf meiner Projekte noch etwas chaotisch. Das Verwalten des Projekts in JIRA und die neue Dokumentationsstrukur, welche ich in diesem Projekt aufbaue, werden mir dabei helfen, zukünftige Projekte strukturierter durchzuführen.

3. **Favicon wird nicht aktualisiert:**
Beim anpassen des Templates, konnte ich das Favicon der Seite nicht anpassen. Gemäss der Dokumentation, sollte ich es genau so ersetzen, wie ich es getan habe. Ich konnte nicht herrausfinden, was genau das Problem war.

Da dies ein weniger Relevantes Detail ist, habe ich ein Task im Backlog erstellt und verschiebe dessen Erledigung zum Schluss.

4. **Mangelnde Kommunikation mit den Stakeholders:**
In diesem Projekt sind die Lehrer, welche die Arbeit kontrollieren, meine Stakeholder. Ich leider bisher zu wenig Updates zu dem Projekt mit ihnen geteilt, was die Beurteilung des Projekts für sie erschwert.

Ich werde in den nächsten Sprints darauf achten, nach jeder Session, ein Update zu senden.

#### Next Sprint

**Ziel:**
Im nächsten Sprint, geht es darum, via Ansible die Hosting Struktur aufzubauen. Ich muss also über Ansible auf AWS zugreifen und dort entsprechend ein S3 Bucket (Oder evtl eine EC2 Instanz) einrichten. Auch soll entsprechend CloudFront konfiguriert werden, um die Seite zu publizieren.

**Tasks die übernommen werden:**
- [SCRUM-15](https://rumidesigns.atlassian.net/browse/SCRUM-15) wird erstmal übernommen. Ich kläre noch ob es nötig ist, das in jeden Sprint mitzunehmen, oder ob es mehr Sinn macht, dies anders handzuhaben.
- [SCRUM-18](https://rumidesigns.atlassian.net/browse/SCRUM-18) wird übernommen und hat nun die höchste Priorität.

### Sprint Retrospective

**Was war gut?**
Aufgrund der bestehenden Hugo funktionalität, war es sehr einfach ein MVP für das Projekt zu machen und zu Demonstrieren.

Ausserdem konnte ich die Struktur für die Dokumentation vollständig festlegen und habe mir dadurch ein einfacheres System für solche Projekte aufgebaut.

**Was war nicht gut?**
Ich habe zu wenig mit den Stakeholders kommuiniziert, was zu dessen Unzufriedenheit geführt hat. Dies muss in Zukunft anders gehandhabt werden.

Ausserdem hat sich rausgestellt, dass dieses Projekt weniger reale Relevanz hat, als ich dachte.

Der Effektive Technische Teil der Arbeit (z.B. AWS mit Ansible einrichten), wurde aufgrund meiner Sprint Planung noch nicht angegangen, weshalb der Komplexer Part der Arbeit noch ansteht, obwohl die Deadline bereits ende dieses Monats ist. Dadurch könnte das Projekt noch aufgrund mangelnder Zeit scheitern, falls es für die nächsten Sprints nicht richtig verwaltet wird. 


**Welche Massnahmen können ergriffen werden?**
Ich werde von nun an, nach jeder Session, ein Update an die Stakeholders senden und auch nach kleineren Änderungen, ein Commits auf die Repository pushen, um die Kommunikation zu den Stakeholdern zu verbessern.

---

## Sprint 2 - AWS Ansible

In diesem Sprint sollte, das eigentliche Produkt zu erstellt werden. Das Ziel des Projekts ist ja eine reproduzierbare Infrastruktur auf AWS zu erstellen, auf welche das Portfolio gehostet werden soll. In diesem Sprint erstellte ich dafür die Infrastruktur einmal manuell, um die genaue Konfiguration festzuslegen und erstellte dann entsprechenden den Ansible Code zur automatischen Einrichtung des ganzen. Das ganze wurde natürlich auch entsprechend nach und nach getestet.

### Sprint Planing
Folgende Backlog items habe ich für den Sprint 2 eingeplant:
- Projektdokumentation für TBZ [SCRUM-15](https://rumidesigns.atlassian.net/browse/SCRUM-15) wurde wieder übernommen, da erst am Schluss des Projekts abgeschlossen werden kann.
- Hugo Portfolio einrichten [SCRUM-18](https://rumidesigns.atlassian.net/browse/SCRUM-18) wurde aus letztem Sprint übernommen, da noch ein subtask nicht als erledigt markiert war.
- Beispiele für Projekt posts erstellen [SCRUM-19](https://rumidesigns.atlassian.net/browse/SCRUM-19)
- ACM Zertifikat [SCRUM-20](https://rumidesigns.atlassian.net/browse/SCRUM-20)
- Privaten S3 Bucket einrichten [SCRUM-21](https://rumidesigns.atlassian.net/browse/SCRUM-21)
- Bucket Policy definieren [SCRUM-22](https://rumidesigns.atlassian.net/browse/SCRUM-22)
- Github Deployment to S3 - IAM Role [SCRUM-23](https://rumidesigns.atlassian.net/browse/SCRUM-23)
- Github Deployment to S3 - Actions Workflow bauen [SCRUM-24](https://rumidesigns.atlassian.net/browse/SCRUM-24)
- Versionierung des Hugo Portfolios [SCRUM-25](https://rumidesigns.atlassian.net/browse/SCRUM-25)
- Kosten Monitor [SCRUM-26](https://rumidesigns.atlassian.net/browse/SCRUM-26)
- CloudFront einrichten [SCRUM-28](https://rumidesigns.atlassian.net/browse/SCRUM-28)
- Domain kaufen & einrichten [SCRUM-29](https://rumidesigns.atlassian.net/browse/SCRUM-29)
- Route53 DNS Setup [SCRUM-33](https://rumidesigns.atlassian.net/browse/SCRUM-33)
- Reproduzierbares Setup mit wenigen Befehlen [SCRUM-133](https://rumidesigns.atlassian.net/browse/SCRUM-133)
- Bisherige Technische Dokumentation ausführen [SCRUM-147](https://rumidesigns.atlassian.net/browse/SCRUM-147)

![Planned Sprint 2](..\..\resources\images\Sprint_2_Plan.png)
> Leider habe ich vergessen am Anfang des Sprints ein Screenshot zu machen, weshalb das Bild den Status der Tasks nach beendigung des Sprints anzeigt

### Sprint Review

Wie bereits erwähnt, habe ich in diesem Sprint den Ansible Anteil und somit das Schlussendliche Produkt des Porjektes erstellt. Ich habe dabei zuerst alle Komponenten, die für das Hosting des Hugo Portfolios benötigt wurden, einmal manuell eingerichtet wodurch ich testen konnte, wie es genau fuktioniert. Auch konnte ich feststellen wo Probleme auftreten können und worauf man achten muss. 
Danach konnte ich das ganze mit unterstüzung von AI recht einfach in Ansible Code umwandeln. Dabei habe ich jeweils beschrieben welche Komponenten ich benötigte und den Code, den AI erstellt hat reviewed, getested und debuged. So konnte ich nach und nach die Komponenten hinzufügen und testen. 
Zum Schluss habe ich diverse vollständige Tests durchgeführt und anpassungen gemacht, sowie auch eine Benutzeranleitung erstellt und nach und nach angepasst.

| Eingeplante Backlog Items | Demo | Status |
|----------|----------|----------|
| [SCRUM-15](https://rumidesigns.atlassian.net/browse/SCRUM-15) | NO DEMO | Weiter bearbeitet, allerdings noch lange nicht abgeschlossen |
| [SCRUM-18](https://rumidesigns.atlassian.net/browse/SCRUM-18) | NO DEMO | Bereits erledigt. Subtask wurde im letzten Sprint versehentlich nicht als abgeschlossen markiert |
| [SCRUM-19](https://rumidesigns.atlassian.net/browse/SCRUM-19) | NO DEMO | Dupliziert eigentlich SCRUM 18, wurde deshalb als gecancelled markiert. |
| [SCRUM-20](https://rumidesigns.atlassian.net/browse/SCRUM-20) | DEMO | Erledigt. Zertifikat wurde manuell erstellt und Ansible Role wurde erstellt und getestet |
| [SCRUM-21](https://rumidesigns.atlassian.net/browse/SCRUM-21) | DEMO | Erledigt. S3 Bucket wurde manuell erstellt und Ansible Role wurde erstellt und getestet |
| [SCRUM-22](https://rumidesigns.atlassian.net/browse/SCRUM-22) | NO DEMO | Erledigt. Wurde im TASK SCRUM-21 miterledigt. |
| [SCRUM-23](https://rumidesigns.atlassian.net/browse/SCRUM-23) | DEMO | Erledigt. IAM Rolle wurde manuell erstellt und Ansible Role wurde erstellt und getestet |
| [SCRUM-24](https://rumidesigns.atlassian.net/browse/SCRUM-24) | DEMO | Erledigt. Github to S3 Deployment Workflow gebaut und getestet |
| [SCRUM-25](https://rumidesigns.atlassian.net/browse/SCRUM-25) | NO DEMO | Cancelled. Da die Github Repository bereits die Versionierung durch die funktion als Repository handelt, und man einfach alte versionen wiederherstellen und pushen kann, ist keine weitere Versionierung nötig |
| [SCRUM-26](https://rumidesigns.atlassian.net/browse/SCRUM-26) | NO DEMO | Cancelled. Der Kosten Monitor wird nicht automatish erstellt, da für das Monitoring die Billing-Informationen des Users angepasst werden müssen. Dies sollte der User manuell einrichten falls benötigt. |
| [SCRUM-28](https://rumidesigns.atlassian.net/browse/SCRUM-28) | DEMO | Erledigt. Cloudfront wurde manuell erstellt und Ansible Role wurde erstellt und getestet |
| [SCRUM-29](https://rumidesigns.atlassian.net/browse/SCRUM-29) | NO DEMO | Erledigt. Domain gekauft und entsprechend konfiguriert. |
| [SCRUM-33](https://rumidesigns.atlassian.net/browse/SCRUM-33) | DEMO | Erledigt. Route53 DNS wurde manuell erstellt und Ansible Role wurde erstellt und getestet |
| [SCRUM-133](https://rumidesigns.atlassian.net/browse/SCRUM-133) | DEMO | Erledigt. Es besteht ein mit Ansible reproduzierbare umgebung, die alles benötigte einrichtet. Es kann in wenigen schritten ausgefürht werden und diese sind dokumentiert. |
| [SCRUM-147](https://rumidesigns.atlassian.net/browse/SCRUM-147) | NO DEMO | Cancelled. Dieser Task wurde stattdessen als Subtask von SCRUM-15 neu erfasst |

#### DEMO - Ansible

In dieser Demo, wird die ausführung der Ansible Plabooks demonstriert. Im ersten Video wird die Initiale ausführung gezeigt. Diese bereitet alles vor, sodass nur noch das Zertifikat in CloudFront angehängt werden muss. Im Zweiten Video wird das Post_Validation Plabook ausgeführt, welches das Zertifikat anhängt. 

<video controls playsinline preload="metadata" width="100%">
  <source src="{{ '/resources/videos/FirstDeployment.mp4' | relative_url }}" type="video/mp4">
  Your browser does not support the video tag.
</video>

> [Source Video File](../../resources/videos/FirstDeployment.mp4)

<video controls playsinline preload="metadata" width="100%">
  <source src="{{ '/resources/videos/PostValidationPlaybook.mp4' | relative_url }}" type="video/mp4">
  Your browser does not support the video tag.
</video>

> [Source Video File](../../resources/videos/PostValidationPlaybook.mp4)

#### DEMO - Github Actions TODO-> videos verlinken

Beschreibung

<video controls playsinline preload="metadata" width="100%">
  <source src="{{ '/resources/videos/Sprint2_Demo.mp4' | relative_url }}" type="video/mp4">
  Your browser does not support the video tag.
</video>

> [Source Video File](../../resources/videos/Sprint2_Demo.mp4)

#### Herausforderungen & Lösungen

**1. Debugging:**
Das debuggen war dank der Unterstüzung von Codex, eigentlich nicht an sich eine Schwierige Herausforderung, allerdings war es der grösste Teil der Arbeit, welche ich für diesen Sprint machen musste. Nach jeder Änderung musste man halt nochmals das ganze ausführen und teilweise auch auf DNS Propagation oder die Validierung des Zertifikats warten.
Nicht die anspruchsvollste Herausforderung, allerdings doch ein grosser Zeitaufwand, selbst mit der Hilfe von AI Tools.

**2. Testing:** 
Wie bereits erwähnt, musste man immer wieder einzelne Komponenten oder die ganze Infrastruktur löschen und neu erstellen. Deshalb habe ich relativ früh angefangen, ein "destroy"- und ein "redeploy"- Playbook erstellt. Diese löschen die zuvor erstellte Infrastruktur und können auch nur einzelne komponenten löschen/neu erstellen. Als Default Eistellung, lasse ich das Zertfikat und die Route53 (DNS) Einstellungen. Denn wenn diese neu erstellt werden, muss man ein paar Stunden warten um die Website wieder live zu sehen. Sie sollten also nur für vollständige Tests verwendet werden.

**3. Zertifikat Validierung:**
Um die Website über HTTPS mit der eigenen Domäne nutzen zu können, muss man ein Zertifikat dafür erstellen und das über DNS validieren. Das Problem hierbei, ist dass dieser Prozess mehrere Stunden dauern kann. Damit nachher aber alles korrekt funktioniert, muss es nach der Validierung auch in der CloudFront konfiguration angehängt werden. Ich habe keinen Weg gefunden, dieses anzuhängen, bevor es validiert wurde. 

Somit gab es nur 2 Optionen. Die erste ist, dass man ein Wartefenster einbaut, indem Ansible wartet, bis das Zertifikat als validiert markiert wurde und hängt es danach an.
Die Zweite Option, ist ein weiteres Playbook zu erstellen, dass ausgeführt wird, sobald das Zertifikat validiert wurde und das entsprechend das Zertifikat bei CloudFront änhängt.

Mit der ersten Option, müsste man den PC auf dem man Ansible laufen lässt, für mehrere Stunden im Hintergrund laufen lassen. Dies ist vielleicht eine Valide Option für einen Server, aber dieses Produkt richtet sich an Privatpersonen, die das ganze einfach auf ihrem normalen PC ausführen wollen.

Deshalb habe ich ein "post_validation" Playbook erstellt. Sobald das Zertifikat validiert wurde, kann man dieses ausführen und es schliesst das Setup ab. Nach eine Weile ist die Seite dann bereits online.

**4. Credentials in den Commits:**
Während der Entwicklung des Ansible Codes, habe ich die gleichen User Credentials immer wieder benötigt, um auf AWS zugreifen zu können. Der einfachheit halber habe ich diese im Readme File eingetragen um sie immer wieder rauskopieren zu können. Dies war ein grosser Fehler.

Abgesehen davon, dass jemand meine Credentials während der Entwicklung des Projekts missbrauchen hätte können, falls ich diese durch ein Push hochgeladen hätte, entstand noch ein Weiteres Problem.
Die Credentials waren nun in einer Menge Commits gespeichert und da Github ein Sicherheitsfeature hat, welches solche Credentials erkennt und den Upload blockiert, konnte ich meine Commits nicht mehr pushen.

Das habe ich leider recht spät gemerkt. Ich musste also schlussendlich in alle Commits rein und die Credentials dort rauslöschen. Das war recht mühsam, selbst mit der Unterstüzung von AI.

Ausserdem hatte ich auch noch versehentlich in einem test-branch gearbeitet und musste den Main branch überschreiben.

**5. Tasks in JIRA mit AI geplant:**
Das dies ein grösseres Problem war, habe ich erst im Zwischengespräch bemerkt, welches ich mit Parisi Corrado hatte. 

Ursprünglich hatte ich die Tasks/Stories im JIRA alle mithilfe von AI erstellt, da ich mir noch nicht sicher war, wie man Stories richtig erfasst.
Die Struktur des ganzen war dadurch dann aber sehr chaotisch. Ich habe zwar selbst die Epics erstellt und sommit ein wenig Struktur bewahren können, aber es gab zu viele zu kleine Tasks oder Tasks die doppelt erfasst wurden etc.

Auch war die Art wie ich die Stories im Jira erfasst hatte nicht die beste. Ich habe die Story-beschreibungen direkt als Titel der Stories genommen. Dadurch konnte man sich nur Schwer ein richtigen überblick im JIRA machen.

Ich habe nun noch einiges aufgeräumt, die Titel angepasst und den inhalt in die Beschreibung geschrieben. Aktzeptanzkriterien und Subtasks habe ich um Zeit zu sparen in diesem Projekt allerdings so gelassen wie sie waren.

Nun habe ich ein besseres verständnis von Stories und wie man ein Scrum Projekt richtig aufsetzt. Deshalb werde ich das im nächsten Projekt besser erfassen können.

#### Next Sprint

**Ziel:**
Der nächste Sprint ist gleichzeitig der letzte. Dannach steht bereits die Abgabe des Projekts an. In diesem Sprint geht es also darum, dass Projekt vollständig abzuschliessen. Das heisst, finaler Test und feinschliff des Produkts, Projektdokumentation abschliessen und Präsentation/Demo vorbereiten.

**Tasks die übernommen werden:**
- [SCRUM-15](https://rumidesigns.atlassian.net/browse/SCRUM-15) Ongoing Task. Muss im folgenden Sprint abgeschlossen werden.
- [SCRUM-133](https://rumidesigns.atlassian.net/browse/SCRUM-133) Dokumentation grösstenteils abgeschlossen, allerdings kann es noch für den User vereinfacht werden.

### Sprint Retrospective

**Was war gut?**
Ich bin konnte den Ansible Code viel schneller fertig stellen als ursprünglich erwartet. Dadurch hatte ich mehr Zeit das Produkt möglichst gut zu machen.

Durch die Rückmeldung von Armin Dörzbach konnte ich auch einige wichtige Änderungen machen, um die Qualität des Endprodukts zu verbessern.

Ausserdem bin ich sehr zufrieden mit dem Endprodukt. Im letzten Sprint habe ich erwähnt, dass ich dachte dieses Produkt hätte keinen realen Wert. Allerdings denke ich doch das es sehr gut eingesetzt werden kann. Es gibt viele HUGO User die ihre Seite lieber auf AWS hosten möchten als auf Github pages und dies vereinfacht den Prozess dafür ungemein. Und man kann man die Infrastruktur jederzeit neu erstellen, bei ausfällen oder falls man es einfach ne Weile nicht mehr benötigt und es dann doch wieder einsetzen möchte etc.

**Was war nicht gut?**
Ich war etwas nächlässig mit dem Nachtragen der erledigten Arbeiten in JIRA. Dadurch hat JIRA nicht mehr den eigentlichen Status des Projekts dargestellt. Das wiederum kann auch Metriken verfälschen und Stakeholder können sich nicht auf die dortigen Informationen verlassen.

**Welche Massnahmen können ergriffen werden?**
Für das nächste Projekt, werde ich JIRA ohne AI aufsetzen und das Projekt besser strukturieren. Daruch wird es dann auch viel einfacher den korrekten Status nachzutragen und ich bin motivierter das auch richtig umzusetzen.

AI war zwar trotzdem hilfreich, da ich zuvor nie ein Scrum Projekt aufgesetzt hatte, aber da ich jetzt ein besseres Verständniss dafür habe, denke ich das es effektiver ist auf AI bei diesem Schritt zu verzichten.

---

## Sprint 3 - Abschluss

In diesem Spürint schliessem wir das Projekt ab. Es gibt einige Tasks die das Produkt verbessern sollen, aber hauptsächlich geht es darum das Produkt nochmals vollständig zu testen (zur Qualitätssicherung) und die Dokumentation abzuschliessen. Ausserdem möchte ich noch eine Demo vorbereiten. Einerseits für die kommende Dokumentation, andereseits aber auch um ein Video-Guide zu erstellen, welches in der Produkt-Repository angezeigt werden soll.

### Sprint Planing
Folgende Backlog items habe ich für den Sprint 3 eingeplant:
- Reproduzierbares Setup mit wenigen Befehlen [SCRUM-133](https://rumidesigns.atlassian.net/browse/SCRUM-133)
- 404 Error Seite [SCRUM-31](https://rumidesigns.atlassian.net/browse/SCRUM-31)
- Template generalisieren [SCRUM-148](https://rumidesigns.atlassian.net/browse/SCRUM-148)
- Portfolio Template und Ansible Code in einer Repo zusammenführen [SCRUM-150](https://rumidesigns.atlassian.net/browse/SCRUM-150)
- "How to use"  dokumentation [SCRUM-14](https://rumidesigns.atlassian.net/browse/SCRUM-14)
- Test Cases definieren für Abschlusstests & Testen [SCRUM-143](https://rumidesigns.atlassian.net/browse/SCRUM-143)
- Screenshots der Ausführung dokumentieren [SCRUM-16](https://rumidesigns.atlassian.net/browse/SCRUM-16)
- Projektdokumentation für TBZ [SCRUM-15](https://rumidesigns.atlassian.net/browse/SCRUM-15)
- Demo Video für Präsentation und User Guide erstellen [SCRUM-151](https://rumidesigns.atlassian.net/browse/SCRUM-151)
- Präsentation des Projekts vorbereiten [SCRUM-27](https://rumidesigns.atlassian.net/browse/SCRUM-27)
- Projekt offiziell abgeben [SCRUM-154](https://rumidesigns.atlassian.net/browse/SCRUM-154)

![Planned Sprint 3](..\..\resources\images\Sprint_3_Plan.png)

### Sprint Review

| Eingeplante Backlog Items | Demo | Status |
|----------|----------|----------|
| [SCRUM-](https://rumidesigns.atlassian.net/browse/SCRUM-) | NO DEMO | desc |
| [SCRUM-](https://rumidesigns.atlassian.net/browse/SCRUM-) | NO DEMO | desc |
| [SCRUM-](https://rumidesigns.atlassian.net/browse/SCRUM-) | NO DEMO | desc |
| [SCRUM-](https://rumidesigns.atlassian.net/browse/SCRUM-) | NO DEMO | desc |
| [SCRUM-](https://rumidesigns.atlassian.net/browse/SCRUM-) | NO DEMO | desc |
| [SCRUM-](https://rumidesigns.atlassian.net/browse/SCRUM-) | NO DEMO | desc |
| [SCRUM-](https://rumidesigns.atlassian.net/browse/SCRUM-) | NO DEMO | desc |
| [SCRUM-](https://rumidesigns.atlassian.net/browse/SCRUM-) | NO DEMO | desc |
| [SCRUM-](https://rumidesigns.atlassian.net/browse/SCRUM-) | NO DEMO | desc |


#### Herausforderungen & Lösungen

### Sprint Retrospective

**Was war gut?**

**Was war nicht gut?**

**Welche Massnahmen können ergriffen werden?**