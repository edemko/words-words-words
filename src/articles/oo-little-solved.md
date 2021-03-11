title: A Diamond Buried Under Rough
published: 2021-03-10
tag: programming
tag: rant

What does object-orientation provide[^except-recursive-records] that isn't already provided better elsewhere?

[^except-recursive-records]: other than recursive records

## Is-a is a Has-a

It's become fairly well-known that implementation inheritance introduces coupling whereas encapsulated composition and interface inheritance are good for decoupling.
Unfortunately, eschewing implementation interface in any halfway-mainstream object-oriented language requires a boatload of boilerplate.
It's no wonder programs are still badly coupled; the temptation of implementation inheritance is too great.

Let's remove implementation inheritance, since it's a poor design choice.
As a knock-on effect, this also makes the `protected` visibility modifier redundant, so let's remove it too.


## Type Inference

Subtyping destroys type inference.
Sure, a little bit can be done, but you'll get nowhere near inferring every type in an un-annotated 10k sloc program like Hindley-Milner-based languages can do.
Interestingly, academics also shy away from existential types and impredicaticity because of their cost in type inference breakages, even though subtyping is so much more damaging.

Perhaps you're a fan of dynamically-typed languages, so the above point is moot.
Personally, I see a static type system as a toolchain feature which dynamic languages definitionally lack.
I can see why you might not see it that way though: most type systems _are_ awful, but if you come from functional programming it's a whole different story.


## Library Composition

Let's say two library authors work independently.
One provides a `Widget` class, and the other provides a `Snarfable` interface.
You are using both libraries and notice that `Widget`s are `Snarfable`.
In an object-oriented language, you must go to the `Widget` author and convince them to add a both a dependency and the implementation of `Snarfable`.
It's either that or write a boilerplate adapter class.
Layer this issue on top of itself a few times, and the lack of composability becomes obvious.

The type-theoretic solution is typeclasses.
They also masquerade under names like "trait" in Rust or "interface" in typescript (and I think I've seen "protocol" somewhere also), and are often mixed together with some other feature(s).
Object-orientation came late to solving this problem and is converging on the same solution that Phillip Wadler and friends invented back in 1990.
Even if orphan instances are disallowed, at least you now need only bend one of the two upstream authors to your will.


## What are we left with?

Now that we have only `public` and `private` visibilities, encapsulation is as easy as lambda.
We've even removed the last vestiges of inheritance, arguably the most distinctive feature of object-orientation.
In its place, we've used typeclasses, a feature born in functional programming.
Replacing inheritance with typeclasses shoves us a long way towards type systems for functional languages.


## `this` Ambiguity

Now that we have nested classes---and even first-class classes in some languages!---it's no longer easy to determine which `this` is which.
Should `this` refer to the innermost class or the outermost class, and should there be some way to alter that behavior?
The problem is so pronounced in Javascript that it's become common practice to always type `const self = this` near the top of methods that contain methods.
Python does show one way around this though: methods always require at least one parameter, and the user gets to decide how it's named.

Of course, the fundamental thing that is happening is recursion.
An object is built out of parts that are able to refer back to the object itself.


## Recursive Records

Objects are recursive values that combine data and functions.
Okay, combining data and functions is not so interesting when seen in a functional light: functions are data and data can be functions.
So, object-orientation isn't bringing anything new to the table by packaging these together.

Nevertheless, the pattern of defining a recursive record is one which I think might be useful, but it's not well-explored in functional languages.
It's just such a pain that the idea is so difficult to explore in the object-oriented languages where it seemingly accidentally originated!


## Conclusion

I understand that these concepts were not all known until about the 1990s, but since we're choosing and designing languages _now_, I don't really care about the history.

I am not trying to argue that functional programming is better.
In fact, I think functional programming is a bit of a misnomer.
Instead, I want to argue that we should take seriously the ideas proposed by people who are paid to think deeply about the consequences of design decisions on comprehensibility: you know, the academics.[^super-rant]
It turns out that, yes, academics are primarily drawn to functional ideas when designing languages, and it's precisely because those ideas are easier to comprehend in their entirety, all the subtle corners included.

It's been a lifetime since we've had better solutions for the problems object-orientation attempted to address.
Something must be broken somewhere if humanity's best ideas only just beginning to see a glimmer of sunlight.

[^super-rant]: You might think that academics are paid to write gobbledygook. Actually, they are paid to examine the most difficult ideas humans have yet grappled with. To do this, they must find ways to communicate their insights _at all_, but even academics would prefer a simpler presentation of the same idea if possible. If you can't read academic papers, it is because you have not joined the community of people trying to push forward the frontiers of knowledge in that field. You don't have to read this stuff to be a good human, but you _should_ recognize your own limitations before dismissing the work of others.
