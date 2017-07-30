This is a work in progress (ALPHA) package of [Kiwix](http://www.kiwix.org) for Sandstorm. Since `kiwix-serve` is currently difficult to build from source, and it is expected to be easier sort of soon, this is going ahead by just downloading binaries from Kiwix's website. This should not be considered to be complete until it builds everything from source, or grabs everything from Debian packages (which may also be a possibilitey at some point). Until then, this is an item in `TODO.md`, and it will not leave BETA, or maybe even ALPHA, until it's fixed.

Relatedly, I acknowledge that the build process is currently not secure. Firstly, it downloads the binary of Kiwix over http, because even if you put "https" it just redirects to an http mirror anyway. (I fear far more sites do this than we like to think). So I don't bother. I do check sha256sum, but it's based on a binary I downloaded myself from a couple different wifi hotspots to have a little assurance that it's the same file. But please, take care until I figure this out.

See `TODO.md` file to get an idea of the current status of this packaging project.

# Hacks

This project took a couple hacks to implement on Sandstorm. Here they are described as best as can be recalled.

## Bleeding edge version of Kiwix

This Sandstorm app currently uses a rather bleeding-edge version of Kiwix. As it turns out, this version of Kiwix is a lot easier to legitimately build from source than previous versions. Hopefully soon, Kiwix will release a new stable version and this app can use that.

## File uploading interface

Firstly, though the Kiwix desktop and mobile programs have built in downloaders, the sever does not. So, a new web-based uploader interface needed to be made. I primarily use flask, bootstrap and jquery-file-uploader.

### Chunking uploads

The usual way to upload large files over HTTP would be to do chunked uploads with the Content-Range header. This app uses jquery-file-uploader to implement the client side of this.

However, as of now Sandstorm doesn't allow the Content-Range header to pass through. So, this package uses a hackaround: the Content-Range header is copied to POST. Look for `contentRange` in main.js and app.py to find it.

### Retry on failure

A retry scheme for upload failures is implemented as part of this package (not part of jquery-file-uploader). If there is an error uploading a chunk, the client will try repeatedly, with a delay. The delay doubles in size for each each failed attempt. If a chunk succeeds, the delay time for the next retry is reset. After a set amount of failures on a single chunk, the client will give up.

This is useful for various hiccups. It seems to even survive a temporary Sandstorm grain shutdown. Spontaneous grain shutdowns and restarts are rare, but common enough that it happens at least once during, say, an upload of Wikipedia. So, in fact, this feature seems to be necessary.

There may be errors (such as running out of space) where we do not wish for the client to retry. In the future, we probably want a way to signal to the client to not bother retrying, and to just let the user try to start over (while still displaying the error message). For the time being, in such cases it will retry the maximum number of times, and (I believe) keep the last error message visible for the user.

## Polling via js for Kiwix to start

If Nginx directs a request to Kiwix before it's started, it will of course fail, and respond with a 502. To prevent this, this package stops the user from visiting Kiwix until it's loaded. How does it figure it out?

Most Sandstorm apps do this by polling in bash on a socket in launcher.sh, thus before the user sees a loaded page. Polling on a socket wasn't so easy to figure out for a standalone executable program like Kiwix (as opposed to, say, a Python/wsgi app), assuming it's even possible. Plus, there's the fact that before the user uploads a file, the user needs to see a page (the upload page) before Kiwix starts. Once the user uploads the file, we need to poll Kiwix, despite that the app has already started. The obvious answer is to poll via javascript, and that's what we do. Look for `kiwixCheck` in main.js to find it.

The other question is, how can the browser route between the uploader and kiwix at the same time, on the same domain? Well, the root path (`/`) on Kiwix is the "library" view where it lists all the files. For Sandstorm, I set up the package to be one zim file per grain, thus we don't need this view. The kiwix file is saved inside the grain as `kiwix.zim`, thus the "home" path is always `/kiwix/`. This is what is polled to see if Kiwix is running, and this is where the user is sent once it's ready. The uploader (along with this javascript), then, is mapped (in nginx.conf) to `/`.

## Symlinked static files

Bootstrap, jquery, and jquery-file-upload are dependencies. I didn't want to include them in the source. Instead, they are loaded as dependencies during the build process, and symlinked into the static directory.

## CPU-heavy progress bar

Earlier versions had a upload progress bar (either Bootstrap or Jquery, not sure which) that made my laptop huff and puff a lot. So for now it just shows progress in the form of text.

# LICENSE

## This app itself

* `zim_uploader/uploader/upload_static/img/kiwix-logo.svg`: GPL 2 or later, from [here](https://commons.wikimedia.org/wiki/File:Kiwix_logo.svg)
* Images found in `.sandstorm/kiwix-icons`: GPL 1.2 or later, originally from [here](https://upload.wikimedia.org/wikipedia/commons/1/14/Kiwix_icon.svg)
* Otherwise [see here](COPYING) for licensing information about this app itself.

## Package distribution

[See here](distribution_licenses.md) for licensing information about the distribution of this package, including bundled dependencies.

## Changelog

(No releases yet)
