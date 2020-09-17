title: Crypto Cookbook
published: 2019-09-24
tag: computing
tag: notes


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


## General Principles

I strongly disagree with the "use this one technology and don't think about it" approach to computer security.
Compsec starts with the education of the individual.
It cannot be otherwise, because it is a war; you wouldn't expect there to be a magic bullet that wins fights, would you?

It is impossible for two parties to authenticate themselves to each other over an insecure channel without some sort of prior communication over a secure channel.
In practice, the prior secure communication takes one of a few forms, from most to least secure:

  * Exchange secrets or public keys (fingerprints) over a secure, authenticated channel established by the parties themselves.
  * Defer trust to a certificate authority, which whom both parties have previously registered public keys and established a secure connection.
  * Establish trust through multiple insecure but _independent_ methods.

Security is never a binary state of secure vs. insecure.
To analyze the security of a procedure, analyze the likelihood of failure compared to other options.
Likelihood of failure is not only likelihood of credential compromise, but also how likely you are to understand the system well enough to use it correctly, or even stick to using it in the first place.


## Managing Passwords

!!! warning
    I've only just started looking into this.

The largest source of password compromises seems to be from cracking into a database.
Signing up with online services means trusting their methods of password storage.[^open-source-trust]
In general, you cannot guarantee that they aren't simply storing passwords in plaintext, or otherwise storing them insecurely.
Therefore, credential stuffing attacks are the most prevalent attack vector to be concerned about.

After that, there's the worry of low-entropy passwords stored securely.
This entropy depends on the attack model: what algorithms are being used to generate guesses?
Against all algorithms, longer, less-memorable passwords are better.
If you need to remember a password, make it memorable based on things that aren't close to being analyzed by a computer.
Personal information, social network effects, and anything that has ever been written down are already analyzed by a computer.
Personally, I use phonetic and metaphorical resonance with my sense of aesthetics, but understand that this process nevertheless reduces the entropy of my passwords, so be over-cautious when doing this.


[^open-source-trust]: In practice, there are very few people who will fully audit an open-source implementation, but at least you can have some increased trust over closed-source in that someone could notice a breach of trust and blow the whistle.

Mitigations include:

  * Sign up for fewer online accounts, and delete the ones you don't need.
  * Use a password manager to increase the likelihood of using unique, high-entropy passwords.
  * Anonymize what accounts you can.
  * Segregate accounts (credentials and identifying information) by threat model.
  * Use password generators such as `pwgen` and `xkcdpass`, but understand the entropy they produce.
  * "Burn" any password that has been compromised, even if it wasn't a password for your account.


!!! note "Links"
    * [';--have i been pwned?](https://haveibeenpwned.com/)
    * [Pwned Passwords](https://haveibeenpwned.com/Passwords)
    * [`pwgen` Manual Page](https://linux.die.net/man/1/pwgen)
    * [`xkcdpass` Manual Page](http://manpages.ubuntu.com/manpages/xenial/man1/xkcdpass.1.html)

!!! caution "To-Do"
    * Sources on how to calculate the entropy of a password generation algorithm, assuming the attacker knows the algorithm?
    * How do aesthetic choices reduce the entropy of a password?

### Pwned Passwords

Never type your password into a third-party service.
Admittedly, [Pwned Passwords](https://haveibeenpwned.com/Passwords) is open-source and allegedly implements anonymity, but I haven't personally audited the source code, so I'll use it locally.
Therefore, I downloaded the database and loaded it into postgresql to I could search it quickly.

```sql
COPY pw (hash, count) FROM 'pwned-passwords-sha1-<version>.txt' WITH DELIMITER ':';
CREATE EXTENSION pgcrypto;
ALTER TABLE pw ALTER COLUMN hash SET DATA TYPE bytea USING decode(hash, 'hex');
VACUUM(FULL, ANALYZE, VERBOSE);
REINDEX TABLE pw;
SELECT * FROM pw WHERE hash = digest('P@ssword', 'sha1');
```

This took a while, and it seriously impacted my harddrive performance, especially during reindexing.
Even just the initial data load took three hours before I went to bed.
Now though, seraching for passwords happens very quickly:

```sql
SELECT * FROM pw WHERE hash = digest('P@ssword', 'sha1');
```

!!!warning
    When done, don't forget to clear your psql history, otherwise that's a place where your passwords are stored in cleartext:

    ```
    echo '' > ~/.psql_history
    ```

!!! caution "To-Do"
    Is there anywhere else that psql might save the cleartext password?
    E.g. query caching?

## Managing Asymmetric Key Cryptography

!!! note "Links"
    * [GPG Tutorial](https://futureboy.us/pgp.html)

!!! caution "To-Do"
    I've got to re-organize this section.

    * when should you create/replace a key?
    * create keys
    * securing and backing up keys
    * revoke keys
    * distribute keys
    * when and how much should you trust others keys?
    * receive keys
    * using keys conveniently
    * particular tasks and services:
        * encrypted storage media
        * verify files
        * ssh client
        * ssh server
        * proton mail
        * sign files

### Create a Key Pair

This should be done on a trusted computer, using trusted software.
Guides recommend `ssh-keygen` or `gpg`, or PuttyGen on Windows.

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

Because the private key is sensitive, many guides recommend adding a passphrase on it.
Both `ssh-keygen` and PuttyGen have this capability built-in.
They ask for a passphrase that I assume is then given to a key derivation function, but leaving the passphrase blank skips the encryption step.
Certainly on a computer on which I am not the sole administrator, I should encrypt my private key.
The same holds for keys that exist on an unencrypted storage medium with no physical access controls.

!!! caution "To-Do"
    I noticed that PuttyGen has a field for "comment".
    I wonder how to do something similar on \*nix.
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

#### Revoke a Key

In the case of a key failure (compromised, lost, or retired intensionally), there must be a way to tell everyone that your key is no longer valid.
This is apparently done with revocation certificates.
In gpg, these end up imported and published to key servers in much the same way as the keys themselves.

!!!note "To-Do"
    Why aren't revocation certificates guarded by a passphrase?
    I haven't even seen this mentioned, much less recommended or implemented.


### Fingerprinting Keys

It seems there are many different fingerprinting algorithms.
On \*nix, it seems `ssh-keygen -lf /path/to/ssh/key` is a common way to obtain a fingerprint.
Also available is `gpg --with-fingerprint <file>.asc`.

!!! caution "To-Do"
    What hashing algorithms are there?
    What are the trade-offs in terms of convenience (time to verify) vs. security (odds of false verification).
    Why not check the entire key?

!!! caution "To-Do"
    What is this `.asc` business?

!!! note "Links"
    * [Stack Overflow -- How do I find my RSA key fingerprint?](https://stackoverflow.com/questions/9607295/how-do-i-find-my-rsa-key-fingerprint)


### Key Servers

!!! caution "To-Do"
    These seem to be a key distribution system.
    Tell me more.
    Especially, what modes of use are safe/unsafe?

Well, Debian gives a limited view on the uses of keyservers.
In particular:

`gpg --keyserver keyring.debian.org --recv-keys 0x<hex key id>`

!!! caution "To-Do"
    Where fo I find key servers?
    How are keys protected in transit?

!!! note "Links"
    * [Verifying authenticity of Debian CDs](https://www.debian.org/CD/verify)
    * [Debian Public Key Server](https://keyring.debian.org/)


### Certificate Authorities

!!! note "Links"
    * [Let's Encrypt](https://letsencrypt.org/)
    * [Certbot](https://certbot.eff.org/)


### SSH Agents

!!! caution "To-Do"
    I do not know how these work.
    Is Putty one?


### Encrypted Email

!!! caution "To-Do"
    I have no clue here.
    Something-something gpg-signatures.


### Verifying Critical Files

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
    Apparently, they exist in `~/.gnupg/`

You should have obtained checksums and a signature on those checksums from a trusted source.
I saw recommended somewhere to always get these from the original site, not a mirror.
However, original sites have been hacked before, so perhaps it's more like increasing your trust levels in the source of the signature.
The convention appears to be `sha256sums.txt` and `sha256sums.txt.sig`.

Check the signature file with `gpg --verify sha256sums.txt.sig`.
This appears to be a short form, and gpg strips the `.sig` off to find the file under scrutiny.
Indeed, Debian distributes a `.sign` file, and I verified it with `gpg --verify SHA256SUMS.sig SHA256SUMS`.
It looks like this step relies on the signing key being in your keyring.

!!! caution "To-Do"
    Is there a way to verify without going to your keyring?
    Where is your keyring?
    How do you move it around between computers?
    What operations exactly are being used to perform verification?
    Are there multiple possible formats for the `.sig` file?
    What even are the real names for these files?

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

!!! note "Links"
    * [How to verify an authenticity of downloaded Debian ISO images](https://linuxconfig.org/how-to-verify-an-authenticity-of-downloaded-debian-iso-images)

## Encrypting Storage Media

With modern distros, it seems to be quite easy to encrypt a partition with LUKS when formatting it.
However, I'll note that I couldn't find the option to do this in gparted, and gnome-disk-utility crashed multiple times immediately after requesting to apply changes until it finally decided to fly straight.
Mounting, at least in XFCE seems to be as easy as mounting anything else, with the exception of an additional step entering your passphrase, which the gui walks you through seamlessly.

!!! caution "To-Do"
    With modern distro's installers, this seems to be quite user-friendly.
    What are the specific technologies behind it?
    What is LUKS?
    How does it really work?
    Are there alternative formats?
    How do I do this stuff from the command line?
    At what other granularities can encryption be performed: drives, directories, files?, and by what means?
    What is the residency of decrypted files? In ram? On lock screen? On suspend/hibernate?

!!! note "Links"
    * [EncryptedFilesystemsOnRemovableStorage](https://help.ubuntu.com/community/EncryptedFilesystemsOnRemovableStorage)

## Specific Services

### SSH

#### Set up `sshd` on the Remote Machine

On debian systems, installation is done through the `openssh-server` package.
It seems this automatically generates a suite of server/host keys.
You can obtain the server's key fingerprint with `ssh-keygen -lf /etc/ssh/ssh_host_ecdsa_key.pub`, or any of the other `ssh_host_*_key.pub` files.
Use this later to verify the machine's identity before each client's first connection.

!!! caution "To-Do"
    Are there any other quality sshd implementations available?
    The debian wiki has some more hardening steps beyond what I've laid out here.

While we're here, it's a good time to harden the ssh server.
Make sure public key authentication is on, password authentication is off.
There are apparently security implications about X11 forwarding, so that can be turned off as well.
It's probably also a good idea to set up a whitelist of groups and users that are even allowed to ssh in.
This seems to be just the basics, and there are more things that could be done; see the links below for some tips

A key component of ssh security is keeping software up-to-date.
To this end, it is probably a good idea to install `unattended-upgrades`.
That suggests `needrestart`, and I expect I need to set restarts to be automatic (`$nrconf{restart} = 'a';`) if unattended-upgrades is to work fully unattended.

!!! Links
    * [Debian — SSH](https://wiki.debian.org/SSH)
    * [OpenSSH security and hardening](https://linux-audit.com/audit-and-harden-your-ssh-configuration/)
    * [UnattendedUpgrades](https://wiki.debian.org/UnattendedUpgrades)



#### Install a Public Key on Another Machine

Add your public key into `~/.ssh/authorized_keys` on the remote machine, or alternatively use `ssh-copy-id`.
I'd recommend doing `ssh-copy-id -n` to do a dry run first.

On first connecting to a machine, you must verify that machine's identity (see below).

To add a public key to `authorized_keys`, I simply appended the key onto the file.
I did make a backup first and verify that all machines can still log in.

```sh
cp ~/.ssh/authorized_keys ~/.ssh/authorized_keys.bak
cat new_key.pub > ~/.ssh/authorized_keys
# check logins still function
rm new_key.pub ~/.ssh/authorized_keys.bak
```

!!! caution "To-Do"
    Why is `authorized_keys` special: is it hardcoded?, is it configured by sshd?
    What is the format of a public key, of various types of keys?
    How much/little whitespace is acceptable?
    Where is the documentation that tells me where the authentication process looks for public keys?
    While I'm at it, I should review the theory behind making an ssh connection.

!!! Links
    * [Debian -- How to set up ssh so you aren't asked for a password](https://www.debian.org/devel/passwordlessssh)
    * [ssh.com -- ssh-copy-id](https://www.ssh.com/ssh/copy-id)


#### Connecting To Another Machine

I believe `ssh-keygen` puts `id_rsa{,.pub}` into `~/.ssh/` by default.
I suppose that's where `ssh` looks for the private key when making a connection.

Graphical programs probably have a file selector to point at your private key.
Filezilla does at least, as does Putty, though I think Putty is technically an ssh agent.

When connecting, the remote machine will identify itself with its own public key.
Ensure the advertised public key is correct.
This generally means obtaining a fingerprint over a secondary (and preferably more secure) communication channel.

!!! note "Links"
    * [UB Center for Computing Research -- Using SSH keys with Filezilla (Windows)](https://ubccr.freshdesk.com/support/solutions/articles/13000036435-using-ssh-keys-with-filezilla-windows-)
    * [Good practices for using ssh](http://lackof.org/taggart/hacking/ssh/)



### ProtonMail

I should have known, but ProtonMail does end-to-end and zero-access encryption with a public key infrastructure.
When emailing someone in ProtonMail, you have the service find the recipient's public key and use that to encrypt.
Incoming insecure messages are encrypted with your public key immediately on reciept.
I haven't yet figured out how email gets sent to insecure recipients.
Between two secure parties is end-to-end, whereas with only one secure party, the best achievable is zero-access.

It seems that party-to-party authentication in ProtonMail relies on the authenticity of the first contact to exchange public keys, and for that we trust the ProtonMail service.
[This post](https://protonmail.com/blog/address-verification-pgp-support/) and [this support article](https://protonmail.com/support/knowledge-base/address-verification/) seem to indicate that trusted sender-key associations are stored similarly to ssh (where e.g. I decide to trust a server's key).
For this, it seems the way to maintain security without necessarily trusting ProtonMail not to have been hacked is to verify the key through an independent connection, preferably secure.
The difference between this and authenticating communications in manual PGP is, it seems, not much.

Private key storage is about what I'd expect.
Your login password is run through a PBKDF to generate a symmetric key locally, which is then used to encrypt your private key before storing it on ProtonMail's servers.
Sources: [Single Password](https://protonmail.com/blog/encrypted_email_authentication/), [Private Key Storage](https://protonmail.com/support/knowledge-base/how-is-the-private-key-stored/).
In case you want to intensionally change your password, that means you d/l your private keys, decrypt them with your existing password, then re-encrypt with the new password before sending them back to the server for encrypted-at-rest storage.

[This](https://protonmail.com/support/knowledge-base/pgp-key-management/) seems to be a good overview of key management in Protonmail, as well as having some links to additional features.

## VPN

!!! caution "To-Do"
    Just plain, simple "To-Do".
