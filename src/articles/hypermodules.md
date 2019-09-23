Modules are good for defining abstraction boundaries around mixed-level subprograms (a mix of terms, types, kinds, &c).
They aren't really meant to group related code.
After all, `cons` might be related to `nil` in that they are both introduction forms for `List`, but `cons` is also realted to `uncons` (its corresponding destructor) and `snoc` (by a list symmetry involving `reverse`).

My shower-thought is that navigating a code base is like navigating wiki.
If I come across a function I don't understand, I should be able to go to its definition, and not only see its type, implementation, and documentation, but also be able to see "related articles---I mean---code", and know why that code is related.

Therefore, how about a href directive with a mandatory `rel`?
Something like:

```
{-#HREF cons (ctor): nil #-}
{-#HREF cons (dtor): uncons #-}
{-#HREF LT (ctor): GT, EQ #-}
```