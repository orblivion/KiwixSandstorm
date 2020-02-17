# Licenses

The license for the codebase to generate the Kiwix Sandstorm app is given in a separate file. However the binary distribution of the app that it generates also includes various bundled dependencies. This file serves to list (with some broad strokes) the licenses of the generated app's contents.

## Installed or downloaded via git, wget or curl

* Kiwix-Tools
  * https://github.com/kiwix/kiwix-tools
  * [GPL 3](https://www.gnu.org/licenses/gpl-3.0.en.html)

* Jquery
  * https://code.jquery.com/jquery-3.2.0.min.js
  * [MIT](https://opensource.org/licenses/MIT)

* jQuery-File-Upload
  * https://github.com/blueimp/jQuery-File-Upload
  * [MIT](https://opensource.org/licenses/MIT)

* Bootstrap CSS
  * https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css
  * [MIT](https://opensource.org/licenses/MIT)

* Bootstrap for Sass
  * https://github.com/twbs/bootstrap-sass
  * [MIT](https://opensource.org/licenses/MIT)

* Sandstorm
  * https://github.com/sandstorm-io/sandstorm/
  * [Apache 2.0](https://www.apache.org/licenses/LICENSE-2.0) ([See here](https://github.com/sandstorm-io/sandstorm/blob/master/LICENSE) for details on licenses of its components.)

## Other

* Kiwix-Sandstorm (This package itself)
  * https://github.com/orblivion/KiwixSandstorm
  * [Modified file](https://github.com/orblivion/KiwixSandstorm/blob/release/zim_uploader/uploader/upload_static/js/main.js) from jQuery File Upload Plugin - [MIT](https://opensource.org/licenses/MIT)
  * [Kiwix Logo](https://github.com/orblivion/KiwixSandstorm/blob/release/zim_uploader/uploader/upload_static/img/kiwix-logo.svg) - GPL 2 or later. (Choosing [GPL 3](https://www.gnu.org/licenses/gpl-3.0.en.html) to be compatible)
    * Source: [https://commons.wikimedia.org/wiki/File:Kiwix_logo.svg](https://commons.wikimedia.org/wiki/File:Kiwix_logo.svg)
  * Otherwise [GPL 3](https://www.gnu.org/licenses/gpl-3.0.en.html)

* A (very small) subset of the "main" repository of the Debian 9 (Stretch) distribution (possibly as built and distributed by QubesOS because of the maintainer's preferred build environment)
  * [See here](https://www.debian.org/legal/licenses/) for information about licensing.

# Maintaining this list

Some notes, perhaps to self, on how to find the list of things to list in this file.

Doublecheck in sources.list of your building system for which repos of Debian's are used. (Hopefully only main)

Grep for `git`, `wget`, `curl`. The results of these should be listable individually; they do not come with dependencies. But you don't need to include build tools, such as `ninja` (You can doublecheck in `sandstorm-files.list`).

Grep for `virtualenv`, `pip`. The results of these should tell you where virtualenvs are. Find them in `sandstorm-files.list`. Look at most of them not in `site-packages`: they're just symlinks to the system Python installation. Then look at what's in site-packages. You should be able to manually do all this within 10 minutes.
