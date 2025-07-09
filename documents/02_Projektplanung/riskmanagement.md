---
layout: default
title: Risikomanagement
parent: 2. Projektplanung
nav_order: 3
---

{: .no_toc }

---- 
# Risikomanagement
# Risikomanagement

Ein effektives Risikomanagement identifiziert und bewertet potenzielle Gefahren für das Projekt und definiert gezielte Gegenmassnahmen. Basierend auf dem Architektur- und Konzeptentwurf lassen sich folgende Risiken sowie Massnahmen ableiten.

## 1. Identifikation und Bewertung wesentlicher Projektrisiken

| **Risiko**                                    | **Beschreibung**                                                                                                     | **Wahrscheinlichkeit** | **Auswirkung** |
|-----------------------------------------------|-----------------------------------------------------------------------------------------------------------------------|------------------------|----------------|
| **HR-Synchronisationsfehler**                 | Falsche oder verzögerte Übernahme von Abteilungscodes aus SwissSalary/Business Central → inkonsistente Gruppenpflege | Gering                 | Hoch           |
| **Fehlerhafte Dynamic Group Queries**         | Unpräzise Abfragen erzeugen falsche Mitgliederzuweisungen → unbefugter Zugriff oder Ausschluss von Nutzern  | Mittel                 | Kritisch       |
| **Asset-Provisionierungsfehler**              | Fehler bei Azure AD-, Intune- oder Graph-API-Zuweisungen → unvollständige oder falsche Asset-Verteilung               | Gering                 | Mittel         |
| **Kostenüberschreitung**                      | Überschreitung des Azure-Sponsorship-Guthabens (2.000 CHF) oder Runbook-Quotas durch intensives Testing               | Gering                 | Gering         |
| **Komplexität der Workflow-Prozesse**         | Verschachtelte Genehmigungs- und Provisioning-Workflows → Verzögerungen und Abhängigkeiten                            | Mittel                 | Mittel         |
| **Integrationsänderungen in Azure/HR-System** | API-Updates oder Versionswechsel in Azure AD, Logic Apps oder SwissSalary → Anpassungsaufwand                         | Gering                 | Hoch           |
| **Single Point of Failure (Person)**          | Projektdurchführung und Wissen liegen bei einer Person → Risiko bei Ausfall oder Überlastung                          | Hoch                   | Hoch           |
| **Akzeptanz und Usability**                   | Fachabteilungen nutzen Self-Service-Elemente nicht wie vorgesehen → hoher manueller Aufwand für IT                    | Mittel                 | Mittel         |

## 2. Gegenmassnahmen und Monitoring

| **Risiko**                             | **Gegenmassnahme**                                                                                              |
|----------------------------------------|---------------------------------------------------------------------------------------------------------------|
| HR-Synchronisationsfehler              | Einrichtung einer Testumgebung. Rollback möglichkeit für Änderungen        |
| Fehlerhafte Dynamic Group Queries      | Fallback Gruppe für Queries Implementieren             |
| Asset-Provisionierungsfehler           | Nutzung von Managed Identities für sichere API-Aufrufe |
| Kostenüberschreitung                   | Monitoring über Azure Cost Management Alerts. Budget-Alerts bei Erreichen definierter Schwellenwerte    |
| Komplexität der Workflow-Prozesse      | Dokumentation der Workflow-Schritte in SharePoint-Listen       |
| Integrationsänderungen in Systeme      | Versioniertes Deployment von Runbooks und Templates         |
| Single Point of Failure (Person)       | Fortlaufende Pflege einer zentralen Projektdokumentation. Durchführung von Knowledge-Transfer-Sessions    |
| Akzeptanz und Usability                | Onboarding-Schulungen und Benutzerworkshops. Einrichtung eines Feedback-Kanals und regelmässiges Review   |

## 3. Zusammenfassung

Dieses Risikomanagement stellt sicher, dass technische, organisatorische und finanzielle Risiken frühzeitig adressiert werden. Durch regelmässiges Monitoring, automatisierte Tests sowie klare Dokumentations- und Schulungsmassnahmen wird das Projekt resilienter gegenüber Veränderungen und Ausfällen.
