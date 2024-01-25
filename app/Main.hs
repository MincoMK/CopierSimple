module Main where

import Data.ConfigFile
import Data.Either.Utils
import System.Sleep
import qualified Shelly

main :: IO ()
main = do
  val <- readfile emptyCP "copier.conf"
  let cp = forceEither val
  let to = forceEither $ get cp "DEFAULT" "to"
  let from = forceEither $ get cp "DEFAULT" "from"
  let after = read $ forceEither $ get cp "DEFAULT" "after" :: Float
  let interval = read $ forceEither $ get cp "DEFAULT" "interval" :: Float

  scheduler interval after to from

scheduler :: Float -> Float -> String -> String -> IO ()
scheduler interval after from to = do
  -- copy logic
  putStrLn "copying..."
  Shelly.shelly $ Shelly.cp_r from to
  sleep $ interval - after
  putStrLn "removing..."
  Shelly.shelly $ Shelly.rm_rf $ to ++ "/*"
  sleep after
  scheduler interval after from to
