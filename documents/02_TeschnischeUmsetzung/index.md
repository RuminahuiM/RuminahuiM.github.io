---
layout: default
title: 2. Technische Umsetzung
nav_order: 3
has_children: true
---

{: .no_toc }

# Technische Umsetzung

## Initial Setup / Entwicklungsumgebung 

### Hugo Setup
Steps taken for hugo setup:
- download hugo extended version (on windows) - (COMMAND: winget install Hugo.Hugo.Extended)
- Install hugo stack theme
- Install go (installer)
- Install dart sass (Add PATH variable + move folder)
- Create github portfolio site (quickstart template) (https://stack.jimmycai.com/guide/getting-started)
- Setup my hugo site as I want it on my windows pc

#### Template anpassen
- setup parameters, links, picture, titel etc
- Creating new posts: "hugo new post/POSTNAME/index.md" in terminal
- important -> change metadata "draft: true" to false to publish
- Changed Metadata
- Deleted preexisting posts all but syntax -> made into full cheatsheet
- Created Project template post -> can be copied to create new posts
 -> aufbau der struktur gemäss vorgaben für Semesterarbeit (TODO struktur ausführen)
- Found that posting can be delayed by setting future date
- Tested Local view (SCRUM-59) - TODO insert video

## TODO - eigenheiten später entdeckt
- Uglyurls nötig um cloudfront nutzen zu können

#### How to Use
- klurz erklären wie neue Projekte erstellt werden.
-> copy template folder. Edit details (TODO- ausführen)

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
