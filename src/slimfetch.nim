import std/[os, terminal, parsecfg, strutils, sequtils, osproc]
 
proc getUptime(): string =
  let uptimeFile = "/proc/uptime".open.readLine.split(".")[0].parseUInt
  if uptimeFile div 3600 == 0:
    return $(uptimeFile mod 3600 div 60) & "m"
  else:
    return $(uptimeFile div 3600) & "h " & $(uptimeFile mod 3600 div 60) & "m"

proc getPackageCount(): string =
  var packagecount = "Unknown"
  case "/etc/os-release".loadConfig.getSectionValue("", "ID"):
    of "arch": packagecount = $("/var/lib/pacman/local".walkDir(relative = true).toSeq.len - 1)
    of "artix": packagecount = $("/var/lib/pacman/local".walkDir(relative = true).toSeq.len - 1)
    of "manjaro": packagecount = $("/var/lib/pacman/local".walkDir(relative = true).toSeq.len - 1)
    of "fedora": packagecount = $(osproc.execCmdEx("rpm -qa")[0].split("\n").len - 1)
    of "gentoo": packagecount = $(osproc.execCmdEx("ls -d /var/db/pkg/*/*| cut -f5- -d/")[0].split("\n").len - 1)
    of "void": packagecount = $(osproc.execCmdEx("xbps-query -l")[0].split("\n").len - 1)
    of "debian": packagecount = $(osproc.execCmdEx("dpkg -l")[0].split("\n").len - 1)
    of "ubuntu": packagecount = $(osproc.execCmdEx("dpkg -l")[0].split("\n").len - 1) # gross ubuntu
    of "pop": packagecount = $(osproc.execCmdEx("dpkg -l")[0].split("\n").len - 1)

  return packagecount

let memUsed = execCmdEx("free -h --giga | grep Mem: | awk '{ print $3 }'")[0].split("\n")[0]
let memTotal = execCmdEx("free -h --giga | grep Mem: | awk '{ print $2 }'")[0].split("\n")[0]


stdout.styledWrite(styleBright,
  "╭────────────╮\n",
  "│ ", fgRed, " ", fgDefault, "user     │ ", fgRed, getEnv("USER"), fgDefault, "\n",
  "│ ", fgYellow, " ", fgDefault, "hostname │ ", fgYellow, "/etc/hostname".open.readLine, fgDefault, "\n",
  "│ ", fgGreen, " ", fgDefault, "distro   │ ", fgGreen, "/etc/os-release".loadConfig.getSectionValue("", "PRETTY_NAME"), fgDefault, "\n",
  "│ ", fgCyan, " ", fgDefault, "kernel   │ ", fgCyan, "Linux ", "/proc/version".open.readLine.split(" ")[2], fgDefault, "\n",
  "│ ", fgBlue, " ", fgDefault, "uptime   │ ", fgBlue, getUptime(), fgDefault, "\n",
  "│ ", fgMagenta, " ", fgDefault, "shell    │ ", fgMagenta, getEnv("SHELL").split("/")[^1], fgDefault, "\n",
  "│ ", fgRed, " ", fgDefault, "packages │ ", fgRed, getPackageCount(), fgDefault, "\n",
  "│ ", fgYellow, " ", fgDefault, "memory   │ ", fgYellow, memUsed, fgDefault, " / ", fgYellow, memTotal, fgDefault, "\n",
  "├────────────┤", "\n",
  "│ ", fgWhite, " ", fgDefault, "colors   │ ", resetStyle, fgBlack, "● ", fgRed, "● ", fgGreen, "● ", fgYellow, "● ", fgBlue, "● ", fgMagenta, "● ", fgCyan, "● ", fgWhite, "● ", fgDefault, styleBright, "\n",
  "╰────────────╯ ", fgBlack, "● ", fgRed, "● ", fgGreen, "● ", fgYellow, "● ", fgBlue, "● ", fgMagenta, "● ", fgCyan, "● ", fgWhite, "● ", fgDefault, resetStyle, "\n"
)