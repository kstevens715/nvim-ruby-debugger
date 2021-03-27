local socket = require("socket")
local host, port = "127.0.0.1", 1234
local tcp = assert(socket.tcp())

tcp:connect(host, port);
tcp:send("break test.rb:5\n")
tcp:send("start\n");

while true do
    local s, status, partial = tcp:receive()
    print(s or partial)
    if status == "closed" then break end
end

tcp:close()
print 'done'
