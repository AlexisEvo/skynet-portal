local _M = {}


--local redis = require "resty.redis"
--local red = redis:new()
--red:set_timeouts(1000, 1000, 1000)

local dbm = require "app/mysql"

function _M.resolve_short_code(short_code)
  local quoted_short = ngx.quote_sql_str(short_code)
  local db = dbm.new()
  dbm.connect(db)


  res, err, errcode, sqlstate = db.query(db, "SELECT uuid FROM short_uri WHERE id=" .. quoted_short .. ";", 1)
  if not res then
    ngx.log(ngx.ERR, "bad result: ", err, ": ", errcode, ": ", sqlstate, ".")
  end

  -- cover empty result sets and invalid uuids
  if res[1] == nil or res[1]['uuid'] == nil or string.len(res[1]['uuid']) ~= 46 then
    ngx.say("file not found")
    ngx.exit(ngx.HTTP_NOT_FOUND)
  end

  dbm.close(db)
  ngx.log(ngx.ERR, "uuid is: ", res[1]['uuid'])

  return res[1]['uuid']
end


return _M