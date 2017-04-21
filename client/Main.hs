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

testUrl :: String
testUrl = "http://localhost:3000"

atom :: TimeAtom
atom = mconcat [makeTimeAtom 4 (Secs 20), makeTimeAtom 100 (Minutes 3)]

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
  let job z = timeAtomToJob 1234 (runReaderT scrapeAndPrint y) z x
  getCurrentTime >>= (\x -> execSubJobs . convertJobIntoSubJobs x $ job x) >> return ()

-- make periodic calls to a site, scrape it for id=chicken
-- check
main :: IO ()
main = newMVar "" >>= \x -> asyncJob x atom

