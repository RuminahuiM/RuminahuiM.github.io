---
layout: default
title: Herausforderungen & Lösungen
parent: 3. Projektdurchführung
nav_order: 3
---

#  Herausforderungen & Lösungen
{:toc}

## HR Daten auslesen

## User müssen auf Lokaler AD aktualisiert werden
-aufteilung in zwei RB

## Gewisse Attribute dürfen nicht aktualisiert werden

## Testing Probleme - Rollback hat noch nicht funtkioniert
habe stattdessen mit Whatif geschaut was es macht und danach nur mein user aktualisiert.
Dann für alle gerunnt. > code funtkioniert wie beabesichtigt

## Runbooks debugging - unleserliche Error Meldungen

## Mailverteiler können nur über Hybrid Worker erstellt werden

Das exchange online module hat problems

## MemberOf filter für dynamische Gruppen noch in Preview

## Sharepoint Daten auslesen
- scheisse über MS Graph
- verschachtelte Daten konnten nicht richtig ausgelesen werden. Nach 4h verschwendung > runbook erstellt für daten cleanup


## Nur 500 "Role Assignable dynamic groups" können in Azure erstellt werden
somit fällt der zweck von abteilungsgruppen vollständig weg und nur asset gruppen die es nötig haben sollten das aktiviert haben

## Dynamische Mailverteiler gleich bennant
-> DL groups > existent Groups rename (noch nicht eingebaut) > 8h update fenster von Addressbook + 24h downloadfenster in outlook (nicht beachtet) + unhide für gruppen + hide alte gruppen noch nicht automatisiert

## Dynamische Mailverteiler zeigen user nicht an

## Neue Dynamische Mailverteiler (Precanned) funtkionieren nicht mit mehreren Codes

