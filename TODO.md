* Bugs when running Kiwix
  * Random button, and sometimes Search button, doesn't work in sandstorm Kiwix, but not normal Kiwix
  * Stack Overflow tag buttons in answers don't work in sandstorm Kiwix. Figure out if this works in normal Kiwix.
  * Gutenberg pdf links are broken
  * Full text search isn't working for Sandstorm Wikipedia
    * Works for Wikivoyage
    * Maybe works in non-Sandstorm Kiwix?
  * Full text search isn't working for Sandstorm Stackoverflow

* Messaging / UI

    * Get HN feedback.

    * In the latest verison, is it now clear where I'm downloading from and to, and where I'm uploading to?
      * Some user feedback in an earlier version showed that there was some confusion here.
      * If singular icons for each step don't work, maybe have two icons per step
        * (Download step = from cloud to computer. Upload step = from computer to new cloud, etc)

    * Is the way I introduce this to the user still too technical?

    * My target demographics:
      * Easiest one:
         * Sandstorm users, in non-connected environments, who also want Kiwix.

      * Harder ones (may require landing pages and outreach):
        * Sandstorm users, in non-connected environments. "Hey this is cool, I'll add it".
          * Just alert them that it exists; it's an easy try if they really care.
        * Sandstorm-curious users, to convince them that the whole thing is cool
          * Not a great demo. This doesn't describe a particular need for hosting a wiki. They'd just do it because it's cool.
        * People looking to start up disconnected mesh things/low-network-connectivity schools, to convince them Sandstorm is worthwhile
          * Here's where presentations come in
        * People looking to install Kiwix, to convince them the Sandstorm way is a little easier, but also has more benefits (has other apps)
          * Get cross-reference from Kiwix.org

    * Should I actually just have a content browser as my first page, since the school already knows what they're getting?
      * Implying that my messaging is too much if they understand it already.
      * Will the extra messaging hurt, though? So long as it's concise.
      * "Click on a piece of content below to get started"

    * Messaging
      * Think about my use cases.
      * Description for Marketplace needs to be on point.
      * sell the idea of 1) having a local version of wikipedia
      * 2) serving it to a community

* Figure out: Should I match Kiwix version to my app version?
  * But then, what if I make multiple Sandstorm app release within a single Kiwix minor release? Sort this out.

* FileDrop/Davros integration (and maybe not have an uploader on this app at all)

* Make I/O more efficient.
  * Look at iotop of server. It seems to spike periodically between uploaded chunks.
  * Then again pgpgout in /proc/vmstat seems to correspond close to 1:1 with the size of the file.
    * But is that disk write? Or is it "swap" only?
    * Anyway, uploading a file in FileDrop also gives 1:1 with vmstat pgpgout
  * Try to find another way of inspecting it. Assuming we care enough before outsourcing uploads to another app altogether.

* When retrying an upload chunk, allow for the file being a little larger than expected.
  * If the upload succeeded, but the response failed, the next request will try to overwrite the part it just wrote.
  * That should be allowed.

* If you open a grain with an in-progress upload in a new tab
  * "Upload appears to be in progress in another window. Cancel it?"

* Doublecheck my claim (shown to users) that two uploads in two different grains at once actually does slow down total upload speed. Maybe it doesn't.
  * Then again, if it does so in the VM, maybe it'll do things in a slow server?
  * Then again again, maybe people with slow servers caveat emptor already. My test server isn't especially fast, so it's probably a good benchmark.

* Kiwix UI concerns
  * Is it going to be a pain to try to use in a tabbed fashion? "Open in new tab" will lose the Sandstorm frame, for instance.
  * Kiwix UI Hacks
    * Hide the Random button? (while it's broken)
    * Hide the Library button? (since in this app it loops back to the same place as the Home button anyway)

* Build improvements
  * Use make files instead of these bash scripts that search for the existence of targets
  * Put everything in "dependencies" directory so it's easier to blow away and start over

* If/when I add a feature to have the server download/torrent straight from Kiwix, Kelson (from Kiwix) suggested that we should use metalink with the aria2c client

* Eventually just use the kiwix-tools Debian package once it's available

* Once [this PR](https://github.com/sandstorm-io/sandstorm/pull/2887) is merged, switch to using Content Range headers instead of POST.

* Validate zim file format?

* Indexed files
  * Find out when all the zim files are indexed for content search, then remove the "Get a non-indexed Zim file" instruction
    * (The only reason we suggest non-indexed is that the indexed version are often split into multiple files, and packaged. We want to keep it simple for the user.)
  * See about indexing it ourselves as a post-upload thing?
  * [Probably not bother, given the above] Support pre-indexed versions that split data into multiple zim files

* Blogging platforms on Sandstorm have a "public view". Can we do that here?

* Multi-language download chooser
  * Maybe try out using kiwix.org's big content file index xml file (Ask Kelson [from Kiwix] about it, I forgot what it was) to omit files that aren't available in a given language.

* Link/URL things
  * Better URLs for sharing links from grain with others
  * Internal links opened in new tabs lose the sandstorm chrome. It's a little weird.
  * External links - make all external links open in new tab
