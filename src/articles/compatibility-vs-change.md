There's a reason why people like backwards-compatibility.
It's no good for a bunch of (sometimes fairly recent) software to suddenly stop working just because a few other developers are in a rush.

At the same time, there are reasons why an API might become backwards-incompatible.
For example, no amount of backwards-compatibility is work the damage cause by `memcpy`-related defects.


I have strong opinions about what should be done to have both stability and change.
This could apply to standards bodies, or to single authors trying to maintain a single stable library.
There must be a plan for adding stuff without locking-in, just in case it turns out to be broken.
THere must be a plan to remove stuff when it is discovered to be broken.
In particular, when something is deprecated, there needs to be a hard timeline.
No it cannot be moved, clients who would otherwise procrastinate must upgrade or else fail to exist on the new system.
There should always be a minimum timeline for removal, but I'd recommend a fixed timeline for every removal.
No, the developers cannot remove it earlier than that, they shouldn't be in such a rush to break everyone else's stuff.



The thing clients want are guarantees about how long their code will work for.
Without those, they are working in an environment of extreme risk.

The thing developers want are guarantees that they will be able to improve things.
Without those, they are working in an environment of extreme hopelessness.


A good system for managing compatibility timescales should be able to apply those techniques to itself.
That is, it should be bootstrapped.



Here's some suggested levels of support.
Hell, maybe this should just be _the_ standard levels of support.
The way SemVer (should be) is the standard version numbering system.

experimental
:   compliant systems are recommended to support it,
    removal does not violate backwards-compatibility.

no modifier
:   compliant systems are required to support it,
    clients are guaranteed support for for at least N years.

deprecated
:   compliant systems must make available,
    clients are guaranteed to be unsupported in N years from date of deprecation.

unsupported
:   compliant systems may choose not to provide bugfixes, or may drop availability altogether

obsolete
:   compliant systems are required to remove it, or replace with an error stub,
    the identifier is guaranteed not to be used while obsolete

removed
:   new functionality may be added under the old identifier after at least M years from date of removal.
