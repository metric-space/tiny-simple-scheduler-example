{-# LANGUAGE OverloadedStrings #-}

import Control.Concurrent
import Control.Concurrent.Async
import Control.Monad.IO.Class
import Control.Monad.Reader
import qualified Data.Text.Lazy as L
import Data.Time
import System.Random
import TinyScheduler.Jobs
import TinyScheduler.SubJobs
import TinyScheduler.Time
import Web.Scotty

statuses :: [L.Text]
statuses =
  [ "Pooping poop"
  , " Making mulan szechuan sauce "
  , " writing letters of self loathe "
  , " loafing "
  , " zzzzzzZZZZZ .. wadya want .. zzzZZZZ"
  ]

asyncStatus :: ReaderT (MVar L.Text) IO ()
asyncStatus = do
  g <- liftIO newStdGen
  x <- ask
  let length_ = length statuses
      (choice, _) = randomR (0, length_ - 1) g
  liftIO $ swapMVar x (statuses !! choice) >> return ()

-- intervals of 2 minutes done 10 times
jobx :: UTCTime -> MVar L.Text -> Job ()
jobx x y = makeJob 1234 100  (Minutes 2) x (runReaderT asyncStatus y)

asyncJob :: MVar L.Text -> IO ()
asyncJob y =
  getCurrentTime >>= (\x -> execSubJobs . convertJobIntoSubJobs x $ (jobx x y)) >> return ()

server :: MVar L.Text -> IO ()
server x = do
  scotty 3000 $
    get "/" $ do
      val <- liftIO $ readMVar x
      let message = mconcat ["<h1>Lukas statas !!</h1>", "<div id='chicken'>", val, "</div>"]
      (html message)

main :: IO ()
main = newMVar "Boy" >>= \x -> concurrently_ (asyncJob x) (server x)
