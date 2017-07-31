* Build from scratch again for a clean slate.
* If you upgraded Kiwix:
  * Try viewing the basic file formats. Try searching around in them.
* If you worked on uploader interface in any way:
  * Make sure upload success works.
  * Make sure upload manual cancel/try again works.
  * Turn on random failure for a while on uploading a very large file. Make sure all failures are tried.
* Regardless of whether you changed the content file links, re-check the file sizes. And maybe re-try the links too.
  * For file sizes, look in "all content in all languages" list page, not kiwix.org/downloads. The latter seems to lag.
* Check/update `distribution_licenses.md` if you've pulled in new dependencies, and/or `sandstorm-files.list` has changed at all.
* Bump appVersion and appMarketingVersion
* `spk pack mypackage.spk` to build
* `spk verify mypackage.spk` to confirm the details of metadata
  * (Reference: https://docs.sandstorm.io/en/latest/developing/publishing-apps/)
* `vagrant-spk publish mypackage.spk` to publish
  * (Reference: https://docs.sandstorm.io/en/latest/developing/publishing-apps/)
* After app is accepted:
  * Make git tag
  * Changelog (date, release number, git hash/tag it was built from, release details)
  * Point "release" branch on github to the hash it was built from, so that relevant links point to it
