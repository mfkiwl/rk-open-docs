all

exclude_rule 'fenced-code-language' # Fenced code blocks should have a language specified
exclude_rule 'first-line-h1' # First line in file should be a top level header

exclude_rule 'MD010' # Hard tabs
exclude_rule 'MD013' # Line length
exclude_rule 'MD033' # Inline HTML
exclude_rule 'MD036' # Emphasis used instead of a header
rule 'MD007', :indent => 4 # Unordered list indentation
rule 'MD009', :br_spaces => 2 # Trailing spaces
rule 'MD024', :allow_different_nesting => true # header duplication under different nesting is allowed
rule 'MD029', :style => "ordered" # Ordered list item prefix
