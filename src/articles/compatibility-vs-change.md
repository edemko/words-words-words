title: Compatibility vs. Change
tag: computing
tag: human factors
tag: notes
published: 2019-01-15


There's a reason why people like backwards-compatibility.
It's no good for a bunch of (sometimes fairly recent) software to suddenly stop working just because a few other developers are in a rush.

At the same time, there are reasons why an API might become backwards-incompatible.
For example, no amount of backwards-compatibility is worth the damage cause by `memcpy`-related defects.


I have strong opinions about what should be done to have both stability and change.
This could apply to standards bodies, or to single authors trying to maintain a single stable library.
There must be a plan for adding stuff without locking-in, just in case it turns out to be broken.
There must be a plan to remove stuff when it is discovered to be broken.
In particular, when something is deprecated, there needs to be a hard timeline.
No the deadline cannot be moved, clients who would otherwise procrastinate must upgrade or else fail to exist on the new system.
There should always be a minimum timeline for removal, but I'd recommend a fixed timeline for every removal.
No, the developers cannot remove it earlier than that, they shouldn't be in such a rush to break everyone else's stuff.



The thing clients want are guarantees about how long their code will work for.
Without those, they are working in an environment of extreme risk.

The thing developers want are guarantees that they will be able to improve things.
Without those, they are working in an environment of extreme hopelessness.





Here's some suggested levels of support for fixed numbers _X_, _Y_.
Hell, maybe this should just be _the_ standard levels of support.
The way [Semantic Versioning](https://semver.org/) (should be) is the standard version numbering system.

!!!warning
    I put this together quickly for publication without a serious review.
    I think before anyone truly proposes anything, the consequences of the requirements and guarantees should be clearly understood.

experimental
:   * Implementations need not necessarily support[^support] it,
    * But a reference implementation should support it promptly.
    * The next stage may be "candidate" or "removed".
    * Removal does not violate backwards-compatibility.

candidate
:   * Compliant systems are recommended to support[^support] it, including bugfixes.
    * The next stage may be "standard" or "unsupported".
    * Removal does not violate backwards-compatibility.

standard
:   * Implementors are required to support[^support] it, including bugfixes.
    * Clients are guaranteed full support for at least _X_ years.
    * The next stage is "deprecated", which does not violate backwards-compatibility.
    * Alternatively, the next stage could be "standard" again, thereby explicitly re-affirming the feature's continuing presence for another _X_ years.

deprecated
:   * Implementors must retain availability[^support], but are recommended to only provide security fixes.
    * Clients are guaranteed to be unsupported[^support] in _Y_ years from date of deprecation.
    * The next stage is "unsupported", which violates backward-compatibility.

unsupported
:   * It is recommended that implementors drop availability[^support] altogether, or replace with an error stub.
    * Implementors must not provide an additional feature under the same identifier.
    * Implementors are required not to provide bugfixes, even security fixes (dropping availability is preferable).
    * Clients cannot rely on its presence.
    * The next stage is "obsolete", which occurs after a timeframe set on a per-feature basis.

obsolete
:   * Implementors are required to remove it, or replace with an error stub.
    * Implementors must not provide an additional feature under the same identifier.
    * Clients are guaranteed that the feature is not available.
    * The next stage is "removed", which occurs after a timeframe set on a per-feature basis.

removed
:   * New features may now be introduced under the same identifier.

[^support]: Here, I'm using "support" to indicate that active maintenance is being done, whereas merely not deleting it is "available".

One guiding principle I've used here is that it's all fun and games until it becomes standard; then we've got to be strict about the lifecycle.

I think that a good system for managing compatibility timescales should be able to apply those techniques to itself.
That is, it should be bootstrapped.
I'm not yet sure how that applies here, since I'm not even sure what constitutes the "interface" I've proposed.

It's worth thinking about rolling vs. synchronized changes to the standard.
Synchronized standards---where changes are made only in large, lump batches---are the norm in standards bodies.
Nevertheless, I would recommend "unofficially" warning about future plans to deprecate before an official update, if you are already working towards that decision.

To be clear, I don't have a lot of (or really any) experience herding a large platform install base over many years.
As such, I would welcome feedback from those who really do this stuff.

This message brought to you by The Committee of People Who Believe that Words Should Mean Things.
