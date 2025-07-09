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

----

**Inhaltsverzeichnis**
 TODO

----

# Abstract

## Zielsetzung
Ziel dieses Projekts ist die Einführung eines möglichst automatisierten Berechtigungs- und Zugangsmanagements in einer hybriden Azure-Umgebung. Derzeit erfolgen Berechtigungen auf Applikationen, Mailverteilern und Daten teils manuell, teils über statische Gruppen. Ausgangspunkt war der Wunsch nach automatischen Mailverteilern, die keiner manuellen Pflege mehr bedürfen.

Geplant ist, die Abteilungs­informationen aus dem HR-System (Business Central sowie SwissSalary-Modul) über synchronisierte extensionAttribute auszulesen. Basierend auf dem jeweiligen Abteilungscode werden für jede Abteilung dynamische Sicherheitsgruppen und Mailverteiler erstellt, denen anschliessend die benötigten digitalen Assets (Tools, Berechtigungen, Lizenzen usw.) zugewiesen werden.Die Automatisierung wird überwiegend mittels PowerShell-Runbooks in Azure Automation realisiert.

### Defintion "Digital Assets"
Im Rahmen dieses Projekts werden "Digital Assets" als einmalig zu konfigurierende Ressourcen verstanden, die Abteilungsgruppen später zugeordnet werden. Die Definition kann im Projektverlauf erweitert werden.

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

----

## Vorgehen

### Projektmanagement:
Das Projekt wird mittels Scrum-Framework in JIRA organisiert. Geplant sind Zwei-Wochen-Sprints, um neben den Projektaufgaben parallel weitere IT-Pflichten erfüllen zu können. Die übergeordneten Phasen und einzelnen Tasks sind in JIRA detailliert angelegt (siehe Kapitel 02 – Projektplanung).

### Involvierte Personen:
**David Feser (Abteilungsleiter):** Stakeholder und Auftraggeber
**Saskia Haas:** Verantwortlich für interne Kommunikation
**Dodoe Mannale:** Projektleitung, Umsetzung, Review
**Alain Knaff:** PowerBI & BC Spezialist, Teilaufgaben

### Ausführung
Die Automatisierung erfolgt über Azure Automation Runbooks (PowerShell 7.2) und eine unterstützende Logic App, die Dataflows aus Power BI und MS Lists in ADLS Gen2 persistiert. Tägliche Trigger lösen das Datenaufbereitungs-Runbook aus, das anschliessend auf einem Hybrid Runbook Worker lokale AD-Änderungen ausführt. Managed Identities sichern dabei den Zugriff auf alle relevanten Ressourcen.

### Dokumentation:
Alle Umsetzungsschritte und Entscheidungen werden in den JIRA-Tasks dokumentiert. Zusätzlich werden die in JIRA generierten Sprint-Berichte als Nachweis der erledigten Arbeiten in den Anhang übernommen.

### Testing
Folgende Testfälle stellen die korrekte Funktionsweise sicher:
- **AD-Synchronisation:** Werden die Benutzerattribute (Abteilung, Standort, Sprache) zuverlässig im lokalen AD aktualisiert?  
- **Mailverteiler & Department Groups:** Werden Verteilerlisten und Abteilungsgruppen in Exchange/Azure AD korrekt erstellt?  
- **Asset-Zuweisung:** Erhalten die Department-Gruppen die definierten Assets (Security Groups, Lizenzen, Apps) entsprechend der MS Lists-Zuordnung?  

### Pilotphase
Die Pilotphase gliedert sich in zwei Teilphasen: Erstens erfolgt die Pilotierung des automatisierten Mailverteilungskonzepts, da dies bereits seit Längerem eine zentrale Forderung des Managements war. Zweitens wird in einer separaten Teilphase die Funktionalität des automatisierten Digital Asset Managements getestet.

**Automatisierte Mailverteiler**
Die Pilotphase beginnt am 26.06.2025 und umfasst zuerst die Abteilung "Services" (inklusive Teilabteilungen wie ICT). Saskia Haas koordiniert die Anwender­kommunikation. Eine Woche vor Start werden betroffene Nutzer über das Verfahren informiert und zu Feedback via Formular eingeladen.


**Automatisiertes Digital Asset Management**
Die zweite Pilotphase richtet sich auf die Abteilung ICT und testet die Zuweisung ausgewählter Digital Assets aus unterschiedlichen Kategorien. TODO - link (Details in Kapitel 05 – Pilotierung Digital Assets.)

----

## Output
Im Rahmen des Projekts wurden folgende Kern-Artefakte bereitgestellt:
- PowerShell-Runbooks zur automatischen Synchronisation von SwissSalary-Daten und AD-Attributen  
- Runbook "Generate-DistributionLists" für Mailverteiler mit "Precanned"-Filtern  
- Logic App und Blob-Container für Self-Service-Daten aus MS Lists  
- Runbook "Update-AssetAssignments" für dynamische Asset-Gruppen-Queries  

----

## Fazit
Das Proof of Concept hat gezeigt, dass die automatisierte Berechtigungs- und Verteilerverwaltung zuverlässig funktioniert. Mit gezielten Nacharbeiten (Rollback-Skript, Monitoring, Mehrfachcode-Filter) ist das System bereit für den produktiven Einsatz.  

----

# Anhang
- Glossar
- Quellenverzeichnis
- Runbook-Powershell-Scripts Quellcode
