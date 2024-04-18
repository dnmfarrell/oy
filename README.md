oy
==
A stupid-simple POSIX-shell todo list app. Uses `sqlite3`.

Copyright © 2024 David Farrell

    oy [command|list]
    
    Commands
      a|add  <desc>                   add a task
      d|done <#>                      mark task as done
      e|edit <#> <desc>               edit task description
      h|help                          print this help
      l|list                          print open tasks & tasks done today
      o|open <#>                      mark task as open
      t|tag  <#> <set> <name> [cargo] tag this task
