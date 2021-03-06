module Maka.App 

import Bindings.Dom.Elements
import Bindings.Dom.Render
import Virtual.Diff
import Virtual.Dom

rootUpdater : Eq msg => Symbol msg model 
                     -> (model -> Html msg)
                     -> (msg -> model -> model) 
                     -> NodeElement 
                     -> msg 
                     -> (model, Html msg)
                     -> IO (model, Html msg) 

rootUpdater symbol view up el msg (mod, oldView) = do
  let res     = up msg mod
  let html    = view res 
  patch symbol (believe_me el) (diff oldView html)
  pure (res, html)

public export
start : Eq msg => (model -> Html msg) -> (msg -> model -> model) -> model -> IO ()
start view update init = do 
  Just main <- getElementById "main" 
    | Nothing => putStrLn "Cannot find main div"

  let symbol = createSymbol "events"
  let html   = view init

  rendered <- render symbol html
  appendChild (cast main) rendered

  addListener symbol 
              (rootUpdater symbol view update (believe_me rendered)) 
              (init, html)

  putStrLn "Rendered"