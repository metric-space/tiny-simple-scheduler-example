# tiny-simple-scheduler

This is an upgrade from the gist of a scheduler created here ([gist](https://gist.github.com/functor-soup/89cd5516382398179475fe2f4bcca34c))

This is supposed to be a dead simple scheduler. I doubt there is any 

shred of elegance here, except for the fact it is written in the most elegant language ever (Haskell)


# Status: Experimental, far from production level, still a work in progress

## Todo
1. Ids for jobs (thread ids should suffice?)
2. Save status of jobs to database, and on complete mark complete
3. The state provided by database can also be used to restart jobs or portions of it ,if the application is restarted
4. Tests man, tests
5. stash thread ids of jobs to writer monad and  db, to kill if necessary
