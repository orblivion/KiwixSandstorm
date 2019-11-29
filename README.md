This is a packaging of [Kiwix](http://www.kiwix.org) (in particular, `kiwix-serve`), for [Sandstorm.io](https://sandstorm.io).

See `TODO.md` file to get an idea of the current status of this packaging project, though it may lag behind actual progress.

# Building

## Requirements and Recommendations

Requires Debian Stretch. Newer versions won't work as-is. The packaging process references specific versions of library files.

Recommended to do this in a dedicated environment such as a VM to avoid cross-contamination with your personal environment. This will install things with apt, and will package various files located in the system it's built in (read about `sandstorm-files.list` [here](https://docs.sandstorm.io/en/latest/developing/raw-packaging-guide/)).

## Instructions

This gets debian packages, so you may want to do `apt update`. Within the `packages/` directory, simply run this script (which will use sudo privileges and possibly ask for password) to install necessary things from the debian repo and download a few things:

    ./build.sh

Then from the same directory, run:

    spk dev

And then follow the [raw packaging guide](https://docs.sandstorm.io/en/latest/developing/raw-packaging-guide/) from there.

# Changelog

## 0.1.0

* appVersion: 15
* Date: 2019-12-29
* Git tag: `app-version-15`
* Switch from building with `vagrant-spk` to `spk`
* Upgrade uploader to python3
* Upgrade Kiwix-Serve to 3.0.1
* Download kiwix-tools binaries from kiwix.org instead of building from source
  * Based on some conversations I determined that building everything from source wasn't important enough for the effort. Perhaps again in the future.

## 0.0.4

* appVersion: 13
* Date: 2017-08-05
* Git tag: `app-version-13`

Change Marketplace description and first couple screens of onboarding. Replace a marketplace screenshot.

## 0.0.3

* appVersion: 12
* Date: 2017-07-31
* Git tag: `app-version-12`

Initial release! It's still a bit rough; see `known_limitations.md`.

# LICENSE

## This app itself

* `zim_uploader/uploader/upload_static/img/kiwix-logo.svg`: GPL 2 or later, from [here](https://commons.wikimedia.org/wiki/File:Kiwix_logo.svg)
* Images found in `package/kiwix-icons`: GPL 1.2 or later, originally from [here](https://upload.wikimedia.org/wikipedia/commons/1/14/Kiwix_icon.svg)
* Otherwise [see here](COPYING) for licensing information about this app itself.

## Package distribution

[See here](distribution_licenses.md) for licensing information about the distribution of this package, including bundled dependencies.

# Hacks

This project took a couple hacks to implement on Sandstorm. Here they are described as best as can be recalled.

## File uploading interface

Though the Kiwix desktop and mobile programs have built-in downloaders, the sever does not. So, a new web-based uploader interface needed to be made. I primarily use flask, bootstrap and jquery-file-uploader.

### Chunking uploads

The usual way to upload large files over HTTP would be to do chunked uploads with the Content-Range header. This app uses jquery-file-uploader to implement the client side of this.

However, as of now Sandstorm doesn't allow the Content-Range header to pass through. So, this package uses a hackaround: the Content-Range header is copied to POST. Look for `contentRange` in main.js and app.py to find it.

### Retry on failure

A retry scheme for upload failures is implemented as part of this package (not part of jquery-file-uploader). If there is an error uploading a chunk, the client will try repeatedly (except for certain failures, such as running out of space), with a delay. The delay doubles in size for each each failed attempt. If a chunk succeeds, the delay time for the next retry is reset. After a set amount of failures on a single chunk, the client will give up.

This is useful for various hiccups. It seems to even survive a temporary Sandstorm grain shutdown. Spontaneous grain shutdowns and restarts are rare, but common enough that it happens at least once during, say, an upload of Wikipedia. So, in fact, this feature seems to be necessary.

## Polling via js for Kiwix to start

If Nginx directs a request to Kiwix before it's started, it will of course fail, and respond with a 502. To prevent this, this package stops the user from visiting Kiwix until it's loaded. How does it figure it out?

Most Sandstorm apps do this by polling in bash on a socket in launcher.sh, thus before the user sees a loaded page. Polling on a socket wasn't so easy to figure out for a standalone executable program like Kiwix (as opposed to, say, a Python/wsgi app), assuming it's even possible. Plus, there's the fact that before the user uploads a file, the user needs to see a page (the upload page) before Kiwix starts. Once the user uploads the file, we need to poll Kiwix, despite that the app has already started. The obvious answer is to poll via javascript, and that's what we do. Look for `kiwixCheck` in main.js to find it.

The other question is, how can the browser route between the uploader and kiwix at the same time, on the same domain? Well, the root path (`/`) on Kiwix is the "library" view where it lists all the files. For Sandstorm, I set up the package to be one zim file per grain, thus we don't need this view. The kiwix file is saved inside the grain as `kiwix.zim`, thus the "home" path is always `/kiwix/`. This is what is polled to see if Kiwix is running, and this is where the user is sent once it's ready. The uploader (along with this javascript), then, is mapped (in nginx.conf) to `/`.

## Symlinked static files

Bootstrap, jquery, and jquery-file-upload are dependencies. I didn't want to include them in the source. Instead, they are loaded as dependencies during the build process, and symlinked into the static directory.

## Removing CPU-heavy progress bar

Earlier versions had a upload progress bar (either Bootstrap or Jquery, not sure which) that made my laptop huff and puff a lot. So for now it just shows progress in the form of text.
