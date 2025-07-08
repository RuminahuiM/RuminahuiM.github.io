---
layout: default
title: Herausforderungen & Lösungen
parent: 3. Projektdurchführung
nav_order: 3
---

{: .no_toc }
# Herausforderungen & Lösungen

Im Verlauf des Projekts sind verschiedene technische und organisatorische Fragestellungen aufgetreten. Die nachfolgenden Abschnitte beschreiben die zentralen Herausforderungen sowie die gewählten Lösungsansätze.

## Lokale AD-Aktualisierung via Hybrid Runbook Worker

**Herausforderung:** PowerShell-Skripte, die lokale AD-Attribute ändern, können nicht direkt in Azure ausgeführt werden, da Azure AD Connect nur eine Synchronisation von On-Premise nach Azure unterstützt.

**Lösung:** Installation eines Hybrid Runbook Workers auf dem lokalen AD-Connect-Server. Das Automatisierungsskript wurde in zwei separate Runbooks aufgeteilt:

1. **Datenaufbereitung:** Extraktion der Power BI-Daten und Transformation in JSON für die einfache Weiterverarbeitung.  
2. **AD-Aktualisierung:** Ausführung auf dem Hybrid Worker, um die lokalen Benutzerattribute zu aktualisieren.

## Einschränkungen bei der Attributsaktualisierung

**Herausforderung:** Bestimmte AD-Attribute (z. B. Name, UPN, E-Mail) dürfen aufgrund interner Vorgaben und potenzieller Nebeneffekte nicht automatisiert geändert werden.

**Lösung:** Implementierung einer Ausnahme-Liste, die sensible Attribute von der automatischen Aktualisierung ausschließt. Künftige Änderungen an UPN oder E-Mail sollen über einen Alarm- und Genehmigungsprozess gesteuert werden.

## Testverfahren und Rollback-Probleme

**Herausforderung:** Das geplante Rollback-Skript hat zunächst nicht wie erwartet funktioniert. Fehlende Tests in der Produktivumgebung erschwerten die Validierung.

**Lösung:** Vorab-Tests mit dem `-WhatIf`-Parameter zur Simulation der Änderungen, anschließend Tests an einem einzelnen Benutzer. Das Rollback-Skript wird vor dem Produktivstart überarbeitet und vollumfänglich getestet.

## Runbook-Debugging und Fehlermeldungen

**Herausforderung:** Azure Automation Runbooks zeigten unleserliche Fehlermeldungen, da die PowerShell-Ausgabe nicht korrekt gerendert wird und Farbcodierung in den Fehlermeldungen hinterlegt ist.

**Lösung:** Deaktivierung der farbigen Ausgabe am Anfang des Runbooks:

```powershell
# Farbige Ausgabe im Runbook deaktivieren für besser lesbare Logs
$PSStyle.OutputRendering = [System.Management.Automation.OutputRendering]::PlainText
```
Einige Fehlermeldungen innerhalb von Funktionen erfordern noch weitergehende Untersuchungen.

## Erstellung von Exchange-Verteilern via Hybrid Worker

**Herausforderung:** Das Exchange Online-Modul ist in Azure Runbooks nicht voll kompatibel.

**Lösung:** Ausführung aller Exchange-spezifischen Runbooks auf dem Hybrid Runbook Worker und Bereitstellung der erforderlichen Module direkt auf dem Server. Der Import erfolgt dynamisch im Skript.

## MemberOf-Filter für dynamische Gruppen nur als Preview

**Herausforderung:** Der memberOf-Operator für Azure AD Dynamic Groups ist seit drei Jahren nur als Preview-Feature verfügbar und in Standard-Tenants nicht zugänglich.

**Lösung:** Anpassung der Architektur: Wegfall der verschachtelten Abteilungsgruppen. Asset-Gruppen filtern nun direkt nach den in MS Lists definierten Abteilungscodes, wodurch Abteilungsgruppen entbehrlich werden und Compute-Budget gespart wird.

## SharePoint-Datenzugriff

**Herausforderung:** Direkter Zugriff auf SharePoint-Inhalte via Graph API in Runbooks war aufgrund von Authentifizierungslimitierungen und komplexen verschachtelten Datenstrukturen problematisch.

**Lösung:** Umsetzung einer Logic App, die die SharePoint-Daten extrahiert und in schema-konsolidierter Form in den Storage Account schreibt. Ein kleines Helper-Runbook übernimmt die Bereinigung und Normierung der Daten.

## Limitierung der Role-Assignable Dynamic Groups

**Herausforderung:** Azure erlaubt maximal 500 Role-Assignable Dynamic Groups pro Tenant.

**Lösung:** Verzicht auf Abteilungsgruppen und Konzentration auf Asset-Gruppen, die nur bei Bedarf Role-Assignable aktiviert werden.

## Herausforderungen bei dynamischen Mailverteilern

**Namen und Sichtbarkeit:** Neue Verteiler werden im Exchange Adressbuch erst nach bis zu 8 Stunden aktualisiert, im Outlook Offline Address Book nach 24 Stunden. Im Pilot fehlte diese Berücksichtigung, weshalb neue Gruppen am ersten Tag nicht sichtbar waren.

**GUI-Probleme bei Custom-Filtern:** Dynamische Verteiler mit benutzerdefinierten Filtern zeigten keine Mitglieder in der GUI.

**Probleme mit Precanned-Filtern und Mehrfachcodes:** Precanned-Filter unterstützen in der GUI nur Einzelcodes; die Kombination mehrerer Codes wird derzeit nicht zuverlässig angezeigt.

**Nächste Schritte:** Weitere Untersuchungen nach Abschluss der Semesterarbeit, mögliche Anpassung der Filterlogik.

