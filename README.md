oy
==
A stupid-simple POSIX-shell todo list app. Uses SQLite.

Copyright © 2024 David Farrell

Dependencies
------------
- SQLite v3.31 or higher
- The `readlink` utility 

Usage
-----

    oy [command|list]
    
    Commands
      a|add  <desc> [desc ...]                add task(s)
      compact                                 delete all intermediate task data
      d|done <#> [# ...]                      mark task(s) as done
      e|edit <#> <desc>                       edit task description
      h|help                                  print this help
      l|list [-d #] [-p name:value] [-t name] print tasks
      o|open <#> [# ...]                      re-open task(s)
      p|prop <#> <set> <name> [cargo]         add/update a property of a task
      r|repeat <#> [off|schedule]             repeat task according to a schedule
      t|tag  [del] <#> <name> [name ...]      delete all and/or add tag(s) to a task
    
      Repeat Schedules
      A schedule comprises of up to three strings in the format:
     
    	YYYY-MM-DD Date pattern
    	0123456    Days of the week
    	12345L     Nth day of the month ("L" = last)
    
    	The wildcard % may also be used:
      
        %          Every day
        %-07-04    July 4th
        % 1        Mondays
    		% 12345    Mondays-Fridays
    		% 5 L      The last Friday of the month
    		% 3 1L     The first and last Wednesday of the month
