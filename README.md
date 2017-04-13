# tiny-simple-scheduler

This is an upgrade from the gist of a scheduler created here ([gist](https://gist.github.com/functor-soup/89cd5516382398179475fe2f4bcca34c))

This is supposed to be a dead simple scheduler. I doubt there is any 

shred of elegance here, except for the fact it is written in the most elegant language ever (Haskell)


# Status: Experimental, far from production level, still a work in progress
1. Jobs' status is now saved to db (sqlite)
2. Thread Id's of threads are now made available to the scheduler of jobs

## Todo
1. Jobs that are scheduled to execute in times prio to time of execution should fail and be logged somewhere
2. Tests man, tests

