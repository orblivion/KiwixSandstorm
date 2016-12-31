**Warning** This is currently just an alpha, as a proof of concept. Don't use this for production.

This is a means of hosting dumps of wiki databases in the zim format. It could be a useful way to take your zim files and display them for the outside world. It could also be a way to take a dump of Wikipedia, or another prominent wiki, and make a mirror of it. This could be particularly useful if your Sandstorm instance is taken in an alternate network scenario, such as a mesh network, or just away from Internet access.

There are two main things that need to be fixed before it can be considered out of alpha:

1) It's built using kiwix's binaries straight from their site, rather than building it from source, or an official Kiwix Debian package (which hopefully will exist again eventually).
2) It can only handle about 10MB zim files or smaller.
