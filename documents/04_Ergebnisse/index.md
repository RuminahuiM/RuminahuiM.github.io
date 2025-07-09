---
layout: default
title: 4. Ergebnisse / Analyse
nav_order: 5
has_children: true
---

{: .no_toc }

# 4. Ergebnisse / Analyse

Um die Resultate transparent darzustellen, werden die zuvor definierten Produkte/Artefakte einzeln betrachtet, deren Ergebnisse zusammengefasst und geplante Anpassungen erläutert.

## SwissSalary-zu-AD Sync

### Status
Funktioniert grundsätzlich; der Trigger für die tägliche Ausführung ist noch nicht definiert. Das Rollback-Skript befindet sich in Überarbeitung, und ein Alerting-Mechanismus ist noch zu implementieren.

### Testing & Ergebnisse
- Probelauf mit dem Parameter `-WhatIf` zeigte die korrekten Anpassungen.  
- Testlauf für einen einzelnen Benutzer bestätigte die fehlerfreie Attributaktualisierung.  
- Vollständiger Lauf über alle User: Stichprobennahmen bestätigten eine ordnungsgemässe Datenaktualität.

### Review & Bewertung
Das Artefakt erfüllt die Anforderungen eines Proof of Concept. Vor dem produktiven Einsatz müssen jedoch:
- das Rollback-Skript stabilisiert und umfassend getestet werden  
- ein Alerting für fehlgeschlagene Ausführungen eingerichtet werden  

## Mail Distribution List Generation & Updates

### Status
Teilweise funktionsfähig: Die Pilotphase wurde nach wenigen Tagen abgebrochen. Die Mailverteiler werden korrekt erstellt, jedoch werden keine Benutzer in der GUI angezeigt. Mit einzelnen Abteilungscodes funktioniert das Runbook nach der letzten Änderung zuverlässig, die Abfrage mehrerer Codes ist jedoch weiterhin fehlerhaft.

### Testing & Ergebnisse
- In der Pilotphase wurden alle Verteiler für die "Services"-Abteilungen erstellt.  
- Die Filter-Queries lieferten die korrekten Ergebnisse, und Testmails wurden erfolgreich versendet.  
- Die Verteiler erschienen jedoch weder im Exchange-Adressbuch noch zeigten sie Mitglieder in Outlook an.

### Review & Bewertung
Das Artefakt erfüllt den Grossteil der Anforderungen. Das verbleibende Hauptproblem ist die gleichzeitige Abfrage mehrerer Abteilungscodes. Gemäss Microsoft-Dokumentation sollte dies möglich sein und wird in einem Folge-Sprint (ausserhalb des aktuellen Scopes) adressiert.


## Asset Assignment Handling

### Status
Funktionsfähig: Änderungen in den MS Lists lösen die Logic App aus, und das Runbook erstellt korrekt formatierte Queries für die jeweiligen Asset-Gruppen.

### Testing & Ergebnisse
- Eine Test-Asset-Gruppe (dynamische Azure AD Security Group) wurde im **Digital Assets Catalog** angelegt.  
- Im **Departments Inventory** wurde die IT-Abteilung eingetragen und das Test-Asset zugewiesen.  
- Das Runbook generierte automatisch die passende Filter-Query und konnte mehrere Abteilungscodes verarbeiten.  
- Die Benutzer wurden daraufhin korrekt der dynamischen Asset-Gruppe zugewiesen und erhielten die entsprechenden Zugriffsrechte.

### Review & Bewertung
Das Artefakt erfüllt vollständig die definierten Anforderungen und war das am einfachsten zu implementierende Feature. Für den produktiven Einsatz sollte der Skriptcode jedoch noch einmal optimiert und auf Robustheit geprüft werden.  


## Self Service

### Status
Die MS Lists ("Departments Inventory" und "Digital Assets Catalog") sind eingerichtet, die zugehörigen Self-Service-Prozesse (z. B. MS Forms-Intake, automatisierte Ticket-Erstellung) wurden jedoch noch nicht finalisiert.

### Testing & Ergebnisse
- Änderungen in den MS Lists lösen erfolgreich die Logic App aus und aktualisieren die JSON-Daten im Azure Storage Account.  
- Nutzeroberflächen und Freigabe-Workflows stehen noch aus.

### Review & Bewertung
Das Self-Service-Interface ist grundlegend etabliert, erfüllt aber derzeit nicht alle Anforderungen. Ein detaillierter Plan für vollständig automatisierte Nutzerprozesse liegt bereits vor und wird nach Abschluss der Semesterarbeit umgesetzt.  


## Logging & Alerting

### Status  
Noch nicht implementiert – aus zeitlichen Gründen und aufgrund der geringeren Priorität im Proof of Concept verschoben.

### Testing & Ergebnisse  
Keine Tests durchgeführt.

### Review & Bewertung  
Die Anforderungen wurden nicht erfüllt. Die Architektur für Alerting (Azure Monitor Alerts für fehlgeschlagene Runbook- und Logic App-Ausführungen) und Audit-Logging (Log Analytics Workspace, regelmässige Reports) ist jedoch bereits definiert und entsprechende Tasks sind dokumentiert.

----

# Zusammenfassung der Ergebnisse

Die umgesetzten Artefakte im Proof of Concept haben sich als tragfähig erwiesen:  
- Die **SwissSalary-zu-AD-Synchronisation** liefert konsistente und verlässliche Benutzerattribute.  
- Die **Mailverteiler-Generierung** automatisiert die Verteilung nahezu fehlerfrei, mit einer kleinen Einschränkung bei Mehrfachcodes die noch gelöst wird.  
- Das **Asset Assignment Handling** funktioniert zuverlässig und stellt Berechtigungen automatisiert bereit.  
- Das **Self-Service-Interface** ist grundlegend etabliert, und **Logging & Alerting** ist konzeptionell geplant.

Mit gezielten Optimierungen (Rollback-Skript, Mehrfachcode-Filter, Monitoring, Überarbeitung der Scripts) ist das System bereit für den produktiven Rollout.

----

# Bewertung der Zielerreichung

### Automatisierte Berechtigungsverwaltung  
Implementierung dynamischer Gruppen in Azure, die basierend auf dem Abteilungscode Berechtigungen (z. B. für SharePoint, Intune, Mailverteiler) automatisch zuweisen.

**Bewertung:** **Erreicht.** Die automatische Zuweisung von Assets funktioniert bereits mit der Anlage neuer Asset-Einträge.

### Auditing und Monitoring  
Einrichtung eines zentralen Systems zur Dokumentation und Überwachung aller Änderungen an Berechtigungen, um inkonsistente oder unautorisierte Zuweisungen frühzeitig zu erkennen.

**Bewertung:** **Nicht erreicht.** Das Konzept für Alerting und Audit-Logging liegt vor, konnte jedoch aus Zeitgründen im Proof of Concept nicht umgesetzt werden.

### Systemintegration, Skalierbarkeit und Änderungsprozesse  
Definition und Implementierung klarer Prozesse zur Aufnahme neuer Abteilungen, Rollen, Mailverteilerlisten und weiterer künftiger Erweiterungen, sodass das System flexibel und nachhaltig anpassbar bleibt.

**Bewertung:** **Erreicht.** Die Prozesse sind dokumentiert und strukturiert definiert. Die vollständige Automatisierung und Schulung erfolgt im Rahmen der nächsten Projektphasen.

### Pilotphase  
Innerhalb der Semesterarbeit sollte eine Pilotphase mit der Abteilung ICT durchgeführt werden, um das Konzept an einer realen Abteilung zu validieren.

**Bewertung:** **Teilweise erreicht.** Die Mailverteiler-Pilotphase wurde planmässig gestartet und lieferte wertvolle Erkenntnisse. Die Asset-Zuweisungs-Pilotphase wurde durch Tests an einer Beispielgruppe ersetzt, um die Automatisierung zu verifizieren.