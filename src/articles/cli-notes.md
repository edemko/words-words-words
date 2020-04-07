title: CLI Cheatsheet
published: 2020-04-07
tag: computing
tag: reference
tag: notes

## Apt/Dpkg

List files installed by a package:

```
:::sh
dpkg -L some-package
```

Find uot which package installed a given file:

```
:::sh
dpkg -S /some/file
```

Find out what (installed) packages depend on a given package:

```
:::sh
apt-cache rdepends  --installed some-package
```


## Devices

Find out what device a file or folder is on:

```
:::sh
df /path/to/filename
```


## Run commands when files change

[entr](http://eradman.com/entrproject/) is said to have good ergonomics.

[This stack overflow answer](https://superuser.com/a/181543) says to use `inotifywait`, but mentions some problems, and it's not installed on my main machine by default.
It also mentions `fswatch` and `incron`, but again these are not everywhere.
