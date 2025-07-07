---
layout: default
title: 2. Projektplanung
nav_order: 3
has_children: true
---

# 2. Projektplanung
{: .no_toc }

## Projektziele (SMART)
nochmals??? maybe anforderungen. aufjedenfall ziele nach smart prinzip - FRAGE TODO - weglassen, da bereits in Einleitung?


----

## Konzepentwurf & Architektur
----

### 1. Architekturüberblick

1. **HR-Synchronisation**  
    - SwissSalary → AD extensionAttribute (Abteilungscode).  

2. **Azure AD Dynamic Groups**  
    - Queries auf extensionAttribute erzeugen:  
    - Mail-enabled Distribution Groups (<DeptCode>_DL)  
    - Security Groups (<DeptCode>_SG)  

3. Asset-Zuweisung  
    - Über Azure AD-Connector, Intune-Connector, Graph API oder ARM-Templates zugeordnet.  

4. Workflows & Automatisierung  
    - Microsoft Forms (Intake) + Logic Apps / Power Automate (Approval & Provisioning).  

5. Übersichten & Reporting  
    - SharePoint-MS Lists, Power BI Dashboards, Sentinel-Integration.

----

### 2. Kernkomponenten

| Komponente | Beschreibung | Output |
|--|--|--|
| **Abteilungs-Inventar** | Zentrale SharePoint/MS Lists-Liste aller Departments & Sub-Departments mit Codes, Beschreibungen, Ownern, Parent-Child-Beziehungen. | Abteilungs-Inventar |
| **Dynamic Group Provisioning** | Automatisierte Erstellung & Pflege von Distribution- und Security-Groups pro DeptCode. | Dynamic Group Provisioning |
| **Digital Assets Katalog** | Definition aller Asset-Typen (Lizenzen, Rollen, Policies, Apps). | Digital Assets Katalog |
| **Naming Policy** | Azure AD Naming Policy: `<DeptCode>_<Type>` | Naming Policy |
| **Fallback-Gruppe** | „General“ für ungültige Codes, löst Review-Workflow aus. | Fallback-Gruppe |

----

### 3. Digital Assets definition

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

----

### 4. Workflows & Prozesse

#### Department Lifecycle

**Erstellen:**  
Forms/JIRA → Dept-Owner → IT → HR-Validation → Provisioning → Stakeholder-Notification  

**Ändern:**  
JIRA Change-Request → Approval Chain → Regel-Anpassung → Automatische Propagation  

**Archivieren:**  
Forms/JIRA → Approval → Expiration Policy (180 Tage) → Asset-Revoke

#### Sub-Department / Rollen

Analog zum Top-Level, zusätzliche Assets nur für Sub-Gruppen, implizite Vererbung durch Hierarchie.

#### Mailing-List Management

**Request & Approval:**  
MS Forms (SharePoint-Embedding) / JIRA → Logic Apps → IT Review/Approval → Exchange DG-Provisioning  

**Update:**  
Manuelle updates durch List Owner  

**Decommission:**  
Inaktivitäts-Review (90 Tage) → IT Review → Approval → Archivierung

#### Asset Assignment & Management

**Asset Aufnahme:**
Aufnahme ins Katalog & Erstellung benötigter Gruppen etc

**Zuweisung:**
Assets werden manuell den Abteilungsgruppen nach Bedarf zugewiesen

#### User Onboarding & Offboarding

**Onboarding:**  
HR schreibt Code → AAD-Sync → Dynamic Groups → Asset-Notifications  

**Offboarding:**  
Code gelöscht → Auto-Removal aus Gruppen → Lizenz-Revoke & Mailbox-Disable

----

### 5. Governance, Monitoring & Auditing

- Azure Monitor & AD Connect Health Alerts  
- Audit Logs aller Workflow-Schritte und System-Aktionen

----

### 6. Self-Service & Dashboards

1. **SharePoint-MS Lists Übersicht**  
    - Mailverteiler-Katalog mit Owner, Mitgliederzahl, Beschreibung  (für individuelle mailverteiler)
    - Abteilungs-Katalog mit  Abteilung, Beschreibung, zugewiesenen Assets
    - Digital Assets-Katalog mit Asset, zugehörigen Gruppen, Beschreibung

2. **Asset-Inventory Dashboard** - TODO -> muss aus dem Scope genommen werden. Zeitlich nicht umsetzbar  
    - Power BI-Bericht: Gruppen, Mitglieder, Asset-Counts, Stale-Group Warnings  

----

### 7. Pilotphase & Rollout

- **Pilot:** ICT-Abteilung (Fokus: Funktionalität, Performance, Governance)  
- **Evaluierungskriterien:** Mitgliedszahlen, Provisioning-Dauer, Fehlerquote, Nutzerfeedback, Alle benötigten Assets zugewiesen  
- **Rollout-Plan:** Sukzessive Aufnahme weiterer Abteilungen nach erfolgreicher Pilot-Review. Jeweils zuerst vorhandene Assets aufnehmen, zuweisen, ausrollen, testen, alte zuweisungen entfernen.

## Projektstrukturplan -> Phasenaufteilung in JIRA TODO
    -> Vorgehen in JIRA
## Zeitplanung - TODO
ungefähre Zeitplanung aufschreiben + aufschreiben das nur enddaten aber keine stunden geplant wurden
    -> Scrum Sprints aufteilung
## Ressourcenplanung - TODO
    -> Alleine + Kommunikation durch saskia -> wenig zeit durch Saskia. Tasks listen
    -> Ressourcen kosten der Runbooks (basically free) + Sponsorship Subscription for NGOs erwähnen
    -> Hybrid Worker erwähnen > keine Kosten + Schneller + nötig für lokale AD

----

## Risikomanagement

### Mögliche Risiken
**Fehlkonfiguration:** Falsch definierte Queries → falsche Berechtigungen
**Unzureichendes Monitoring:** Fehlende Alerts oder Auditing → Compliance-Lücken
**Prozessinkonsistenzen:** Unklare SLA/Genehmigungsketten → Verzögerungen, Inkonsistenzen
**Integrationskomplexität:** Intune, HR-System und weitere Tools benötigen klare Mapping-Standards

---- 

### Massnahmen
TODO - Managed identities z.b , least priviledge, etc

----

## Projektplan JIRA - TODO


## Kommunikationsplan TODO
    -> Gemäss absprache mit Saskia + Pilot erwähnung + einzelne absprache mit HR und beim Rollout mit jeder einzelnen Abteilung erstmal
