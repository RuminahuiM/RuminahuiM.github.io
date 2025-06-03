---
layout: default
title: 2.1 Task 
parent: 2. Task
nav_order: 1
---

# Task

## Project Title

DB Collectors automation

## Starting Situation

Within our team in UBS, we are in charge of several databases. These databases are monitored through AppDynamics, a full-stack application performance monitoring and analytics platform that helps organizations track, optimize, and troubleshoot application and infrastructure performance in real time.

Setting up one of these databases is currently a repetitive manual process that needs to be done for every single collector we want to create within the monitoring tool.

## Project purpose

This project will be centered around the automation of the process of database collector creation. This will be achieved through ansible playbooks. The goal is that the playbook should be able to fully setup the collector with a few pieces of information added as extra vars in the deployment, such as database name and identifier, which are needed for the jbdc string AppDynamics uses to communicate with the database.

This will decrease the manual labor involved in improving our visibility for our oracle databases, pushing us to easily onboard all of them and offer the end user a better experience by noticing issues before they happen, or allow us to react faster to them.

## Goals

The goal of this project is as follows:

- Reduce the time spent manually creating collectors.

- Reduce the likelihood of errors.

- Create a better experience for the end user by providing a better overview of our databases
 
- The Ansible playbook should be able to distinguish and set up the collector in exactly the same way, regardless of the runtime/environment in which it is running.