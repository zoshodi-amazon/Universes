#!/usr/bin/env nu

# Terminal audio visualizer - plays audio + draws live level bars
def main [input: string]: nothing -> nothing {
  let width: int = 50

  let lines = (^ffmpeg -i $input -af "astats=metadata=1:reset=1,ametadata=print:key=lavfi.astats.Overall.RMS_level" -f null - e>| lines)

  for line in $lines {
    if ($line | str contains "RMS_level") {
      let val: string = ($line | split row "=" | last | str trim)
      if $val != "-inf" {
        let db: float = ($val | into float)
        let raw: float = (($db + 60) / 60 * $width)
        let level: int = (if $raw < 0 { 0 } else if $raw > $width { $width } else { $raw | math round | into int })
        let bar: string = (0..<$width | each {|i|
          if $i < $level { "█" } else { " " }
        } | str join "")
        print -n $"\r\e[36m▕($bar)▏\e[33m ($val) dB\e[0m  "
      }
    }
  }
  print ""
}
