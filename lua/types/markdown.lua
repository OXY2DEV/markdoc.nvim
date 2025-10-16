---@meta

---@alias markdoc.config.markdown.url_modifier
---| string
---| fun (description: string, destination: string): string

---@class markdoc.config.markdown.url_modifier.entry
---
---@field [1] string `Lua-pattern` to match.
---@field [2] markdoc.config.markdown.url_modifier


---@alias markdoc.config.markdown.use_link_refs
---| boolean
---| fun (description: string, destination: string): boolean


-- Configuration for `markdown`
---@class markdoc.config.markdown
---
---@field use_link_refs markdoc.config.markdown.use_link_refs Should *references* be used instead of `URLs`
---@field link_ref_format? string `Format string` used for the link references. Default: `{%d}`.
---@field link_url_modifiers markdoc.config.markdown.url_modifier.entry[] Changes the url based on a pattern

