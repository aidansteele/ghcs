import strtabs

proc optionsTable*(inputArgs: openarray[string]): StringTableRef =
  var idx = 0
  var tab = newStringTable()
  while idx < high(inputArgs):
    let prefixedName = inputArgs[idx]
    let name = prefixedName[2..high(prefixedName)]
    let value = inputArgs[idx+1]
    tab[name] = value
    idx += 2
  result = tab

when defined(testing):
  import unittest

  suite "options table tests":
    test "parse correctly":
      let args = @["--name", "value", "--key", "value2"]
      let tab = optionsTable(args)
      check(len(tab) == 2)
      check(tab["name"] == "value")
      check(tab["key"] == "value2")
