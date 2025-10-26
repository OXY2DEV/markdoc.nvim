---@meta

---@class markdoc.rule
---
---@field [1] string A `tree-sitter` query.
---@field [2] fun(buffer: integer, match: string, TSNode: TSNode): nil Function to run on the captures of `query`.


-- Generic options for controlling help file generation.
---@class markdoc.config.generic
---
---@field filename? string Name of help file.
---@field relative_path? boolean Is the file oath relative to the `source` file? Gets set to `false`, if `filename` starts with `~`.
---@field force_write? boolean Should `:write!` be used instead of `:write`?
---@field winopts? table Window options for the previewer.
---
---@field textwidth? integer Text width of the help file.
---@field indent? integer Number of spaces to use for indentation.
---
---@field header markdoc.config.generic.header
---@field links markdoc.config.generic.links
---@field images markdoc.config.generic.links
---@field toc markdoc.config.generic.toc


---@class markdoc.config.generic.header
---
---@field enabled? boolean
---
---@field tag? string Name of `help tag` for this file..
---@field desc? string Short description to show at top.
---
---@field author? string[] Author(s) of the help file.
---@field version? string Version string.
---@field last_modified? boolean Should the last modification date be shown?


---@class markdoc.config.generic.links
---
---@field enabled? boolean
---@field desc? string Short description to show at top of link section.
---
---@field list_marker? string
---@field url_format? string


---@class markdoc.config.generic.toc
---
---@field enabled? boolean
---
---@field heading? string
---@field heading_level? integer
---
---@field entries generic.toc.entry[]


---@class generic.toc.entry
---
---@field text string
---@field tag string

