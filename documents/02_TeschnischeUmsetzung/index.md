---
layout: default
title: 2. Technische Umsetzung
nav_order: 3
has_children: true
---

{: .no_toc }

# Technische Umsetzung

In diesem Abschnitt, beschreibe ich die Technische Umsetzung des Projekts und die schlussendliche Funktionsweise des Produktes.

## Initial Setup / Entwicklungsumgebung 

Im folgenden erläutere ich, wie ich meine Entwicklungsumgebung eigerichtet habe. Wichtig dabei ist, dass ich auf einem Windows Gerät arbeite und für Ansible eine WSL Instanz verwende. Auf diese Insatz greife ich direkt über VSCode zu. Genaueres dazu später.

### Hugo Setup

Wenn man eine Hugo Website auf Github Pages oder auf AWS hosten will, muss man eigentlich Hugo nicht direkt auf seinem Gerät installieren.
Die entsprechenden Github Workflows, führen den Build command mit der neusten Hugo version in einer temporären Umgebung aus. Die daraus generierte statische Seite wird dann in einen Public ordner geladen und dieser wird veröffentlicht. 

Allerdings wollte ich sicherstellen, dass mein bearbeitetes template richtig 'builded' und dass ich die Error Meldungen direkt einsehen kann, um allfällige Probleme einfacher debuggen zu können.

Hier eine kurze Anleitung um dieses Setup einzurichten:
1. Hugo auf windows installieren. Wichtig ist hierbei die 'extended' Version zu installieren, da diese für das Stack Theme benötigt wird
```cmd
winget install Hugo.Hugo.Extended
```
2. Go über den MSI installer installieren wie unter [https://go.dev/doc/install](https://go.dev/doc/install) beschrieben.
3. Dart Sass gemäss [Hugo Anleitung](https://gohugo.io/functions/css/sass/#dart-sass) installieren. Dafür habe ich persönlich die [prebuilt binaries](github.com/sass/dart-sass/releases/latest) zur installation verwendet und entsprechend mit zur PATH Variable hinzugefügt.
4. Nun kann man das [starter Template](https://github.com/CaiJimmy/hugo-theme-stack-starter) nutzen, das JimmyCai, der ersteller des Stack Themes, vorbereitet hat. Dafür einfach seine Repository Klonen und umbennenen. Ich habe diese für den Moment "portfolio" benannt.
5. Nun kann ich lokal das Template anpassen und mit Hugo testen.


#### Template anpassen

Ich habe das Template entsprechend meiner Vorstellungen angepasst. Dafür habe ich vorallem irrelevante Beispiel Posts entfernt, einen eigenen Beispiel Post erstellt und alle Syntax tipps, die das vorherige Template gelistet hat, in einem Post 'Markdown Cheatsheet' zusammengefasst.

Um neue Posts zu erstellen, kann man den Befehl "hugo new post/POSTNAME/index.md" nutzen oder ein existierenden Post 

So sah meine Version zu dem Zeitpunkt aus:

<video controls playsinline preload="metadata" width="100%">
  <source src="{{ '/resources/videos/SCRUM-59_lokaleVorschauTest.mp4' | relative_url }}" type="video/mp4">
  Your browser does not support the video tag.
</video>

> [Source Video File](../../resources/videos/SCRUM-59_lokaleVorschauTest.mp4)

Diese Version hatte ich auch mit den Lehrern geteilt. Eine Weile hatte ich diese auf Github Pages veröffentlicht. 

Wie ihr seht, hatte ich es zum Testen bereits mit etwas persönlichem Inhalt beschrieben. Dies habe ich später wieder genralisieren müssen, um daraus ein wiederverwendbares Produkt zu machen.

**Wichtige Erkentnisse**
Ich habe in diesem Schritt einiges ausprobiert, um zu verstehen wie Hugo funktioniert. Folgende Erkentnisse habe ich daraus entnommen:
- Hugo muss nicht lokal installiert/'builded' werden, wenn es über Github pages veröffentlicht wird. Das Template bietet bereits ein Github Workflow für den build und deployment Prozess.
- Um neue Posts zu erstellen muss nicht unbedingt der entsprechende Hugo Befehl verwendet werden und es ist praktischer ein vorherigen Post-Odner einfach zu kopieren.
- In der Metadata der Posts, können Posts als Draft markiert werden, wodurch diese nicht veröffentlicht werden. 
- Auch kann ein Veröffentlichungsdatum geplant werden. Wenn dies während dem build Prozess in der Zukunft liegt, wird der Post auch nicht veröffentlicht.

### Ansible & AWS

**VSCode über WSL**

Wie bereits erwähnt, arbeite ich auf einem Windows Computer. Ansible kann aber nicht auf Windows ausgeführt werden. Deshalb musst ich eine WSL Instanz installieren.

Nun gibt es die Möglichkeit VSCode direkt in einer solchen WSL Instanz zu öffnen. Dadurch kann man VSCode ganz normal verwenden um Ansible Code zu entwickeln. Es wird gleich angezeigt wie wenn es auf Windows läuft, allerdings läuft die App eigentlich auf der WSL Instanz. Man hat also ein Bash Terminal das auf die Linux Instanz zugreift und die Dateien werden auch auf der WSL Instanz gespeichert.

Man muss allenfalls in der Umgebung erneuert dinge wie Hugo oder sonstige benötigte Software installieren und auch VSCode extensions müssen nochmals installiert werden.

Hier findet ihr das Tutorial, nachdem ich mir diese Umgebung aufgebaut habe: [https://www.youtube.com/watch?v=bRW5r7TK6KM&t=368s](https://www.youtube.com/watch?v=bRW5r7TK6KM&t=368s)

**Benötigte Software installieren**

Nun da ich auf der WSL Umgebung arbeiten konnte, mussten als nächstes alle Tools installiert werden, welche ich für das Projekt benötigte. Hier eine kurze Anleitung dazu:

1. Ansible installieren:
```bash
sudo apt update
sudo apt -y upgrade
sudo apt -y install ca-certificates curl unzip gnupg lsb-release software-properties-common python3 python3-pip pipx
pipx ensurepath

sudo apt -y install ansible
```

2. Git installieren

```bash
sudo apt -y install git

sudo apt -y install git
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```


3. AWS CLI installieren:
```bash
sudo curl -L "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip
sudo unzip -q awscliv2.zip
sudo ./aws/install --update

```

4. Mit folgenden befehlen kann man verifizieren das alles installiert ist:
```bash
git --version
ansible --version
aws --version
```
![Proof of Installation](..\..\resources\images\proofOfInstallation01.png)

**Neue Repository**
Der Ansible Code, muss im Moment nicht wirklich mit dem Hugo Template interargieren. Um also in ruhe den Ansible Code schreiben und testen zu können, habe ich eine eigene Repository 'https://github.com/RuminahuiM/hugo-portfolio-setup' dafür erstellt.
Später habe ich die beiden Repositories zusammengeführt, weshalb das fertige Produkt sich nun in dieser Repository befindet. Genaueres dazu später.

#### Mauelles Test Hosting auf AWS einrichten

Damit es mir später einfacher fällt, das Setup über Ansible zu erstellen, habe ich erst mal das ganze Manuell eingerichtet.

Automatisierungen sind immer einfacher zu erstellen, wenn man bereits den genauen Prozesse einmal durchgespielt hat und alle Eigenheit kennt, die Probleme verursachen könnten.

Ich habe auch hier bereits die Domain 'ruminahui.ch' für mein Projekt gekauft, um das Portfolio später darüber zu veröffentlichen und bereits damit testen zu können.

Im folgenden beschreibe ich die Manuelle erstellung der einzelnen Komponenten.

**S3 Bucket erstellen**

Ich habe zuerst einen Public Bucket erstellt und darauf Static Webhosting aktiviert. Dann habe ich den Inhalt des Public Ordners von Hugo hochgeladen, um das Webhosting zu testen.

Bucket Versioning bleibt deaktiviert, da wir mit Github bereits ein Versionierungstool haben.

1. Standard S3 Bucket erstellt:
![Test Hosting S3 Properties](..\..\resources\images\testHosting_S3props.png)

2. Static Webhosting aktiviert:
![Test Hosting S3 Webhosting](..\..\resources\images\testHosting_S3web.png)

3. Public Access zulassen:
![Test Hosting S3 Allow Public Access](..\..\resources\images\testHosting_S3pblaccess.png)

4. Public Read Policy konfiguriert:
![Test Hosting S3 Bucket Policy](..\..\resources\images\testHosting_S3Policy.png)

5. Nun war die Seite unter dem AWS Resource link verfügbar:
![Test Hosting S3 Result](..\..\resources\images\testHosting_S3_result.png)

Für CloudFront muss der Bucket nicht öffentlich sein. Deshalb habe ich später das Static Webhosting deaktiviert, die Bucket Policy entsprechend entfernt und Public Access auf den Bucket wieder blockiert, um das ganze auch mit dem privaten Bucket und der entsprechenden Policy zu testen.

Neue Bucket Policy:
```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowCloudFrontServicePrincipalReadOnly",
      "Effect": "Allow",
      "Principal": { "Service": "cloudfront.amazonaws.com" },
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::YOUR_BUCKET_NAME/*",
      "Condition": {
        "StringEquals": {
          "AWS:SourceArn": "arn:aws:cloudfront::YOUR_ACCOUNT_ID:distribution/YOUR_DISTRIBUTION_ID"
        }
      }
    }
  ]
}
```

![Test Hosting S3 Block Public Access](..\..\resources\images\testHosting_S3_block.png)

**Route 53 Konfiguration:**

> Route 53 Beschreibung gemäss ChatGPT: Route 53 ist ein Dienst von Amazon Web Services (AWS).Damit kannst du DNS-Einträge verwalten, also z.B. festlegen, auf welchen Server eine Domain zeigt. Er kann auch prüfen, ob Server erreichbar sind, und den Traffic automatisch umleiten. Man kann ihn außerdem nutzen, um Domains zu registrieren.

Wir verwenden Route 53 als unseren DNS Dienst, um alle zugriffe auf unsere domain direkt zu unserer Hugo Seite weiterzuleiten.

Da ich zuerst das Hosting ohne CloudFront getestet habe, habe ich die Domain direkt zum Static Hosting auf dem S3 Bucket geleitet. Später habe ich das ganze zu CloudFront weitergeleitet. Mehr dazu im Abschnitt zum CloudFront Test. 

1. Zuerst habe ich eine Hosted Zone für meine Domain erstellt:
![Test Hosting Route 53 HostedZone](..\..\resources\images\testHosting_R53_zone.png)

2. Folgende default einträge werden automatisch erstellt:
![Test Hosting Route 53 DefaultRecords](..\..\resources\images\testHosting_R53_defRecords.png)

3. Nun kann man das ganze zur S3 Resource weiterleiten mit folgendem Eintrag:
![Test Hosting Route 53 Routed to S3](..\..\resources\images\testHosting_R53_routetoS3.png)

4. Beim Domain Registrar müssen noch die Nameserver angepasst werden, welche offiziell für die Domain zuständig sind. Dafür die im Route 53 angegebenen Nameserver in der Konfiguration der Domain angeben. Bei Hostpoint sieht das folgendermasen aus:
![Test Hosting Route 53 Nameservers](..\..\resources\images\testHosting_R53_NS.png)
![Test Hosting Route 53 Registrar](..\..\resources\images\testHosting_R53_registrar.png)

5. Nachdem die DNS Propagation durch ist kann man nun über HTTP auf die Seite zugreifen. Sie ist aber nicht SSL verschlüsselt:
![Test Hosting Route 53 Result](..\..\resources\images\testHosting_R53_result.png)

**ACM Zertifikat erstellen:**

Damit wir die Seite auch über HTTPS erreichen können, müssen wir noch ein Zertifikat für die Domäne erstellen und das validieren. 

> WICHTIG: Das Zertifikat muss in der Region us-east-1 angelegt sein. Nur so kann es für CloudFront verwendet werden.

1. Auf die Region us-east-1 in der AWS Konsole wechseln und unter ACM ein öffentliches Zertifikat beantragen:
![Test Hosting ACM Request](..\..\resources\images\testHosting_ACM_request.png)

2. Beim Zertifikat wir der status als 'Pending Validation' angezeigt:
![Test Hosting ACM Pending](..\..\resources\images\testHosting_ACM_pending.png)

3. Nun muss man in Route 53 die Validierung aufesetzen. Dafür einfach ein CNAME erstellen. Name und Value werden beim Zertifikat angezeigt:
![Test Hosting ACM DNS Validation](..\..\resources\images\testHosting_ACM_validation.png)

4. Die Validierung kann eine Weile dauern. Sobald es validiert ist dies es folgendermassen aus:
![Test Hosting ACM DNS Validated](..\..\resources\images\testHosting_ACM_validated.png)

**CloudFront konfiguration:**

Als nächstes ging es darum das ganze über eine CloudFront Distribution zu testen. So sollte es schlussendlich auch gehostet werden.

1. CloudFront Distribution erstellen:
![Test Hosting CloudFront](..\..\resources\images\testHosting_CF_create.png)

2. Origin Type muss als S3 origin konfiguriert werden:
![Test Hosting CloudFront](..\..\resources\images\testHosting_CF_origin.png)
![Test Hosting CloudFront](..\..\resources\images\testHosting_CF_originEndpoint.png)

3. Weiter mit Standardeinstellungen bis man zum Zertfikat kommt. Hier müssen wir das validierte Zertifikat angeben. Es wird erst erscheinen, sobald es validiert wurde. Ich hatte es hier noch ohne Zertifikat erstellt und habe es im Nachhinein angehängt.

4. Nun müssen wir den Route53 A Record, den wir zuvor zu S3 weitergeleitet haben, zu CloudFront weiterleiten:
![Test Hosting CloudFront](..\..\resources\images\testHosting_CF_Arecord.png)

5. Wie erwähnt, hängen wir nun das Zertifikat an. Auch geben wir hier 'ruminahui.ch' und 'www.ruminahui.ch' als alternative domain names an
![Test Hosting CloudFront](..\..\resources\images\testHosting_CF_zert.png)
![Test Hosting CloudFront](..\..\resources\images\testHosting_CF_final.png)

Danach war die Seite über HTTPS erreichbar und so eingerichtet, wie ich sie haben wollte. Diese Version habe ich ebenfalls eine Weile Online gelassen, damit die zuständigen Lehrer (Stakeholder) diese einsehen konnten.

#### Umsetzung in Ansible

Ich werde kurz erläutern wie ich vorgegangen bin und danach auf die Architektur des Endprodukts eingehen.

Für die Umsetzung in Ansible habe ich viel mit AI gearbeitet. ChatGPT hat einen grossteil des Codes geschrieben. Da ich alle Schritte kannte, konnte ich die AI recht gut durch diesen Prozess leiten.

Zuerst habe ich ChatGPT ein Framework erstellen lassen und dabei alle elemente bennant die später erstellt werden sollten und auch erwähnt, wie ich dabei vorgehen werde und wie meine Entwicklungsumgebung aussieht.

Danach konnte ich jedes einzelne Element durchgehen und für jedes jeweils benötigte Variablen & Roles definieren lassen sowie das Deployment Playbook entsprechend anpassen. Ich habe nach jeder Änderung das ganze reviewed, getestet und debugged, bis es funktionierte.

So konnte ich nach und nach die einzelnen Elemente durchgehen, bis alle erfolgreich & korrekt erstellt werden konnten.

Da ich dadurch sehr häufig alles wieder löschen und neu erstellen musste, habe ich recht bald ein paar weitere Playbooks hinzufügen lassen. 'destroy.yml' löscht alle zuvor erstellten Ressourcen und 'redeploy.yml' löst das destroy Playbook aus und danach das 'site.yml' Playbook, welches alles erneuert aufsetzt.

**Problem mit Zertifikat Validierung**
Um die Website über HTTPS mit der eigenen Domäne nutzen zu können, muss man ein Zertifikat dafür erstellen und das über DNS validieren. Das Problem hierbei, ist dass dieser Prozess mehrere Stunden dauern kann. Damit nachher aber alles korrekt funktioniert, muss es nach der Validierung auch in der CloudFront konfiguration angehängt werden. Ich habe keinen Weg gefunden, dieses anzuhängen, bevor es validiert wurde. 

Somit gab es nur 2 Optionen. Die erste ist, dass man ein Wartefenster einbaut, indem Ansible wartet, bis das Zertifikat als validiert markiert wurde und hängt es danach an.
Die Zweite Option, ist ein weiteres Playbook zu erstellen, dass ausgeführt wird, sobald das Zertifikat validiert wurde und das entsprechend das Zertifikat bei CloudFront änhängt.

Mit der ersten Option, müsste man den PC auf dem man Ansible laufen lässt, für mehrere Stunden im Hintergrund laufen lassen. Dies ist vielleicht eine Valide Option für einen Server, aber dieses Produkt richtet sich an Privatpersonen, die das ganze einfach auf ihrem normalen PC ausführen wollen.

Deshalb habe ich ein "post_validation" Playbook erstellt. Sobald das Zertifikat validiert wurde, kann man dieses ausführen und es schliesst das Setup ab. Nach eine Weile ist die Seite dann bereits online.

**Ansible Architektur**

> Note: Dies folgende Beschreibung wurde mit ChatGPT erstellt, da es durch direkten Zugriff auf den Code das ganze sehr effizient einsehen kann und da ein Grossteil des Codes bereits durch ChatGPT erstellt wurde.

> **Architekturüberblick**
> **Ausführungskontext:** `ansible/ansible.cfg` setzt Inventory und Rollenpfad; `ansible/inventory/hosts.yml` definiert > localhost als Ziel, AWS-Region wird pro Play gesetzt.
> **Orchestrierung:** Die Playbooks koordinieren den Lebenszyklus, Rollen kapseln die Fachlogik pro AWS-Service.
> **Modularität:** Funktionen sind über `*_enabled` schaltbar; Zustände über `*_state` und Behalte-Flags `keep_*` > steuerbar.
> **Datenfluss:** Rollen setzen Fakten (IDs/ARNs/Domain-Namen) und nutzen sie zur Auflösung von Abhängigkeiten.
> **Ausgaben:** Ein Output-Modul stellt GitHub-Variablen und DNS-Infos für die nächsten Schritte bereit.
> 
> **Playbook-Fluss**
> **Provisioning:** `ansible/playbooks/site.yml` setzt die AWS-Umgebung, initialisiert Variablen und führt die Rollen in > definierter Reihenfolge aus.
> **Post-Validation:** `ansible/playbooks/post_validation.yml` aktualisiert nach der ACM-Validierung CloudFront und DNS.
> **Destroy:** `ansible/playbooks/destroy.yml` setzt States auf absent, räumt Records, deaktiviert CloudFront und entfernt > Ressourcen.
> **Redeploy:** `ansible/playbooks/redeploy.yml` kombiniert Destroy und Site für einen sauberen Neustart.
> 
> **Rollen-Module**
> **Storage/CDN:** `ansible/roles/s3_static_site` verwaltet das Bucket; `ansible/roles/cloudfront_distribution` erstellt > die Distribution, OAI und S3-Policy.
> **TLS-Zertifikate:** `ansible/roles/acm_certificate` beantragt Zertifikate, liest Validierungs-Records und prüft den > Status.
> **DNS-Zone:** `ansible/roles/route53_hosted_zone` erstellt die Hosted Zone und liefert Nameserver.
> **DNS-Records:** `ansible/roles/route53_records` legt A/AAAA-Alias-Records an und bereinigt sie beim Abbau.
> **Deployment-Identity:** `ansible/roles/github_deployer_role` richtet GitHub-OIDC und eine Deploy-Rolle inkl. Policies > ein.
> **IAM & Outputs:** `ansible/roles/iam_role` erzeugt zusätzliche Rollen; `ansible/roles/deployment_outputs` gibt GitHub-Variablen und Next-Steps aus.
> - ChatGPT, https://chatgpt.com

**AWS CLI User Setup um über Ansible zuzugreifen:**
Damit man über Ansible auf die AWS CLI zugreifen kann, muss am Anfang ein temporärer User erstellt werden mit einem Access Key und bestimmten Berechtigungen.

Ich habe hierfür darauf geachtet, nur benötigte Berechtigungen zu vergeben. 

Eine Anleitung zur erstellung des Users und der Anwendung der Credentials, findet ihr in README des Produktrepositories: [https://github.com/RuminahuiM/hugo-portfolio-setup/tree/main?tab=readme-ov-file#aws-credentials](https://github.com/RuminahuiM/hugo-portfolio-setup/tree/main?tab=readme-ov-file#aws-credentials)

Die Policy die für den User angewendet wird, ist ebenfalls dort enthalten ihr könnt sie aber auch direkt hier einsehen:

<details>
<summary>IAM policy JSON</summary>

```json
{
"Version": "2012-10-17",
"Statement": [
    {
    "Sid": "S3StaticSite",
    "Effect": "Allow",
    "Action": [
        "s3:CreateBucket",
        "s3:DeleteBucket",
        "s3:DeleteObject",
        "s3:DeleteObjectVersion",
        "s3:ListBucket",
        "s3:ListBucketVersions",
        "s3:GetBucketLocation",
        "s3:GetBucketPolicy",
        "s3:GetBucketWebsite",
        "s3:GetBucketTagging",
        "s3:GetBucketVersioning",
        "s3:GetBucketRequestPayment",
        "s3:GetBucketPublicAccessBlock",
        "s3:GetBucketOwnershipControls",
        "s3:GetBucketAcl",
        "s3:GetBucketObjectLockConfiguration",
        "s3:GetInventoryConfiguration",
        "s3:PutBucketWebsite",
        "s3:PutBucketPolicy",
        "s3:PutBucketPublicAccessBlock",
        "s3:PutBucketTagging",
        "s3:PutBucketAcl"
    ],
    "Resource": "*"
    },
    {
    "Sid": "ACM",
    "Effect": "Allow",
    "Action": [
        "acm:RequestCertificate",
        "acm:DescribeCertificate",
        "acm:DeleteCertificate",
        "acm:ListCertificates",
        "acm:ListTagsForCertificate",
        "acm:AddTagsToCertificate",
        "acm:RemoveTagsFromCertificate"
    ],
    "Resource": "*"
    },
    {
    "Sid": "Route53",
    "Effect": "Allow",
    "Action": [
        "route53:CreateHostedZone",
        "route53:DeleteHostedZone",
        "route53:GetHostedZone",
        "route53:UpdateHostedZoneComment",
        "route53:ListHostedZones",
        "route53:ListResourceRecordSets",
        "route53:ChangeResourceRecordSets",
        "route53:GetChange",
        "route53:GetDNSSEC",
        "route53:EnableHostedZoneDNSSEC",
        "route53:DisableHostedZoneDNSSEC",
        "route53:ListTagsForResource",
        "route53:ChangeTagsForResource"
    ],
    "Resource": "*"
    },
    {
    "Sid": "CloudFront",
    "Effect": "Allow",
    "Action": [
        "cloudfront:CreateDistribution",
        "cloudfront:UpdateDistribution",
        "cloudfront:GetDistribution",
        "cloudfront:GetDistributionConfig",
        "cloudfront:DeleteDistribution",
        "cloudfront:ListDistributions",
        "cloudfront:CreateCloudFrontOriginAccessIdentity",
        "cloudfront:GetCloudFrontOriginAccessIdentity",
        "cloudfront:ListCloudFrontOriginAccessIdentities",
        "cloudfront:DeleteCloudFrontOriginAccessIdentity",
        "cloudfront:CreateInvalidation",
        "cloudfront:GetInvalidation",
        "cloudfront:TagResource",
        "cloudfront:UntagResource",
        "cloudfront:ListTagsForResource"
    ],
    "Resource": "*"
    },
    {
    "Sid": "GitHubOIDCProvider",
    "Effect": "Allow",
    "Action": [
        "iam:CreateOpenIDConnectProvider",
        "iam:DeleteOpenIDConnectProvider",
        "iam:GetOpenIDConnectProvider"
    ],
    "Resource": "*"
    },
    {
    "Sid": "STS",
    "Effect": "Allow",
    "Action": [
        "sts:GetCallerIdentity"
    ],
    "Resource": "*"
    },
    {
    "Sid": "IAMRole",
    "Effect": "Allow",
    "Action": [
        "iam:CreateRole",
        "iam:DeleteRole",
        "iam:GetRole",
        "iam:UpdateRoleDescription",
        "iam:UpdateAssumeRolePolicy",
        "iam:AttachRolePolicy",
        "iam:DetachRolePolicy",
        "iam:PutRolePolicy",
        "iam:DeleteRolePolicy",
        "iam:TagRole",
        "iam:UntagRole",
        "iam:ListAttachedRolePolicies",
        "iam:ListRolePolicies"
    ],
    "Resource": "*"
    }
]
}
```

</details>

**Anwendung:**

Die Anwendung des Ansible Codes wird im [README der Produktrepository](https://github.com/RuminahuiM/hugo-portfolio-setup) detailiert beschrieben. Deshalb werde ich diese hier nicht erneuert ausführen.

### Github Actions

Nun ging es nur noch darum über Github Actions Updates der Hugo Seite hochladen zu können.

Dafür habe ich ein Deployment Workflow erstellt, welches über eine IAM Role zugriff auf den S3 Bucket erhält und auch die Berechtigung hat, die aktuelle Seite auf CloudFront zu überschreiben (invalidate).

Das ganze basiert hauptsächlich auf bestehennden Code aus diesem Artikel: [https://jeromethibaud.com/en/blog/deploy-hugo-site-to-s3/](https://jeromethibaud.com/en/blog/deploy-hugo-site-to-s3/)

Allfällige Änderungen daran habe ich mit AI erstellt. Weshalb ich hier nicht grossartig darauf eingehen werde.

Wichtig ist das die Rolle nachfolgende Permission Policies erhält. Dies sind nur Beispiele und müssten entsprechend angepasst werden. Diese Rolle wir aber auch durch den Ansible Code miterstellt und benötigte informationen werden ausgegeben. 

**CF Invalidation**
```json
{
	"Statement": [
		{
			"Action": "cloudfront:CreateInvalidation",
			"Effect": "Allow",
			"Resource": "arn:aws:cloudfront::016084273789:distribution/EGCLATS1J8CNP",
			"Sid": "FlushCache"
		}
	],
	"Version": "2012-10-17"
}
```

**Deployment to S3**
```json
{
	"Statement": [
		{
			"Action": [
				"s3:PutObject",
				"s3:GetObject",
				"s3:ListBucket",
				"s3:DeleteObject"
			],
			"Effect": "Allow",
			"Resource": [
				"arn:aws:s3:::www.ruminahui.ch",
				"arn:aws:s3:::www.ruminahui.ch/*"
			],
			"Sid": "SyncToBucket"
		}
	],
	"Version": "2012-10-17"
}
```

Als Trusted Entity wird die eigene Repository eingetragen mit dem gewünschten branch. Beispiel:
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::016084273486:oidc-provider/token.actions.githubusercontent.com"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "token.actions.githubusercontent.com:sub": "repo:RuminahuiM/hugo-portfolio-setup:ref:refs/heads/public",
                    "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
                }
            }
        }
    ]
}
```

Der Workflow ist einerseits in der Produkt Repository [hier](https://github.com/RuminahuiM/hugo-portfolio-setup/blob/main/.github/workflows/deployToS3.yml) zu finden. Ihr könnt ihn aber auch direkt hier einsehen:
<details>
<summary>Github Workflow</summary>

```yml
# Workflow for building and deploying a Hugo site to S3
name: Deploy Hugo site to S3

on:
  push:
    branches:
      - "**"

  # Allows you to run this workflow manually from the Actions tab
  workflow_dispatch:
# Sets permissions of the GITHUB_TOKEN to allow deployment to S3
permissions:
  contents: read
  id-token: write

# Allow only one concurrent deployment, skipping runs queued between the run in-progress and latest queued.
# However, do NOT cancel in-progress runs as we want to allow these production deployments to complete.
concurrency:
  group: "hugo_deploy"
  cancel-in-progress: false

# Default to bash
defaults:
  run:
    shell: bash

jobs:
  # Build job
  build:
    if: github.ref_name == vars.DEPLOY_BRANCH
    runs-on: ubuntu-latest
    steps:
      - name: Setup Hugo
        uses: peaceiris/actions-hugo@v2
        with:
          hugo-version: "latest"
          extended: true
      - name: Install Dart Sass
        run: sudo snap install dart-sass
      - name: Checkout
        uses: actions/checkout@v4
        with:
          submodules: recursive
#      - name: Install Node.js dependencies
#        run: "[[ -f package-lock.json || -f npm-shrinkwrap.json ]] && npm ci || true"
      - name: Build with Hugo
        env:
          # For maximum backward compatibility with Hugo modules
          HUGO_ENVIRONMENT: production
          HUGO_ENV: production
        run: |
          hugo \
            --minify \
            --source hugo-site \
            --baseURL "${{ vars.SITE_BASE_URL }}/"          
      - name: Upload a Build Artifact
        uses: actions/upload-artifact@v4.3.1            
        with:
          name: hugo-site
          path: hugo-site/public

  # Deployment job
  deploy:
    if: github.ref_name == vars.DEPLOY_BRANCH
    runs-on: ubuntu-latest
    needs: build
    steps:
      - name: Download artifacts (Docker images) from previous workflows
        uses: actions/download-artifact@v4
        with:
          name: hugo-site
          path: ./public
      - name: "Configure AWS Credentials"
        uses: aws-actions/configure-aws-credentials@v4.0.2
        with:
          aws-region: ${{ vars.AWS_REGION }}
          role-to-assume: ${{ vars.AWS_ROLE_ARN }}
          role-session-name: GithubActions-MyHugoProject
          mask-aws-account-id: true
      - name: Sync to S3
        id: deployment
        run: aws s3 sync ./public/ s3://${{ vars.BUCKET_NAME }} --delete --cache-control max-age=31536000
      - name: Cloudfront Invalidation
        id: flushcache
        run: aws cloudfront create-invalidation --distribution-id ${{ vars.CF_DISTRIBUTION_ID }} --paths "/*"

```
</details>

**Anwendung:**
Um den Deployment Workflow nutzen zu können, müssen gewisse Parameter als Repository Variablen gesetzt werden. Danach können einfach Änderungen des angegebenen Branch gepusht werden und die Live-Seite wird aktualisiert.

Eine genaue Anleitung findet ihr im README des Produktrepositories: [https://github.com/RuminahuiM/hugo-portfolio-setup/tree/main?tab=readme-ov-file#after-the-first-run](https://github.com/RuminahuiM/hugo-portfolio-setup/tree/main?tab=readme-ov-file#after-the-first-run)

### Cost Monitoring

Ich habe Schlussendlich kein automatisch eingerichtetes Cost-Monitoring eingerichtet. Hauptsächlich, weil der User zum das aktivieren, seine Identität verifizieren und seine Daten für die Abrechnung angeben muss.

Allerdings werden alle Ressourcen die durch Ansible erstellt werden, mit einem Tag versehen, welches im user.yml konfiguriert werden kann. Mithilfe dieses Tags kann man sich recht einfach ein Kost Monitoring manuell einrichten.

## Design

### Architektur
Im folgenden Bild, seht ihr eine vereinfachte Darstellung der geplanten Architektur für dieses Produkt:

[Architektur Skizze](../../resources/images/architektur.png)

Wie ihr sehen könnt, ist das Ziel eine Repository zu haben, welche bei einem Push die Hugo Seite erstellt (build) und diese auf einen S3 Bucket hochlädt. Dieser S3 Bucket wird von CloudFront als Datenablage verwendet. CloudFront stellt vereinfach gesagt einen Webserver dar, welcher die Seite zur Verfügung stellt. 

### Use Cases 

Grundsätzlich, kann das Endprodukt für verschiedene Zwecke verwendet werden. Dieses Template ist zwar dazu gedacht als Portfolio verwendet zu werden, allerdings kann man sich auch ein Blog damit erstellen oder anderes.

Es wäre auch recht einfach, das Theme zu ändern. Dafür muss der User einfach den Hugo Ordner mit seinem eigenen Hugo Template ersetzen. Dadurch gibt es sehr viele Einsetzmöglichkeiten für dieses Produkt.

Wenn man es richtig konfiguriert, kann man auch eine Zweite Repository angeben, die über einen Github Workflow hochgeladen werden soll. Dadurch könnte man es für jegliche Art von statischer Webseite verwenden. Das Produkt würde einfach die Infrastruktur für eine CloudFront distribution einrichten.

Im Normalfall, wird ein möglicher User dieses Template kopieren, sich damit einmal die Infrastruktur deployen und den Ansible part nicht mehr wirklich benötigen.

Wenn die Seite runtergenommen werden soll, kann es verwendet werden, um alles wieder zu löschen mit nur einem Befehl.

## Testingprotocoll & Results

| Test-ID | Playbook | Zweck | Vorbedingungen | Schritte (Befehl) | Erwartetes Ergebnis | Effektives Ergebnis |
|---|---|---|---|---|---|---|
| TP-01 | `ansible/playbooks/site.yml` | Erstes Provisioning aller AWS-Ressourcen | AWS-Creds vorhanden; AWS CLI installiert; Collections aus `ansible/requirements.yml` installiert; Variablen wie `aws_region`, `s3_bucket_name`, `route53_zone_name`, `acm_domain_name`, `cloudfront_aliases` gesetzt | `ansible-playbook ansible/playbooks/site.yml` | S3, CloudFront, ACM, Route53, IAM, GitHub-OIDC erstellt; Outputs werden angezeigt | Erfolgreich: alle Ressourcen erstellt, Outputs sichtbar, keine Fehler |
| TP-02 | `ansible/playbooks/site.yml` | Idempotenz pruefen | Ressourcen aus TP-01 existieren | `ansible-playbook ansible/playbooks/site.yml` | Keine neuen Ressourcen; nur minimale Aenderungen; keine Fehler | Erfolgreich: keine unerwarteten Aenderungen, run stabil |
| TP-03 | `ansible/playbooks/post_validation.yml` | CloudFront/DNS nach ACM-Validierung finalisieren | ACM-Zertifikat ist `ISSUED`; DNS-Validierung abgeschlossen | `ansible-playbook ansible/playbooks/post_validation.yml` | CloudFront nutzt Custom-Cert + Aliases; Route53-Records gesetzt | Erfolgreich: CloudFront aktualisiert, DNS-Records aktiv |
| TP-04 | `ansible/playbooks/destroy.yml` | Vollstaendiger Abbau | Ressourcen existieren; `keep_*` Flags sind false | `ansible-playbook ansible/playbooks/destroy.yml` | Route53-Records entfernt; CloudFront deaktiviert; S3 geleert/geloescht; IAM entfernt; ACM geloescht (oder Warnung falls noch in Nutzung) | Erfolgreich: Ressourcen entfernt, keine Restobjekte |
| TP-05 | `ansible/playbooks/redeploy.yml` | Sauberer Neustart (Destroy + Provision) | TP-01 oder TP-04 durchgefuehrt | `ansible-playbook ansible/playbooks/redeploy.yml` | Ressourcen werden entfernt und neu erstellt; neue IDs/ARNs; Outputs erscheinen | Erfolgreich: Redeploy komplett, neue IDs/ARNs vorhanden |
| TP-06 | `ansible/playbooks/site.yml` oder `ansible/playbooks/destroy.yml` | Bedingte Rollen (enable/disable) testen | Beispiel: `cloudfront_enabled=false` oder `route53_enabled=false` gesetzt | `ansible-playbook ansible/playbooks/site.yml` | Deaktivierte Rollen werden uebersprungen; nur aktivierte Services veraendern sich | Erfolgreich: deaktivierte Rollen skipped, keine Nebenwirkungen |
