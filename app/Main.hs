module Main where

import Time
import Jobs
import Data.Time

job_ :: UTCTime -> Job
job_ x = Job 123 x (Secs 20) 4 (putStrLn "Hello")

main :: IO ()
main =  do
           currentUTC <- getCurrentTime
           convertJobIntoTask (job_ currentUTC)
           x <- getLine
           putStrLn x

