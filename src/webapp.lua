module('webapp', package.seeall)

local tirtemplate = require('tirtemplate')
local inspect = require('inspect')

local before_fn = nil;
local after_fn = nil;

request = {};
local before_fns = {};
local after_fns = {};

---
---
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
---
---
function render(template_name, context)
    --ngx.header.content_type = 'text/html';
    local page = tirtemplate.tload(template_name)
    local ctx = context
    ctx['request'] = request
    ngx.print( page(ctx) )
end


function routes(user_routes)
    for pattern, view in pairs(user_routes) do
        local uri = '^/'.. pattern
        local match = ngx.re.match(ngx.var.uri, uri, "") -- regex mather in compile mode
        if match then
            for i, fn in ipairs(before_fns) do
                fn()
            end

            local args={}

            for k,v in pairs(match) do
                if match[k] then
                    args[k]=k
                end
            end

            -- We should unpack match so that we can pass the arguments that match in order
            exit = view(unpack(match)) or ngx.HTTP_OK

            for i, fn in ipairs(after_fns) do
                fn()
            end

            ngx.exit( exit )
        end
    end
end

