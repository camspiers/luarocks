# Neovim Rocks

## Luarocks for lazy.nvim

### Example

Install `rocks` and build the `fzy` luarock.

```lua
{
  "camspiers/rocks"
  dependencies = {
    "rcarriga/nvim-notify", -- optional
  },
  opts = {
    rocks = { "fzy" }
  }
}
```
