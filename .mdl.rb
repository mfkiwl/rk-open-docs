all

exclude_rule 'fenced-code-language' # Fenced code blocks should have a language specified
exclude_rule 'first-line-h1' # First line in file should be a top level header

exclude_rule 'MD013' # Line length
exclude_rule 'MD036' # Emphasis used instead of a header
exclude_rule 'MD010' # Hard tabs
rule 'MD029', :style => "ordered"
