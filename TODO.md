# To complete before BETA release:

## For the main script:

* Run once to capture files list

* License - do I need to put Kiwix's license, or my package's license? I probably have to match its license anyway.

* Make sure latest version is on Github.

* Create/publish the package

# To complete before out of BETA:

## For the main script:

* Build from `kiwix-serve` source, or use `kiwix-serve` Debian package when it's added
  * Until such point that everything is from source or official Debian packages, this package is not legit.

## For the Uploader

* Validate zim file format.

* Allow for huge files (Wikipedia)
  * Still have a file size limit to prevent DOSing or something. Though, Sandstorm may have system-wide stuff for that.
  * Actually, look into nginx handling file uploads itself.

* Link to [Zim downloads](http://www.kiwix.org/wiki/Content_in_all_languages) on Kiwix's site

* Send user to zim file directly, skip library view
  * We'd need to hide the library link in the main view as well.

* bootstrap css, (or spectre.css? seems smaller/simpler)

# Other TODOs

* Show demo to creators of Kiwix! (Will probably show them BETA)

* When creating the file in the uploader, wait for kiwix to start before directing the user there.
  * As it is, before the file is there, Kiwix is on a loop waiting for it.
  * We could have the Flask upload request handler just stall and then redirect to /kiwix/

* Simplify nginx - just distinguish between `zim\_uploader` and `kiwix` by URL path; no need to check for file existence.
  * On the other hand, we could have the kiwix launcher script start kiwix, wait and confirm that it's running, then write a "kiwix\_ready" file that nginx reads. That way kiwix always ready by the time nginx proxies to it.

* Sign my code

* Add icons (accounting for Kiwix's policy on app resources)
