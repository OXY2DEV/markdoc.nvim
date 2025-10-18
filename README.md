<!--markdoc
    {
        "generic": {
            "filename": "doc/markdoc.nvim.txt",
            "force_write": true,
            "header": {
                "desc": "Tree-sitter based `Markdown -> Vimdoc` converter for Neovim",
                "tag": "markdoc.nvim"
            }
        },
        "markdown": {
            "tags": {
                "Features$": [ "markdoc.nvim-features" ],

                "^generic$": [ "markdoc.nvim-generic" ],
                "^filename$": [ "markdoc.nvim-filename", "markdoc.nvim-generic.filename" ],
                "^force_write$": [ "markdoc.nvim-force_write", "markdoc.nvim-generic.force_write" ],
                "^winopts$": [ "markdoc.nvim-winopts", "markdoc.nvim-generic.winopts" ],
                "^textwidth$": [ "markdoc.nvim-textwidth", "markdoc.nvim-generic.textwidth" ],
                "^indent$": [ "markdoc.nvim-indent", "markdoc.nvim-generic.indent" ],
                "^header$": [ "markdoc.nvim-header", "markdoc.nvim-generic.header" ],
                "^links$": [ "markdoc.nvim-links", "markdoc.nvim-generic.links" ],
                "^images$": [ "markdoc.nvim-images", "markdoc.nvim-generic.images" ],
                "^toc$": [ "markdoc.nvim-toc", "markdoc.nvim-generic.toc" ],

                "^markdown$": [ "markdoc.nvim-markdown" ],
                "^use_link_refs$": [ "markdoc.nvim-use_link_refs", "markdoc.nvim-markdown.use_link_refs" ],
                "^link_ref_format$": [ "markdoc.nvim-link_ref_format", "markdoc.nvim-markdown.link_ref_format" ],
                "^link_url_modifiers$": [ "markdoc.nvim-link_url_modifiers", "markdoc.nvim-markdown.link_url_modifiers" ],
                "^heading_ratio$": [ "markdoc.nvim-heading_ratio", "markdoc.nvim-markdown.heading_ratio" ],
                "^block_quotes$": [ "markdoc.nvim-block_quotes", "markdoc.nvim-markdown.block_quotes" ],
                "^code_blocks$": [ "markdoc.nvim-code_blocks", "markdoc.nvim-markdown.code_blocks" ],
                "^hr$": [ "markdoc.nvim-hr", "markdoc.nvim-markdown.hr" ],
                "^tables$": [ "markdoc.nvim-tables", "markdoc.nvim-markdown.tables" ],
                "^tags$": [ "markdoc.nvim-tags", "markdoc.nvim-markdown.tags" ]
            }
        }
    }
-->
<!--markdoc_ignore_start-->
# 🎇 markdoc.nvim

Tree-sitter based `markdown` to `vimdoc` converter for Neovim.
<!--markdoc_ignore_end-->

<div align="center">
    <img src="htllo">
</div>

## 🪄 Features

- Basic `markdown` syntax support.
- `Inline HTML` support.
- *Aligned* paragraph(via `<p align=""></p>` or `<div align=""></div>`)
- Preserves whitespace.
- Extended syntax support(e.g. Callouts).
- Custom Table of contents generator.
- Custom file header support(with support for `version`, `author`, `date modified`).
- Fully customizable.
- Ability to configure per file(using `JSON`).

## 🧭 Requirements

- `tree-sitter-markdown`.
- `tree-sitter-markdown_inline`.
- `tree-sitter-html`(for inline `HTML`).

>[!IMPORTANT]
> By default, `callouts` use `nerd font` characters. You can change this in the config to use normal text instead.

## 📦 Installation

### 🧩 Vim-plug

```vim
Plug "OXY2DEV/markdoc.nvim"
```

### 💤 lazy.nvim

```lua
{
    "OXY2DEV/markdoc.nvim"
},
```

```lua
return {
    "OXY2DEV/markdoc.nvim"
};
```

### 🦠 mini.deps

```lua
local MiniDeps = require("mini.deps");

MiniDeps.add({
    source = "OXY2DEV/markdoc.nvim",
})
```

### 🌒 rocks.nvim

>[!WARNING]
> `luarocks package` may sometimes be a bit behind `main`.

```vim
:Rocks install markdoc.nvim
```

### 📥 GitHub release

Tagged releases can be found in the [release page](https://github.com/OXY2DEV/markdoc.nvim/releases).

>[!NOTE]
> `Github releases` may sometimes be slightly behind `main`.

## 🎇 Usage

There is a single command,

```vim
:Doc
```

When called **without arguments**, it runs on the **current buffer**.

When called with an argument,

```vim
:Doc README.md
```

It converts given file(s). It can be called with multiple files.

```vim
:Doc README.md test.md
```

## 🔧 Configuration

The plugin can be set-up by using the `setup()` function.

```lua
require("markdoc").setup({
    markdown = {
        code_blocks = {
            fallback_language = "vim",
            indentation = "\t"
        },
    }
});
```

The following options are supported,

### generic

Type: `markdoc.config.generic`

Generic configuration options. These are,

#### filename

Type: `string`

Name of the file to save to.

>[!NOTE]
> This is relative to the current working directory!

#### force_write

Type: `boolean`

When `true`, use `:write!` instead of `:write`.

#### winopts

Type: `vim.api.keyset.win_config`

Options passed to `nvim_open_win()` for showing file preview.

#### textwidth

Type: `integer`

Same as 'textwidth'(`:h 'textwidth'`). Used for text wrapping & setting the modeline.

Used by options that use ratios.

>[!NOTE]
> This will fallback to 80 by default.

#### indent

Type: `integer`

Unused.

#### header

Type: `markdoc.config.generic.header`

Configuration for `file header`.

```lua
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
```

#### links

Type: `markdoc.config.generic.links`

Configuration for `link reference` section.

```lua
---@class markdoc.config.generic.links
---
---@field enabled? boolean
---@field desc? string Short description to show at top of link section.
---
---@field list_marker? string
---@field url_format? string
```

#### images

Type: `markdoc.config.generic.links`

Configuration for `image reference` section. Same as above.

#### toc

Type: `markdoc.config.generic.toc`

Configuration for `table of contents` section.

```lua
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
```

### markdown

Markdown options.

```lua
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
```

#### use_link_refs

Type: `markdown.use_link_refs`

```lua
---@alias markdown.use_link_refs
---| boolean
---| fun (description: string, destination: string): boolean
```

Controls whether references be used instead of the URL.

```vimdoc
With `use_link_refs = true`.

Link {1}

With `use_link_refs = true`.

Link www.example.com
```

#### link_ref_format

Type: `string`

Text used for formatting the reference of a link. Default is `{%d}`.

#### link_url_modifiers

Type: `markdown.url_modifier.entry[]`

```lua
---@class markdown.url_modifier.entry
---
---@field [1] string `Lua-pattern` to match.
---@field [2] markdown.url_modifier

---@alias markdown.url_modifier
---| string
---| fun (description: string, destination: string): string
```

Modifies URLs. Useful for section links(e.g. `#link_url_modifiers`).

#### heading_ratio

Type: `[ integer, integer ]`

Ratio of spaces taken by heading text & the tags. Default is `{ 6, 4 }`.

>[!NOTE]
> This may not be respected if a tag is too long.

#### block_quotes

Type: `markdoc.config.markdown.block_quotes`

```lua
---@class markdown.block_quotes.opts
---
---@field border? string
---@field icon? string
---@field preview? string


---@class markdoc.config.markdown.block_quotes
---
---@field default markdown.block_quotes.opts
---@field [string] markdown.block_quotes.opts
markdown = {
    block_quotes = {
        ---|fS

        default = {
            border = "▋",
        },

        ["ABSTRACT"] = {
            preview = "󱉫 Abstract",
            icon = "󱉫",
        },

        ["NOTE"] = {
            preview = "󰋽 Note",
            icon = "󰋽",
        },

        -- ...

        ---|fE
    },
}
```

Configuration for `block quotes` & `callouts`.

#### code_blocks

Type: `markdoc.config.markdown.code_blocks`

```lua
---@class markdoc.config.markdown.code_blocks
---
---@field indentation? string Text used for indenting code block.
---@field fallback_language? string Fallback language for `code_blocks` without a language.
```

Configuration for `code blocks`.

#### hr

Type: `string`

Text representing a `horizontal rule`.

```lua
markdown = {
    hr = " ╶" .. string.rep("─", 76) .. "╴ ",
}
```

#### list_items

Type: `markdoc.config.markdown.list_items`

```lua
---@class markdoc.config.markdown.list_items
---
---@field marker_plus? string Text used to replace `+` markers.
---@field marker_minus? string Text used to replace `-` markers.
---@field marker_star? string Text used to replace `*` markers.
---
---@field marker_dot? string Text used to replace `%d+.` markers. May contain `%d` to add the marker number.
---@field marker_parenthesis? string Text used to replace `%d+)` markers. May contain `%d` to add the marker number.
markdown = {
    list_items = {
        marker_plus = "•",
        marker_dot = "%d:"
    }
}
```

#### tables

Type: `markdoc.config.markdown.tables`

```lua
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


---@class markdoc.config.markdown.tables
---
---@field max_col_size? integer Maximum width of a table `column`.
---@field preserve_whitespace? boolean Should **leading** & **trailing** whitespaces be preserved?
---@field default_alignment? "left" | "center" | "right" Default *text alignment* of table cells.
---@field borders? markdown.tables.border Table border.
markdown = {
    tables = {
        max_col_size = 20,
        preserve_whitespace = true,
        default_alignment = "left",

        borders = {
            header = { "│", "│", "│" },
            row = { "│", "│", "│" },

            separator = { "├", "─", "┤", "┼" },
            row_separator = { "├", "─", "┤", "┼" },

            top = { "╭", "─", "╮", "┬" },
            bottom = { "╰", "─", "╯", "┴" },
        },
    },
}
```

#### tags

Type: `markdoc.config.markdown.tags`

```lua
---@class markdoc.config.markdown.tags
---
---@field default? string[]
---@field [string] string[]
markdown = {
    tags = {
        ["^textwidth$"]: { "markdoc.nvim-textwidth", "markdoc.nvim-generic.textwidth" },
    },
}
```

Maps heading text to a list of `tags`.

