{-# LANGUAGE OverloadedStrings #-}

module Main where

import Data.Time
import Database.SQLite.Simple
import Jobs
import SubJobs
import Time

jobx :: UTCTime -> Job ()
jobx x = Job 1234 x (Secs 20) 4 (putStrLn "Hello")

main :: IO ()
main = do
  currentUTC <- getCurrentTime
  execSubJobs . convertJobIntoSubJobs currentUTC $ (jobx currentUTC)
  --x <- getLine
  --putStrLn x
  return ()
