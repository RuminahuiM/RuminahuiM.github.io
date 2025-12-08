---
layout: default
title: 0. Porjektdefinition gemäss Einreichungsformular
nav_order: 1
permalink: /
---

{: .no_toc }

# Semesterarbeit HF Cloud
Titel des Projekts: Automatisiertes Hugo Portfolio
Name des Studierenden: Dodoe Ruminahui Mannale
Klasse / Studiengang: ITCNE25 - Cloud Native HF
Semester: 02 Semester
Betreuende Lehrperson: Armin Bernet (Ansible / IAC), Parisi Corrado (Projektmanagement)

----

# Problemstellung

Ich baue eine öffentliche Portfolio-Website mit Hugo. Die Seite läuft statisch auf AWS: Dateien liegen in S3, nach außen wird sie über CloudFront ausgeliefert.
Die Infrastruktur richte ich einmalig mit Ansible ein (Bucket, CloudFront, Domain/HTTPS).
Sobald ich im Repo Änderungen mache, baut GitHub Actions die Seite neu und lädt sie in S3. Danach wird der CloudFront-Cache aktualisiert, damit die neuen Inhalte sofort sichtbar sind.
Warum so: Eine statische Seite ist günstig, schnell und pflegeleicht. Ich halte den Umfang bewusst klein (ein Repo, klare Pipeline), damit es zuverlässig funktioniert und ich alles sauber dokumentieren kann.


# Ziele

- Hugo Portfolio Seite mithilfe eines Templates erstellen & Struktur definieren
- AWS-Grundaufbau per Ansible (S3 privat, CloudFront davor, HTTPS, optional Route 53).
- CI/CD mit GitHub Actions: Hugo bauen → nach S3 hochladen → CloudFront aktualisieren.
- Sicherheitsstandards sollen gemäss Best Practices eingehalten werden
- Vollständige dokumentation gemäss Richtlinien der Semesterarbeit

# Sachmittel

- Laptop mit Ansible, AWS-CLI, Hugo.
- AWS-Account (S3, CloudFront, ggf. Route 53).
- GitHub-Repo (Code + Workflow).

# Vorgaben, Methoden und Werkzeuge

- Ansible für das einmalige Einrichten auf AWS.
- Hugo für die statische Seite (ein Repo für alle Projekte).
- GitHub Actions für automatische Builds & Uploads bei jedem Push.
- AWS: S3 (Dateien), CloudFront (Auslieferung, HTTPS).

# Risiken

Hauptsächlich kann es bei Domain/HTTPS haken (falsche Region fürs Zertifikat oder fehlerhafte DNS-Einträge); ich lege das Zertifikat daher in us-east-1 an und prüfe die DNS-Bestätigung. Technisch heikel ist auch eine falsche S3/CloudFront-Konfiguration: Der Bucket bleibt strikt privat und wird nur über CloudFront (OAC) genutzt, damit die Seite sicher erreichbar ist. In der CI kann es zu Build- oder Rechteproblemen kommen (z.B. falsche baseURL oder fehlende AWS-Rolle); ich starte deshalb minimal, pinne die Hugo-Version und nutze OIDC statt fester Schlüssel. Kosten halte ich im Blick (wenige Invalidierungen, Budget-Alarm). Verzögerungen durch Zertifikats- oder DNS-Propagation plane ich mit etwas Puffer ein.