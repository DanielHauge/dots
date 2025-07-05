vim.api.nvim_create_user_command("Calc", 'lua require("calculator").calculate()', { ["range"] = 1, ["nargs"] = 0 })

local function paste_image_to_docs()
  local image_name = os.date("screenshot-%Y%m%d-%H%M%S") .. ".png"
  local image_path = "docs/" .. image_name
  local full_path = vim.fn.getcwd() .. "/" .. image_path
  vim.fn.mkdir("docs", "p")
  local command = nil
  if vim.fn.has("mac") == 1 then
    command = string.format("pngpaste %s", full_path)
  elseif vim.fn.has("unix") == 1 then
    command = string.format("wl-paste --type image/png > %s", full_path)
  elseif vim.fn.has("win32") == 1 then
    command =
      string.format("powershell.exe Get-Clipboard -Format Image | Set-Content -Encoding Byte -Path %s", full_path)
  end

  if command then
    local image_write_code = os.execute(command)
    print("Executing command: " .. command)
    if image_write_code ~= 0 then
      print("Failed to write image to " .. full_path)
      return
    end
    local markdown = string.format("![%s](%s)", image_name, image_path)
    vim.api.nvim_put({ markdown }, "c", true, true)
  else
    print("Unsupported OS or missing clipboard tool.")
  end
end

vim.api.nvim_create_user_command("PasteImageToDocs", paste_image_to_docs, { ["nargs"] = 0 })
