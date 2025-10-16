---@meta

---@class markdoc.rule
---
---@field [1] string A `tree-sitter` query.
---@field [2] fun(buffer: integer, match: string, TSNode: TSNode): nil Function to run on the captures of `query`.


---@class markdoc.config
---
---@field generic markdoc.config.generic
---@field markdown markdoc.config.markdown


-- Generic options for controlling help file generation.
---@class markdoc.config.generic
---
---@field name? string Name of help file.
---@field tag? string Name of `help tag` for this file..
---
---@field desc? string Short description to show at top.
---@field spacing? integer[] *Ratio* between the spaces taken by `tag` & `name`. Default: `[ 4, 6 ]`.
---
---@field author? string[] Author(s) of the help file.
---@field version? string Version string.
---@field last_modified? boolean Should the last modification date be shown?
---
---@field textwidth? integer Text width of the help file.
---@field indent? integer Number of spaces to use for indentation.
---
---@field toc markdoc.config.generic.toc


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

