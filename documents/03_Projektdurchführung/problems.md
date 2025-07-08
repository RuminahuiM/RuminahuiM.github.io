---
layout: default
title: Herausforderungen & Lösungen
parent: 3. Projektdurchführung
nav_order: 3
---

{: .no_toc }

#  Herausforderungen & Lösungen

## User müssen auf Lokaler AD aktualisiert werden
ich musste ein hybrid worker installieren, da ich herausgefunden habe, dass man nur von der lokalen AD aus über powershell scripts die lokale AD bearbeiten kann. dies kann nicht über ein script gemacht werden das auf azure läuft, weil der azure ad sync nur von onpremise auf azure synced aber nicht umgekehrt.

Ausserdem habe ich deswegen das script in zwei teile aufgeteilt. mit einem hole ich die daten aus powerbi und transformiere sie in json zur einfacheren verarbeitung. und mit dem anderen aktulisiere ich die lokale AD. Das zweite script wird deshalb auch auf dem hybrid runbook worker ausgeführt.

## Gewisse Attribute dürfen nicht aktualisiert werden
Attribute wie Namen, UPN, Email durften noch nicht mit dem vorhandenen flow aktualisiert werden. Hauptsächlich wegen internen streitigkeiten bezüglich doppelnamen.
Aber beim UPN auch deswegen, weil es diverse auswirkungen auf den user haben kann. in zukunft soll bei einer solchen anpassung alarmiert werden. Für den Moment habe ich einfach eine exception liste für diverse attribute eingebaut wodurch diese nicht akutalisiert werden.

## Testing Probleme - Rollback hat noch nicht funtkioniert
habe stattdessen mit -Whatif geschaut was es macht und danach nur mein user aktualisiert um zu testen.
Dann für alle gerunnt. > code funtkioniert wie beabesichtigt

Das Rollback script muss noch korrigiert und getestet werden bevor das projekt produktiv geschaltet wird.

## Runbooks debugging - unleserliche Error Meldungen
Runbooks ergaben unleserliche fehlermeldungen. Dies ist ein formatierungsproblem das powershell farbcodierung etc verwendet, welche in runbook outputs nicht korrekt gerendert wird. ich konnte das mit dem folgenden powershell code für das meiste beheben. Teilweise funktioniert es aber weiterhin nich so gut wenn der code innerhalb einer funktion liegt. Dies werde ich später nochmals genauer anschauen.

```PowerShell
# Disable coloured output for the whole runbook - this makes for more readable runbook outputs
$PSStyle.OutputRendering = [System.Management.Automation.OutputRendering]::PlainText
```

## Mailverteiler können nur über Hybrid Worker erstellt werden

Das exchange online module hat kompatibilitätsprobleme mit azure runbooks. deshalb muss das runbook auf dem hybrid worker ausgeführt werden und entsprechende module müssen daruaf vorhanden sein. den import handle ich aber im script selbst.

## MemberOf filter für dynamische Gruppen noch in Preview
Wie bereits angesprochen, ist der memberof filter seit 3 jahren in preview und deshalb doch nicht verfügbar. ich habe dies leider etwas spät rausgefunden. Es scheint mir auch wahrscheinlich das dieses feature evtl gar nicht mehr rauskommt oder nicht in absehbarer zeit.

Nach einigen überlegungen habe ich festgestellt, dass es die Abteilungsgruppen aber auch nicht umbedingt braucht. ich kann die user, direkt den entsprechenden Assets gemäss den zugewiesenen assets in der MS List zuweisen indem ich die Queries in den Asset Gruppen entsprechend anpasse. Somit können die abteilungsgruppen komplett weggelassen werden. Sie hätten wahrscheinlich auch etwas unnötig compute power benötigt.

## Sharepoint Daten auslesen
- scheisse über MS Graph. vorallem was die authentifiezierung aus dem runbook heraus angeht. deshalb habe ich dann schlussendlich die logic app dafür erstellt
- in logic app -> verschachtelte Daten konnten nicht richtig ausgelesen werden. Nach 4h verschwendung > runbook erstellt für daten cleanup

## Nur 500 "Role Assignable dynamic groups" können in Azure erstellt werden
somit fällt der zweck von abteilungsgruppen vollständig weg und nur asset gruppen die es nötig haben sollten das aktiviert bekommen

## Dynamische Mailverteiler gleich bennant
-> DL mailverteiler > existent Groups rename geplant (noch nicht eingebaut)
ausserdem gibt es ein 8h update fenster damit das Adressbook auf exchange online aktualisiert wird  und ein 24h downloadfenster in outlook bis das offline adressbook aktualisiert wird (nicht beachtet bei pilotphase, weshalb die gruppen am ersten tag nicht sichtbar waren)

## Dynamische Mailverteiler zeigen user nicht an
Die mailverteiler haben nicht die zugewiesenen user angezeigt. nach einiger recherche habe ich rausgefunden, das dies am filter lag. es gibt zwei möglichkeiten solche gruppen über powershell zu erstellen. Mit custom filter, was ich bis dahin getan hatte, oder mit "Precanned"-Filtern. Mit custom filter funktioniert die gui nicht richtig. Die filter werden als code angezeigt und die user können nicht angezeigt werden, selbst wenn sie korrekt funktionieren.

## Neue Dynamische Mailverteiler (Precanned) funtkionieren nicht mit mehreren Codes

Nachdem ich den code aktualisiert hatte, um precanned filter zu verwenden, wurden die user nur angezeigt, wenn ich einen einzelnen Abteilungscode verwendete. Es ist aber oft nötig mehrere zu verwenden. Gemäss microsofts eigener dokumentation sollte das möglich sein, doch nach einigen versuchen konnte ich es noch nicht lösen.
Ich werde dies nach abschluss der semesterarbeit nochmals angehen. 