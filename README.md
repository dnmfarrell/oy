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
      a|add  <desc>                      add a task
      c|compact                          delete all intermediate task data
      d|done <#> [# ...]                 mark task(s) as done
      e|edit <#> <desc>                  edit task description
      h|help                             print this help
      l|list [#]                         print open & tasks done today or -# days
                                         ago
      o|open <#> [# ...]                 re-open task(s)
      p|prop <#> <set> <name> [cargo]    add/update a property of a task
      t|tag  [del] <#> <name> [name ...] delete all and/or add tag(s) to a task
