{-# LANGUAGE OverloadedStrings #-}

--import System.Environment (getEnv)
import Text.HTML.Scalpel
import TinyScheduler.Jobs
import TinyScheduler.SubJobs
import TinyScheduler.Time
import TinyScheduler.TimeAtom
import Data.Maybe
--import Data.Monoid
import Control.Monad.Reader
import Control.Concurrent
import Data.Time
import Data.Monoid

testUrl :: String
testUrl = "http://localhost:3000"

atom :: TimeAtom
atom = (makeTimeAtom 10 $ Minutes 3) <> (makeTimeAtom 4 $ Secs 20)

scrapeAndPrint :: ReaderT (MVar String) IO ()
scrapeAndPrint = do
  mvar <- ask
  prev <- liftIO $ readMVar mvar
  x <- liftIO $ scrapeURL  testUrl  (text $ "div" @: ["id" @= "chicken"])
  let status = fromJust x
  if status /= prev
     then (liftIO $ putStrLn $ status) >> (liftIO $ swapMVar mvar status) >> return ()
     else liftIO $ putStrLn "Nothing's changed, come again later ya animal"
  return ()

asyncJob :: MVar String -> TimeAtom -> IO ()
asyncJob y x = do
  let jobb z = timeAtomToJob 1234 (runReaderT scrapeAndPrint y) z x
  getCurrentTime >>= (\p -> execSubJobs . convertJobIntoSubJobs p $ jobb p) >> return ()

-- make periodic calls to a site, scrape it for id=chicken
-- check
main :: IO ()
main = newMVar "" >>= \x -> asyncJob x atom

