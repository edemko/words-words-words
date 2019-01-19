title: CLI Notes
tag: computing
tag: notes

# List files installed by a package:
dpkg -L some-package
# Find out what (installed) packages depend on a given package:
apt-cache rdepends  --installed some-package

# Find out what device a file or folder is on:
df /path/to/filename

# Run commands when files change
[entr](http://eradman.com/entrproject/) is said to have good ergonomics.

[This stack overflow answer](https://superuser.com/a/181543) says to use `inotifywait`, but mentions some problems, and it's not installed on my main machine by default.
It also mentions `fswatch` and `incron`, but again these are not everywhere.
