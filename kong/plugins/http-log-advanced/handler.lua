local BasePlugin = require "kong.plugins.base_plugin"
local Payload = require "kong.plugins.tcp-log-advanced.payload"
local log = require "kong.plugins.tcp-log-advanced.log"
local kong_tls = require "resty.kong.tls"

local TcpLogAdvancedHandler = BasePlugin:extend()

TcpLogAdvancedHandler.PRIORITY = 7

function TcpLogAdvancedHandler:new()
  TcpLogAdvancedHandler.super.new(self, "tcp-log-advanced")
end

function TcpLogAdvancedHandler:access(conf)
  TcpLogAdvancedHandler.super.access(self)
  payload = Payload.create_payload(conf)
  ngx.ctx.runscope = {
    payload = payload
  }
end

function TcpLogAdvancedHandler:log(conf)
  TcpLogAdvancedHandler.super.log(TcpLogAdvancedHandler)
  kong.log.err("ici", ngx.ctx.runscope.payload)
  log.execute(conf, ngx.ctx.runscope.payload)
end

function TcpLogAdvancedHandler:init_worker()

  local orig_ssl_certificate = Kong.ssl_certificate
  Kong.ssl_certificate = function()
    orig_ssl_certificate()
    kong.log.debug("enabled, will request certificate from client")

    local res, err = kong_tls.request_client_certificate()
    if not res then
      kong.log.err("unable to request client to present its certificate: ", err)
    end

    -- disable session resumption to prevent inability to access client
    -- certificate
    -- see https://github.com/Kong/lua-kong-nginx-module#restykongtlsget_full_client_certificate_chain
    res, err = kong_tls.disable_session_reuse()
    if not res then
      kong.log.err("unable to disable session reuse for client certificate: ",
                   err)
    end
  end

  TcpLogAdvancedHandler.super.init_worker(TcpLogAdvancedHandler)
end

return TcpLogAdvancedHandler
