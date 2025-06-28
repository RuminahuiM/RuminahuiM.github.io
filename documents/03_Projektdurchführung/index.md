---
layout: default
title: 3. Projektdurchführung
nav_order: 4
has_children: true
---

# 3. Projektdurchführung

{: .no_toc }


• Beschreibung der Umsetzung
    -> jeden einzelnen Sprint
    -> Einbau des AD Sync Tools
• Vorgehensweise bei der Problemlösung
    the fuck??

• Technische Umsetzung (Cloud-Dienste, IaC, CI/CD etc.)
    -> Logging + Auditing in Azure + Alerts (noch nicht gebaut)
    -> PowerBI + DataGen2
    -> Az Automation (dev + prod environment) > Runbooks
    -> Storage Account für Manuelle department DB (im moment gleicher storage account )
    -> Sharepoint Lists
    -> Logic App für Sync

• Herausforderungen & Lösungen
    -> Probleme aufschreiben
        -> PowerBI Dataflows per https scheiss > managed identity + datagen2 storage
        -> Hybrid Worker
        -> Entscheidungen für ausnahmen mancher attribute
        -> Runbooks debuggen > error meldungen scheisse > formatierungsproblem nicht lösbar
        -> Aufteilung in zwei Runbooks
        -> Entscheidung Logic App für Sharepoint
        -> memberOf nesting doch nicht möglich > grund für Problem -> abklärung durch GPT gemacht
        -> Crapy Data des HR Tools für Departments -> eigene Departments
        -> Logic app sharepoint DATA scheisse -> Runbook simplify > nicht funktioniert > umgehung für den Moment (cut your losses) + XML in select nicht geklapt + For loops nicht geklapt weil select nur für arrays -> 4h zeit verschwendet
        -> Rollback CSV -> testing oder so > noch nicht voll funktionsfähig > backups vorhanden > für den Moment nicht dringend bis nach pilot
        -> DL groups > existent Groups rename (noch nicht eingebaut) > 8h update fenster von Addressbook + 24h downloadfenster in outlook (nicht beachtet) + unhide für gruppen + hide alte gruppen noch nicht automatisiert
• Änderungsmanagement
    -> gemäss scrum > aufgefallen, notiert und im gleichen oder nächsten sprint bearbeitet
    -> geplante änderungen auflisten
