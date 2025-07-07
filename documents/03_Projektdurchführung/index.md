---
layout: default
title: 3. Projektdurchführung
nav_order: 4
has_children: true
---

# 3. Projektdurchführung

{: .no_toc }

## Recherche / Analyse

TODO - input picture of planned jira phase + description / intro ( sowas wie: dies war der plan für die erste phase in der ich dies und das recherchierte etc.)

Zuerst habe ich mich darüber informiert wie Dynamic Groups in azure funktionieren und wie Dynamic distribution lists in exchange online funktionieren.
Ich kannte diese zwar schon ein wenig aber hatte sie kaum selbst eingesetzt. 

Ich habe rausgefunden, dass ich beide über Powershell verwalten kann, was ich bereits erwartet hatte. Auch ist es möglich nach den extensionAttributen der User zu filtern, in denen ich den Department Code der user hinterlegen wollte.
Für az dynamic groups gab es scheinbar auch die möglichkeit mit "memberoff" nach usern aus einer anderen dynamic Group zu filtern und diese somit zu verschachteln. Dies hat sich allerdings später als irrtum rausgestellt, da dies seit 3 Jarhen ein Preview feature ist und normalen Tenants nicht vefügbar. 

Ausserdem habe ich rausgefunden, dass es constraints gibt was die aktualisierung der user gibt. Man hat nur ein gewisses Compute-Budget, mit dem Gruppen täglich aktualisiert werden. Das wiederum bedeutet es könnte sein das Gruppen erst nach mehreren tagen aktualisiert werden, wenn man zu viele Gruppen hat. Ich nahm mir vor im späteren Verlauf zu prüfen ob dies ein Problem ist und alternativ ein eigenes Script zu erstellen um die User selbst abzufüllen, da man nur so, zusätzliche Compute-Leistung nutzen kann. (PS: für den Moment ist es kein Problem. Sollte sich aber rausstellen das es zu viele gruppen sind, werde ich dies anpassen)

Nach diesen Recherchen entschied ich, für jede Abteilung eine Dynamische Gruppe zu erstellen und für jedes "Digital Asset" eine Gruppe zu erstellen. Dann würde die jeweilige asset gruppe den 'memberoff' filter nutzen, um alle user der zugewiesenen abteilungen zuzuweisen. Ich hätte auch in den Asset Gruppen direkt nach den Abteilungscodes der user filtern können, allerdings hielt ich das für weniger nachhaltig. Im verlauf des Projektes hat sich das geändert, aber auch hierzu später mehr beim Kapitel "Herausforderungen & Lösungen"


Nun musste ich entscheiden, ob ich die benötigten automatisierungen lieber mit Logic Apps oder azure automation runbooks lösen wollte.
Ich hatte bereits früher viel mit Logic apps und runbooks gearbeitet allerdings war es da jeweils eine Logic app und runbooks wurden bloss zur hilfe für komplexere Codeabläufe verwendet. 
Dabei habe ich auch Probleme der Logic apps kennengelernt. An sich sind logic Apps etwas gutes. Es ist eine möglichkeit automatisationen zu erstellen ohne scripten können zu müssen. Dies sorgt dafür, dass jeder es theoretisch verstehen und maintainen kann. Allerdings stimmt dies in der Realtität nicht so ganz. Auch logic apps können teilweise sehr komplex werden und wenns um berechtigungen und gewisse Spezielle actions geht, muss man sich trotzdem reinlesen.
Ausserdem finde ich persönlich jedenfalls Scripts tatsächlich leserlicher (wenn man sie gemäss Powershell best practices leserlich schreibt natürlich). Und in logic apps können teilweise dinge die in code einfach gemacht werden können, gar nicht oder nur mit mehreren Connector und actions gelöst werden. Ein bespiel hierzu seht ihr später im kapitel (TODO - link oder titel einfügen!)
Deshalb bevorzuge ich Runbooks solange es nicht um einfache vorgänge geht die schnell mit einer logic app gebaut werden können. Und somit habe ich entschieden möglichst alles über Runbooks zu lösen und nur logic apps einzusetzen, falls es den zugriff ungemein vereinfacht. (bei Runbooks müsste man teilweise für bestimmte connctions extra HTTP Requests machen, während logic apps integrierte connectors haben)

Als Datenbank / Inventar wollte ich am liebsten nur eine Datenbank in einem Storage Account verwenden, allerdings brauchte es eine Self-Service übersicht. Hierfür habe ich entschieden MS Lists zu verwenden, da diese einfach im Sharepoint integriert werden können und dies unsere Haupt-Kommunikationsablage in der firma ist.
Allerdings wollte ich möglichst wenig von MS Lists abhängig machen.

Bezüglich der Herkunft der Daten, hatte ich bereits herausgefunden, das alle daten der HR in Business Central gespeichert sind und über PowerBI abgegriffen werden können. Ein Mitarbeiter der Zuständig für PowerBi Berichte ist, konnte mir also entsprechende reports machen, aus denen ich die daten auslesen können würde. 

weitere fragen die sich mir stellten zur ganzen Lösung:

Welche Daten werden in BC gespeichert und stehen mir zur verfügung?
    -> Mitarbeiter Angaben + Mitarbeiter Sprachcode und Abteilungscode
    -> Liste aller Abteilungen

aktuelle Roles & Department names 
    -> Rollen abzudecken ist für den moment out of scope, nach einer absprache mit David (abteilungsleiter)
    -> Aktuelle departments konnten aus BC ausgelesen werden (allerdings stellte sich später raus das die liste unvollständig ist. mehr dazu unter "Herausforderungen & Lösungen")

Existing Azure AD groups
-> es existieren bereits manuell erstellte und manuel geführte Distribution lists und teilweise auch abteilungsgruppen auf der local AD, alledings nicht gemäss einem konsistenten musster, sondern konzeptlos nach bedarf erstellt

What groups are needed?
 -> Abteilunngsgruppen + Abteilungsmailverteiler
 -> Zuweisungsgruppen für Digital Assets gemäss definition

Current new department creation
    -> manuell wird nach bedarf pro user alles eingestellt.
    -> erstellung einer neuer abteilung findet nur in der HR richtig statt

What kind of permissions could be needed? (Types)
 -> wurde im zusammenhang mit dem konzept bereits geklärt. Habe dabei mögliche Digital Assets kategorisiert.

How to areview changes
    -> Audit logs in AZ Tenant können genutzt werden um zu überprüfen ob/ wann user einer neuen gruppe zugewiesen werden können

Computanional quotas for tenat
    ->  TODO - Google the quotas on computation for az dynamic memberships and input them here

----

## Environment Setup 

Aufgrund von übersichtlichkeit, werde ich kurz die gesamte umgebung und dessen komponenten erklären die benötigt wird für diese automatisierung. Es war zwar nicht so, dass ich die umgebung vollständig bereits geplant hatte und vorbereiten konnte bevor ich anfing die einzelnen teile zu bauen, allerdings erscheint es mir einfach für die dokumentation übersichtlicher diese teile zu bündeln.

----

### PowerBI / BC mit DataLake Gen 2 Ablage

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

### AZ Automation Account (dev-environment)

Für die Entwicklungsphase, wollte ich es einfach halten, um mich erstmal auf die benötigten automatisierungen fokusieren zu können. Deshalb habe ich für den Moment nur einen einzelnen Az Automation Account mit dem Namen "Main-Test" erstellt. Dieser Automation account soll als Test und Entwicklungsumgebung für diverse automatisierungen zur verfügung stellen. Danach kann jeweils ein Projekt spezifischer account als produktiv umgebung erstellt werden. Bei diesem sollen die Berechtigungen dann etwas stärker eingeeschränkt werden (wenn möglich ) und auch alerts, sowie die triggers für die Runbooks korrekt eingestellt werden.

Alle Runbooks die ich darin erstelle, sind powershell 7.2 Runbooks.

TODO - Bild der Az account overview

#### Managed identity
Der Automtion Account verfügt über eine System Managed Identity. Diese wird wo nötig berechtigt (z.B. auf dem Storage account, auf entra ID und exchange online). Dadurch kann der Automation account direkt auf andere Ressourcen des Tenants zugreifen, ohne zusätzliche Passwörter zu benötigen.

TODO - Bild der Managed Identity

#### Key Vault
Für manche Dinge, konnte ich die Managed Identity leider nicht verwerden. Deshalb nutze ich zusötzlich dazu, den Credentials Vault im Automation Account. Darin sind zugangsdaten für zwei Service User abgelegt.

TODO - Bild des Key Vaults

Einer wird benötigt, um auf der lokalen AD Änderungen vornehmen zu können. Dieser Service User besitzt nur eingeschränkte berechtigungen um die benötigten Attribute and den Usern in unserer user OU anpassen zu können. Ansonsten besitzt er keine weiteren Berechtigungen, um dem Least-Priviledge prinzip zu entsprechen.

Der zweite Benutzer wird benötigt um auf Sharepoint zuzugreifen. Es ist zwar scheinbar möglich, eine App Registration zu erstellen, allerdings ist die Berechtigung davon recht mühsam. Nachdem ich mich mehrere Stunden daran versuchte, entschied ich mich dazu, die Sharepoint connection stattdesen mit einem ServiceUser und einer Logic app zu lösen. Genaueres dazu später.

#### Hybrid Runbook Worker 
TODO - verlinken der einrichtungsanleitung die ich verwendet habe

Da wir eine Hybrid AD umgebung haben (also eine lokale ad die auf Azure synchronisiert wird), müssen manche änderungen, wie z.B die user properties anpassungen, auf der Lokalen AD umgesetzt werden. Um aber über Powershell auf die lokale AD zuzugreifen, muss das script lokal auf einem Server laufen, der sich in der Domäne befindet. Hierfür kann man einen Hybrid Runbook Worker auf einem Domänen-Server installieren, welcher Jobs von Azure Automation Accounts ausführen kann. 

Da wir einen eigenen Server für den AD Sync verwenden (also ein server auf den der AD Connect installiert ist), habe ich in absprache mit unserem Abteilungsleiter, einen Hybrid Runbook Worker installiert. Dieser führt das Script aus, welches die User auf der Lokalen AD updated.

TODO - Bild des hybrid workers im AZ automation account

PS: Ausserdem ist mir dabei aufgefallen, das runbooks darauf viel schneller ausgeführt werden können und keine kosten erzeugen, da es ja der lokale server ist der die hauptarbeit leistet. Da die ausführung der benötigten runbook allerdings sowieso höchstens ein paar rappen im monat kostet (es gibt eine bestimmte compute quota von runbooks die täglich gratis ausgeführt werden kann), ist dies nicht umbedingt nötig. Für den Moment lasse ich diese entscheidung offen.

#### Powershell Modules
Ich musste für meine Scripts zustätzlich folgende Module im Az Automtion Account importieren:
TODO - modulliste erstellen

----

### Sharepoint

Sharepoint wird bei der HEKS (dem unternehmen wo ich arbeite. ps. diese notiz ist an chatgpt gerichtet) als Zentrale Ablage, vorallem für interne Kommunikation und öffentliche Ablagen verwendet. Auch tickets können bei uns über eine Sharepoint Seite erstellt werden.
Deshalb war es nur logisch, dass die benötigten Self-Service möglichkeiten und Übersichten, welche für dieses Projekt benötigt werden, in Sharepoint abgelegt werden.

#### MS List 

Ich habe in unserer ICT Bibliothek, zwei MS Listen erstellt. Die Listen "Departments Inventory" und "Digital Assets Catalog" enthalten die benötigten Daten für die automatisierung und dienen gleichzeitig als interface um flows auslösen zu können.

TODO - bild der beiden listen einfügen

##### Departments Inventory
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

##### Digital Assets Catalog
In der Liste "Digital Assets Catalog" werden alle Assets nach und nach erfasst. Dabei wird ein Asset so eingerichtet, das es mit einer einzelnen dynamischen Sicherheitsgruppe zugewiesen werden kann. Dann wird in dieser liste die entsprechende Sicherheitsgruppe erfasst, damit user automatisch zugewiesen werden können. Die Assets aus diesem Katalog können in der Departments Liste ausgewählt weren um sie abteilungen zuzuweisen.

**Eigenschaften der MS List**
- **Title:** Name des Assets
- **SecurityGroup:** Manuell eingerichtete dynamische Security Group für die Asset zuweisung
- **Description:** Beschreibung des Assets und wofür es benötigt wird

#### Teams integration

Die beiden Listen können in der Teams App direkt in einem Team Channel als Panel hinzugefügt werden um somit das ganze direkt aus Teams steuern zu können. Ich habe diese für den Moment in einem Channel verfügbar gemacht, der nur für uns System Engineers zu verfügung steht.

- TODO bild der beiden Listen integriert in unser System Engineer Team Channel zeigen

#### Datenablage in Storage account für verarbeitung¨

Um die verarbeitung der Daten mithilfe von Powershell zu vereinfachen, habe ich einen Zwischenschritt hinzugefügt. Wie zuvor schonmal erwähnt, habe ich hierfür eine Logic app erstellt. Diese Synchronisiert die Daten mit einem Storage account und speichert diese als JSON ein, sodass ich sie später direkt einlesen kann. Genaueres dazu später.

----

### Logic apps 

Wie bereits erwähnt habe ich für die Connection zu Sharepoint ebenfalls eine Logic App erstellt. Für diese habe ich ebenfalls eine Managed Identity aktiviert. Diese ist Berechtigt, auf den Storage account zu schreiben (PS: im moment nutze ich den gleichen DataLakeGen2 storage, nur das ich darin einen eigenen Container erstellt habe. Ich will allerdings daraus einen eigenen Azure Storage machen, da dies eine bessere abtrennung der komponenten ermöglicht). Ausserdem ist die Logic app berechtigt azure automation jobs zu verwalten (im moment auf dem Main-Test Automation account). Dies ist nötig, da ich ein Problem mit dem auslesen bestimmter Sharepoint daten mit der Logic App hatte. Deshalb habe ich ein kleines Powershell Helper script (runbook) geschrieben, welches von der Logic app ausgelöst wird. Dieses bereinigt die Daten.


### Geplante Anpassungen für Poduktiv-Umgebung - TODO less prio

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


## Produkte / Artefakte / Komponenten (TODO - find the best title)

Dieses Projekt besteht aus verschiedenen Komponenten/Features. Deshalb teile ich im folgenden, dass Porjekt in verschiedene Artefakte ein, die aus dem Projekt entstanden sind und die wiederum diverse komponenten benötigen aber jeweils nur 1 feature darstellen.

### Swiss Salary zu AD Synchronisation

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

#### Ablauf / Flow

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


### Mail Distribution List Generation & Updates

Bei diesem Artefakt dient der erstellung der automatisch befüllten Mailverteilerlisten. Dies war der Ursprung des Projekts. Es wurde gewünscht, dass neue Mitarbeiter automatisch in die entsprechenden Mailverteiler befüllt werden und diese somit nicht mehr von den jeweiligen Abteilungsleiterinnen gepflegt werden müssen.

Dabei soll der Mailverteiler einer Abteilung, immer auch alle user der Sub-Abteilungen beinhalten. Deshalb ist auch der "ParentCode" in den Abteilungsdaten angegeben. Dadurch kann das script, alle subabteilungen finden und die Query für den Mailverteiler entsprechend um deren Abteilungscodes erweitern

Zuerst hatte ich die Queries mit einem custom advanced filter erstellt. Allerdings stellte sich in der Pilotphase raus, dass dadurch die zugewiesenen user nicht eingesehen werden können.
Ich habe es nun umgestellt sodass es sogennante "Precanned" filter nutzt. Dies sind von Microsoft vordefinierte filterfunktionen. Die GUI funktioniert nur korrect, wenn diese Filterfunktionen verwendet werden. 
Das funktioniert nun auch, allerdings nur wenn ich einen einzelnen Abteilungscode verwende. Scheinbar müsste ich mehrere abteilungscodes mit Commas trennen können um mehrere Abteilungscodes abfragen zu können, dies klappt in der realität aber noch nicht so ganz.

Dieses Problem werde ich im nächsten Sprint angehen. Dies ist jedoch dann nach abschluss der Semesterarbeit und nicht mehr teil des Scopes. 

> Dieses Script wird auf dem Hybrid Runbook worker ausgeführt, da das Exchange Online Modul ein Kompatibilitätsproblem mit Azure Automation hat. Es kann sich allerdings einfach vom Server (Hybrid Runbook Worker) aus mit der Managed Identity an Exchange online authentifizieren.

#### Ablauf / Flow

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

#### Geplante Änderungen

Das Script heisst aktuel "Generate-DepartmentGroups" da es ursprunglich dazu gedacht war Mailverteiler und Security Groups für Abteilungen zu erstellen. Allerdings fallen die Security Groups wie bereits erwähnt weg und somit wird es umbenannt und angepasst um nur mailverteiler für Abteilungen zu erstellen.

Ausserdem werde ich das Problem mit der Abfrage mehrerer Abteilungscodes noch angehen. Gemäss Microsofts eigener Dokumentation auf learn.microsoft.com, sollte es möglich sein mehrere Values mitzugeben. Es sollte also lösbar sein.
Danach sollten auch die user entsprechend richtig angezeigt werden.

### Asset Assigment Handling

Beim dritten Artefakt, geht es darum, die Asset zuweisung zu handhaben. Hierfür haben wir die beiden MS Listen die miteinander verknüpft sind. Wenn in der Abteilungsliste ein Asset an eine Abteilung zugewiesen wird, wird entsprechend ein script ausgelöst, dass diese zuweisung vornimmt.

Dabei werden die Daten zuerst bei jeglichen Updates in der MS List durch eine Logic App in ein Azure Storage Account synchronisiert.

Später wenn das script läuft (läuft in regelmässigen zyklus durch z.b einmal am tag), überprüft das script ob Asset zuweisungen verändert wurden. Falls ja erstellt es eine neue Query für das entsprechende Asset, welches die Abteilungen entfernt/hinzufügt. 

Die user werden dann durch die Query automatisch der Dynamischen Asset Gruppe (achtung Asset gruppe ist meine persönliche bezeichnung dafür. Hier geht es um eine Dynamische Azure Security Group) zugewiesen und erhalten somit die freigabe für das Asset (also z.B acces auf eine Site oder App oder eine bestimmte lizenz wird zugewiesen etc.).

### Storage Account Container "manualdb"

Weil das ganze projekt noch im Anfangsstadium ist, habe ich der einfachheithalber den gleich storage account weiterverwendet wie für PowerBI. Ich habe allerdings einen zweiten Container darin erstellt und ihn "manualdb" bennant. Dies wird später noch angepasst.

Darin befinden sich 3 Directories. Eine für den Assets Catalog, eine für die unverarbeiteten Daten aus dem Department Inventory und eine für die bereinigten Abteilungsdaten.

Die Logic App und der Automation Account haben beide über ihre jeweiligen Managed Identity Schreibzugriff auf dem Storage Account.

TODO - Bild der struktur im storage account einfügen

#### Logic App - MS List zu Storage Account Synchronisieren

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

#### Assignment Logic Ablauf / Flow

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

#### Beispiel Asset Group:


### Self Service

TODO - note its unfinished


## Testing und Error handling - TODO -> not sure where to put this is this good? 

## Logging & Auditing - TODO -> not sure where to put this - TODO less prio 


##  Herausforderungen & Lösungen

### HR Daten auslesen

### User müssen auf Lokaler AD aktualisiert werden
-aufteilung in zwei RB

### Gewisse Attribute dürfen nicht aktualisiert werden

### Testing Probleme - Rollback hat noch nicht funtkioniert
habe stattdessen mit Whatif geschaut was es macht und danach nur mein user aktualisiert.
Dann für alle gerunnt. > code funtkioniert wie beabesichtigt

### Runbooks debugging - unleserliche Error Meldungen

### Mailverteiler können nur über Hybrid Worker erstellt werden

Das exchange online module hat problems

### MemberOf filter für dynamische Gruppen noch in Preview

### Sharepoint Daten auslesen
- scheisse über MS Graph
- verschachtelte Daten konnten nicht richtig ausgelesen werden. Nach 4h verschwendung > runbook erstellt für daten cleanup


### Nur 500 "Role Assignable dynamic groups" können in Azure erstellt werden
somit fällt der zweck von abteilungsgruppen vollständig weg und nur asset gruppen die es nötig haben sollten das aktiviert haben

### Dynamische Mailverteiler gleich bennant
-> DL groups > existent Groups rename (noch nicht eingebaut) > 8h update fenster von Addressbook + 24h downloadfenster in outlook (nicht beachtet) + unhide für gruppen + hide alte gruppen noch nicht automatisiert

### Dynamische Mailverteiler zeigen user nicht an

### Neue Dynamische Mailverteiler (Precanned) funtkionieren nicht mit mehreren Codes


## Änderungsmanagement

Geplante änderungen wurden oder werden im Backlog aufgenommen und von dort in die nächsten sprints geplant.
Epic für grössere konzept-änderungen erstellt.

alle scripts müssen noch überarbeitet werden


## Sprint Reviews
    -> jeden einzelnen Sprint durchgehen
