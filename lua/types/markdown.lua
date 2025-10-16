---@meta

-- Configuration for `markdown`
---@class markdoc.config.markdown
---
---@field use_link_refs markdown.use_link_refs Should *references* be used instead of `URLs`
---@field link_ref_format? string `Format string` used for the link references. Default: `{%d}`.
---@field link_url_modifiers markdown.url_modifier.entry[] Changes the url based on a pattern
---
---@field block_quotes markdoc.config.markdown.block_quotes
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

