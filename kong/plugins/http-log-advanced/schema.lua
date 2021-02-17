local typedefs = require "kong.db.schema.typedefs"

return {
  name = "http-log-advanced",
  fields = {
    {consumer = typedefs.no_consumer}, {protocols = typedefs.protocols_http}, {
      config = {
        type = "record",
        required = true,
        fields = {
          {
            services = {
              type = "array",
              required = true,
              len_min = 1,
              elements = {
                type = "record",
                fields = {
                  {url = {required = true, type = "string"}},
                  {timeout = {default = 10000, type = "number"}},
                  {keepalive = {default = 60000, type = "number"}},
                  {include_cert = {default = false, type = "boolean"}},
                  {include_credential = {default = false, type = "boolean"}},
                  {include_consumer = {default = false, type = "boolean"}},
                  {include_route = {default = false, type = "boolean"}}
                }
              }
            }
          }
        }
      }
    }
  }
}
