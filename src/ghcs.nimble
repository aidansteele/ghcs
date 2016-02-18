# Package

version       = "0.1.0"
author        = "Aidan Steele"
description   = "Shiny GitHub commit statuses for everyone"
license       = "MIT"

bin           = @["ghcs"]
skipDirs      = @["js"]

# Dependencies

requires "nim >= 0.12.1"

