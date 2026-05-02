return {
  {
    "mason-org/mason.nvim",
    cmd = "Mason",
    opts = {},
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "mason-org/mason.nvim" },
    opts = function()
      local has = function(bin)
        return vim.fn.executable(bin) == 1
      end

      local tools = {
        "stylua",
        "black",
      }

      if has("npm") then
        table.insert(tools, "prettier")
        table.insert(tools, "shfmt")
      end

      if has("gem") then
        table.insert(tools, "rubocop")
      end

      return {
        ensure_installed = tools,
        auto_update = false,
        run_on_start = true,
        start_delay = 3000,
      }
    end,
  },
  {
    "mason-org/mason-lspconfig.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason-org/mason.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      "neovim/nvim-lspconfig",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local has = function(bin)
        return vim.fn.executable(bin) == 1
      end

      local cmp_nvim_lsp = require("cmp_nvim_lsp")
      local capabilities = cmp_nvim_lsp.default_capabilities()

      local servers = {
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = {
                globals = { "vim" },
              },
              workspace = {
                checkThirdParty = false,
              },
              telemetry = {
                enable = false,
              },
            },
          },
        },
        marksman = {},
      }

      if has("npm") then
        servers.pyright = {}
        servers.bashls = {}
      end

      if has("gem") then
        servers.solargraph = {}
      end

      if has("npm") then
        local ts_server = #vim.api.nvim_get_runtime_file("lsp/ts_ls.lua", false) > 0 and "ts_ls" or "tsserver"
        servers[ts_server] = {}
      end

      local ensure_installed = vim.tbl_keys(servers)

      require("mason-lspconfig").setup({
        ensure_installed = ensure_installed,
        automatic_enable = false,
      })

      for server_name, server in pairs(servers) do
        server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
        vim.lsp.config(server_name, server)
        vim.lsp.enable(server_name)
      end
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = {
          { name = "nvim_lsp" },
          { name = "luasnip" },
        },
      })
    end,
  },
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    opts = {
      format_on_save = function(bufnr)
        local disable_filetypes = {
          c = true,
          cpp = true,
        }

        if disable_filetypes[vim.bo[bufnr].filetype] then
          return nil
        end

        return {
          timeout_ms = 1000,
          lsp_format = "fallback",
        }
      end,
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "ruff_format", "black" },
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        sh = { "shfmt" },
        bash = { "shfmt" },
        zsh = { "shfmt" },
        ruby = { "rubocop" },
      },
    },
  },
}
