---
layout: default
title: 0. Übersicht
nav_order: 1
permalink: /
---

{: .no_toc }

# Semesterarbeit HF Cloud
Titel des Projekts: Azure Dynamic Groups - Access Governance Concept 
Name der Studierenden: Dodoe Ruminahui Mannale
Klasse / Studiengang: ITCNE25 - Cloud Native HF
Semester / Datum: 01 Semester - 09.07.2025 TODO
Betreuende Lehrperson: Samuel Müller (Azure), Caeser Roth (Projektmanagement)

# Inhaltsverzeichnis

Wird automatisch generiert TODO

# Abstract

## Ziele
Bei diesem Projekt geht es darum, ein besseres/möglichst automatisiertes Berechtigungs + Zugangsmanagement zu erschaffen.
Im moment wird zugang zu apps, mailverteiler rollen und Daten, manuell berechtigt. Teilweise werden Gruppen eingesetzt und teilweise werden berechtigungen einzelnen usern zugewiesen.
Das Projekt entstand aus der anfrage heraus, automatische Mailverteiler zu haben, welche nicht mehr gepflegt werden müssen.
Wir haben uns überlegt, das wir die Abteilungsdaten aus dem HR Tool (BC + SwissSalary modul) auslesen können (jeder user hat ein Abteilungscode zugewiesen) und diese verwenden können um pro abteilung sicherheitsgruppen und mailverteiler erstellen können, welchen wir die jeweilig benötigten Tools und berechtigungen (Digital Assets) zuweisen können.
Das ganze wird Hauptsächlich mit Powershell Runbooks in Azure automation umgesetzt.

Als erweiterung, haben wir uns überlegt, das wir pro "Digital Asset" eine Sicherheitsgruppe erstellen können, um jedes Asset nur einmal einrichten zu können. Wir führen eine Liste der Abteilungen und der zugewiesenen Assets und dadurch werden die Assets automatisch den entsprechenden Abteilungsgruppen zugewiesen.

Da wir eine grosse firma sind, bringt das mit sich, dass wir viele Assets nutzen und diese sich pro Abteilung unterscheiden.
Da man jedes Asset einzeln in unser konzept einbeten muss, bringt das einen langwirigen Prozess mit sich, in dem wir für jede Abteilung die Assets durchgehen, einpflegen und den entsprechenden gruppen zuweisen.
Deshalb ist in der Projektarbeit nur angedacht, ein MVP mit einer Pilotphase zu machen. Das effektive enrollment über die gesamt Firma erfolgt nach abschluss der Arbeit über mehrere Monate.

genauere Details zur Zielsetzung in der Einleitung (01-Einleitung)

### Digital Assets definition
Im folgenden wird Definitiert um was es sich bei Digital Assets handelt, beziehungsweise was wir als Digital Assets bezeichen.
Diese Assets werden von uns in zukunft einmalig eingerichtet werden und dann den entsprechenden Gruppen zugewiesen.
Diese Definition wird nach bedarf im späteren Verlauf des Porjekts erweitert.

**Zugriffs- & Sicherheits-Assets**
Azure AD-Rollen, RBAC, Conditional Access, PIM, Local AD Access  

**Dateizugriffs-Assets**
SharePoint-Site-Berechtigungen, NTFS-Rechte (Lokale AD Gruppen)

**Kommunikations-Assets**
Distribution Groups, Shared Mailboxes, Teams-Memberships.  

**Geräte- & App-Assets**  
Intune-Apps, Compliance Policies, Autopilot Profiles.  

**Lizenzen & Subscriptions**  
Microsoft 365-SKUs, Add-On-Subscriptions, Feature-Lizenzen.  

**Weitere Ressourcen**
Power BI Workspaces, Azure Functions/Logic Apps Zugriffe, Entitlement Management Packages PowerApp Zugriffe.

## Vorgehen
### Projektmanagement:
Für das Projektmanagement verweden wir bereits JIRA in unserer Abteilung, weshalb ich entschieden habe, das Projekt ebenfalls in JIRA zu managen.
Ich führe das Projekt im Scrum Modell durch. Dabei mache ich Sprints die jeweils zwei Wochen andauern, da ich zwischendurch andere aufgaben erledigen muss und ich somit genug tasks in einem sprint erledigen kann.
Ich habe das projekt in mehrere Phasen aufgeteilt und darunter detailiertere Tasks erfasst. 
Details folgen unter punkt 02-Projektplanung

### Involvierte Personen:
David Feser (Abteilungsleiter): Stakelholder/Auftragsgeber, anforderungen angegeben
Saskia Haas - Zuständig für interne Kommunikation an User
Dodoe Mannale - Projektmanagement + Umsetzung + Review(mit den andern beiden)

### Ausführung
TODO - weglassen? weiss nicht genau was hier rein soll. Detailierte umsetzungsbeschreibung erfolgt in anderem kapitel

### Dokumentation:
Durch die erfassung der einzelnen Tasks in JIRA, ist es sinnvoll in diesen Tasks Kommentare über den verlauf der Umsetzung zu dokumentieren.
Wo immer ich es für nötig gehalten habe, habe ich Details und Probleme direkt in den JIRA Tasks dokumentiert.

Für die Dokumentation des Sprints und jeweils erledigten Tasks gibt es eine Funktion in JIRA die Sprint Berichte erstellt. Diese Berichte werde ich im späteren Verlauf der Dokumentation aufzeigen.

### Testing
TODO - Vorgehen für Testing?
es gibt nicht wirklich die möglichkeit Unit Tests oder so zu machen. Weshalb ich einfach immer wieder die Scripts 

### Pilotphase
Die Pilotphase besteht aus zwei Teilen. Einerseits gibt es eine einzelne Pilotphase, für die automatisierten Mailverteiler, da dies ursprünglich eine Anforderung aus dem Management und schon länger erwünscht ist. 
Andererseits gibt es eine zweite Pilotphase in der die Funktionalität des automatisierten Asset Managements getestet werden.

**Automatisierte Mailverteiler**
Für die Mailverteiler wird der gesamte Bereich Services als Testobject dienen. Darunter sind mehrere Abteilungen, unter anderem auch die ICT.
Dabei erstelle ich mit dem Script, welches automatisch die Department Gruppen und Mailverteiler erstellt, erstmal nur die Gruppen für den Bereicht Services. Da ich als input im Moment ein CSV verwende, kann ich aus diesem alle anderen Abteilungen erstmal für die Pilotphase entfernen.

Die Pilotphase startet am 26.06.2025. Saskia übernimmt dabei die Kommunikation an die betroffenen User.
Die User werden eine Woche vor Start der Pilotphase über die neuen Mailverteiler und den Start der Pilotphase informiert.
Wir teilen Ihnen dabei eine Tabelle mit den bisherigen Mailverteilern und den neuen Mailverteiler. Dazu die Anweisung nur noch die neuen Mailverteiler zu verwenden und ein Feedback Formular. Ausserdem stehen Saskia und ich für Fragen über Mail zur Verfügung.


**Automatisiertes Digital Asset Management**
TODO - Detials müssen noch ausgearbeitet werden.
Pilotphase startet erstmal mit der ICT abteilung und einigen wenigen Assets aus verschiedenen Kategorien.

# Output -> TODO hierhin platzieren für eine bessere übersicht?

# Fazit? -> TODO
kurzes Fazit werde ich gegen ende der Projektarbeit hier erfassen

# Anhang
• Quellcode-Auszüge - Runbooks?? + beschreibunng TODO
• Screenshots - JIRA Screenshots -> direkt wo nötig
• Architektur überblick > zu designen TODO
• Projektpläne / Diagramme -> summaries JIRA
• Protokolle - Maybe JIRA Berichte TODO
• Glossar (falls nötig) TODO
• Quellenverzeichnis - ??? ms learn? chat gpt? Stack overflow? idk