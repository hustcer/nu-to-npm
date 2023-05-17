#!/usr/bin/env nu

def main [output: string] {

  if not (which typos | length) > 0 {
    print $'(ansi y)[WARN]: (ansi reset)`Typos` not installed, please install it by running `brew install typos-cli`...'
    exit 2
  }
  if $output != 'table' { typos .; exit 0 }
  typos . --format brief
    | lines
    | split column :
    | rename file line column correction
    | sort-by correction
    | update line {|l| $'(ansi pb)($l.line)(ansi reset)' }
    | update column {|l| $'(ansi pb)($l.column)(ansi reset)' }
    | upsert author {|l|
        let line = ($l.line | ansi strip)
        git blame $l.file -L $'($line),($line)' --porcelain | lines | get 1 | str replace 'author ' ''
      }
    | move author --before correction
}
