module Jobs
    ( Job (..),
      convertJobIntoTask
    ) where


import Time
import Data.Time
import Control.Concurrent

data Job = Job { startDate :: UTCTime , interval :: Interval, hits :: Int, job :: IO () }

doTask :: Int -> IO () -> IO ()
doTask delay job = forkIO (threadDelay delay >> job ) >> return ()

convertJobIntoTask :: Job -> IO () 
convertJobIntoTask x = do 
                         currentUTC <- getCurrentTime
                         let interv = intervalToSecs $ interval x
                             diff = diffUTCTime (startDate x) currentUTC
                             -- delay & interval_ are in microseconds
                             delay = fromEnum $  10^^(-6) * diff
                             interval_ = (round (interv * 10 ^(6))) + delay :: Int
                         mapM_ ((flip doTask)  (job x) . (interval_  *)) [1..(hits x)]

