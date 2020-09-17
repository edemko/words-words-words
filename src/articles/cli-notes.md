title: CLI Cheatsheet
published: 2020-04-07
updated: 2020-09-16
tag: computing
tag: reference
tag: notes

## Quick Fixes

After a shell finds an executable, it caches its location... except it doesn't check its own validity.
So when you mess with executable locations or the `PATH` clear that cache with

```sh
hash -r # entire cache
hash -d <exe name> # one entry
```

## System Info

```sh
uname -a # generic info about the machine
lsb_release -a # what version of my distro am I running?
```

## Apt/Dpkg

List files installed by a package:

```sh
dpkg -L some-package
```

Find out which package installed a given file:

```sh
dpkg -S /some/file
```

Find out what (installed) packages depend on a given package:

```sh
apt-cache rdepends  --installed some-package
```

Install from `.deb`:

```sh
sudo dpkg -i <deb-file>
sudo apt-get install -f
```

or

```sh
sudo apt install <deb-file>
```


## Devices

Find out what device a file or folder is on:

```sh
df /path/to/filename
```

Find out how much storage space is left on drives:

```sh
df -H
```

## Run commands when files change

[entr](http://eradman.com/entrproject/) is said to have good ergonomics.

[This stack overflow answer](https://superuser.com/a/181543) says to use `inotifywait`, but mentions some problems, and it's not installed on my main machine by default.
It also mentions `fswatch` and `incron`, but again these are not everywhere.

## Using `mini-httpd` in scripts

First off, on some systems it's `mini-httpd`, and some its `mini_httpd`.
In any case, if you run it from a script (from a script from a script from a…), then you need a way to shut it down nicely.
Otherwise, you need to find it with

```sh
ps -ef | grep mini[_-]httpd | awk '{print $2}' | xargs kill
ps -ef | grep [d]efunct | awk '{print $3}' | xargs kill
```

repeating the second until there are no more defunct processes.

However, you could do the following when starting httpd:

```sh
_term() {
  echo "Caught SIGTERM signal!"
  kill "$child" 2>/dev/null
  exit 0
}
trap _term TERM INT HUP QUIT EXIT KILL

port=10080
echo >&3 "Starting server on port $port..."
echo >&3 "(Ctrl-C to exit)"
"$HTTPD" -D -u "$USER" -p "$port" -d <DIR> &
child=$!
wait "$child"
```

I'm not entirely sure which signals I really have to wait on, but this seems to work.
It may even be useful in more general cases.

This was taken from [this stack overflow answer](https://unix.stackexchange.com/a/146770).
There are more comments and tweaks mentioned there, but it's worked well enough so far.
