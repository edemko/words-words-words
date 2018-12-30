title: Crypto Cookbook

Cryptography is a technology fundamentally important to the information age.
It's also one of those "magic" technologies.
But technology is never magic, and it's a shame not to understand it.

In my case, I manage cryptographic keys on occasion, so it's negligent of me to not understand what's going on under the hood.
On the one hand, I learned the basics of the theory in school, but on the other, I've been taught nothing about the practice.
Therefore, I go out to guides.
Too many of these guides walk me through the process by rote.
Here, I want to understand:

  * What is the procedure for various common key-related tasks?
  * What choices are made during those processes?
  * What are consequences of the various options?
  * Which tradeoffs are most important in which situations?
  * What is the providence of this information?

!!! warning
    This is an extreme work-in-progress.
    It does not abide the standards I have laid out above.
    The information here is merely for my own reference later as I write the real article.


## Create a Key Pair

This should be done on a trusted computer, using trusted software.
Guides recommend `ssh-keygen`, or PuttyGen on Windows.

There's definitely a choice of key type (PuttyGen gives RSA, DSA, ECDSA, ED25519, and SSH-1 (RSA). I can only assume plain RSA means SSH-2?).
At least RSA, but likely others offer a choice of size, which defaults to 2048 bits.
IIRC, my sysadmin had me create a 4096-bit key at work.

!!! caution "To-Do"
    What key types are available?
    For each key type, what are the parameters?
    Where size is an available parameter, how do I calculate the expected lifetime of a key based on its size?
    Do any programs have limitations on the supported key types/sizes?

Once the keypair is generated, both keys should be saved.
With `ssh-keygen`, it seems that the convention is `.pub` for the public key and no extension for the private.
With PuttyGen, it seems the convention is `.ppk` for the private key, and no extension for the public.
Either way, the base names for a keypair should probably be identical.

!!! caution "To-Do"
    What are the actual conventions?
    What are the consequences of those conventions for quickly recognizing a key as public or private?
    It appears there are multiple formats for the output: PuttyGen does not use OpenSSH format.
    What formats are there, and how compatible are they between different programs?

!!! caution "To-Do"
    Atlassian recommends checking for an existing key pair.
    If `ssh-keygen` really does just use a default, this seems like wise advice.

Because the private key is sensitive, many guides recommend encrypting it.
Both `ssh-keygen` and PuttyGen have this capability built-in.
They ask for a passphrase that I assume is then given to a key derivation function, but leaving the passphrase blank skips the encryption step.
Certainly on a computer on which I am not the sole administrator, I should encrypt my private key.
Similarly if they key exists on an unencrypted storage medium.

!!! caution "To-Do"
    I noticed that PuttyGen has a field for "comment".
    I wonder how to do something similar on *nix.
    Where is that comment stored, and are there any conventions about it?

Backup the keypair.
If the private key (or its passphrase) is ever lost, (the idea is that) it will be irrecoverable.
Therefore, it is worth not having to reconstruct your cryptographic identity to ensure that you have backups.

!!! caution "To-Do"
    IIRC, the public key is reconstructible from the private key.
    That's probably more work than it's worth though, and it'd be better to simply back both up together.

!!! Links
    * [Debian -- How to set up ssh so you aren't asked for a password](https://www.debian.org/devel/passwordlessssh)
    * [Microsoft Azure -- How to use SSH keys with Windows on Azure](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/ssh-from-windows)
    * [Atlassian -- Creating SSH keys](https://confluence.atlassian.com/bitbucketserver/creating-ssh-keys-776639788.html)


## Install a Public Key on Another Machine

For many online services, this consists of merely pasting your public key into a text input box.
For ssh, this means adding the public key into `~/.ssh/authorized_keys` on the remote machine.
There's also a utility called `ssh-copy-id`.

In any case, it seems that authenticators are especially sensitive to trailing whitespace.

Presenting your public key is not generally dangerous.
However, it's not 
On first connecting to a machine, you must verify that machine's identity (see below).

!!! caution "To-Do"
    Why is `authorized_keys` special: is it hardcoded?, is it configured by sshd?
    What is the format of a public key, of various types of keys?
    How much/little whitespace is acceptable?
    Where is the documentation that tells me where the authentication process looks for public keys?
    While I'm at it, I should review the theory behind making an ssh connection.

!!! Links
    * [Debian -- How to set up ssh so you aren't asked for a password](https://www.debian.org/devel/passwordlessssh)
    * [ssh.com -- ssh-copy-id](https://www.ssh.com/ssh/copy-id)


## Connecting To Another Machine

I believe `ssh-keygen` puts `id_rsa{,.pub}` into `~/.ssh/` by default.
I suppose that's where `ssh` looks for the private key when making a connection.

Graphical programs probably have a file selector to point at your private key.
Filezilla does, at least, as does Putty, though I think Putty is technically an ssh agent.

When connecting, the remote machine will identify itself with its own public key.
Ensure the advertised public key is correct.
This generally means obtaining a fingerprint over a secondary (and preferably more secure) communication channel.

!!! note "Links"
    * [UB Center for Computing Research -- Using SSH keys with Filezilla (Windows)](https://ubccr.freshdesk.com/support/solutions/articles/13000036435-using-ssh-keys-with-filezilla-windows-)


## Fingerprinting Keys

It seems there are many different fingerprinting algorithms.
On *nix, it seems `ssh-keygen -lf /path/to/ssh/key` is a common way to obtain a fingerprint.
Also available is `gpg --with-fingerprint <file>.asc`.

!!! caution "To-Do"
    What hashing algorithms are there?
    What are the trade-offs in terms of convenience (time to verify) vs. security (odds of false verification).
    Why not check the entire key?

!!! caution "To-Do"
    What is this `.asc` business?

!!! note "Links"
    * [Stack Overflow -- How do I find my RSA key fingerprint?](https://stackoverflow.com/questions/9607295/how-do-i-find-my-rsa-key-fingerprint)


## Key Servers

!!! caution "To-Do"
    These seem to be a key distribution system.
    Tell me more.
    Especially, what modes of use are safe/unsafe?


## Certificate Authorities

!!! note "Links"
    * [Let's Encrypt](https://letsencrypt.org/)


## SSH Agents

!!! caution "To-Do"
    I do not know how these work.
    Is Putty one?


## Encrypted Email

!!! caution "To-Do"
    I have no clue here.
    Something-something gpg-signatures.


## Verifying Critical Files

Certain files, especially OS distros and system software packages, are high-value targets, and should be verified carefully.
It seems this is generally done by also providing a file of hashes, and signing this hash file.

Obtain the author's signing key.
This is a point-to-point key exchange, so be sure to obtain it over a secure connection, or at least from a secondary connection(s).
At least sometimes it is distributed as a `.asc` file.
At least sometimes it is obtained from a key server.
In either case, verify the signing key using fingerprints as normal.
Proper verification here is the foundation of the security in all following steps.

Once verified, add the key to your gpg keyring with `gpg --import <file>.asc`.
I don't seem to have notes on it, but I believe it is possible to add a key directly from a keyserver with `gpg` as well.

!!! caution "To-Do"
    What is this about gpg keyrings?
    How do I manage them?

You should have obtained checksums and a signature on those checksums from a trusted source.
I saw recommended somewhere to always get these from the original site, not a mirror.
However, original sites have been hacked before, so perhaps it's more like increasing your trust levels in the source of the signature.
The convention appears to be `sha256sums.txt` and `sha256sums.txt.sig`.

Check the signature file with `gpg --verify sha256sums.txt.sig`.
This appears to be a short form, and gpg strips the `.sig` off to find the file under scrutiny.
It looks like this step relies on the signing key being in your keyring.

!!! caution "To-Do"
    Is there a way to verify without going to your keyring?
    Where is your keyring?
    How do you move it around between computers?
    What operations exactly are being used to perform verification?
    Are there multiple possible formats for the `.sig` file?
    What even are the real names for thee files?

Now that the hashes have been verified to come from a trusted source, all that is left is to verify the integrity of the file(s).
This can be done with `sha256sum --check --ignore-missing sha256sums.txt`.
Note that `-c` is a synonym for `--check`.

!!! caution "To-Do"
    There are surely other hash algorithms that could be used.
    I happen to know sha512 is faster on 64-bit machines, so why is sha256 so prevalent?
    For that matter, why only one set of hashes instead of a menu of checksums with different algorithms?

In summary:

  * d/l target files and checksums
  * d/l checksum signature from trusted source(s)
  * obtain author's signing key from trusted source(s)
  * visually verify signing key (fingerprint)
  * import signing key to keyring
  * verify checksum signature with gpg
  * verify target file integrity with `sha256sum -c`


## Encrypting Storage Media

!!! caution "To-Do"
    With modern distro's installers, this seems to be quite user-friendly.
    How does it really work?
    What are the specific technologies behind it?
    What is LUKS, for example?
    At what granularities can encryption be performed: drives, partitions, directories, files?, and by what means?
    What is the residency of decrypted files? In ram? On lock screen? On suspend/hibernate?
    How do I mount an encrypted partition after the computer is booted?


## General Principles

It is impossible for two parties to authenticate themselves to each other over an insecure channel without some sort of prior communication over a secure channel.
In practice, the prior secure communication takes on of two forms.
Exchange public keys (or their fingerprints) over a secure channel established by the parties themselves.
Defer trust to a certificate authority, which whom both parties have previously registered public keys.

!!! caution
    Do I have my terminology correct above?
    Are there really no distributed methods?