-- Copyright 2024 The zb Authors
-- SPDX-License-Identifier: MIT

---@param system string
---@return boolean
local function isWindows(system)
  -- TODO(someday): Use string module to check suffix.
  return system == "x86_64-windows" or system == "aarch64-windows"
end

local function forSystem(_, currentSystem)
  local drvName <const> = "hello.lua"
  local content <const> = [[return "Hello, World!"]].."\n"
  local drv
  if isWindows(currentSystem) then
    drv = derivation {
      name = drvName;
      builder = [[C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe]];
      args = {
        "-Command",
        [[${env:content} | Out-File -NoNewline -Encoding ascii -FilePath ${env:out}]],
      };
      content = content;
      system = currentSystem;
    }
  else
    drv = derivation {
      name = drvName;
      builder = "/bin/sh";
      args = {
        "-c",
        [[echo -n "$content" > "$out"]],
      };
      content = content;
      system = currentSystem;
    }
  end

  return dofile(drv.out)
end

local t = {}
setmetatable(t, {
  __index = forSystem;
})
return t
