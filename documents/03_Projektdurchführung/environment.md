---
layout: default
title: Environment Setup
parent: 3. Projektdurchführung
nav_order: 1
---

{: .no_toc }

# Environment Setup 

Für eine übersichtliche Dokumentation werden die zentralen Komponenten und Umgebungen zusammenhängend beschrieben, die für die Automatisierung der Dynamic Groups benötigt werden.  

## PowerBI mit DataLake Gen 2 Ablage

Die HR-Daten werden in Business Central (SwissSalary-Modul) verwaltet und über Power BI aufbereitet:

**Dataflow und Berichtserstellung**
In Zusammenarbeit mit dem Power BI-Spezialisten wurde ein Dataflow angelegt, der die relevanten Tabellen (Mitarbeiterstammdaten und Abteilungsinventar) extrahiert und in zwei CSV-Dateien im Data Lake abspeichert.
- Tabelle "Mitarbeiter": Enthält Benutzerattribute wie Abteilungs- und Sprachcodes.
- Tabelle "Abteilungen": Liste aller gültigen Abteilungscodes mit Bezeichnung.

**Data Lake Gen2 Anbindung**
Ein neues Power BI-Workspace ist mit einem ADLS Gen2 Storage Account verknüpft. Power BI legt automatisiert tägliche Snapshots der Dataflows als CSV-Dateien mit Zeitstempel im Storage ab.

**Zugriff über Managed Identity**
Der Azure Automation Account verwendet eine System Managed Identity, die Leseberechtigung auf den entsprechenden Storage-Container erhält. Somit werden die CSV-Dateien direkt per PowerShell eingelesen und verarbeitet.

TODO - Bild von powerBI Dataflow  
TODO - Bild von PowerBI DataLake Gen2 connection
TODO - Bild von Daten in AZ Storage account
Abb. 4.1: Power BI Dataflow und Gen2-Verbindung

----

## AZ Automation Account (dev-environment)

Alle Runbooks die ich darin erstelle, sind powershell 7.2 Runbooks.

Für die Entwicklungs- und Testphase wurde ein Azure Automation Account mit dem Namen "Main-Test" angelegt:

**Runbook-Typ:** PowerShell 7.2 Runbooks
**Zweck:** Zentrale Entwicklungs- und Testumgebung für alle Automatisierungsskripte
**Zukünftige Prod-Umgebung:** Nach der Pilotphase wird ein separater, produktiver Automation Account eingerichtet, in dem restriktivere Zugriffsrechte und Alerts definiert werden.

TODO - Bild der Az account overview

### Managed identity
Der Automation Account verfügt über eine System Managed Identity, die folgenden Zugriffsrechten zugewiesen wurde:

- **Storage Blob Reader** auf dem Data Lake Gen2
- **Entra Groups Administrator** für Gruppen- und Benutzerabfragen
- **Exchange-Berechtigungen** zur Verwaltung von Distribution Groups

TODO - Bild der Managed Identity

### Key Vault
Für Credentials, die nicht über Managed Identity abgedeckt werden können, wird der Credential Vault des Automation Accounts genutzt:

- **Service User AD:** Kennwort für lokale AD-Änderungen (Least-Privilege-Account zum Schreiben der ExtensionAttributes)
- **Service User SharePoint:** Anmeldedaten für SharePoint-API-Zugriffe in einer unterstützenden Logic App

TODO - Bild einfügen

----

## Hybrid Runbook Worker 

Ein Hybrid Runbook Worker wurde auf dem lokalen AD-Connect-Server installiert, um PowerShell-Skripte unmittelbar in der On-Premise-Umgebung auszuführen. Dies ermöglicht lokale AD-Änderungen (z. B. Anpassung von User-Attributen) und reduziert Ausführungszeiten und Azure-Kosten, da die Hauptlast on-premises verarbeitet wird.

----

## Powershell Modules
Für die Runbooks wurden folgende Module importiert:
TODO - modulliste erstellen

----

## Sharepoint

Als Self-Service-Interface und Inventar werden zwei Microsoft Lists in SharePoint Online verwendet.

### Departments Inventory

In der Liste **"Departments Inventory"** werden Abteilungen gepflegt, da die HR-Liste in Business Central unvollständig ist und sich nicht direkt für die Automatisierung eignet. System Engineers können hier neue Abteilungen anlegen und mit Digital Assets aus dem **Digital Assets Catalog** verknüpfen. Bevor die Provisionierung erfolgt, muss der Status **"Approved"** manuell auf **YES** gesetzt werden. Anschliessend führt jeweils ein PowerShell-Runbook:

- die Erstellung des dynamischen Mailverteilers durch  
- die automatische Zuweisung aller in **AssignedAssets** definierten Assets  

Ursprünglich war geplant, zusätzlich eine dynamische Sicherheitsgruppe pro Abteilung anzulegen. Dieser Schritt wurde jedoch aufgrund eines technischen Limitationsfehlers (siehe Kapitel "Herausforderungen & Lösungen") vorerst ausgesetzt.

**Felder der MS List "Departments Inventory"**  
- **Title:** Name der Abteilung  
- **AssignedAssets:** Dropdown-Auswahl aus dem **Digital Assets Catalog**; Komma-getrennte Liste der Asset-Namen (z. B. "Intune, EntraAdmin, SRV-SharepointSite")  
- **AssignedAssetsSecurityGroups:** Dropdown-Auswahl aus dem Katalog; Komma-getrennte Liste der zugehörigen SecurityGroup-Namen  
- **DepartmentCode:** Abteilungscode für die Filterung in Dynamic Groups  
- **Approved:** YES/NO (Standard: NO); manuelle Freigabe zur Ausführung des Provisioning-Runbooks  
- **SpecialCodes:** Zusätzliche Abteilungscodes (z. B. ICT1, ICT2) für Unterteams  
- **ParentCode:** Code der übergeordneten Abteilung, notwendig für verschachtelte Mailinglisten  

### Digital Assets Catalog

In der Liste **"Digital Assets Catalog"** werden alle Digital Assets erfasst, die automatisiert zugewiesen werden können. Jedes Asset ist einer eigenen dynamischen Sicherheitsgruppe zugeordnet. System Engineers wählen aus dieser Liste die gewünschten Assets aus, die auf Abteilungsebene zugewiesen werden sollen. Die Runbooks nutzen die Einträge zur Erstellung und Zuweisung der entsprechenden Gruppen.

**Felder der MS List "Digital Assets Catalog"**  
- **Title:** Name des Digital Assets  
- **SecurityGroup:** Dynamische Sicherheitsgruppe für die Asset-Zuweisung  
- **Description:** Beschreibung des Assets und dessen Einsatzzweck  

### Teams-Integration

Die beiden MS Lists wurden in einem Teams-Kanal als Registerkarten eingebunden, um direkte Bearbeitung und Monitoring durch das System Engineering-Team zu ermöglichen:

TODO - bild der beiden listen einfügen

----

## Datenablage in Storage Account für Verarbeitung

Um die Verarbeitung der in den Microsoft Lists **"Departments Inventory"** und **"Digital Assets Catalog"** gespeicherten Daten mit PowerShell zu vereinfachen, wurde im bestehenden ADLS Gen2 Storage Account ein eigener Blob-Container **`manualdb`** angelegt. Dort werden die einzelnen Listen in JSON Format abgelegt.

Die Runbooks greifen direkt auf diese JSON-Dateien zu und können die Daten so ohne zusätzliche API-Aufrufe lokal einlesen und verarbeiten. 

----

## Logic apps 

Für die Verbindung zu SharePoint wurde eine einzelne Logic App erstellt, die über einen User auf Sharepoint authentifiziert wird, um den Sharepoint Connector zu verwenden. Dies zu implementieren stellte sich als vesentlich simpler heraus, als die Daten über ein Runbook auszulesen. Sie besitzt:

- **Schreibzugriff** auf den Azure Data Lake Gen2 (aktuell im selben Storage-Account, künftig geplant als separater Azure Storage zur besseren Abtrennung der Komponenten)  
- **Lesezugriff** auf der Sharepoint Site in welcher die MS-Listen abgelegt sind.
- **Rechte zur Verwaltung von Azure Automation Jobs** im Automation Account "Main-Test"

Die Logic App übernimmt:

1. Die **Synchronisation** der benötigten SharePoint-Daten in den Storage-Container.  
2. Das **Auslösen** eines kleinen PowerShell-Runbooks (Helper-Runbook), das Datensätze bereinigt und normiert, damit sie vollständig über Skripte verarbeitet werden können.

Dieser Ansatz war nötig, da das direkte Auslesen bestimmter SharePoint-Inhalte in Logic Apps an Grenzen stiess. Durch die Kombination von Logic App + Helper-Runbook bleibt der Workflow einfach, sicher und wartbar.

----

## Ausblick: Produktiv-Umgebung

Für die spätere produktive Umgebung sind geplant:

- Aufteilung in Development- und Production-Accounts
- Feingranulares Rollen- und Berechtigungsmanagement im Automation Account
- Alerts und Monitoring für fehlerhafte Runbook- und Logic App-Ausführungen