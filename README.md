[![tests](https://github.com/ddev/ddev-addon-template/actions/workflows/tests.yml/badge.svg)](https://github.com/ddev/ddev-addon-template/actions/workflows/tests.yml) ![project is maintained](https://img.shields.io/maintenance/yes/2024.svg)

# ddev-xhgui <!-- omit in toc -->

- [Introduction](#introduction)
- [Warning](#warning)
- [Getting started](#getting-started)
- [Framework configuration](#framework-configuration)
   - [Drupal 8+](#drupal-8)
   - [WordPress](#wordpress)
   - [Silverstripe](#silverstripe)
- [Usage](#usage)

## Introduction

This addon is designed to add the XHGui service to a project served by DDEV.

[XhGui](https://github.com/perftools/xhgui) is a graphical interface for XHProf profiling data that can store the results in MongoDB or PDO database.

## Warning

This addon is intended for debugging in a development environment.
Profiling in a production environment is not recommend.

## Getting started

- Install the `ddev-xhgui` add-on:

  ```shell
  ddev get tyler36/ddev-xhgui
  ddev restart
  ```

- Install a profiler. If your application uses composer, you can install it with

   ```shell
   ddev composer require perftools/php-profiler --dev
   ```

## Framework configuration

### Drupal 8+

The `xhgui/examples` contains files which can be used to quick-start a Drupal installation.

- Copy the files from `xhgui/examples` to the sites's `web/sites/default` folder.

- Add the following line to `web/sites/default/settings.local.php` to include the collector.

   ```php
   require_once __DIR__ . '/xhgui.collector.php';
   ```

- Comment out the above line to disable profiling.

### WordPress

Download latest version of `perftools/php-profiler` (this has been validated with the current latest release, 0.18.0).
If you use [bedrock](https://roots.io/bedrock/), just use the composer command from the previous section.

If you use vanilla WordPress:

   ```shell
   wget https://github.com/perftools/php-profiler/archive/refs/tags/0.18.0.tar.gz
   tar -xvf 0.18.0.tar.gz
   ```

- Copy the two files in the `.ddev/xhgui/examples` folder (not the `php-profiler` you just downloaded) to your WordPress folder, and append to your `wp-config-ddev.php`:

   ```php
   require_once __DIR__ . '/php-profiler-0.18.0/autoload.php';
   require_once __DIR__ . '/xhgui.collector.php';
   ```

- Comment out the above line to disable profiling.

If you want to stop profiling, you can just comment/remove those lines.

Take into account that with the default configuration, every time you `ddev start`, DDEV will recreate this file. You can remove the `#ddev-generated` at the top of the file if you want to avoid that.

### Silverstripe

Add/install `perftools/php-profiler`, as per [getting started](#getting-started)

- Copy the files from `.ddev/xhgui/examples` folder to your `public` folder (`cp .ddev/xhgui/examples/*.php public/`)
- Add the requirement to your `public/index.php`, right after the autoload includes:

  ```php
  if (file_exists(__DIR__ . '/../vendor/autoload.php')) {
    require __DIR__ . '/../vendor/autoload.php';
  } elseif (file_exists(__DIR__ . '/vendor/autoload.php')) {
      require __DIR__ . '/vendor/autoload.php';
  } else {
      header('HTTP/1.1 500 Internal Server Error');
      echo "autoload.php not found";
      exit(1);
  }
  if (file_exists(__DIR__ . '/xhgui.collector.php')) {
    require_once __DIR__ . '/xhgui.collector.php';
  }
  ```

- Run `ddev xhprof` to start profiling
- XHGui is now available at <https://>`yourproject.ddev.site`:8142

## Usage

The service will automatically start when run: `ddev start` or `ddev restart`.

By default, xhgui will be available at <https://>`<your site>`:8143.

Remember, if you updated `settings.ddev.php` or `wp-config-ddev.php`, these file will be overwritten unless you remove the `#ddev-generated`.

Use the following command to check the logs:

   ```shell
   ddev logs -s xhgui
   ```

**Contributed and maintained by [@tyler36](https://github.com/tyler36) based on the original [ddev-contrib PR](https://github.com/ddev/ddev-contrib/pull/128) by [@penyaskito](https://github.com/penyaskito)**
