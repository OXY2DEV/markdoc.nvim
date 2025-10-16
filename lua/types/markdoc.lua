---@meta

---@class markdoc.rule
---
---@field [1] string A `tree-sitter` query.
---@field [2] fun(buffer: integer, match: string, TSNode: TSNode): nil Function to run on the captures of `query`.

