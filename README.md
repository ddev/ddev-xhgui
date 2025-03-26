[![tests](https://github.com/ddev/ddev-xhgui/actions/workflows/tests.yml/badge.svg?branch=main)](https://github.com/ddev/ddev-xhgui/actions/workflows/tests.yml?query=branch%3Amain)
[![project is obsolete](https://img.shields.io/badge/maintenance-obsolete-red.svg)](https://github.com/ddev/ddev-xhgui/commits)
[![release](https://img.shields.io/github/v/release/ddev/ddev-xhgui)](https://github.com/ddev/ddev-xhgui/releases/latest)

# DDEV XHGui (obsolete)

This add-on is a part of DDEV since [v1.24.4](https://github.com/ddev/ddev/releases/tag/v1.24.4).

## Overview

[XHGui](https://github.com/perftools/xhgui) is a graphical interface for XHProf profiling data that stores its results the database.

This add-on integrates XHGui into your [DDEV](https://ddev.com/) project.

See <https://performance.wikimedia.org/xhgui/> for an demonstration of XHGui data collection.

## Warning

This addon is for debugging in a development environment.
Profiling in a production environment is not recommended.

## Installation

```sh
ddev add-on get ddev/ddev-xhgui
ddev restart
```

After installation, make sure to commit the `.ddev` directory to version control.

## Usage

When you want to start profiling, `ddev xhprof on`.

The web profiling UI is at `https://yourproject.ddev.site:8143` or use `ddev xhgui` to launch it.

For detailed information about a single request, click on the "Method" keyword on the "Recent runs" dashboard.

![Click GET method](./images/xhgui-get.png)

To check the xhgui service's logs:

```sh
ddev logs -s xhgui
```

## Advanced Customization

To configure XHGui, add `.ddev/xhgui/xhgui.config.php`.

For example, to set xhgui to use `Asia/Toyko` timezone for dates:

- Remove `#ddev-generated` from `.ddev/xhgui/xhgui.config.php`
- Change the timezone value

  ```php
  'timezone' => 'Asia/Tokyo',
  'date.format' => 'Y-m-d H:i:s',
  ```

## Credits

**Contributed and maintained by [@tyler36](https://github.com/tyler36) based on the original [ddev-contrib PR](https://github.com/ddev/ddev-contrib/pull/128) by [@penyaskito](https://github.com/penyaskito)**
