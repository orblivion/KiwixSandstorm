* Build from scratch again for a clean slate.
* If you upgraded Kiwix:
  * Try viewing the basic file formats. Try searching around in them.
* If you worked on uploader interface in any way:
  * Turn on random failure for a while on uploading Wikipedia to your home server. Make sure all failures are tried.
* Regardless of whether you changed the content file links, re-check the file sizes. And maybe re-try the links too.
  * For file sizes, look in "all content in all languages" list page, not kiwix.org/downloads. The latter seems to lag.
* Check/update `distribution_licenses.md` if you've pulled in new dependencies, and/or `sandstorm-files.list` has changed at all.
* `spk verify mypackage.spk` to confirm the details of metadata
  * (Reference: https://docs.sandstorm.io/en/latest/developing/publishing-apps/)
* `vagrant-spk publish mypackage.spk` to publish
  * (Reference: https://docs.sandstorm.io/en/latest/developing/publishing-apps/)
* After app is accepted:
  * Changelog (date, release number, git hash it was built from)
  * Point "release" branch on github to the hash it was built from, so that relevant links point to it
