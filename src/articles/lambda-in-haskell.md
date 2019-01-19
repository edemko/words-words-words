title: λ in Haskell
tag: computing

This is an interpreter for the lambda calculus which is beautiful.
I was inspired by a Papers We Love talk ["The Most Beautiful Program Ever Written"](https://www.youtube.com/watch?v=OyfBQmvr2Hc) to do something amazing.
I noticed that the given Lisp self-interpreter[^not-self-interpreter] is strict, but the full lambda calculus need not be.
In fact, the full lambda calulus is stronger in a way (though I'm not exactly sure how; I remember something about it in the paper on A-normal form).

[^not-self-interpreter]: It's actually a λ-calculus interpreter, not a Lisp interpreter---unless the concrete syntax that Lisp _totally doesn't have_ is important in your estimation. Then again, the most-used parts of Lisp are really just the λ-calculus anyway, so I can't complain too much.

Well, it's maybe not so amazing, because this is not a self-interpreter.
Nevertheless, the principle is there, and with a bit of decoding into the plain λ-calculus, it very well could be a self-interpreter, but I'd much rather read this syntax.

```haskell
-- FIXME do I need to import `Data.List`?
import Data.Symbol

data Expr
    = Var Symbol
    | Lam Symbol Expr
    | App Expr Expr

fvs :: Expr -> [Symbol]
fvs (Var x) = [x]
fvs (Lam y e) = fvs e \\ [y]
fvs (App f a) = nub (fvs f ++ fvs a)

subst :: Symbol -> Expr -> Expr
subst x e' e = case e of
    Var y -> if x == y then e' else e
    -- FIXME `e` needs to not have `y` in its free variables
    Lam y body -> if x == y then e else head [ Lam y' (subst e' body') | (y', body') <- newLams ]
        where
        newVars = y : intern . (unintern y ++) . ('_':) . show <$> [1..]
        newLams = [(y', subst y (Var y') body) | y' <- newVars y, if y' `notElem` fvs e' ]
    App f a -> App (subst f) (subst a)

eval :: Expr -> Expr
eval (App f a) = case eval f of
    Lam x b -> eval (subst x a b)
    e -> App e a
eval e = e
```