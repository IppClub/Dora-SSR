-- Native broker for the built-in AtomPie submission panel.
local function register(options)
	local base = options.api
	local db, http = Dora.DB, Dora.HttpClient
	local cache, pending, locks = {}, {}, {}
	local function fail(message, code)
		return {success = false, message = message, code = code}
	end
	local function hex(value, length)
		return type(value) == "string" and #value == length and not value:find("[^0-9a-f]")
	end
	local function upstream(path, data, access)
		local headers = {"Content-Type: application/json","X-Dora-Transport: json-post-v1"}
		if access then headers[#headers+1] = "Authorization: Bearer " .. access end
		local body = next(data) and Dora.json.encode(data) or "{}"
		local raw = http:postAsync(base .. path, headers, body, 30)
		if not raw then return nil, fail("原子派未完成请求，请检查连接和稿件状态后重试。", "upstream") end
		local result = Dora.json.decode(raw)
		if type(result) ~= "table" then return nil, fail("原子派响应格式不正确。") end
		if (type(result.code) == "number" and (result.code < 200 or result.code >= 300)) or result.error then
			local err = fail(result.message or "原子派未接受请求。", result.error or result.code)
			err.definitive = type(result.code) == "number" and result.code >= 400 and result.code < 500
			return nil, err
		end
		return result.data or result
	end
	local function binding(id)
		local rows = db:query("SELECT slot, share FROM AtomPieBinding WHERE client = ?", {id})
		return rows and rows[1]
	end
	-- Every new refresh token gets a fresh, browser-generated random pad. Only
	-- the complementary bytes are written to the engine DB. Neither store on
	-- its own contains a usable AtomPie refresh credential.
	local function transform(value, pad, opening)
		local bytes = {}
		if opening then
			if #value % 2 ~= 0 or #value > #pad then return end
			for i = 1, #value, 2 do
				bytes[#bytes+1] = string.char(tonumber(value:sub(i,i+1),16) ~ tonumber(pad:sub(i,i+1),16))
			end
		else
			if #value * 2 > #pad then return end
			for i = 1, #value do
				bytes[i] = string.format("%02x", value:byte(i) ~ tonumber(pad:sub(i*2-1,i*2),16))
			end
		end
		return table.concat(bytes)
	end
	local function accept(id, req, tokens)
		if type(tokens.access_token) ~= "string" or type(tokens.refresh_token) ~= "string" then return fail("原子派未返回授权凭据。") end
		local share = transform(tokens.refresh_token, req.new_pad, false)
		if not share then return fail("原子派凭据格式不受支持。") end
		db:exec("INSERT INTO AtomPieBinding(client, slot, share) VALUES(?,?,?) ON CONFLICT(client) DO UPDATE SET slot=excluded.slot,share=excluded.share", {id, req.new_slot, share})
		cache[id] = {access=tokens.access_token, pad=req.new_pad, slot=req.new_slot, expires=os.time() + (tonumber(tokens.expires_in) or 300)}
		return {success=true, status="authorized", slot=req.new_slot}
	end
	local function action(req)
		local id, op = base .. "|" .. req.client, req.action
		local row = binding(id)
		if op == "binding" then return {success=true, slot=row and row[1] or nil} end
		if op == "start" then
			if row then return fail("请先断开当前原子派账号。") end
			for key, session in pairs(pending) do if session.untilTime <= os.time() then pending[key]=nil end end
			local res, err = upstream("/device", {})
			if not res then return err end
			if type(res.device_code) ~= "string" or type(res.user_code) ~= "string" then return fail("未取得有效授权码。") end
			pending[id] = {code=res.device_code, user_code=res.user_code, untilTime=os.time()+(tonumber(res.expires_in) or 600)}
			return {success=true, user_code=res.user_code, verification_uri=res.verification_uri_complete or res.verification_uri,
				interval=res.interval or 5, expires_in=res.expires_in or 600}
		end
		if op == "cancel" then
			if pending[id] and pending[id].user_code == req.user_code then pending[id]=nil end
			return {success=true}
		end
		if op == "poll" or op == "restore" then
			if not hex(req.new_slot, 32) or not hex(req.new_pad, 1024) or (row and req.new_slot==row[1]) then return fail("无效的授权事务。") end
		end
		if op == "poll" then
			local item = pending[id]
			if item and item.user_code ~= req.user_code then return {success=true,status="expired_token"} end
			if not item or item.untilTime <= os.time() then pending[id]=nil; return {success=true,status="expired_token"} end
			local res, err = upstream("/token", {device_code=item.code})
			if not res then return err end
			if res.status == "authorized" then pending[id]=nil; return accept(id,req,res) end
			if res.status == "access_denied" or res.status == "expired_token" then pending[id]=nil end
			return {success=true, status=res.status, interval=res.interval}
		end
		if not row or req.slot ~= row[1] or not hex(req.pad,1024) then return fail("请重新连接原子派。", "binding_changed") end
		local session = cache[id]
		if session and session.slot ~= row[1] then cache[id]=nil; session=nil end
		if session and session.pad ~= req.pad then return fail("授权凭据不匹配。") end
		if op == "restore" then
			if session and session.expires > os.time()+30 then return {success=true,status="authorized",slot=req.slot} end
			local refresh = transform(row[2],req.pad,true)
			local res, err = upstream("/refresh",{refresh_token=refresh})
			if not res then
				if err.code == "invalid_grant" then
					db:exec("DELETE FROM AtomPieBinding WHERE client = ?", {id})
					cache[id]=nil
				end
				return err
			end
			return accept(id,req,res)
		elseif op == "disconnect" then
			local refresh = transform(row[2],req.pad,true)
			local res, err = upstream("/revoke",{refresh_token=refresh},session and session.access)
			if not res then return err end
			db:exec("DELETE FROM AtomPieBinding WHERE client = ?", {id})
			cache[id],pending[id]=nil,nil
			return {success=true}
		end
		if not session or session.expires <= os.time() then return fail("请刷新授权。","refresh_needed") end
		local path = ({me="/me", create="/drafts"})[op]
		if op == "read" or op == "update" or op == "cover" or op == "submit" then
			if type(req.id) ~= "number" or req.id < 1 or req.id ~= math.floor(req.id) then return fail("稿件编号无效。") end
			path = "/drafts/" .. tostring(math.floor(req.id)) .. "/" .. op
		end
		if not path then return fail("不支持的原子派操作。") end
		local result, err = upstream(path,req.payload or {},session.access)
		if not result then
			if err.code == "invalid_token" then cache[id]=nil; return fail("请刷新授权。","refresh_needed") end
			return err
		end
		return {success=true,data=result}
	end
	db:exec("CREATE TABLE IF NOT EXISTS AtomPieBinding(client TEXT PRIMARY KEY, slot TEXT NOT NULL, share TEXT NOT NULL)")
	Dora.HttpServer:postSchedule(options.route or "/atompie", function(request)
		local req = request.body
		if type(req)~="table" or not hex(req.client,64) then return fail("无效的 IDE 连接。") end
		if locks[req.client] then return fail("另一项投稿操作正在进行。","busy") end
		locks[req.client]=true
		local ok, result = pcall(action,req)
		locks[req.client]=nil
		return ok and result or fail("Dora 无法完成原子派请求。")
	end)
end

return register
