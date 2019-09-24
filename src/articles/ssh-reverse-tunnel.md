title: SSH Reverse Tunneling
published: 2019-09-24
tag: computing
tag: notes

I want to be able to log into my home machine from my laptop when I'm out and about.
Unfortunately, my home network is behind a firewall and network address translation, and that's the way it should be.
This means that I'll have to connect from my home machine out to an intermediary that listens for requests.
The intermediary then needs to forward those requests back down home-intermediary connection.





## Setting up the Intermediary Server

The idea here is to set up a user whose only capability is to listen for tunnel establishment from the home machine.

```sh
sudo adduser --disabled-password --no-create-home revssh-<home hostname>
sudo mkdir -p /home/revssh-<home hostname>/.ssh
sudo chown -R revssh-<home hostname>:revssh-<home hostname> /home/revssh-<home hostname>
sudo chmod -R go-rwx /home/revssh-<home hostname>/.ssh/
```

Then, add the following lines to the end of the sshd configuration (`/etc/ssh/sshd_config`), substituting where needed.
This will need a sshd restart (e.g. `sudo service sshd restart`).

```
Match User revssh-<home hostname>
  #AllowTcpForwarding yes
  #X11Forwarding no
  #PermitTunnel no
  #GatewayPorts no
  AllowAgentForwarding no
  PermitOpen localhost:<reverse tunnel entry port>
  ForceCommand echo "Sorry, this account can only be used for tunneling."
```





## Setting up the Home Machine

The home machine must now be able to establish an ssh connection to the intermediary server.
In order for the connection to be established automatically (e.g. after an automatic reboot of the home machine), it's best to make sure that `root` is the one that logs in.

If you don't already have one, generate a keypair for `root` as normal.
Then, install the public key in the revssh user's `authorized_keys` file on the intermediary server.
Finally, verify the intermediary's key fingerprint.
To test, switch to the root user and run `ssh revssh-<home hostname>@<intermediary server>`.
You should see `Sorry, this account can only be used for tunneling.`.


Once the tunnel is established, requests to the intermediary will be forwarded to the home machine.
Since the requests will be from an ssh client, the home machine will need an ssh server to handle them.
Therefore, install an ssh server (with apt: `sudo apt install openssh-server`).
Make sure to secure it as you would any other server, restarting if necessary.
Finally, ensure that the server is running (e.g. `service sshd status`).

Before you can connect to the home machine, it will need to be able to authenticate requests.
Add users' public ssh keys from the intermediary server to the `authorized_keys` on the home machine's users.
For my part, I use the same username on all my machines, so I just `ssh <server> 'cat .ssh/id_<algorithm>.pub' >> ~/.ssh/authorized_keys`.





## Interlude: Testing

Now, let's see if it works.
Hop on both your server and your home machine.
Check connections on your both with `netstat -tanp` to get a baseline.
Then, on the home machine, `su root` and `ssh -fN -R <reverse tunnel entry port>:localhost:22 revssh-<home hostname>@<intermediary server>`.

On the home machine, `netstat -tanp` should report an additional ssh connection.
Additionaly, you can confirm that connection is the intended one with `ps -aux | grep ssh | grep -v grep` and match the... pids? Actually it looks like my pids don't match for... reasons?
On the server, `netstat -tanp` should again report a new ssh connection.
Importantly, it should be in state `LISTEN` and the local address should be `127.0.0.1:<reverse tunnel entry port>`.

Now, from the intermediary server, try to ssh through the reverse tunnel entry port.
The command is `ssh <home machine user>@localhost -p <reverse tunnel entry port>`.
You may need to verify the key fingerprint when prompted.
This is the fingerprint of the sshd on the home machine (`<home hostname>:/etc/ssh/ssh_host_<key type>.pub`).


To clean up, `kill <pid>` on the home machine.
You can check `netstat -tanp` to make sure it's dead.





## Setting Up the Laptop

This is the simplest stage; all we need to do is make sure we can connect to the intermediary server from the laptop.
Odds are that the laptop distro already has an ssh client.
All that is required is to give the laptop's public key to the intermediary server, and verify the intermediary's key fingerprint when you try to connect from the laptop.





## Manually Establishing the Connection

On the home machine, connect to the intermediary:

```sh
sudo ssh -fN -R <reverse tunnel entry port>:localhost:22 revssh-<home hostname>@<intermediary server>
```

Obviously the intermediary server must be running.

On the laptop, connect to the intermediary, then connect through the reverse tunnel to the home machine:
```sh
ssh <intermediary server>
ssh <user>@localhost -p <tunneling port>
```

TODO: I'm not sure why I can't get a single command on the laptop to do the whole thing nicely.
The closest I got was `ssh <intermediary server> 'ssh -T <user>@localhost -p <tunneling port>'`, but I don't get a prompt, or auto-complete, or anything.

TODO there's an annoying thing when I exit from my home machine where it clears the screen, which I don't really need. I'll have to look into that.

To close the tunnel:

```sh
ps -aux | grep ssh -fN | grep -v grep
# look for the pid
sudo kill <pid>
```

Or, if you're feeling brave:

```sh
sudo kill `ps -aux | grep 'ssh -fN' | grep -v grep | awk '{print($2)}'`
```

If you have multiple machines (or don't want to remember which port you use), you might want to put a list of which ports are forwarded to which hosts.





## Setting Up Automatic Connections

So that the tunnel re-establishes itself in the event of connection loss, use autossh instead.
On the home machine, install autossh (e.g. `sudo apt install autossh`).

Next, we want to ensure that whenever the network comes up, the reverse tunnel gets established.
Create a file `/etc/network/if-up.d/revssh-tunnel`.
Change the owner/group to `root` and give it execute permissions.
Then, put the following in:

```sh
#!/bin/sh
autossh -fN M <some unused home machine port> -R <reverse tunnel entry port>:localhost:22 revssh-<home hostname>@<intermediary server>
```

To test, restart the home machine, but don't login.
Then try to login from the laptop.





## Links

The main place I got information from was the blog [Oz for us](http://www.oz4.us/2015/10/linux-restricted-tunneling-handling.html).

[This](https://blog.devolutions.net/2017/3/what-is-reverse-ssh-port-forwarding) is a much shorter article, but it recommends setting the `-T` flag when establishing the tunnel.