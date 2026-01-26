---
layout: default
title: 3. Fazit und Ausblick
nav_order: 4
has_children: true
---

{: .no_toc }

# 3. Fazit und Ausblick

## Reflexion Projektverlauf

### Was lief gut?
Das MVP stand früh und stabil: Bereits nach Sprint 1/2 liefen Hugo und die GitHub Actions verlässlich, Builds wurden auf jeden Push ausgelöst und bereitgestellt. 

Im zweiten Sprint habe ich die gesamte AWS‑Infrastruktur mit Ansible aufgesetzt (S3, CloudFront, OIDC‑Rolle, Zertifikats‑Handling) und so gestaltet, dass sie jederzeit reproduzierbar bleibt. Das Endprodukt wirkt dadurch stimmig: ein generalisiertes Template, eine ausführliche Benutzeranleitung, Demo‑Videos sowie eine technisch saubere, nachvollziehbare Pipeline. 

Rückmeldungen aus Zwischengespräch und Reviews habe ich konsequent in Rollen, Workflows und Dokumentation eingearbeitet, was Qualität und Verständlichkeit messbar verbessert hat.

### Was lief weniger gut?

Mein Zeitmanagement war der kritischste Punkt: Zu wenige verbindliche Arbeitsfenster führten zu Verzögerungen, inklusive eines verpassten ersten Zwischenmeetings. 

In Jira entstand zeitweise Unordnung, weil AI‑generierte Stories doppelt oder zu kleinteilig waren und der Status nicht immer aktuell blieb. Das Aufräumen kostete am Ende zusätzliche Zeit. 

Der gravierendste Fehler war das versehentliche Einchecken von Credentials, was ein aufwändiges Bereinigen historischer Commits notwendig machte. 

Auch die Dokumentationsstruktur habe ich zu spät konsolidiert, wodurch kurz vor Abgabe unnötiger Druck entstand. Die Demo‑Videos erforderten mehr Aufwand als erwartet, da mehrere Takes nötig waren und für die Live‑Demo vorbereitete Route53/ACM‑Ressourcen stehen bleiben mussten.

## Persönliche Erkenntnisse

- Ohne fest eingeplante Wochen‑Slots rutscht ein Projekt sofort ins Hintertreffen. Künftig blocke ich diese Zeiten wie Termine. 
- User Stories verfasse ich selbst und halte Jira laufend sauber, statt mich beim Zuschnitt auf AI zu verlassen. 
- Sicherheitsdisziplin kommt an erster Stelle: Keine Credentials im Repo, frühe Checks und klare Secret‑Handling‑Regeln. 
- Die Dokumentationsstruktur definiere ich zu Projektbeginn und pflege sie kontinuierlich, statt sie am Ende nachzutragen.

An sich hat mir das Projekt trotzdem viel Spass gemacht und ich konnte einiges über Ansible, AWS und Github Actions & HUGO lernen.