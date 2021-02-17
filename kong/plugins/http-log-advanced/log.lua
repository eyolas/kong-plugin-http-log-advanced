local JSON = require "kong.plugins.http-log-advanced.json"
local PAYLOAD = require "kong.plugins.http-log-advanced.payload"
local basic_serializer = require "kong.plugins.log-serializers.basic"
local url = require "socket.url"

local kong = kong
local ngx = ngx
local kong_response = kong.response
local ngx_re_match = ngx.re.match
local ngx_re_find = ngx.re.find
local timer_at = ngx.timer.at

local HTTP = "http"
local HTTPS = "https"

local _M = {}

local function parse_url(host_url)
  local parsed_url = url.parse(host_url)
  if not parsed_url.port then
    if parsed_url.scheme == HTTP then
      parsed_url.port = 80
    elseif parsed_url.scheme == HTTPS then
      parsed_url.port = 443
    end
  end
  if not parsed_url.path then parsed_url.path = "/" end
  return parsed_url
end

local function send(premature, conf, payload, message)
  if premature then return end
  local name = "[middleman-advanced] "
  local ok, err
  local parsed_url = parse_url(conf.url)
  local host = parsed_url.host
  local port = tonumber(parsed_url.port)

  local url
  if parsed_url.query then
    url = parsed_url.path .. "?" .. parsed_url.query
  else
    url = parsed_url.path
  end

  local payload = PAYLOAD.compose(url, host, payload, message)

  local sock = ngx.socket.tcp()
  sock:settimeout(conf.timeout)

  ok, err = sock:connect(host, port)
  if not ok then
    kong.log.err(name .. "failed to connect to " .. host .. ":" ..
                     tostring(port) .. ": ", err)
    return
  end

  if parsed_url.scheme == HTTPS then
    local _, err = sock:sslhandshake(true, host, false)
    if err then
      kong.log.err(name .. "failed to do SSL handshake with " .. host .. ":" ..
                       tostring(port) .. ": ", err)
    end
  end

  ok, err = sock:send(payload)
  if not ok then
    kong.log.err(name .. "failed to send data to " .. host .. ":" ..
                     tostring(port) .. ": ", err)
  end

  ok, err = sock:setkeepalive(conf.keepalive)
  if not ok then
    kong.log.err(name .. "failed to keepalive to " .. host .. ":" ..
                     tostring(port) .. ": ", err)
    return false, nil, nil
  end
end

function _M.execute(conf, payload)
  local message = basic_serializer.serialize(ngx)
  for i, config in pairs(conf.services) do
    local b, code, body = timer_at(0, send, config, payload, message)
    if not b then kong.log.err("failed to create timer: ", body) end
  end
end

return _M
