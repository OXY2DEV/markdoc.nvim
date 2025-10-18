---@meta

-- Configuration for `markdown`
---@class markdoc.config.markdown
---
---@field use_link_refs markdown.use_link_refs Should *references* be used instead of `URLs`
---@field link_ref_format? string `Format string` used for the link references. Default: `{%d}`.
---@field link_url_modifiers markdown.url_modifier.entry[] Changes the url based on a pattern
---
---@field heading_ratio integer[] Ratio for the amount of space a heading text & it's tags should take. Default: `{ 6, 4 }`.
---
---@field block_quotes markdoc.config.markdown.block_quotes
---@field code_blocks markdoc.config.markdown.code_blocks
---@field hr? string Text used to show `horizontal rules`
---@field list_items markdoc.config.markdown.list_items
---@field tables markdoc.config.markdown.tables
---@field tags markdoc.config.markdown.tags


---@alias markdown.url_modifier
---| string
---| fun (description: string, destination: string): string

---@class markdown.url_modifier.entry
---
---@field [1] string `Lua-pattern` to match.
---@field [2] markdown.url_modifier


---@alias markdown.use_link_refs
---| boolean
---| fun (description: string, destination: string): boolean


---@class markdoc.config.markdown.block_quotes
---
---@field default markdown.block_quotes.opts
---@field [string] markdown.block_quotes.opts


---@class markdown.block_quotes.opts
---
---@field border? string
---@field icon? string
---@field preview? string


---@class markdoc.config.markdown.tags
---
---@field default? string[]
---@field [string] string[]


---@class markdoc.config.markdown.code_blocks
---
---@field indentation? string Text used for indenting code block.
---@field fallback_language? string Fallback language for `code_blocks` without a language.


---@class markdoc.config.markdown.list_items
---
---@field marker_plus? string Text used to replace `+` markers.
---@field marker_minus? string Text used to replace `-` markers.
---@field marker_star? string Text used to replace `*` markers.
---
---@field marker_dot? string Text used to replace `%d+.` markers. May contain `%d` to add the marker number.
---@field marker_parenthesis? string Text used to replace `%d+)` markers. May contain `%d` to add the marker number.


---@class markdoc.config.markdown.tables
---
---@field max_col_size? integer Maximum width of a table `column`.
---@field preserve_whitespace? boolean Should **leading** & **trailing** whitespaces be preserved?
---@field default_alignment? "left" | "center" | "right" Default *text alignment* of table cells.
---@field borders? markdown.tables.border Table border.


-- Border elements for the table.
---@class markdown.tables.border
---
---@field top markdown.tables.border.decoration
---@field bottom markdown.tables.border.decoration
---
---@field separator markdown.tables.border.decoration
---@field row_separator markdown.tables.border.decoration
---
---@field header markdown.tables.border.row
---@field row markdown.tables.border.row


---@class markdown.tables.border.decoration
---
---@field [1] string Left border
---@field [2] string Character used to make creating columns.
---@field [3] string Right border
---
---@field [4] string Column separator.


---@class markdown.tables.border.row
---
---@field [1] string Left border
---@field [2] string Column separator.
---@field [3] string Right border

