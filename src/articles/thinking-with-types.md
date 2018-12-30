I'm not going to sit here and say that everyone should be using a statically-typed language for everything.
The build scripts for this very blog are written in dynamically-typed languages.
If I even get to the point where one of my build systems _needs_ static typing, I need to stop and think about my life choices.

That said, I'm not sure many people understand types on anything more than a surface emotional level.
They either like types, or they don't like them, and they can rationalize their feelings, but at the end of they day, I've seen few people who could convince me either way.
Today, I just want to focus on one particular perspective on types: that some languages don't have them.


Here's some code in an untyped language:

```python
def force(thunk):
    """forall a. Thunk a -> a
        where Thunk a = () -> a
    """
    return thunk()
```

If someone notices my type annotation and tells me "Python doesn't have types. Stop thinking in terms of types.", that's fine.

```python
force(3)
```

And if that person then tells me that `force(3)` will never work, then I will say:

  > A wise man once gave me this advice which I will pass on to you: "Stop thinking in terms of types."


Because it turns out that we all think in terms of types, and it doesn't matter if your a statically- or dynamically-typed kind of person.
What's different about folks who claim to despise thinking with type, is that they have not yet learned the appropriate language in which to communicate about types.
That language, shockingly enough, is called type theory.

Now, if they still prefer dynamically-typed languages to today's typed languages[^today-problems], I can't necessarily blame them.
Nevertheless, the cost they'll pay for not having types is more time spent in some combination of:

  * writing boilerplate documention,
  * writing boilerplate tests,
  * tedious defensive programming, and
  * fixing type errors.

[^today-problems]: Let's be honest the mainstream type systems are awful, the decent production-ready ones do have some real limitations, and the good unlimited ones are not ergonomic.