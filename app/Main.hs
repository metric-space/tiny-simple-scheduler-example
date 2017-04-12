{-# LANGUAGE OverloadedStrings #-}

module Main where

import Time
import Jobs
import SubJobs
import DB
import Data.Time
import Database.SQLite.Simple


jobx :: UTCTime -> Job
jobx x = Job 1234 x (Secs 20) 4 (putStrLn "Hello")

main :: IO ()
main =  do
           conn <- open "test.db"
           currentUTC <- getCurrentTime
           _ <- convertJobIntoTask (DBDetails conn "scheduler") (jobx currentUTC)
           x <- getLine
           putStrLn x

