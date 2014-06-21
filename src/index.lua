local webapp = require('webapp')

-- Load redis
local redis = require "resty.redis"

-- Set the content type
ngx.header.content_type = 'text/html';

-- use nginx $root variable for template dir
TEMPLATEDIR = ngx.var.src .. '/templates/';

-- the db global
red = nil

--
-- Index view
--
local function index(args)
    local counter, err = red:incr("index_visist_counter")

    webapp.render('index.html', {counter = tostring(counter) } )
end

--
-- the about view
--
local function about(args)
    -- increment about counter
    local counter, err = red:incr("about_visist_counter")

    webapp.render('about.html', {counter = tostring(counter) })
end

local function hello(first, second)
    webapp.render('hello.html', {first = first, second = second})
end

--
-- Initialise db
--
local function init_db()
    -- Start redis connection
    red = redis:new()
    local ok, err = red:connect("127.0.0.1:6379")
    if not ok then
        ngx.say("failed to connect: ", err)
        return
    end
end

local function add_user()
    webapp.__request['user'] = 1
end

--
-- End db, we could close here, but park it in the pool instead
--
local function end_db()
    -- put it into the connection pool of size 100,
    -- with 0 idle timeout
    local ok, err = red:set_keepalive(0, 100)
    if not ok then
        ngx.say("failed to set keepalive: ", err)
        return
    end
end

webapp.middleware(init_db, end_db)
webapp.middleware(add_user, nil)

webapp.routes({
    ['$']      = index,
    ['about$'] = about,
    ['hello/(?<first>.*)/(?<second>.*)$'] = hello,
})




