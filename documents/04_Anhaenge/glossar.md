---
layout: default
title: Glossar
parent: Anhänge
nav_order: 1
---

# Glossar

> Hinweis: Dieses Glossar wurde durch ChatGPT generiert.

- **ACM (AWS Certificate Manager)** - AWS-Dienst zum Beantragen und Verwalten von TLS-Zertifikaten; fuer CloudFront muss das Zertifikat in `us-east-1` liegen und per DNS validiert werden.
- **Ansible** - Automatisierungs-Tool auf YAML-Basis; im Projekt fuer das Provisionieren und Abbauen der AWS-Infrastruktur sowie fuer reproduzierbare Deployments genutzt.
- **Ansible Inventory** - Host- und Gruppen-Definitionen (z.B. `inventory/hosts.yml`), die den Ausfuehrungskontext fuer Playbooks festlegen.
- **Ansible Playbook** - Ausfuehrungsdatei, die Rollen in einer definierten Reihenfolge aufruft (z.B. `site.yml`, `post_validation.yml`, `destroy.yml`, `redeploy.yml`).
- **Ansible Rolle** - Modulartige Einheit mit Tasks/Variablen; kapselt Logik pro Service (z.B. S3 Bucket, CloudFront Distribution, Route53 Records, GitHub OIDC Rolle).
- **Artefakt** - Ergebnis eines Builds (z.B. `public/`), das von GitHub Actions gespeichert und deployed wird.
- **AWS (Amazon Web Services)** - Cloud-Plattform, auf der die Hosting-Infrastruktur (S3, CloudFront, Route53, ACM, IAM) betrieben wird.
- **AWS CLI** - Kommandozeilen-Tool zum Zugriff auf AWS; wird lokal in WSL eingesetzt und von Ansible/Workflows genutzt.
- **Branchschutz** - GitHub-Regeln, die z.B. direkte Pushes auf `main` verhindern und damit Code-Qualitaet sichern.
- **Bucket Policy** - Zugriffsrichtlinie eines S3 Buckets, z.B. um CloudFront-Lesezugriff zu erlauben und Public Access zu verhindern.
- **CDN (Content Delivery Network)** - Netz aus Edge-Standorten, das Inhalte nahe am Nutzer ausliefert; in diesem Projekt ueber CloudFront.
- **CI/CD (Continuous Integration/Continuous Deployment)** - Automatisierte Build- und Release-Kette; hier per GitHub Actions fuer Hugo-Build, Upload nach S3 und CloudFront-Invalidation.
- **CloudFront** - CDN von AWS; liefert die statische Hugo-Seite aus dem S3-Origin aus, unterstuetzt HTTPS via ACM-Zertifikat und Caching mit Invalidation.
- **CloudFront Distribution** - Konfigurationseinheit von CloudFront (Origin, Caching, Aliases, Zertifikat), ueber die die Seite ausgeliefert wird.
- **CloudFront Invalidation** - Vorgang, um gecachte Objekte zu loeschen, damit neue Deployments sofort sichtbar sind.
- **CNAME / A / AAAA Record** - DNS-Recordtypen; CNAME fuer ACM-Validierung, A/AAAA Alias fuer CloudFront.
- **DNS (Domain Name System)** - System, das Domainnamen auf IPs/Services aufloest; verwaltet ueber Route53.
- **DNS-Propagation** - Zeitliche Verzoegerung, bis DNS-Aenderungen weltweit wirksam werden.
- **DoD (Definition of Done)** - Projektinterne Checkliste: umgesetzt, gebaut/getestet, live geprueft, Doku/Notiz aktualisiert.
- **DoR (Definition of Ready)** - Kriterien, wann ein Backlog Item startklar ist: Ziel klar, Akzeptanzkriterien notiert, Zugriffe vorhanden.
- **GitHub Actions** - Automatisierter Workflow-Dienst; verwendet, um Hugo zu bauen, Artefakte zu speichern und via AWS-Rolle nach S3/CloudFront zu deployen.
- **GitHub Pages** - Hosting-Funktion von GitHub fuer statische Seiten; wurde im Projekt fuer Tests genutzt.
- **Git Repository** - Versionskontroll-Repository; enthaelt Doku und Produktcode.
- **Hugo** - Static-Site-Generator; erzeugt aus Markdown die statische Portfolio-Seite (Theme: Stack).
- **Hugo Extended** - Hugo-Variante mit Sass/SCSS-Unterstuetzung, benoetigt fuer das Stack-Theme.
- **IAM (Identity and Access Management)** - AWS-Dienst fuer Benutzer, Rollen und Berechtigungen.
- **IAM Policy** - JSON-Regelwerk, das Zugriffsrechte definiert (z.B. fuer S3, CloudFront, Route53).
- **IAM Role** - Temporar annehmbare Identitaet mit definierten Rechten (z.B. GitHub OIDC Rolle).
- **Infrastructure as Code (IaC)** - Infrastruktur wird als Code beschrieben und automatisiert bereitgestellt (hier mit Ansible).
- **Jira** - Tool fuer Projektmanagement und Scrum-Backlog.
- **Markdown** - Auszeichnungssprache fuer Inhalte; Grundlage der Hugo-Seiten und Dokumentation.
- **MVP (Minimum Viable Product)** - Erstes lauffaehiges Inkrement: Hugo-Seite + Build-Pipeline; spaeter um AWS/Ansible erweitert.
- **OAC/OAI (Origin Access Control/Identity)** - Mechanismen, mit denen CloudFront auf private S3 Buckets zugreift.
- **OIDC (OpenID Connect)** - Identitaetsprotokoll, mit dem GitHub Actions sich gegenueber AWS ausweist, ohne dauerhafte Access Keys.
- **Produkt Backlog** - Gesamtliste der User Stories/Tasks, die im Projekt umgesetzt werden sollen.
- **Route53** - AWS-DNS-Dienst; verwaltet Hosted Zones, CNAMEs fuer ACM-Validierung und A/AAAA-Alias-Eintraege auf CloudFront.
- **S3 Bucket** - Objektspeicher und Origin fuer CloudFront; bleibt privat, CloudFront greift via OAC/OAI zu.
- **S3 Static Website Hosting** - S3-Funktion fuer direktes, oeffentliches Hosting; im Projekt nur fuer Tests genutzt.
- **Scrum** - Agiles Rahmenwerk mit festen Sprints, Rollen und Zeremonien.
- **Sprint** - Zeitlich fixiertes Inkrement (hier 2 Wochen) mit Planung, Daily, Review und Retrospektive.
- **Sprint Review** - Meeting am Sprintende, in dem Ergebnisse gezeigt und Feedback gesammelt wird.
- **Sprint Retrospektive** - Rueckblick auf den Sprint: Was lief gut, was schlecht, welche Massnahmen folgen.
- **Stakeholder** - Anspruchsgruppen; hier insbesondere die Lehrpersonen, die das Projekt beurteilen.
- **Story Points** - Relative Aufwandsschaetzung (1,2,3,5,8,13) fuer Backlog Items; Grundlage der Sprint-Planung.
- **SWOT-Analyse** - Analyse von Staerken, Schwaechen, Chancen und Risiken des Projekts.
- **Terraform** - IaC-Tool, das fuer einmaliges Provisionieren geeignet ist; im Projekt bewusst nicht verwendet.
- **User Story** - Fachlich formulierte Anforderung aus Sicht eines Nutzers; Grundlage fuer Backlog Items.
- **VS Code** - Editor/IDE; genutzt fuer Entwicklung auf Windows und in WSL.
- **WSL (Windows Subsystem for Linux)** - Linux-Umgebung unter Windows; dient als Host fuer Ansible und CLI-Tools.
- **Zwei-Phasen-Setup** - Aufteilung in Initial-Setup und Post-Validation: Erst Infrastruktur erstellen, dann nach Zertifikats-Validierung CloudFront/DNS finalisieren.
