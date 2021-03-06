module('webapp', package.seeall)

local tirtemplate = require('tirtemplate')
local inspect = require('inspect')

local before_fn = nil;
local after_fn = nil;

__request = {};
local before_fns = {};
local after_fns = {};

---
--- Add a before and after function (either optional) that will
--- be called before and after the request is complete.  The
--- before function is always added at the end if the queue of
--- functions to be run, and the after always at the start.  This
--- means they'll be called as follows:
---
---    webapp.middleware(a, b)
---    webapp.middleware(x, z)
---
---    a()
---    x()
---    z()
---    b()
---
function middleware(before, after)
    if before ~= nil then
        before_fns[#before_fns+1] = before
    end
    if after ~= nil then
        table.insert(after_fns, 0, after)
    end
end

---
--- Render the context in the provided template name.
---
function render(template_name, context)
    --ngx.header.content_type = 'text/html';
    local page = tirtemplate.tload(template_name)
    local ctx = context
    ctx['request'] = __request
    ngx.print( page(ctx) )
end


---
--- Let the user provide urls and the functions they should be
--- routed to.  The urls should be regular expressions, not contain the
--- root / and look something like:
---
--- webapp.routes({
---    ['$']      = index,
---    ['about$'] = about,
---    ['hello/(?<first>.*)/(?<second>.*)$'] = hello,
--- })
---
--- The named parameters in the 'hello' url will be passed in that order
--- to the function.  They don't need to be named parameters, this is
--- just in case I can work out how to pass them as named parameters ;)
---
function routes(user_routes)
    for pattern, view in pairs(user_routes) do
        local uri = '^/'.. pattern
        local match = ngx.re.match(ngx.var.uri, uri, "")
        if match then

            table.foreach(before_fns, function(k,v) v() end)

            -- We should unpack the match so that we can pass the arguments
            -- in order. Hopefully I can work out how to unpack them in a way
            -- that'll allow named params ...
            exit = view(unpack(match)) or ngx.HTTP_OK

            table.foreach(after_fns, function(k,v) v() end)

            ngx.exit( exit )
        end
    end
end


---------------------------------------------------- ---------------------- Helpers

function map(tbl, f)
    local t = {}
    for k,v in pairs(tbl) do
        t[k] = f(v)
    end
    return t
end


