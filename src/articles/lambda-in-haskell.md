title: λ in Haskell
tag: computing
tag: notes

This is an interpreter for the lambda calculus which is beautiful.
I was inspired by a Papers We Love talk ["The Most Beautiful Program Ever Written"](https://www.youtube.com/watch?v=OyfBQmvr2Hc) to do something amazing.
I noticed that the given Lisp self-interpreter[^not-self-interpreter] is strict, but the full lambda calculus need not be.
In fact, the full lambda calulus is stronger in a way (though I'm not exactly sure how; I remember something about it in the paper on A-normal form).

[^not-self-interpreter]: It's actually a λ-calculus interpreter, not a Lisp interpreter---unless the concrete syntax that Lisp _totally doesn't have_ is important in your estimation. Then again, the most-used parts of Lisp are really just the λ-calculus anyway, so I can't complain too much.

Well, it's maybe not so amazing, because this is not a self-interpreter.
Nevertheless, the principle is there, and with a bit of decoding into the plain λ-calculus, it very well could be a self-interpreter, but I'd much rather read this syntax.
Besides, one thing this can do extra is finding most-normalized forms even when there are free variables, and it prints out the resulting form in full rather than merely saying `#<procedure at interp.scm:489>`.

!!!warning
    There's just one problem: hygienic substitution makes the interpreter strict again.
    Give `eval $ App (Lam "x" $ Lam "y" $ Var "y") undefined` a try.


```haskell
data Expr
    = Var String
    | Lam String Expr
    | App Expr Expr

fvs :: Expr -> [String]
fvs (Var x) = [x]
fvs (Lam y e) = filter (/= y) (fvs e)
fvs (App f a) = fvs f ++ fvs a

subst :: (String, Expr) -> Expr -> Expr
subst (x, e') e = case e of
    Var y -> if x == y then e' else e
    Lam y body
        | x == y -> e
        | otherwise -> Lam y' (subst (x, e') body')
            where
            newVars = y : map ((y ++) . ('_':) . show) [1..]
            (y', body') = head [mkLam y' | y' <- newVars, y' `notElem` fvs e' ]
            mkLam x = (x, subst (y, Var x) body)
    App f a -> App (subst (x, e') f) (subst (x, e') a)

eval :: Expr -> Expr
eval (App f a) = case eval f of
    Lam x body -> eval (subst (x, a) body)
    e -> App e a
eval e = e

usage = eval $ App (Lam "y" $ Lam "x" $ App (Var "x") (Var "y")) (Var "x")
```
