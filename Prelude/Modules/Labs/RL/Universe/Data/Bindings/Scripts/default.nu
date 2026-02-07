#!/usr/bin/env nu
# Data binding: DataSpec -> Table
# Preview dataset, show schema, list providers

def main [config_path: string]: nothing -> nothing {
  let cfg: record = (open $config_path)
  let provider: string = $cfg.data.provider
  let data_dir: string = $cfg.data.dataDir

  print (gum style --border normal --padding "0 1" $"Data Provider: ($provider)")

  match $provider {
    "csv" => {
      let file: string = $"($data_dir)/sample.csv"
      if ($file | path exists) {
        let df = (open $file)
        let rows: int = ($df | length)
        let cols = ($df | columns)
        print $"  File: ($file)"
        print $"  Rows: ($rows)"
        print $"  Columns: ($cols | str join ', ')"
        print ""
        print (gum style --foreground 212 "Preview (first 10 rows):")
        $df | first 10 | table | print
      } else {
        print (gum style --foreground 196 $"No data found at ($file). Run: just init")
      }
    }
    _ => {
      print $"  Tickers: ($cfg.data.tickers | str join ', ')"
      print $"  Interval: ($cfg.data.interval)"
      print $"  Range: ($cfg.data.startDate) to ($cfg.data.endDate)"
      print $"  Indicators: ($cfg.data.indicators | str join ', ')"
      print ""
      print "Run: just download  (to fetch data from provider)"
    }
  }
}

def "main download" [config_path: string]: nothing -> nothing {
  let cfg: record = (open $config_path)
  print (gum style --border normal --padding "0 1" $"Downloading from ($cfg.data.provider)")
  (^rl data download
    --provider $cfg.data.provider
    --tickers ($cfg.data.tickers | str join ",")
    --interval $cfg.data.interval
    --start $cfg.data.startDate
    --end $cfg.data.endDate
    --output $cfg.data.dataDir)
}
