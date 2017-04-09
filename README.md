# tiny-simple-scheduler

This is an upgrade from the gist of a scheduler created here ([gist](https://gist.github.com/functor-soup/89cd5516382398179475fe2f4bcca34c))

This is supposed to be a dead simple scheduler. I doubt there is any 

shred of elegance here, except for the fact it is written in the most elegant language ever (Haskell)


# Status: Experimental, far from production level, still a work in progress
1. Jobs' status is now saved to db (sqlite)

## Todo
1. The state provided by database can also be used to restart jobs or portions of it ,if the application is restarted
2. Tests man, tests
3. stash thread ids of jobs to state monad to kill if necessary, and cleanup code with monadic abstractions like reader. state monad
