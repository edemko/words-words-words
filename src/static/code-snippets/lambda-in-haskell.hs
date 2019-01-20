data Expr
    = Var String
    | Lam String Expr
    | App Expr Expr
    deriving (Eq, Show)

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