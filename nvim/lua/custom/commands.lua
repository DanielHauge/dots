vim.api.nvim_create_user_command("Calc", 'lua require("calculator").calculate()', { ["range"] = 1, ["nargs"] = 0 })

-- ROS 2 Commands
vim.api.nvim_command [[
  command! ColconBuild :! colcon build --symlink-install --cmake-args -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
]]

-- Test
vim.api.nvim_command [[
  command! ColconTest :! colcon test
]]
vim.api.nvim_command [[
  command! -nargs=1 ColconTestSingle :! colcon test --packages-select <args>
]]
vim.api.nvim_command [[
  command! ColconTestResult :! colcon test-result --all
]]
