---
layout: default
title: Environment Setup
parent: 3. Projektdurchführung
nav_order: 1
---

# Environment Setup 
{:toc}

Aufgrund von übersichtlichkeit, werde ich kurz die gesamte umgebung und dessen komponenten erklären die benötigt wird für diese automatisierung. Es war zwar nicht so, dass ich die umgebung vollständig bereits geplant hatte und vorbereiten konnte bevor ich anfing die einzelnen teile zu bauen, allerdings erscheint es mir einfach für die dokumentation übersichtlicher diese teile zu bündeln.

----

## PowerBI / BC mit DataLake Gen 2 Ablage

Da die HR Daten im Moment in Bussiness Central gepseichert werden, konnten wir diese wie gesagt in powerBi auslesen um ein Report zu erstellen, das nur die benötigten daten enthält. Dafür habe ich mich mit unserem PowerBi spezialisten abgesprochen. Bisher wurde bereits ein CSV erstellt welches die nötigen user daten enthielt. Dieses wurde dann hin und wieder manuell heruntergeladen und auf einen Server kopiert um ein script auszuführen, welches die user daten auf der lokalen AD aktualisierte.

Allerdings wollte ich direkt auf diese daten von einem Az automation account aus zugreifen um den vorgang vollständig zu automatisieren. Nach einiger recherche und tests, fand ich heraus das ich um auf den aktuellen report zugreifen zu müssen, eine HTTPS abfrage machen müsste. Ich wollte allerdings möglichst alles mit managed identities handhaben da dies sicherer und angenehmer ist. Für Http requests brauch ich entweder einen Service user oder eine App Registration, auf die ich mich wieder mit einem Secret authentifizieren muss, welchen ich wiederum irgendwo abspeichern und regelmässig erneuern muss. Das würde zu kompliziert werden. 

Deshalb habe ich schlussendlich ein neues Workspace in PowerBi erstellt und dieses mit einem Datalake Gen2 Speicher verbunden.
Ein solcher speicher ist im Hintergund ein Azure Storage account, welcher mit powerbi verknüpft wird. Dabei werden die Daten die im Workspace gespeichert sind regelmässig in den Storage Account abgelegt.

In PowerBI hat Alain ( der PowerBi experte) einen Dataflow mit den von mir gewünschten daten erstellt. Dabei werden 2 Tabellen generiert. Eine mit den Mitarbeitern und ihren Daten und eine Liste aller abteilungen. Diese werden im Storage account als Data Blob (Datei), im csv format mit dem aktuellem datum gespeichert.

Somit kann ich nun meinem Az automation Account (bzw. dessen managed identity) direkten zugriff auf dem Storage account geben. Dadurch kann er die Darin gepspeicherten daten auslesen und dann verarbeiten.

TODO - Bild von powerBI Dataflow  
TODO - Bild von PowerBI DataLake Gen2 connection
TODO - Bild von Daten in AZ Storage account

----

## AZ Automation Account (dev-environment)

Für die Entwicklungsphase, wollte ich es einfach halten, um mich erstmal auf die benötigten automatisierungen fokusieren zu können. Deshalb habe ich für den Moment nur einen einzelnen Az Automation Account mit dem Namen "Main-Test" erstellt. Dieser Automation account soll als Test und Entwicklungsumgebung für diverse automatisierungen zur verfügung stellen. Danach kann jeweils ein Projekt spezifischer account als produktiv umgebung erstellt werden. Bei diesem sollen die Berechtigungen dann etwas stärker eingeeschränkt werden (wenn möglich ) und auch alerts, sowie die triggers für die Runbooks korrekt eingestellt werden.

Alle Runbooks die ich darin erstelle, sind powershell 7.2 Runbooks.

TODO - Bild der Az account overview

## Managed identity
Der Automtion Account verfügt über eine System Managed Identity. Diese wird wo nötig berechtigt (z.B. auf dem Storage account, auf entra ID und exchange online). Dadurch kann der Automation account direkt auf andere Ressourcen des Tenants zugreifen, ohne zusätzliche Passwörter zu benötigen.

TODO - Bild der Managed Identity

## Key Vault
Für manche Dinge, konnte ich die Managed Identity leider nicht verwerden. Deshalb nutze ich zusötzlich dazu, den Credentials Vault im Automation Account. Darin sind zugangsdaten für zwei Service User abgelegt.

TODO - Bild des Key Vaults

Einer wird benötigt, um auf der lokalen AD Änderungen vornehmen zu können. Dieser Service User besitzt nur eingeschränkte berechtigungen um die benötigten Attribute and den Usern in unserer user OU anpassen zu können. Ansonsten besitzt er keine weiteren Berechtigungen, um dem Least-Priviledge prinzip zu entsprechen.

Der zweite Benutzer wird benötigt um auf Sharepoint zuzugreifen. Es ist zwar scheinbar möglich, eine App Registration zu erstellen, allerdings ist die Berechtigung davon recht mühsam. Nachdem ich mich mehrere Stunden daran versuchte, entschied ich mich dazu, die Sharepoint connection stattdesen mit einem ServiceUser und einer Logic app zu lösen. Genaueres dazu später.

## Hybrid Runbook Worker 
TODO - verlinken der einrichtungsanleitung die ich verwendet habe

Da wir eine Hybrid AD umgebung haben (also eine lokale ad die auf Azure synchronisiert wird), müssen manche änderungen, wie z.B die user properties anpassungen, auf der Lokalen AD umgesetzt werden. Um aber über Powershell auf die lokale AD zuzugreifen, muss das script lokal auf einem Server laufen, der sich in der Domäne befindet. Hierfür kann man einen Hybrid Runbook Worker auf einem Domänen-Server installieren, welcher Jobs von Azure Automation Accounts ausführen kann. 

Da wir einen eigenen Server für den AD Sync verwenden (also ein server auf den der AD Connect installiert ist), habe ich in absprache mit unserem Abteilungsleiter, einen Hybrid Runbook Worker installiert. Dieser führt das Script aus, welches die User auf der Lokalen AD updated.

TODO - Bild des hybrid workers im AZ automation account

PS: Ausserdem ist mir dabei aufgefallen, das runbooks darauf viel schneller ausgeführt werden können und keine kosten erzeugen, da es ja der lokale server ist der die hauptarbeit leistet. Da die ausführung der benötigten runbook allerdings sowieso höchstens ein paar rappen im monat kostet (es gibt eine bestimmte compute quota von runbooks die täglich gratis ausgeführt werden kann), ist dies nicht umbedingt nötig. Für den Moment lasse ich diese entscheidung offen.

## Powershell Modules
Ich musste für meine Scripts zustätzlich folgende Module im Az Automtion Account importieren:
TODO - modulliste erstellen

----

## Sharepoint

Sharepoint wird bei der HEKS (dem unternehmen wo ich arbeite. ps. diese notiz ist an chatgpt gerichtet) als Zentrale Ablage, vorallem für interne Kommunikation und öffentliche Ablagen verwendet. Auch tickets können bei uns über eine Sharepoint Seite erstellt werden.
Deshalb war es nur logisch, dass die benötigten Self-Service möglichkeiten und Übersichten, welche für dieses Projekt benötigt werden, in Sharepoint abgelegt werden.

## MS List 

Ich habe in unserer ICT Bibliothek, zwei MS Listen erstellt. Die Listen "Departments Inventory" und "Digital Assets Catalog" enthalten die benötigten Daten für die automatisierung und dienen gleichzeitig als interface um flows auslösen zu können.

TODO - bild der beiden listen einfügen

### Departments Inventory
In der Liste "Departments Inventory" können wir Abteilungen eintragen (Die liste aus dem HR ist leider unvollständig und nicht für eine automatisierung zu gebrauchen, weshalb wir momentan eine zusätzliche Liste manuell führen müssen). Darin können der Abteilung Assets aus dem Digital Assets Katalog zugewiesen werden. Die Abteilung muss ausserdem von der IT approved werden. Sobald eine Abteilung approved wird, wird die Abteilung mithilfe einiger Scripts erstellt. Dabei wird ein dynamischer Mailverteiler erstellt und die entsprechenden Assets werden automatisch zugewisen.

Ursprünglich war angedacht, dass ausserdem eine Sircherheitsgruppe für die Abteilung erstellt wird, allerdings ist das aufrund eines Problems weggefallen (TODO - link zur problem erklärung einfügen sobald erfasst)

**Eigenschaften der MS List**
 - **Title:** Name der Abteilung
 - **AssignedAssets:** Mit Asset Katalog verknüpft (kann aus dropdown ausgewählt werden). Ist eine komma getrente liste der namen aller zugewiesenen assets (bsp. "Intune, EntraAdmin, SRV-SharepointSite").
 - **AssignedAssetsSecurityGroups:** Mit Asset Katalog verknüpft. Ist eine komma getrente liste der SecurityGroups der zugewiesenen assets
 - **DepartmentCode:** Abteilungscode für Userzuordnung
 - **Approved:** YES/NO - standardmässig auf NO. Wird von System Engineers auf approved gesetzt sobald die Daten stimmen und die Erstellung der Abteilung ausgeführt werden darf
 - **SpecialCodes:**  Zustätzliche abteilungscodes (z.b teilt die HR manchmal abteilungen in teams auf und fügt nummern an den code an. Bsp ICT1, ICT2, etc)
 - **ParentCode:** Abteilungscode der übergeordneten abteilung. Hauptsächlich benötigt für Mailverteiler.

### Digital Assets Catalog
In der Liste "Digital Assets Catalog" werden alle Assets nach und nach erfasst. Dabei wird ein Asset so eingerichtet, das es mit einer einzelnen dynamischen Sicherheitsgruppe zugewiesen werden kann. Dann wird in dieser liste die entsprechende Sicherheitsgruppe erfasst, damit user automatisch zugewiesen werden können. Die Assets aus diesem Katalog können in der Departments Liste ausgewählt weren um sie abteilungen zuzuweisen.

**Eigenschaften der MS List**
- **Title:** Name des Assets
- **SecurityGroup:** Manuell eingerichtete dynamische Security Group für die Asset zuweisung
- **Description:** Beschreibung des Assets und wofür es benötigt wird

## Teams integration

Die beiden Listen können in der Teams App direkt in einem Team Channel als Panel hinzugefügt werden um somit das ganze direkt aus Teams steuern zu können. Ich habe diese für den Moment in einem Channel verfügbar gemacht, der nur für uns System Engineers zu verfügung steht.

- TODO bild der beiden Listen integriert in unser System Engineer Team Channel zeigen

## Datenablage in Storage account für verarbeitung¨

Um die verarbeitung der Daten mithilfe von Powershell zu vereinfachen, habe ich einen Zwischenschritt hinzugefügt. Wie zuvor schonmal erwähnt, habe ich hierfür eine Logic app erstellt. Diese Synchronisiert die Daten mit einem Storage account und speichert diese als JSON ein, sodass ich sie später direkt einlesen kann. Genaueres dazu später.

----

## Logic apps 

Wie bereits erwähnt habe ich für die Connection zu Sharepoint ebenfalls eine Logic App erstellt. Für diese habe ich ebenfalls eine Managed Identity aktiviert. Diese ist Berechtigt, auf den Storage account zu schreiben (PS: im moment nutze ich den gleichen DataLakeGen2 storage, nur das ich darin einen eigenen Container erstellt habe. Ich will allerdings daraus einen eigenen Azure Storage machen, da dies eine bessere abtrennung der komponenten ermöglicht). Ausserdem ist die Logic app berechtigt azure automation jobs zu verwalten (im moment auf dem Main-Test Automation account). Dies ist nötig, da ich ein Problem mit dem auslesen bestimmter Sharepoint daten mit der Logic App hatte. Deshalb habe ich ein kleines Powershell Helper script (runbook) geschrieben, welches von der Logic app ausgelöst wird. Dieses bereinigt die Daten.


## Geplante Anpassungen für Poduktiv-Umgebung - TODO less prio

TODO - an chatgpt: bitte versuche hier aus vorangegangenen beschreibungen dinge auszulisten

- right now everything is in dev environment
    -> powerbi setup & Sync
    -> dev umgebung setup
    -> az automation
    -> hybrid runbook worker
    -> Sharepoint
    -> 

- planned split ups
- planned permission changes
- planned alerting on failed automation jobs & logic app
