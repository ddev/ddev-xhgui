[![tests](https://github.com/ddev/ddev-addon-template/actions/workflows/tests.yml/badge.svg)](https://github.com/ddev/ddev-addon-template/actions/workflows/tests.yml) ![project is maintained](https://img.shields.io/maintenance/yes/2026.svg)

# ddev-xhgui <!-- omit in toc -->

- [Introduction](#introduction)
- [Warning](#warning)
- [Getting started](#getting-started)
- [Usage](#usage)
- [Configuration](#configuration)

## Introduction

This addon adds the XHGui service to a project served by DDEV.

[XhGui](https://github.com/perftools/xhgui) is a graphical interface for XHProf profiling data that stores its results the database.

See <https://performance.wikimedia.org/xhgui/> for an demonstration of XHGui data collection.

## Warning

This addon is for debugging in a development environment.
Profiling in a production environment is not recommended.

## Getting started

- Install the `ddev-xhgui` add-on and restart your project

```shell
  ddev add-on get ddev/ddev-xhgui && ddev restart
```

## Usage

When you want to start profiling, `ddev xhprof on`.

The web profiling UI is at `https://yourproject.ddev.site:8143` or use `ddev xhgui` to launch it.

For detailed information about a single request, click on the "Method" keyword on the "Recent runs" dashboard.

![Click GET method](./images/xhgui-get.png)

To check the xhgui service's logs:

   ```shell
   ddev logs -s xhgui
   ```

## Configuration

To configure Xhgui, add `.ddev/xhgui/xhgui.config.php`.

For example, to set xhgui to use `Asia/Toyko` timezone for dates:

- Remove `#ddev-generated` from `.ddev/xhgui/xhgui.config.php`
- Change the timezone value

  ```php
    'timezone' => 'Asia/Tokyo',
    'date.format' => 'Y-m-d H:i:s',
  ```

**Contributed and maintained by [@tyler36](https://github.com/tyler36) based on the original [ddev-contrib PR](https://github.com/ddev/ddev-contrib/pull/128) by [@penyaskito](https://github.com/penyaskito)**
