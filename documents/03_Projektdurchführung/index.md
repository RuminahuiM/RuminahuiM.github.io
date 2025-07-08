---
layout: default
title: 3. Projektdurchführung
nav_order: 4
has_children: true
---

{: .no_toc }

# 3. Projektdurchführung

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
