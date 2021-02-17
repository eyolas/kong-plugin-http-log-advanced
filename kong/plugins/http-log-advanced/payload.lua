local JSON = require "kong.plugins.middleman-advanced.json"
local resty_kong_tls = require("resty.kong.tls")


local get_body = ngx.req.get_body_data
local get_headers = ngx.req.get_headers
local get_uri_args = ngx.req.get_uri_args
local read_body = ngx.req.read_body
local string_format = string.format

local _M = {}

function _M.create_payload(conf)
  local headers = get_headers()
  local uri_args = get_uri_args()
  local next = next

  read_body()
  local body_data = get_body()

  headers["target_path"] = kong.request.get_path()
  headers["target_uri"] = ngx.var.request_uri
  headers["target_method"] = ngx.var.request_method



  local json_body
  if headers["content-type"] == 'application/json' then
    json_body = JSON.decode(body_data)
  else
    json_body = body_data
  end

  local credential
  if conf.include_credential then
    credential = kong.client.get_credential()
  end

  local consumer
  if conf.include_consumer then
    consumer = kong.client.get_consumer()
  end

  local certificate
  if conf.include_cert then
    local pem, err = resty_kong_tls.get_full_client_certificate_chain()
    certificate = pem
  end

  local kong_routing
  if conf.include_route then
    local route =kong.router.get_route()
    local service =kong.router.get_service()

    kong_routing = {
      ['route'] = route,
      ['service'] = service,
    }
  end

  local params
  if next(uri_args) then
    params = uri_args
  end


  local payload = {
    ['certificate'] = certificate,
    ['consumer'] = consumer,
    ['credential'] = credential,
    ['kong_routing'] = kong_routing,
    ['request'] = {
      ['headers'] = headers,
      ['params'] = params,
      ['body'] = json_body,
    }
  }

  return JSON.encode(payload)
end

function _M.compose(url, host, payload_json, message)
  local payload = JSON.decode(payload_json)
  payload['message'] = message
  local payload_body = JSON.encode(payload)
  local payload_headers = string_format(
    "POST %s HTTP/1.1\r\nHost: %s\r\nConnection: Keep-Alive\r\nContent-Type: application/json\r\nContent-Length: %s\r\n",
    url, host, #payload_body)

  local res = string_format("%s\r\n%s", payload_headers, payload_body)

  return res
end

return _M
