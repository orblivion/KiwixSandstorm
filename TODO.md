# To complete before ALPHA release:

## For the main script:

* Publish the package, albeit with an ALPHA warning
  * https://docs.sandstorm.io/en/latest/developing/publishing-apps/

# To complete before out of ALPHA:

## For the Uploader

* Validate zim file format.

* Allow for huge files (Wikipedia)
  * Still have a file size limit to prevent DOSing or something. Though, Sandstorm may have system-wide stuff for that.
  * Actually, look into nginx handling file uploads itself.

* Link to [Zim downloads](http://www.kiwix.org/wiki/Content_in_all_languages) on Kiwix's site

* Send user to zim file directly, skip library view
  * We'd need to hide the library link in the main view as well.

* bootstrap css, (or spectre.css? seems smaller/simpler)

* Alternately, scrap my hacky uploader and just connect to a FileDrop grain when that's possible.

# Other TODOs

* Eventually just use the kiwix-tools Debian package once it's available

* Show demo to creators of Kiwix! (Will probably show them ALPHA)

* When creating the file in the uploader, wait for kiwix to start before directing the user there.
  * As it is, before the file is there, Kiwix is on a loop waiting for it.
  * We could have the Flask upload request handler just stall and then redirect to /kiwix/

* Simplify nginx - just distinguish between `zim\_uploader` and `kiwix` by URL path; no need to check for file existence.
  * On the other hand, we could have the kiwix launcher script start kiwix, wait and confirm that it's running, then write a "kiwix\_ready" file that nginx reads. That way kiwix always ready by the time nginx proxies to it.

* Sign my code

* Fill in more details in package definition (PGP sig, etc)

* read-only permissions for sharing

* Confirm about aria2c - It's not used during build, right? Only running (for fetching Zim files in the library manager)?
  * I think it's only for the Desktop, though, since the web interface doesn't have a library manager (that's why this Sandstorm app adds its own uploader).

* flask-file-uploader/jquery-file-uploader
  * Enable max chunk size, and read Content-Range header
  * Requires Sandstorm to add Content-Range header
