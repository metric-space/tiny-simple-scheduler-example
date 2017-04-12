{-# LANGUAGE OverloadedStrings #-}

module SubJobs
  ( convertJobIntoTask
  ) where

import Control.Applicative
import Control.Concurrent
import Control.Monad.IO.Class
import Control.Monad.Trans.Reader
import DB
import qualified Data.Text as T
import Data.Time
import Database.SQLite.Simple
import Database.SQLite.Simple.FromRow
import Jobs
import Prelude hiding (id)

data SubJob = SubJob
  { jobId :: Int
  , delay :: Int
  , startDate_ :: T.Text
  , hitNo :: Int
  , job_ :: ReaderT DBDetails IO ()
  , threadId :: Maybe ThreadId
  , status :: T.Text
  }

instance ToRow SubJob where
  toRow (SubJob id_ delay startDate hitNo job threadId status) =
    toRow (id_, startDate, hitNo, status)

superChargeJob :: Int -> Int -> IO () -> ReaderT DBDetails IO ()
superChargeJob jobId hitNo job = do
  liftIO job
  details <- ask
  let conn = connection details
      updateQuery = statusUpdateQuery (tableName details)
  liftIO $
    executeNamed
      conn
      updateQuery
      [":str" := ("completed" :: T.Text), ":id" := jobId, ":hit" := hitNo]

convertJobIntoSubJobs :: UTCTime -> Job -> [SubJob]
convertJobIntoSubJobs currentTime x =
  let timeDelays =
        calculateDelay currentTime (startDate x) (interval x) (hits x)
      zippedDelays = zip [1 ..] timeDelays
      newJob = (\c -> superChargeJob (id x) c (job x))
  in map
       (\(i, z) ->
          SubJob
            (id x)
            z
            (T.pack . show $ startDate x)
            i
            (newJob i)
            Nothing
            "not-executed")
       zippedDelays

execSubJob :: SubJob -> ReaderT DBDetails IO SubJob
execSubJob x = do
  details <- ask
  let conn = connection details
      insertQuery_ = insertQuery $ tableName details
      jobToExec = runReaderT (job_ x) details
  liftIO $ execute conn insertQuery_ x
  threadId <- liftIO $ doTask (delay x) jobToExec
  let mSubJob = x {threadId = Just threadId} -- work needs to be done here
  return mSubJob

execSubJobs :: [SubJob] -> ReaderT DBDetails IO [SubJob]
execSubJobs subJobs = mapM execSubJob subJobs
 -- actual Job to Concurrent Task(s) (conversion)

convertJobIntoTask :: DBDetails -> Job -> IO [SubJob]
convertJobIntoTask details x = do
  currentTime <- getCurrentTime
  let subjobs = convertJobIntoSubJobs currentTime x
  runReaderT (execSubJobs subjobs) details
