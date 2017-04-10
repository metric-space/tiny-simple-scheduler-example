
module Main where

import Time
import Jobs
import SubJobs
import Data.Time

jobx :: UTCTime -> Job
jobx x = Job 1234 x (Secs 20) 4 (putStrLn "Hello")

main :: IO ()
main =  do
           currentUTC <- getCurrentTime
           convertJobIntoTask "test.db" (jobx currentUTC)
           x <- getLine
           putStrLn x

