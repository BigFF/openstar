
local cjson_safe = require "cjson.safe"

local function get_argByName(name)
	local x = 'arg_'..name
    local _name = ngx.unescape_uri(ngx.var[x])
    return _name
end

local _action = get_argByName("action")
local _name = get_argByName("name")
local _debug = get_argByName("debug")
local config_dict = ngx.shared.config_dict

local _tb,config = config_dict:get_keys(0),{}
for i,v in ipairs(_tb) do
	config[v] = config_dict:get(v)
end

local config_base = cjson_safe.decode(config_dict:get("base")) or {}


-- 写文件(filepath,msg,ty)  默认追加方式写入
local function writefile(filepath,msg,ty)
	if ty == nil then ty = "a+" end
	-- w+ 覆盖
    local fd = io.open(filepath,ty) --- 默认追加方式写入
    if fd == nil then return end -- 文件读取错误返回
    fd:write("\n"..tostring(msg))
    fd:flush()
    fd:close()
end

if _action == "save" then

	if _name == "all_config" then
		for k,v in pairs(config) do
			if k == "base" then
				if _debug == "no" then
					writefile(config_base.baseDir.."config.json",v,"w+")
				else
					writefile(config_base.baseDir.."config_bak.json",v,"w+")
				end
			else
				if _debug == "no" then
					writefile(config_base.jsonPath..k..".json",v,"w+")
				else
					writefile(config_base.jsonPath..k.."_bak.json",v,"w+")
				end
			end
		end
		ngx.say("it is ok")
	else
		local msg = config[_name]
		if not msg then return ngx.say("name is error") end 
		if _name == "base" then
			if _debug == "no" then
				writefile(config_base.baseDir.."config.json",msg,"w+")
			else
				writefile(config_base.baseDir.."config_bak.json",msg,"w+")
			end
		else
			if _debug == "no" then
				writefile(config_base.jsonPath.._name..".json",msg,"w+")
			else
				writefile(config_base.jsonPath.._name.."_bak.json",msg,"w+")
			end
		end
		sayHtml_ext(msg)
	end

elseif _action =="load" then

	loadConfig()

else
    sayHtml_ext({action="error"})
end


