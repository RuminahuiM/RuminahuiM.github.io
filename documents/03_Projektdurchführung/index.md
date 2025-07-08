---
layout: default
title: 3. Projektdurchführung
nav_order: 4
has_children: true
---

{: .no_toc }

# 3. Projektdurchführung

## Recherche / Analyse
Zu Beginn des Projekts stand eine vertiefte Recherche im Fokus, um sämtliche technischen und organisatorischen Rahmenbedingungen für die dynamische Gruppen- und Asset-Provisionierung zu klären. In dieser Phase habe ich insbesondere folgende Fragestellungen bearbeitet:

1. Funktionsweise von Dynamic Groups und Dynamic Distribution ListsIch habe untersucht, wie Azure AD Dynamic Groups und Exchange Online Dynamic Distribution Lists per PowerShell erstellt und verwaltet werden können. Dabei bestätigte sich, dass sich beide Konzepte über entsprechende Abfragen auf die extensionAttribute filtern lassen, in dem der Abteilungscode der Benutzer hinterlegt wird.

2. Einsatz des memberOf-Filters zur GruppenschachtelungUrsprünglich plante ich, Asset-Gruppen über den memberOf-Operator dynamisch aus Abteilungsgruppen zu befüllen, die ebenfalls automatisch erstellt werden sollten. Später stellte sich jedoch heraus, dass dieser Operator seit drei Jahren nur als Preview-Feature verfügbar ist und in Standard-Tenants nicht unterstützt wird.

3. Leistungs- und Quota-BeschränkungenDie Aktualisierung von Dynamic Groups unterliegt einem täglichen Compute-Budget, das bei einer großen Anzahl von Gruppen zu verzögerten Aktualisierungen führen kann. Ich habe beschlossen, zunächst die Standard-Mechanismen zu nutzen und später zu prüfen, ob ein maßgeschneidertes PowerShell-Runbook erforderlich ist, um Gruppen unabhängig vom Azure-Budget zu aktualisieren.

4. Konzept der GruppenstrukturBasierend auf den Erkenntnissen definierte ich ursprünglich eine Haupt-Dynamic Group pro Abteilung und jeweils eine Gruppe je Digital Asset. Die Zuordnung erfolgt über den memberOf-Filter in den Asset-Gruppen, um Redundanzen zu vermeiden. Diese Architektur wurde im Projektverlauf angepasst; Details folgen in den folgenden Kapiteln.

5. Toolauswahl: Logic Apps vs. RunbooksNach Abwägung weiterer Kriterien (Lesbarkeit, Komplexität, Wartbarkeit) entschied ich mich für Azure Automation Runbooks als primäre Automatisierungsplattform. Logic Apps setze ich nur dann ein, wenn Standard-Connectoren und einfache Workflow-Schritte eine schnelle Umsetzung erlauben. Diese Entscheidung begründet sich durch folgende Punkte:
- Skripte (Runbooks) sind gemäß PowerShell-Best Practices besser lesbar und versionierbar.
- Logic Apps eignen sich für einfache, schnell umsetzbare Workflows, können jedoch bei spezifischen Berechtigungen oder komplexen Aktionen unübersichtlich werden.

6. Datenhaltung und InventarFür das zentrale Abteilungs- und Asset-Inventar wählte ich Microsoft Lists, da diese nahtlos in SharePoint integriert ist – unsere zentrale Wissensablage. Durch MS Lists entsteht eine Self-Service-Übersicht, während der Großteil der Automatisierung über Runbooks abläuft.

7. Datenquellen und AnforderungenDie Abteilungs- und Mitarbeiterdaten werden in Business Central (SwissSalary Plugin/Modul) verwaltet und sind per Power BI abrufbar. In Abstimmung mit dem PowerBI-Verantwortlichen wurden maßgeschneiderte Reports erstellt, um:
- Mitarbeiterstammdaten inkl. Abteilungs- und Sprachcodes zu extrahieren
- Eine vollständige Liste aller vorhandenen Abteilungen bereitzustellen

### Weitere offene Fragen, die im weiteren Projektverlauf geklärt wurden:

Vollständigkeit der Abteilungsliste in Business Central (siehe Kapitel TODO- einfügen)

Vorhandene manuelle AD- und Exchange-Gruppen ohne konsistentes Namensschema

Detaillierte Klassifikation der benötigten Berechtigungsarten (vgl. Digital Assets Definition)

Einrichtung und Prüfung der Azure Dynamic Membership-Quotas (TODO)