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
                "^toc$": [ "markdoc.nvim-toc", "markdoc.nvim-generic.toc" ]
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

