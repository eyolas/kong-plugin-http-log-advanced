# Kong http log advanced

Send request and response logs to multiple HTTP servers.
With many configuration + body


## Installation

WIP

## Configuration

You can add the plugin on top of an API by executing the following request on your Kong server:

```sh
$ http POST :8001/services/{api}/plugins name=middleman-advanced config:='{ "services": [{"url": "http://myserver.io/validate", "response": "table", "timeout": 10000, "keepalive": 60000}]}'
```

<table><thead>
<tr>
<th>form parameter</th>
<th>default</th>
<th>description</th>
</tr>
</thead><tbody>
<tr>
<td><code>name</code></td>
<td></td>
<td>The name of the plugin to use, in this case: <code>middleman</code></td>
</tr>
<tr>
<td><code>config.services</code><br><em>required</em></td>
<td></td>
<td>The list of services witch the plugin make a JSON <code>POST</code></td>
</tr>

</tbody></table><br />

### Service config
<table><thead>
<tr>
<th>form parameter</th>
<th>default</th>
<th>description</th>
</tr>
</thead><tbody>
<tr>
<td><code>url</code><br><em>required</em></td>
<td></td>
<td>The URL to which the plugin will make a JSON <code>POST</code> request before proxying the original request.</td>
</tr>
<tr>
<td><code>response</code><br><em>required</em></td>
<td>table</td>
<td>The type of response the middleman service is going to respond with</td>
</tr>
<tr>
<td><code>timeout</code></td>
<td>10000</td>
<td>Timeout (miliseconds) for the request to the URL specified above. Default value is 10000.</td>
</tr>
<tr>
<td><code>keepalive</code></td>
<td>60000</td>
<td>Keepalive time (miliseconds) for the request to the URL specified above. Default value is 60000.</td>
</tr>
<tr>
<td><code>include_cert</code></td>
<td>false</td>
<td>Include the original certificate in JSON POST</td>
</tr>
<tr>
<td><code>include_credential</code></td>
<td>false</td>
<td>Include the credential in JSON POST</td>
</tr>
<tr>
<td><code>include_consumer</code></td>
<td>false</td>
<td>Include the consumer in JSON POST</td>
</tr>
<tr>
<td><code>include_route</code></td>
<td>false</td>
<td>Include the route in JSON POST</td>
</tr>
</tbody></table>

Middleman will execute a JSON <code>POST</code> request to the specified <code>url</code> with the following body:


## Payload
```lua
local payload = {
    ['certificate'] = certificate,
    ['consumer'] = consumer,
    ['credential'] = credential,
    ['kong_routing'] = kong_routing,
    ['message'] = message,
    ['request'] = {
      ['headers'] = headers,
      ['params'] = params,
      ['body'] = json_body,
    }
  }
```

<table>
    <tr>
        <th>Attribute</th>
        <th>Description</th>
    </tr>
    <tr>
    <td><code>certificate</code></td>
    <td><small>The certificate of the original request if include_credential <br/> see resty_kong_tls.get_full_client_certificate_chain()</small></td>
    </tr>
    <tr>
        <td><code>consumer</code></td>
        <td><small>The consumer of the original request <br/> see kong.client.get_consumer()</small></td>
    </tr>
    <tr>
        <td><code>credential</code></td>
        <td><small>The consumer of the original request <br/> see kong.client.get_credential()</small></td>
    </tr>
    <tr>
        <td><code>kong_routing</code></td>
        <td><small>The kong_routing of the original request <br/> see kong.router.get_route() and kong.router.get_service()</small></td>
    </tr>
    <tr>
        <td><code>request</code></td>
        <td><small>The request of the original request <br /> see the next table : request</small></td>
    </tr>
    <tr>
        <td><code>message</code></td>
        <td><small>The original log send by kong <br /> see basic_serializer.serialize(ngx)</small></td>
    </tr>
</table>

Request
<table>
    <tr>
        <th>Attribute</th>
        <th>Description</th>
    </tr>
    <tr>
    <td><code>body</code></td>
    <td><small>The body of the original request</small></td>
    </tr>
    <tr>
        <td><code>params</code></td>
        <td><small>The url arguments of the original request</small></td>
    </tr>
    <tr>
        <td><code>headers</code></td>
        <td><small>The headers of the original request</small></td>
    </tr>
</table>

## Author
David TOUZET

## License
<pre>
The MIT License (MIT)
=====================

Copyright (c) 2020 David TOUZET

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
</pre>
