{-# LANGUAGE OverloadedStrings #-}
module SubJob
    ( 
      convertJobIntoTask
    ) where


import           Control.Applicative
import qualified Data.Text as T
import           Database.SQLite.Simple
import           Database.SQLite.Simple.FromRow
import           Jobs
import           Data.Time
import Prelude hiding (id)

data SubJob = SubJob {jobId :: Int, delay :: Int, startDate_ :: T.Text, hitNo :: Int, job_ :: IO (), threadId :: Int, status :: T.Text}

instance ToRow SubJob where
  toRow (SubJob id_ delay startDate hitNo job threadId status) = toRow (id_, startDate, hitNo, status)

statusUpdateQuery :: Query
statusUpdateQuery = "UPDATE scheduler SET status = :str WHERE jobId = :id AND hitNo = :hit" 


superChargeJob :: Connection -> Int -> Int -> IO () -> IO () 
superChargeJob conn jobId hitNo job = job >>
                                      executeNamed conn statusUpdateQuery [":str" := ("completed" :: T.Text), ":id" := jobId, ":hit" := hitNo]
 
                                         

convertJobIntoSubJobs :: Connection -> UTCTime -> Job -> [SubJob]
convertJobIntoSubJobs conn currentTime  x =  let timeDelays = calculateDelay currentTime (startDate x) (interval x) (hits x)
                                                 zippedDelays = zip [1..] timeDelays   
                                                 newJob = (\c -> superChargeJob conn (id x) c (job x))
                                             in map (\(i,z) -> SubJob (id x) z (T.pack . show $ startDate x) i (newJob i) 0 "not-executed" ) zippedDelays


execSubJob :: Connection -> SubJob -> IO ()
execSubJob db x = do
                    execute db "INSERT INTO scheduler (jobId, startDate, hitNo, status) VALUES (?,?,?,?)" x
                    threadId <- doTask  (delay x) (job_ x)
                    --let mSubJob = x { threadId = threadId } -- work needs to be done here
                    return ()
                    
execSubJobs :: Connection -> [SubJob] -> IO ()
execSubJobs db  = mapM_ (execSubJob db) 
                      
                       
 -- actual Job to Concurrent Task(s) (conversion)
convertJobIntoTask ::String -> Job -> IO () 
convertJobIntoTask dbname x = do 
                               conn <- open dbname
                               currentTime <- getCurrentTime
                               let subjobs = convertJobIntoSubJobs conn currentTime x
                               execSubJobs conn subjobs                      
                          
                             



