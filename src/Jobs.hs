module Jobs
    ( Job (..),
      convertJobIntoTask
    ) where

import Time
import Data.Time
import Control.Concurrent

data Job = Job { id :: Int, startDate :: UTCTime , interval :: Interval, hits :: Int, job :: IO () }

doTask :: Int -> IO () -> IO ()
doTask delay job = forkIO (threadDelay delay >> job ) >> return ()


-- this is the thread delay, calculated as (unit: microseconds)
-- (startTime - currentTime) + (interval * multiplier)
calculateDelay :: UTCTime -> UTCTime -> Interval -> Int -> [Int]
calculateDelay currentTime startDate interval hits
         = let intervalInSeconds = intervalToSecs interval 
               delay = fromEnum $  10^^(-6) * (diffUTCTime startDate currentTime)
               interval_ = (round (intervalInSeconds * 10 ^(6))) + delay :: Int
           in map (interval_ *) [0 .. hits]


-- actual Job to Concurrent Task(s) (conversion)
convertJobIntoTask :: Job -> IO () 
convertJobIntoTask x = do 
                         currentTime <- getCurrentTime
                         let timeDelays = calculateDelay currentTime (startDate x) (interval x) (hits x)
                         mapM_ ((flip doTask)  (job x)) timeDelays 
