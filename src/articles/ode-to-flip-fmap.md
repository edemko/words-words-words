title: An Ode to `<&>`
published: 2020-09-14
tags: programming

When we were first learning about haskell, we learned that do-notation was just syntactic sugar:

```haskell
thing1 x >>= \a ->
  thing2 a y >>= \b ->
    thing3 b z
```

As we progressed, we probably learned that `Applicative` is often a better abstraction because it offers less power
(in the same way that pure languages are better because they don't offer the power of mutation).
However, it can get syntactically obnoxious working with applicative sometimes:

```haskell
(\xFld yFld -> MyRecord{xFld,yFld}) <$> getX <*> getY
```

So we learned to enable `ApplicativeDo` and write

```
do
  xFld <- getX
  yFld <- getY
  pure MyRecord{xFld,yFld}
```

Recently I found myself working with `Functor` (because less power → more flexible) in the same way I might work with `Applicative`.
There is no language extension to make functors look nice.
However, I remembered my `>>=`, and noticed the similarity with `<&>`:

```haskell
foo x <&> \x' ->
  bar x' y
```

As it happened, I could start by writing the more familiar monadic algorithms.
Once I made sure it worked, I retrofitted it to the functorial case with very few keystrokes thanks to `<&>`.
So thank you `<&>`! You are a wonderful little tool!

P.S. There's probably something to be said for your friend `&` as well...
