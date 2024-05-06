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
      r|repeat <#> [off|schedule] ...         repeat task according to schedule(s)
      t|tag  [del] <#> <name> [name ...]      delete all and/or add tag(s) to a task
    
      Repeat Schedules
      A schedule is a string in the format YYYY-MM-DD [0-6] which is compared to
      the current local date and day of the week. If the comparison succeeds, any
      "done" task is flipped back to "open". The wildcard % may also be used.
      
        %          every day
        %-07-04 %  every July 4th
        % 1        every Monday
      
      The repeat command accepts multiple schedules for a task, so to repeat task
      50 on Saturdays and Sundays:
      
        oy r 50 '% 6' '% 0'
