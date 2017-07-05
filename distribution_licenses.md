# Licenses

The license for the codebase to generate the Kiwix Sandstorm app is given in a separate file. However the binary distribution of the app that it generates also includes various bundled dependencies. This file serves to list (with some broad strokes) the licenses of the generated app's contents.

## Installed via git, wget, or curl

* Kiwix-Lib
  * https://github.com/kiwix/kiwix-lib
  * [GPL 3](https://www.gnu.org/licenses/gpl-3.0.en.html)

* Kiwix-Tools
  * https://github.com/kiwix/kiwix-tools
  * [GPL 3](https://www.gnu.org/licenses/gpl-3.0.en.html)

* Jquery
  * https://code.jquery.com/jquery-3.2.0.min.js
  * [MIT](https://opensource.org/licenses/MIT)

* jQuery-File-Upload
  * https://github.com/blueimp/jQuery-File-Upload
  * [MIT](https://opensource.org/licenses/MIT)

* JavaScrpt-Templates
  * https://github.com/blueimp/JavaScript-Templates
  * [MIT](https://opensource.org/licenses/MIT)

* Bootstrap CSS
  * https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css
  * [MIT](https://opensource.org/licenses/MIT)

* Bootstrap for Sass
  * https://github.com/twbs/bootstrap-sass
  * [MIT](https://opensource.org/licenses/MIT)

* LibZim
  * https://github.com/openzim/libzim/
  * [GPL 2](https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html)
  * TODO - As of now, incompatible with Kiwix. They are currently sorting this out.

* PugiXML
  * https://github.com/zeux/pugixml
  * [MIT](https://opensource.org/licenses/MIT)

* Xapian Core
  * https://git.xapian.org/xapian
  * GPL 2 or later. (Choosing [GPL 3](https://www.gnu.org/licenses/gpl-3.0.en.html) to be compatible)

* Sandstorm
  * https://github.com/sandstorm-io/sandstorm/
  * [See here](https://github.com/sandstorm-io/sandstorm/blob/master/LICENSE) for information about licensing.

## Installed via Virtualenv

Found in `zim_uploader/env`:

* Virtualenv 1.11.6 (site.py)
  * [MIT](https://opensource.org/licenses/MIT)
* Flask==0.10
  * [BSD 3-Clause](https://opensource.org/licenses/BSD-3-Clause)
* itsdangerous==0.24
  * [BSD 3-Clause](https://opensource.org/licenses/BSD-3-Clause)
* Jinja2==2.9.6
  * [BSD 3-Clause](https://opensource.org/licenses/BSD-3-Clause)
* MarkupSafe==1.0
  * [BSD 3-Clause](https://opensource.org/licenses/BSD-3-Clause)
* Werkzeug==0.12.1
  * [BSD 3-Clause](https://opensource.org/licenses/BSD-3-Clause)

## Other

* Kiwix-Sandstorm (This package itself)
  * https://github.com/orblivion/KiwixSandstorm
  * [Modified file](https://github.com/orblivion/KiwixSandstorm/blob/release/zim_uploader/uploader/upload_static/js/main.js) from jQuery File Upload Plugin - [MIT](https://opensource.org/licenses/MIT)
  * [Kiwix Logo](https://github.com/orblivion/KiwixSandstorm/blob/release/zim_uploader/uploader/upload_static/img/kiwix-logo.svg) - GPL 2 or later. (Choosing [GPL 3](https://www.gnu.org/licenses/gpl-3.0.en.html) to be compatible)
    * Source: [https://commons.wikimedia.org/wiki/File:Kiwix_logo.svg](https://commons.wikimedia.org/wiki/File:Kiwix_logo.svg)
  * Otherwise [GPL 3](https://www.gnu.org/licenses/gpl-3.0.en.html)

* A (very small) subset of the "main" repository of the Debian 8 (Jessie) distribution.
  * [See here](https://www.debian.org/legal/licenses/) for information about licensing.

# Maintaining this list

Some notes, perhaps to self, on how to find the list of things to list in this file.

Go into `vagrant vm ssh`. Doublecheck in sources.list which repos of Debian's are used. (Hopefully only main)

Grep for `git`, `wget`, `curl`. The results of these should be listable individually; they do not come with dependencies. But you don't need to include build tools, such as `ninja` (You can doublecheck in `sandstorm-files.list`).

Grep for `virtualenv`, `pip`. The results of these should tell you where virtualenvs are. Find them in `sandstorm-files.list`. Look at most of them not in `site-packages`: they're just symlinks to the system Python installation. Then look at what's in site-packages. You should be able to manually do all this within 10 minutes.
