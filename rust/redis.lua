local log = function(...)
	local li = {}
	for _, v in ipairs({ ... }) do
		table.insert(li, cjson.encode(v))
	end
	redis.log(redis.LOG_NOTICE, unpack(li))
end

local TS = function()
	return redis.call("time")[1]
end

local ZREM = function(key, ...)
	return redis.call("ZREM", key, ...)
end

local HSETNX = function(key, field, val)
	return redis.call("HSETNX", key, field, val)
end

local HINCRBY = function(key, field, val)
	return redis.call("HINCRBY", key, field, val)
end

local HSET = function(key, field, val)
	return redis.call("HSET", key, field, val)
end

local HGET = function(key, field)
	return redis.call("HGET", key, field)
end

local INCR = function(key)
	return redis.call("INCR", key)
end

local ZADD = function(key, score, member)
	return redis.call("ZADD", key, score, member)
end

local ZADD_XX = function(key, score, member)
	return redis.call("ZADD", key, "XX", score, member)
end

local ZADD_NX = function(key, score, member)
	return redis.call("ZADD", key, "NX", score, member)
end

local ZSCORE = function(key, member)
	local r = redis.call("ZSCORE", key, member)
	if r then
		return r.double
	end
end

local binInt = function(str)
	local n = 0
	local base = 1
	for i = 1, #str do
		local c = str:sub(i, i)
		n = n + base * c:byte()
		base = base * 256
	end
	return n
end

local intBin = function(n)
	local t = {}
	while n > 0 do
		local r = math.fmod(n, 256)
		table.insert(t, string.char(r))
		n = (n - r) / 256
	end
	return table.concat(t)
end

local zsetGid = function(zset, gid, key)
	local id = ZSCORE(zset, key)
	if not id then
		id = INCR(gid)
		ZADD(zset, id, key)
	end
	return tonumber(id)
end

-- 用来获取登录的用户，用户 id - 最后登录时间的时间戳，已经退出登录的用户积分是负数
function zumax(KEYS)
	-- flags no-writes
	local zset = unpack(KEYS)
	local max = redis.call("ZRANGE", zset, 0, 0, "REV", "WITHSCORES")
	if #max > 0 then
		max = max[1]
		if max[2].double > 0 then
			return max[1]
		end
	end
end

function zsetGt0Now(KEYS, ARGS)
	local zset = unpack(KEYS)
	local key = unpack(ARGS)
	local s = ZSCORE(zset, key)
	if s then
		if s > 0 then
			ZADD(zset, TS(), key)
			return true
		end
	end
end

function zsetId(KEYS, ARGS)
	local zset = KEYS[1]
	local key = ARGS[1]
	local id = ZSCORE(zset, key)
	if id then
		return id
	end
	id = redis.call("ZREVRANGE", zset, 0, 0, "WITHSCORES")[1]
	if id then
		id = 1 + id[2].double
	else
		id = 33
	end

	ZADD(zset, id, key)
	return id
end
