This is an interpreter for the lambda calculus which is beautiful.
I was inspired by a Papers We Love talk ["The Most Beautiful Program Ever Written"](https://www.youtube.com/watch?v=OyfBQmvr2Hc) to do something amazing.
I noticed that the given Lisp self interpreter is strict, but the full lambda calculus need not be.
In fact, the full lambda calulus is stronger in a way (though I'm not exactly sure how; I remember something about it in the paper on A-normal form).

Well, it's not so amazing, because this is not a self-interpreter.
Nevertheless, the principle is there, and with enough Churchesque encoding work, it very well could be a self-interpreter.
Then again, the interpreter given in the talk isn't a self-interpreter either: it's an interpreter for the lambda calculus written in Lisp.

```haskell
import Data.Symbol

data Expr
    = Var Symbol
    | Lam Symbol Expr
    | App Expr Expr

subst :: Symbol -> Expr -> Expr
subst x e' e = case e of
    Var y -> if x == y then e' else e
    Lam y body -> if x == y then e else Lam y (subst e' body)
    App f a -> App (subst f) (subst a)

eval :: Expr -> Expr
eval (App f a) = case eval f of
    Lam x b -> eval (subst x a b)
    e -> App e a
eval e = e
```