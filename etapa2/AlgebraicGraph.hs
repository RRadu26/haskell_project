module AlgebraicGraph where

import qualified Data.Set as S

data AlgebraicGraph a
    = Empty
    | Node a
    | Overlay (AlgebraicGraph a) (AlgebraicGraph a)
    | Connect (AlgebraicGraph a) (AlgebraicGraph a)
    deriving (Eq, Show)

-- (1, 2), (1, 3)
angle :: AlgebraicGraph Int
angle = Connect (Node 1) (Overlay (Node 2) (Node 3))

-- (1, 2), (1, 3), (2, 3)
triangle :: AlgebraicGraph Int
triangle = Connect (Node 1) (Connect (Node 2) (Node 3))

{-
    *** TODO ***

    Mulțimea nodurilor grafului.

    Hint: S.union
-}
nodes :: Ord a => AlgebraicGraph a -> S.Set a
nodes graph = case graph of 
    Empty -> S.empty
    Node x -> S.singleton x
    Overlay g1 g2 -> S.union (nodes g1) (nodes g2)
    Connect g1 g2 -> S.union (nodes g1) (nodes g2)

{-
    *** TODO ***

    Mulțimea arcelor grafului.

    Hint: S.union, S.cartesianProduct
-}
edges :: Ord a => AlgebraicGraph a -> S.Set (a, a)
edges graph = case graph of
    Empty -> S.empty
    Node x-> S.empty
    Overlay g1 g2 -> S.union (edges g1) (edges g2)
    Connect g1 g2 -> S.union (S.cartesianProduct (nodes g1) (nodes g2)) (S.union (edges g1) (edges g2))

{-
    *** TODO ***

    Mulțimea nodurilor înspre care pleacă arce dinspre nodul curent.

    ATENȚIE! NU folosiți funcția edges definită mai sus, pentru că ar genera
    prea multe muchii inutile.
-}
outNeighbors :: Ord a => a -> AlgebraicGraph a -> S.Set a
outNeighbors node graph = case graph of
    Empty -> S.empty
    Node x -> S.empty
    Overlay g1 g2 -> S.union (outNeighbors node g1) (outNeighbors node g2)
    Connect g1 g2 -> S.union (if S.member node (nodes g1) then S.union (outNeighbors node g1) (nodes g2) else S.empty) (outNeighbors node g2)

{-
    *** TODO ***

    Mulțimea nodurilor dinspre care pleacă arce înspre nodul curent.

    ATENȚIE! NU folosiți funcția edges definită mai sus, pentru că ar genera
    prea multe muchii inutile.
-}
inNeighbors :: Ord a => a -> AlgebraicGraph a -> S.Set a
inNeighbors node graph = case graph of
    Empty -> S.empty
    Node x -> S.empty
    Overlay g1 g2 -> S.union (inNeighbors node g1) (inNeighbors node g2)
    Connect g1 g2 -> S.union (if S.member node (nodes g2) then S.union (inNeighbors node g2) (nodes g1) else S.empty) (inNeighbors node g1)

{-
    *** TODO ***

    Întoarce graful rezultat prin eliminarea unui nod și a arcelor în care
    acesta este implicat. Dacă nodul nu există, se întoarce același graf.

    Hint: Definiți o funcție recursivă locală (de exemplu, în where),
    care să primească drept parametri doar entități variabile de la un apel
    recursiv la altul, astfel încât să nu copiați la fiecare apel parametrii
    nemodificați. De exemplu, parametrul node nu se modifică, în timp ce
    parametrul graph se modifică.
-}
removeNode :: Eq a => a -> AlgebraicGraph a -> AlgebraicGraph a
removeNode node graph = removeNodeAux graph 
    where 
        removeNodeAux g = case g of
            Empty -> Empty
            Node x -> if x == node then Empty else Node x
            Overlay g1 g2 -> Overlay (removeNodeAux g1) (removeNodeAux g2)
            Connect g1 g2 -> Connect (removeNodeAux g1) (removeNodeAux g2)
    

{-
    *** TODO ***

    Divizează un nod în mai multe noduri, cu eliminarea nodului inițial.
    Arcele în care era implicat vechiul nod trebuie să devină valabile
    pentru noile noduri.
    
    Hint: Funcție recursivă locală, ca la removeNode.
-}
splitNode :: Eq a
          => a                 -- nodul divizat
          -> [a]               -- nodurile cu care este înlocuit
          -> AlgebraicGraph a  -- graful existent
          -> AlgebraicGraph a  -- graful obținut
splitNode old news graph = splitNodeAux graph
    where 
        splitNodeAux g = case g of
            Empty -> Empty
            Node x -> if x == old then foldl (\acc x-> Overlay acc (Node x)) Empty news else Node x
            Overlay g1 g2 -> Overlay (splitNodeAux g1) (splitNodeAux g2)
            Connect g1 g2 -> Connect (splitNodeAux g1) (splitNodeAux g2)

{-
    *** TODO ***

    Îmbină mai multe noduri într-unul singur, pe baza unei proprietăți
    respectate de nodurile îmbinate, cu eliminarea acestora. Arcele în care
    erau implicate vechile noduri vor referi nodul nou.

    Hint: Funcție recursivă locală, ca la removeNode.
-}
mergeNodes :: (a -> Bool)       -- proprietatea îndeplinită de nodurile îmbinate
           -> a                 -- noul nod
           -> AlgebraicGraph a  -- graful existent
           -> AlgebraicGraph a  -- graful obținut
mergeNodes prop node graph = mergeNodesAux graph
    where 
        mergeNodesAux g = case g of
            Empty -> Empty
            Node x -> if prop x then Node node else Node x
            Overlay g1 g2 -> Overlay (mergeNodesAux g1) (mergeNodesAux g2)
            Connect g1 g2 -> Connect (mergeNodesAux g1) (mergeNodesAux g2)
    
