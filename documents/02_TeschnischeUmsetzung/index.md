---
layout: default
title: 2. Technische Umsetzung
nav_order: 3
has_children: true
---

{: .no_toc }

# Technische Umsetzung

In diesem Abschnitt, beschreibe ich die Technische Umsetzung des Projekts und die schlussendliche Funktionsweise des Produktes.

TODO - kurze zsfassung des kommenden Inhalts

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

- install WSL and open it in vs code (https://www.youtube.com/watch?v=bRW5r7TK6KM&t=368s)

- install ansible: (ps von chatgpt)
```bash
sudo apt update
sudo apt -y upgrade
sudo apt -y install ca-certificates curl unzip gnupg lsb-release software-properties-common python3 python3-pip pipx
pipx ensurepath

sudo apt -y install ansible
```

install git:
```bash
sudo apt -y install git

sudo apt -y install git
git config --global user.name "Your Name"
git config --global user.email "you@example.com"

```

Install AWS CLI:
```bash
sudo curl -L "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip
sudo unzip -q awscliv2.zip
sudo ./aws/install --update

```


Check if installed:
```bash
git --version
ansible --version
aws --version
```


- Created new respository for Ansible code -> "hugo-portfolio-starter"
- 

#### Test Hosting on AWS
- create s3 bucket
- build hugo website local
- Upload public files 
- Testing - 403
- Problem - bucket policy hat gefehlt:  

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::test-hugohosting01/*"
        }
    ]
}
```
- resultat screenshot einfügen

#### Test CloudFront hinzufügen


#### Best Practice changes

##### Lock down S3 bucket
- deactive static webhosting
- Block all public Access
- Change Bucket Policy:
New Policy:
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



### AWS CLI Setup for using it with ansible:

- create temporary user with permissions policy

Policy to attach:
```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "S3StaticSite",
      "Effect": "Allow",
      "Action": [
        "s3:CreateBucket",
        "s3:DeleteBucket",
        "s3:ListBucket",
        "s3:GetBucketLocation",
        "s3:PutBucketWebsite",
        "s3:PutBucketPolicy",
        "s3:PutBucketPublicAccessBlock",
        "s3:PutBucketTagging",
        "s3:PutBucketAcl",
        "s3:GetBucketPolicy",
        "s3:GetBucketWebsite"
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
        "route53:ListHostedZones",
        "route53:ListResourceRecordSets",
        "route53:ChangeResourceRecordSets",
        "route53:GetChange"
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
        "cloudfront:CreateInvalidation",
        "cloudfront:GetInvalidation",
        "cloudfront:TagResource",
        "cloudfront:UntagResource"
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

### Github Actions

policy code für HugoPortfolio_S3Deployer Rolle in IAM:
```
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Sid": "SyncToBucket",
			"Effect": "Allow",
			"Action": [
				"s3:PutObject",
				"s3:GetObject",
				"s3:ListBucket",
				"s3:DeleteObject"
			],
			"Resource": [
				"arn:aws:s3:::www.ruminahui.ch/*",
				"arn:aws:s3:::www.ruminahui.ch"
			]
		}
	]
}
```


flushcache policy: 
```
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Sid": "FlushCache",
			"Effect": "Allow",
			"Action": "cloudfront:CreateInvalidation",
			"Resource": "arn:aws:cloudfront::016084273735:distribution/E2E6PXSPTVGMI8"
		}
	]
}
```


Github Actions Workflow: (TODO - bearbeiten um branch und Role ARN auch als variable zu haben)
```
# Workflow for building and deploying a Hugo site to S3
name: Deploy Hugo site to S3

on:
  # Runs on pushes targeting the default branch
  push:
    branches: ["test-s3upload01"]

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
    runs-on: ubuntu-latest
    env:
      HUGO_VERSION: ${{ vars.HUGO_VERSION }}
    steps:
      - name: Install Hugo CLI
        run: |
          wget -O ${{ runner.temp }}/hugo.deb https://GitHub.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_linux-amd64.deb \
          && sudo dpkg -i ${{ runner.temp }}/hugo.deb          
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
            --baseURL "${{ vars.SITE_BASE_URL }}/"          
      - name: Upload a Build Artifact
        uses: actions/upload-artifact@v4.3.1            
        with:
          name: hugo-site
          path: ./public

  # Deployment job
  deploy:
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
          role-to-assume: arn:aws:iam::016084273735:role/HugoPortfolio_S3Deployer # this will be the ARN of the role you created in the "Creating a Role for deployment" step.
          role-session-name: GithubActions-MyHugoProject
          mask-aws-account-id: true
      - name: Sync to S3
        id: deployment
        run: aws s3 sync ./public/ s3://${{ vars.BUCKET_NAME }} --delete --cache-control max-age=31536000
      - name: Cloudfront Invalidation
        id: flushcache
        run: aws cloudfront create-invalidation --distribution-id ${{ vars.CF_DISTRIBUTION_ID }} --paths "/*"
```



## Design

### Architektur Skizze

### Use Cases

## Herausforderungen

- a

## Testingprotocoll & Results
