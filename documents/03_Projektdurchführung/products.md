---
layout: default
title: Produkte / Artefakte
parent: 3. Projektdurchführung
nav_order: 2
---

# Produkte / Artefakte / Komponenten (TODO - find the best title)
{:toc}


Dieses Projekt besteht aus verschiedenen Komponenten/Features. Deshalb teile ich im folgenden, dass Porjekt in verschiedene Artefakte ein, die aus dem Projekt entstanden sind und die wiederum diverse komponenten benötigen aber jeweils nur 1 feature darstellen.

## Swiss Salary zu AD Synchronisation

TODO - passt der name artefakte? ansonsten ersetzen

Dieses Artefakt war usprünglich nicht als teil dieses Projekts angedacht. Allerdings ist es nötig, damit dieses Projekt funktioniert. Zuerst wollte ich es im vorhinein vorbereiten aber das wurde selbst zu komplex und ausserdem ist es eigentlich schon teil des projekts, da es eine dependencie darstellt.

Dabei geht es darum, das wir ja aktuell die Mitarbeiter Daten wie z.b. Abteilung, Standort, Sprache, etc nur im HR Tool pflegen. Allerdings wollen wir diese in unser AD synchronisieren. Bisher wurde das bereits gemacht, allerdings unregelmässig, mit einem script das manuell mit daten gefüttert und ausgeführt werden musste. Dies führt zu inkosistenzien und ist unnötig aufwendig. Ausserdem wird es dardurch nicht wirklich aktuell gehalten und es wurden nicht alle benötigten daten Synchronisiert.

**Welche Benutzer-Daten werden Synchronisiert?** 
- EmployeeID: ID auss SwissSalary
- Surname
- Firstname
- UserPrincipalName: E-Mail-Adresse bzw. UPN in der AD (sollte gleich sein). **Wird nicht aktiv angepasst, in zukunft soll bei änderung aber ein Alert & Ticket ausgelöst werden**
- Initials
- DepartmentCode
- JobTitel
- Division: Abteilungs-ID (Nummer aus SwissSalary)
- DepartmentDescription: Abteilungsname
- LanguageCode: Drei stelliger Sprachcode -> wird in extensionAttribute2 abgefüllt
- PostalCode: Bezug auf Anstellungsstandort
- City: Bezug auf Anstellungsstandort
- CountryCode: Bezug auf Anstellungsstandort
- StreetAdress: Bezug auf Anstellungsstandort
- State: Bezug auf Anstellungsstandort
- Company: "HEKS/EPER" (nicht hardcoded aber überall gleich)
- CountryFullname: Bezug auf Anstellungsstandort
- CountryNumeric: wird durch kleine funktion generiert. Entspricht codes die von Microsoft für das dropdownmenu in der AD verwendet werden und müssen mit-angepasst werden.

> PS: wo es selbstverständlich ist, habe ich keine erklärung hinzugefügt

### Ablauf / Flow

Hier eine grobe übersicht des Ablaufs:

1. Daten werden von HR in Swiss Salary (BC backend) angepasst
2. PowerBI Dataflow erstellt Report aller aktiven user + Abteilungen
3. PowerBi Reports werden als CSV in DataLake Gen2 Storage (az storage account) abgespeichert
4. Einmal täglich wird das Runbook "Get-PBIUserData" ausgelöst. Dieses holt die Daten aus dem Storage Account, transformiert sie in Json und löst ein neuen automation job mit dem Runbook "Update-UserdataLocalAD" auf dem Hybrid Worker aus.
5. Das Runbook "Update-UserdataLocalAD" wird auf dem Hybrid Runbook Worker ausgelöst. Dort vergleicht es die neuen Userdaten mit dem aktuellen Stand und Updated diese oder alarmiert entsprechend.
6. Das zweite runbook erstellt ebenfalls Logs und ein Backup CSV, welches zusammen mit einem weiteren Powershell Runbook verwendet werden kann um ein rollback auf den vorherigen zustand bzw auf einen der Backup CSV's auszuführen 

**Runbook "Get-PBIUserData"**

TODO - an CHATGPT - füge hier eine knappe beschreibung des scripts hinzu

```PowerShell
```

**Runbook "Update-UserdataLocalAD"**

> PS: Dieses script wird auf dem Hybrid Runbook worker ausgeführt

TODO - an CHATGPT - füge hier eine knappe beschreibung des scripts hinzu

```PowerShell
```

**Runbook "Start-RollbackFromBackupCSV"**

> PS: Dieses script wird auf dem Hybrid Runbook worker ausgeführt

TODO - an CHATGPT - füge hier eine knappe beschreibung des scripts hinzu

```PowerShell
```


## Mail Distribution List Generation & Updates

Bei diesem Artefakt dient der erstellung der automatisch befüllten Mailverteilerlisten. Dies war der Ursprung des Projekts. Es wurde gewünscht, dass neue Mitarbeiter automatisch in die entsprechenden Mailverteiler befüllt werden und diese somit nicht mehr von den jeweiligen Abteilungsleiterinnen gepflegt werden müssen.

Dabei soll der Mailverteiler einer Abteilung, immer auch alle user der Sub-Abteilungen beinhalten. Deshalb ist auch der "ParentCode" in den Abteilungsdaten angegeben. Dadurch kann das script, alle subabteilungen finden und die Query für den Mailverteiler entsprechend um deren Abteilungscodes erweitern

Zuerst hatte ich die Queries mit einem custom advanced filter erstellt. Allerdings stellte sich in der Pilotphase raus, dass dadurch die zugewiesenen user nicht eingesehen werden können.
Ich habe es nun umgestellt sodass es sogennante "Precanned" filter nutzt. Dies sind von Microsoft vordefinierte filterfunktionen. Die GUI funktioniert nur korrect, wenn diese Filterfunktionen verwendet werden. 
Das funktioniert nun auch, allerdings nur wenn ich einen einzelnen Abteilungscode verwende. Scheinbar müsste ich mehrere abteilungscodes mit Commas trennen können um mehrere Abteilungscodes abfragen zu können, dies klappt in der realität aber noch nicht so ganz.

Dieses Problem werde ich im nächsten Sprint angehen. Dies ist jedoch dann nach abschluss der Semesterarbeit und nicht mehr teil des Scopes. 

> Dieses Script wird auf dem Hybrid Runbook worker ausgeführt, da das Exchange Online Modul ein Kompatibilitätsproblem mit Azure Automation hat. Es kann sich allerdings einfach vom Server (Hybrid Runbook Worker) aus mit der Managed Identity an Exchange online authentifizieren.

### Ablauf / Flow

Hier eine grobe übersicht des Ablaufs:
1. Das Script holt sich die zuletzt aktualisierten Daten der Abteilungsliste die auf dem Azure Storage Account abgelegt ist. (Im moment sind das die Daten aus PowerBI, werde es aber noch anpassen, damit es sich die Daten aus der MS List holt, da wie erwähnt die Abteilungen in Swiss Salary nicht sauber geführt sind).
2. Das Script bereit alle benötigten Parameter vor
3. Das Script iteriert über alle subabteilungen einer abteilung und bereitet dadurch die entsprechende query für jede Abteilung vor.
4. Das script vergleicht die aktuell existierenden Mailverteiler mit den Daten und erfasst, ob die Mailverteiler bereits erstellt wurden. Falls nicht erstellt es die Mailverteiler neu.
5. Falls die Mailverteiler bereits existieren aber änderungen in den Daten verzeichnet sind, wird es die Mailverteiler entsprechend anpassen

> Note: Das script wird warhscheinlich einmal täglich ausgeführt. Allerdings ist das noch nicht abgeklärt da es noch nicht so relevant ist.

**Runbook "Generate-DepartmentGroups"**
TODO - an CHATGPT - füge hier eine knappe beschreibung des scripts hinzu

```PowerShell
```

### Geplante Änderungen

Das Script heisst aktuel "Generate-DepartmentGroups" da es ursprunglich dazu gedacht war Mailverteiler und Security Groups für Abteilungen zu erstellen. Allerdings fallen die Security Groups wie bereits erwähnt weg und somit wird es umbenannt und angepasst um nur mailverteiler für Abteilungen zu erstellen.

Ausserdem werde ich das Problem mit der Abfrage mehrerer Abteilungscodes noch angehen. Gemäss Microsofts eigener Dokumentation auf learn.microsoft.com, sollte es möglich sein mehrere Values mitzugeben. Es sollte also lösbar sein.
Danach sollten auch die user entsprechend richtig angezeigt werden.

## Asset Assigment Handling

Beim dritten Artefakt, geht es darum, die Asset zuweisung zu handhaben. Hierfür haben wir die beiden MS Listen die miteinander verknüpft sind. Wenn in der Abteilungsliste ein Asset an eine Abteilung zugewiesen wird, wird entsprechend ein script ausgelöst, dass diese zuweisung vornimmt.

Dabei werden die Daten zuerst bei jeglichen Updates in der MS List durch eine Logic App in ein Azure Storage Account synchronisiert.

Später wenn das script läuft (läuft in regelmässigen zyklus durch z.b einmal am tag), überprüft das script ob Asset zuweisungen verändert wurden. Falls ja erstellt es eine neue Query für das entsprechende Asset, welches die Abteilungen entfernt/hinzufügt. 

Die user werden dann durch die Query automatisch der Dynamischen Asset Gruppe (achtung Asset gruppe ist meine persönliche bezeichnung dafür. Hier geht es um eine Dynamische Azure Security Group) zugewiesen und erhalten somit die freigabe für das Asset (also z.B acces auf eine Site oder App oder eine bestimmte lizenz wird zugewiesen etc.).

### Storage Account Container "manualdb"

Weil das ganze projekt noch im Anfangsstadium ist, habe ich der einfachheithalber den gleich storage account weiterverwendet wie für PowerBI. Ich habe allerdings einen zweiten Container darin erstellt und ihn "manualdb" bennant. Dies wird später noch angepasst.

Darin befinden sich 3 Directories. Eine für den Assets Catalog, eine für die unverarbeiteten Daten aus dem Department Inventory und eine für die bereinigten Abteilungsdaten.

Die Logic App und der Automation Account haben beide über ihre jeweiligen Managed Identity Schreibzugriff auf dem Storage Account.

TODO - Bild der struktur im storage account einfügen

### Logic App - MS List zu Storage Account Synchronisieren

Für diesen Simplen Prozess habe ich mich entschieden eine Logic App statt einem Runbook zu verwenden, da ich ansonsten HTTPS requests über das MS Graph interface hätte machen müssen, was vorallem die Berechtigungslage unnötig verkompliziert hätte.

Stattdessen habe ich einen Service User erstellt, welcher Leseberechtigungen auf der ICT Site hat, auf der die beiden MS Lists gespeichert sind (später können diese Berechtingungen allenfalls noch weiter eingeschränkt werden). Dann habe ich diesen im Connector hinterlegt. 

Das passwort für den Benutzer wird irgendwann auslaufen und muss erneuert werden. Hierfür muss ich mir noch eine Lösung überlegen. Allerdings hatte da eine niedrigere priorität und ich hatte leider keine Zeit mehr dies zu lösen.

**Ablauf / Flow**
Hier eine grobe übersicht des Ablaufs der Logic App:
1. Connector erkennt änderung an MS List und triggered die Logic App
2. Logic App hat zwei Parallele Abläufe die ausgelöst werden
    - Der erste Ablauf convertiert die Daten des Asset Katalogs direct in JSON und speichert diese als Blob im Storage account.
    - Der zweite Ablauf convertiert die Daten nur soweit wie möglich aus der Department List. Einige felder mit verschachtelten werden wie z.B die zugewiesenen Assets, können allerdings nicht so einfach convertiert werden. Deshalb speichert es die Daten als JSON in einer separaten Directory im Container im Storage account als "RAW" Daten.
3. Ein Automation Job wird ausgelöst, welcher das Runbook "LogicAppHelper-SimplifyDepartmentsData" startet.
4. Das Helper Runbook, holt sich die zuletzt aktualisierten Daten aus dem Storage account
5. Es filtert die benötigten daten raus und generiert ein "cleaned" JSON.
6. Das JSON wird dann im Storage account in der Directory "Departments" abgelegt.

TODO - Bild von Logic app einfügen


**Runbook "LogicAppHelper-SimplifyDepartmentsData"**
TODO - an CHATGPT - füge hier eine knappe beschreibung des scripts hinzu

```PowerShell
```

### Assignment Logic Ablauf / Flow

Hier eine grobe übersicht des Ablaufs:
1. Daten auf der MS List werden geändert und Logic App synchronisiert die Daten in den Storage Account
2. Einmal täglich wird das "Update-AssetAssignments" Script gestartet
3. Das script holt sich die zuletzt aktualisierten Daten aus dem Storage Account
4. Es erstellt eine Liste aller Assets und welche Abteilungen in der Query vorhanden sein müssen.
5. Dann übeprüft es den aktuellen zustand der Queries und vergleicht diese mit den neuen Daten.
6. Falls änderungen gefunden werden, passt es die Queries der Asset Groups entsprechend an.

**Runbook "Update-AssetAssignments"**

TODO - an CHATGPT - füge hier eine knappe beschreibung des scripts hinzu

```PowerShell
```

### Beispiel Asset Group:


## Self Service

TODO - note its unfinished

## Logging & Auditing - TODO -> not sure where to put this - TODO less prio 

