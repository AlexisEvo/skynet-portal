local _M = {}

-- safe to share on module level as it is a static table (?)
local connect_settings = require "secrets/env"

function _M.new()
  local mysql = require "resty.mysql"
  local db, err = mysql:new()

  return db
end

function _M.connect(db)
  db:set_timeout(1000)

  local ok, err, errcode, sqlstate = db:connect(connect_settings)

  if not ok then
    ngx.log(ngx.ERR, "failed to connect: ", err, ": ", errcode, " ", sqlstate)
    ngx.say("Unable to connect to DB")
    ngx.exit(ngx.ERROR)
  end

end

function _M.query(db, query, nrows)

  if nrows == nil then
    return db:query(query)
  else
    return db:query(query, nrows)
  end

end

function _M.get_reused_times(db)
  return db:get_reused_times()
end

-- Does not actually close, instead returns connection to the pool
function _M.close(db)
  db:set_keepalive(10000, 5)
end

return _M