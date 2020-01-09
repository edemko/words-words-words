title: Thinking With Types
published: 2019-01-15
tag: computing
tag: types

I'm not sure many people understand types on anything more than a surface emotional level.
They either like types, or they don't like them, and they can rationalize their feelings, but at the end of they day, I've seen few people who could convince me either way.
The only reliable information I have is my own experience programming.[^what-experience]

[^what-experience]: In case you're curious, that's 19 years using 17 languages across several paradigms.

I'm not going to give an example of an idiom that I like/dislike, or a program that I enjoy/despise.
I'm not even going to try to change the way you program---I'm not your mom.
I just want to look at the thought process behind one particular, widespread perspective on types: that **some languages don't have them**.


Here's some code in an untyped language:

```python
def force(thunk):
    """forall a. Thunk a -> a
        where Thunk a = () -> a
    """
    return thunk()
```

If someone notices my "type annotation" and tells me "Python doesn't have types. Stop thinking in terms of types.", that's fine.

```python
force(3)
```

And if that person then tells me that `force(3)` will never work, then I will say:

  > A wise man once gave me this advice which I will pass on to you: "Stop thinking in terms of types."

Because it turns out that we all think in terms of types, and it doesn't matter if you're a statically- or dynamically-typed kind of person.
What's interesting about folks who claim to despise thinking with types, is that they have not yet learned the appropriate language in which to communicate about types.
That language---shockingly enough---is called _type theory_.


I'm not going to sit here and say that everyone should be using a statically-typed language for everything.
The build scripts for this very blog are written in dynamically-typed languages.
If I even get to the point where one of my build systems _needs_ static typing, I need to stop and think about my life choices.

What I want to suggest to the detractors of static typing is that they cannot defeat an enemy without understanding it.
In order to defeat the idea of static typing, one must first learn what types are and what they are capable of.
To be fair, that's currently a lot of work, and I wouldn't recommend it for everyone.
Still, it's perfectly fine for people to not have an informed opinion on everything, just as long they don't proselytize from ignorance.

Now, if you still prefer to use dynamically-typed languages, I can't necessarily blame you.
Today's type systems aren't perfect[^today-problems].
Nevertheless, in my experience the cost of not performing static type checks is more time spent in some combination of:

  * writing boilerplate documentation,
  * writing boilerplate tests,
  * tedious defensive programming, and
  * fixing type errors.

[^today-problems]: Let's be honest: the mainstream type systems are awful, the good production-ready ones do have some real limitations, and the ones without limitation are not yet ergonomic.
