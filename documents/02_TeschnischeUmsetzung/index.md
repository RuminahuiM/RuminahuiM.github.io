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



### Github Actions


## Design

### Architektur Skizze

### Use Cases

## Herausforderungen

- a

## Testingprotocoll & Results
