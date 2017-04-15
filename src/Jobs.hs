module Jobs
  ( Job(..)
  , calculateDelay
  ) where

import Control.Concurrent
import Data.Time
import Time

data Job a = Job
  { id :: Int
  , startDate :: UTCTime
  , interval :: Interval
  , hits :: Int
  , job :: IO a
  }

-- this is the thread delay, calculated as (unit: microseconds)
-- (startTime - currentTime) + (interval * multiplier)
calculateDelay :: UTCTime -> UTCTime -> Interval -> Int -> [Int]
calculateDelay currentTime startDate interval hits =
  let intervalInSeconds = intervalToSecs interval
      delay = fromEnum $ 10 ^^ (-6) * (diffUTCTime startDate currentTime)
      interval_ = (round (intervalInSeconds * 10 ^ (6))) + delay :: Int
  in map (interval_ *) [0 .. hits]
