#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with chocolatey](#setup)
    * [What chocolatey server affects](#what-chocolatey-server-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with chocolatey server](#beginning-with-chocolatey-server)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

Sets up a Simple Server for Chocolatey packages. Allows you to [host your own packages](https://github.com/chocolatey/choco/wiki/How-To-Host-Feed), many times as a private package feed.

## Module Description

There are three types of package feeds for Chocolatey - folder/unc share, simple server, and the sophisticated package gallery. Simple server is in the middle and most widely used NuGet Package Server format.

**Advantages:**
* Push over HTTP/HTTPS.
* API key for pushing packages.
* No direct access to packages - acls are locked down to just admins and push through api key.
* Package store is file system.

**Disadvantages:**
* Only one API key, so no multi user scenarios.
* Starts to affect choco performance once the source has over 500 packages (maybe?).
* No moderation.
* No website to view packages.
* No package statistics.

For more details about the other types of package feeds, see [host your own feed](https://github.com/chocolatey/choco/wiki/How-To-Host-Feed).

## Setup

### What chocolatey server affects

* Will create files at c:\tools\chocolatey.server.
* Will install IIS and ASP.NET if not already installed.
* Will remove the default website.
* Sets up a website on port 80 (configurable) pointing to chocolatey.server

### Setup Requirements

Chocolatey installed

### Beginning with Chocolatey Server

Move along, nothing to say here at the moment.

## Usage

    include chocolatey_server

## Limitations

Works with Windows only.

## Development

We like Pull Requests!
