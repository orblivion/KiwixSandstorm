* If you upgraded Kiwix, do a quick feature check:
  * Viewing the basic file formats
    * Wiki
    * Stack Exchange
    * Gutenberg
    * Ted
    * Phet
  * "Random Page" on various formats
  * Seeking within videos
  * Search
    * By document titles, including autocomplete
    * By document content
    * By tag (Stack Exchange) including autocomplete
    * By author (Project Gutenberg) including autocomplete
  * Downloading books in PDF and epub formats
* If you worked on uploader interface in any way:
  * Make sure upload success works.
  * Make sure upload manual cancel/try again works.
  * Turn on random failure for a while on uploading a large file. Make sure all failures are tried.
  * Turn on force failure. Make sure it stops without retrying with 409 (just put 409 in the force_failure file)
* Regardless of whether you changed the content file links, re-check the file sizes. And maybe re-try the links too.
  * For file sizes, look in "all content in all languages" list page, not kiwix.org/downloads. The latter seems to lag.
* Check/update `distribution_licenses.md` if you've pulled in new dependencies, and/or `sandstorm-files.list` has changed at all.
* Bump appVersion and appMarketingVersion
* Build from scratch again for a clean slate.
* `spk pack mypackage.spk` to build
* `spk verify mypackage.spk` to confirm the details of metadata
  * (Reference: https://docs.sandstorm.io/en/latest/developing/publishing-apps/)
* Make sure existing grains still work after an update.
* `spk publish mypackage.spk` to publish
  * (Reference: https://docs.sandstorm.io/en/latest/developing/publishing-apps/)
* After app is accepted:
  * Make git tag
  * Changelog (date, release number, git tag it was built from, release details)
  * Point "release" branch on github to the tag it was built from, so that relevant links point to it
