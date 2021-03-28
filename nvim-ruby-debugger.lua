local socket = require("socket")
local host, port = "127.0.0.1", 1234
local tcp = assert(socket.tcp())

function place_sign()
   vim.cmd("sign define piet text=>> texthl=Search")
   vim.cmd("sign place 2 group=ga line=5 name=piet file=" .. vim.api.nvim_eval('expand("%:p")'))
end

function start_debug()
   buffers = vim.api.nvim_list_bufs()

   tcp:connect(host, port);

   for index, bufnr in pairs(buffers) do
      val = vim.api.nvim_eval("sign_getplaced(" .. bufnr ..", {'group': 'ga'})")

      for index, sign in pairs(val[1]['signs']) do
         path = vim.api.nvim_eval('expand("#' .. bufnr .. ':p")')
         break_command = "break " .. path .. ":" .. sign['lnum'] .. "\n"
         tcp:send(break_command)
      end
   end

   tcp:send("start\n");

   while true do
       local s, status, partial = tcp:receive()
       print(s or partial)
       if status == "closed" then break end
   end

   tcp:close()
   print 'done'
end

function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end


place_sign()
start_debug()
