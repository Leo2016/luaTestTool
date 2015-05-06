local tableFromApp 	= nil; 	--���������
local tableToApp 	= nil; 	--���ص�����
local swapInfo 		= nil;  --��������
local sourceType 	= nil;  --��������
cjson = require("json")
function isIosArk()
  if (isNotNullOrEmpty(sourceType) and (string.find(sourceType, "ios_ark"))) then return true;end;
  return false;
end
function isAndroidArk()
  if (isNotNullOrEmpty(sourceType) and (string.find(sourceType, "android_ark"))) then return true;end;
  return false;
end
function isIosJp()
  if (isNotNullOrEmpty(sourceType) and (string.find(sourceType, "ios_jp"))) then return true;end;
  return false;
end
function isAndroidJp()
  if (isNotNullOrEmpty(sourceType) and (string.find(sourceType, "android_jp"))) then return true;end;
  return false;
end
function isAndroidCtrip()
  if (isNotNullOrEmpty(sourceType) and (string.find(sourceType, "Android_ctrip"))) then return true;end;
  return false;
end
function isIosCtrip()
  if (isNotNullOrEmpty(sourceType) and (string.find(sourceType, "ios_ctrip"))) then return true;end;
  return false;
end

function getEmptyReturn()
	local rst = {};
	rst.header = {};
	rst.params = {};
	rst.info = {};
	return rst;
end
--���12306�������ݺϷ���
function check12306Response(response)
  local rst = {};
--~   print(response.code)
  if(response.code ~= 200) then rst.code, rst.message = -1, "12306�쳣(200)"..tostring(response.code); return rst; end;

  local html = response.body;
  if (html == nil) then rst.code, rst.message = -2, "��վ�����쳣(002)"; return rst; end;
--~   if (html == nil and response.datastr == nil) then rst.code, rst.message = -2, "��վ�����쳣(002)"; return rst; end;

--~   if (cjson.testFlag ~= nil) then html = string.gsub(html, "\"messages\"%:%[%]", ""); response.body = html;end;
--~   --<title>��¼ | ���˷��� | ��·�ͻ���������</title>
--~   if (string.find (html,"<title>��¼</title>")) then rst.code, rst.message = -96, "12306�ʺ�δ��¼";return rst;end;

  rst.code, rst.message, rst.data = 1, "", {};
  return rst;
end



--�ַ������
function string:split(sep)
  local fields = {};
  local pattern = string.format("([^%s]+)", (sep or "\t"));
  self:gsub(pattern, function(c) fields[#fields+1] = c end);
  return fields;
end

--��ȡ������
function getObjectValueByPath(obj, path)
  if (obj == nil or path == nil) then return nil end;

  local rst = obj;
  local arr = string.split(path, ".");
  for k,v in ipairs(arr) do
    if (v == nil) then rst = nil;break;end;
    if (type(rst) ~= "table") then rst = nil;break;end;
    local sp, ep, val = string.find(v, "^#(%d)");
    if (sp) then v = tonumber(val) end;
    rst = rst[v];
    if (rst == nil) then break end;
  end;
  return rst;
end

---[[bit������
do
local function check_int(n)
  if(n - math.floor(n) > 0) then
    error("trying to use bitwise operation on non-integer!")
  end
end

local function to_bits(n)
  check_int(n)
  if(n < 0) then
    -- negative
    return to_bits(bit.bnot(math.abs(n)) + 1)
   end
   -- to bits table
   local tbl = {}
   local cnt = 1
   while (n > 0) do
    local last = math.mod(n,2)
  if(last == 1) then
      tbl[cnt] = 1
    else
      tbl[cnt] = 0
    end
    n = (n-last)/2
    cnt = cnt + 1
  end
  return tbl
end

local function tbl_to_number(tbl)
 local n = table.getn(tbl)

 local rslt = 0
 local power = 1
 for i = 1, n do
  rslt = rslt + tbl[i]*power
  power = power*2
 end

 return rslt
end

local function expand(tbl_m, tbl_n)
 local big = {}
 local small = {}
 if(table.getn(tbl_m) > table.getn(tbl_n)) then
  big = tbl_m
  small = tbl_n
 else
  big = tbl_n
  small = tbl_m
 end
 -- expand small
 for i = table.getn(small) + 1, table.getn(big) do
  small[i] = 0
 end

end

local function bit_or(m, n)
 local tbl_m = to_bits(m)
 local tbl_n = to_bits(n)
 expand(tbl_m, tbl_n)

 local tbl = {}
 local rslt = math.max(table.getn(tbl_m), table.getn(tbl_n))
 for i = 1, rslt do
  if(tbl_m[i]== 0 and tbl_n[i] == 0) then
   tbl[i] = 0
  else
   tbl[i] = 1
  end
 end

 return tbl_to_number(tbl)
end

local function bit_and(m, n)
 local tbl_m = to_bits(m)
 local tbl_n = to_bits(n)
 expand(tbl_m, tbl_n)

 local tbl = {}
 local rslt = math.max(table.getn(tbl_m), table.getn(tbl_n))
 for i = 1, rslt do
  if(tbl_m[i]== 0 or tbl_n[i] == 0) then
   tbl[i] = 0
  else
   tbl[i] = 1
  end
 end

 return tbl_to_number(tbl)
end

local function bit_not(n)

 local tbl = to_bits(n)
 local size = math.max(table.getn(tbl), 32)
 for i = 1, size do
  if(tbl[i] == 1) then
   tbl[i] = 0
  else
   tbl[i] = 1
  end
 end
 return tbl_to_number(tbl)
end

local function bit_xor(m, n)
 local tbl_m = to_bits(m)
 local tbl_n = to_bits(n)
 expand(tbl_m, tbl_n)

 local tbl = {}
 local rslt = math.max(table.getn(tbl_m), table.getn(tbl_n))
 for i = 1, rslt do
  if(tbl_m[i] ~= tbl_n[i]) then
   tbl[i] = 1
  else
   tbl[i] = 0
  end
 end

 --table.foreach(tbl, print)

 return tbl_to_number(tbl)
end

local function bit_rshift(n, bits)
 check_int(n)

 local high_bit = 0
 if(n < 0) then
  -- negative
  n = bit_not(math.abs(n)) + 1
  high_bit = 2147483648 -- 0x80000000
 end

 for i=1, bits do
  n = n/2
  n = bit_or(math.floor(n), high_bit)
 end
 return math.floor(n)
end

-- logic rightshift assures zero filling shift
local function bit_logic_rshift(n, bits)
 check_int(n)
 if(n < 0) then
  -- negative
  n = bit_not(math.abs(n)) + 1
 end
 for i=1, bits do
  n = n/2
 end
 return math.floor(n)
end

local function bit_lshift(n, bits)
 check_int(n)

 if(n < 0) then
  -- negative
  n = bit_not(math.abs(n)) + 1
 end

 for i=1, bits do
  n = n*2
 end
 return bit_and(n, 4294967295) -- 0xFFFFFFFF
end

local function bit_xor2(m, n)
 local rhs = bit_or(bit_not(m), bit_not(n))
 local lhs = bit_or(m, n)
 local rslt = bit_and(lhs, rhs)
 return rslt
end

--ʮ����תʮ������ӳ���
local map_hex = {['0'] = '0', ['1'] = '1', ['2'] = '2', ['3'] = '3', ['4'] = '4', ['5'] = '5', ['6'] = '6', ['7'] = '7',
					['8'] = '8', ['9'] = '9', ['10'] = 'A', ['11'] = 'B', ['12'] = 'C', ['13'] = 'D', ['14'] = 'E', ['15'] = 'F'}

--nΪ������ת����������16�����ַ���
function dec2hex(n)
	local a = ''
	local b, c, d, dStr

	repeat
		b, c = math.modf(n/16)
		d = n % 16
		dStr = map_hex[tostring(d)]
		a  = dStr..a
		n = b
	until b < 16

	dStr = map_hex[tostring(b)]
	a  = dStr..a
	return a
end

--ʮ����2�����ƣ�����һ����λ�ַ���,��������8λ�ֽڵ����
local function to_8bits(n)
	check_int(n)
	if(n < 0) then
    -- negative
		return to_bits(bit.bnot(math.abs(n)) + 1)
	end
	-- to bits table
	local tblStr = ''
	local tbl = {}
	local cnt = 1
	while (n > 0) do
		local last = math.mod(n,2)
		if(last == 1) then
			tbl[cnt] = 1
		else
			tbl[cnt] = 0
		end
    n = (n-last)/2
    cnt = cnt + 1
	end
	--������8λ����0
	for i = 8, 1, -1 do
		if tbl[i] then
			tblStr = tblStr..tostring(tbl[i])
		else
			tblStr = tblStr..'0'
		end
	end
  return tblStr
end

--base64Stringӳ���
local base64Map = {	['0'] = 'A',  ['1'] = 'B',  ['2'] = 'C',  ['3'] = 'D',  ['4'] = 'E',  ['5'] = 'F',  ['6'] = 'G',  ['7'] = 'H',  ['8'] = 'I',  ['9'] = 'J',
					['10'] = 'K', ['11'] = 'L',	['12'] = 'M', ['13'] = 'N', ['14'] = 'O', ['15'] = 'P', ['16'] = 'Q', ['17'] = 'R', ['18'] = 'S', ['19'] = 'T',
					['20'] = 'U', ['21'] = 'V', ['22'] = 'W', ['23'] = 'X', ['24'] = 'Y', ['25'] = 'Z', ['26'] = 'a', ['27'] = 'b', ['28'] = 'c', ['29'] = 'd',
					['30'] = 'e', ['31'] = 'f', ['32'] = 'g', ['33'] = 'h', ['34'] = 'i', ['35'] = 'j', ['36'] = 'k', ['37'] = 'l', ['38'] = 'm', ['39'] = 'n',
					['40'] = 'o', ['41'] = 'p', ['42'] = 'q', ['43'] = 'r', ['44'] = 's', ['45'] = 't', ['46'] = 'u', ['47'] = 'v', ['48'] = 'w', ['49'] = 'x',
					['50'] = 'y', ['51'] = 'z', ['52'] = '0', ['53'] = '1', ['54'] = '2', ['55'] = '3', ['56'] = '4', ['57'] = '5', ['58'] = '6', ['59'] = '7',
					['60'] = '8', ['61'] = '9', ['62'] = '+', ['63'] = '/',
}

function bin2Base64String(key)
	return base64Map[tostring(key)]
end


bit = {
  bnot = bit_not,
  band = bit_and,
  bor  = bit_or,
  bxor = bit_xor,
  rshift = bit_rshift,
  lshift = bit_lshift,
  bxor2 = bit_xor2,
  blogic_rshift = bit_logic_rshift,

  tobits = to_bits,
  to8bits = to_8bits,
  tonumb = tbl_to_number,
  dec2hex = dec2hex,
  bin2Base64String = bin2Base64String
}

end
--]]
---[[��morCustomRealm�������������飬�ں�"16����תBase64����"
do
--N ����ӳ���
cnt_n = 12
--���ھ���16������
local map_n = {
	'7D', '5F', '52', '59', '5C', '55', '64', '59', '53', '5B', '55', '44'
}

--C ����ӳ���
cnt_c = 19
--���ھ���16������
local map_c = {
	'53', '5E', '1E', '01', '02', '03', '00', '06', '1E', '42', '51', '59',
	'5C', '43', '01', '02', '03', '00', '06'
}


--һЩȫ�ֱ���
bufferSize = 1024;
buffer = {};
bufPos = 0;
errCode = nil;

--��ʼ��
function ResetAllInfo()
	errCode = 0;
	buffer = {};
	bufPos = 0;
end

--ͨ��ָ����split_char�����str
function string_split(str, split_char)
    local sub_str_tab = {};
    local i = 0;
    local j = 0;
    while true do
        j = string.find(str, split_char,i+1);
--~ 		print(j)
        if j == nil then
            table.insert(sub_str_tab,str.sub(str,i+1));
            break;
        end;
        table.insert(sub_str_tab,string.sub(str,i+1,j-1));
        i = j;
    end

	--��������Ŀ
	for k, v in pairs(sub_str_tab) do
		if v == '' then
			sub_str_tab[k] = nil
		end
	end

    return sub_str_tab;
end

--flag = 0 ��ʾ N ������ = 1 ��ʾ C ������
function calc_value_pos(val, flag)
	rst = ((flag == 0) and {val % cnt_n} or {((flag == 1) and {val % cnt_c} or {0})[1]})[1]
	return rst;
end

--������� �����������ݵĴ�С < 0 ����
function fill_buffer_with_value(pos, bufsize, val, flag, seg, segcount)
	local x, y = math.modf( val / 1000 );
	y = val - x * 1000;
	local v1 = calc_value_pos(x, flag);
	local v2 = calc_value_pos(y, flag);

	if (v1 > v2) then
        v1, v2 = v2, v1;
    end

    --���ݳ���
    local vs = v2 - v1 + 1;
	if vs < 0 then return -1; end;
	if vs > bufsize then return -2; end;

	--ת������,���������壬C#��-1%2=-1,��lua��-1%2=1��������Ҫ�����
	local val_xor = '0';
	if segcount > seg then
		if ((segcount - seg - 1) % 2) == 1 then
			val_xor = '30';								--val_xor = 0x30;
		end
	end

    --׼��������
    local buf_source = ((flag == 0) and {map_n} or {map_c})[1];						--(flag == 0) ? map_n : map_c;

	local i = v1
    --��������
	while i <= v2 do
        local val_s = buf_source[i+1];
		local aa = bit.bxor(tonumber(val_s, 16), tonumber(val_xor, 16));
		local bb = bit.dec2hex(aa);
--~ 		buffer[pos + i - v1] = bit.dec2hex(bit.bxor(val_s, val_xor));
		buffer[pos + i - v1 + 1] = bb;
		i = i + 1
    end

    --���ظ��Ƶ����ݵĳ���
	return vs;
end

--16����ת��ΪBase64����
function convert2Base64String(buffer)
	local rst = ''
	local bitBuffer = ''
	if #buffer % 3 == 0 then
		for k,v in pairs(buffer) do
			local aa = bit.to8bits(tonumber(v, 16))
			bitBuffer = bitBuffer..aa
		end
--~ 		print(bitBuffer)
	else
		for k,v in pairs(buffer) do
			local aa = bit.to8bits(tonumber(v, 16))
--~ 			local aa = bit.to8bits(string.byte(v))
			bitBuffer = bitBuffer..aa
		end
--~ 		print(bitBuffer)
		if #buffer % 3 == 1 then
			bitBuffer = bitBuffer.."0000000000000000"
		else
			bitBuffer = bitBuffer.."00000000"
		end
	end
	for i = 1, string.len(bitBuffer), 6 do
		local aa = string.sub(bitBuffer, i, i+5)
--~ 		print(aa)
		local bb = tonumber(aa, 2)
--~ 		print(bb)
		local cc = bit.bin2Base64String(bb)
--~ 		print(cc)
		rst = rst..cc
	end

	if #buffer % 3 == 1 then
		rst = string.gsub(rst, '%w%w$', '==')
	else if #buffer % 3 == 2 then
			rst = string.gsub(rst, '%w$', '=')
		end
	end
--~ 	print(rst)

	return rst
end

--��һ������
function BuildCodeStep1(str, seg, segcount)
	local len = string.len(str);
	local pos = 0;

	while pos + 7 < len do
		_,_,c = string.find(str, "(%w)", pos + 7);
		vs = string.sub(str, pos + 1, pos + 6);
		vv = tonumber(vs);

		flag = (( c == 'N' ) and {0} or {( ( c == 'C') and {1} or {-1} )[1]})[1];
		size = fill_buffer_with_value(bufPos, 256, vv, flag, seg, segcount);

		if (size >= 0) then
			bufPos = bufPos + size;
        end

		pos = pos + 7;							--pos = pos + 7
    end
end

--�ڶ�������
function BuildCodeStep2(str)
--~ 	print("enter fuction bulidcodestep2,the str is "..str..", the bufPos is "..bufPos);
	for i = 0, bufPos - 1, 1 do
		local fix_pos = (i % 8 + 1);				--i % 8
		local fix_c = string.match(str, "(%w)", fix_pos);

--~ 		print("fix_pos is "..tostring(fix_pos)..", fix_c is "..fix_c.."i is "..tostring(i))

		local fix_v = nil;

		if fix_c >= '0' and fix_c <= '9' then
			fix_v = string.byte(fix_c) - string.byte('0');
		else if fix_c >= 'A' and fix_c <= 'F' then
			fix_v = tonumber('71', 16) + (string.byte(fix_c) - string.byte('A'));
			end
		end
--~ 		print(buffer[i+1])
		local aa = bit.bxor(tonumber(buffer[i+1], 16), fix_v);
		buffer[i+1] = bit.dec2hex(aa);
    end
end

--��ں���
function BuildCode(val)
    --׼������
	ResetAllInfo();

    --��S��֣�ͳ�Ƴ�segCount,��0��ʼ����
	arrVal = string_split(val, 'S');
	segCount = #arrVal;

	for seg = 0, segCount - 1, 1 do
		s1 = arrVal[seg+1];
		--��X���
		arrS1 = string_split(s1, 'X');
		if #arrS1 ~= 2 then
			errCode = -1;
			break;
		end

		ss1 = arrS1[1];
		ss2 = arrS1[2];

		BuildCodeStep1(ss1, seg, segCount);

--~ 		print("what in buffer!")
--~ 		for k,v in pairs(buffer) do
--~ 			print(k, '0x'..v)
--~ 		end

		BuildCodeStep2(ss2);
	end

    rst = "";

--~ 	print("what in buffer!")
--~ 	for k,v in pairs(buffer) do
--~ 		print(k, '0x'..v)
--~ 	end

	if (errCode < 0) then
		--�д�����
		print("Error has happend, the errCode is "..tostring(errCode))
	else --iosдi��Androidдa
		rst = "i" .. convert2Base64String(buffer);
    end

	return rst;
end

end --ƥ����һ��do��morCustomRealm���������������
--]]
---[[12306APP�˳�ʼ�������
function ReachRequest(info)
	local rst = getEmptyReturn();
	rst.url = "https://mobile.12306.cn/otsmobile/apps/services/reach";
	rst.method = "GET";
	rst.header["User-Agent"] = "Mozilla/5.0 (iPhone; CPU iPhone OS 8_2 like Mac OS X) AppleWebKit/600.1.4 (KHTML, like Gecko) Mobile/12D508 (384115952)/Worklight/6.0.0";
    rst.info.message ="���ڳ�ʼ��25%";
	return rst;
end

function ReachResponse(info, response)

	local rst = check12306Response(response);
	if (rst.code < 0) then return rst; end;

	local data = response.body;
	if data ~= "OK" then
		rst.code = -1;
		rst.message = "��ַ�޷�����";
	else
		rst.code = 1;
		rst.message = "���ڳ�ʼ��"
	end
	return rst;
end

function InitStep1Request(info)
	local rst = getEmptyReturn();
	rst.url = "https://mobile.12306.cn/otsmobile/apps/services/api/MobileTicket/iphone/init";--������Ҫ�����ֻ����Կ�
	rst.method= "POST";
    rst.info.message ="���ڳ�ʼ��50%";
	rst.header["User-Agent"] = "Mozilla/5.0 (iPhone; CPU iPhone OS 8_2 like Mac OS X) AppleWebKit/600.1.4 (KHTML, like Gecko) Mobile/12D508 (384115952)/Worklight/6.0.0";
    rst.header["X-Requested-With"] = "XMLHttpRequest";
    rst.header["x-wl-app-version"] = "2.0";
    rst.header["x-wl-platform-version"] = "6.0.0";

	--����post�����params
	rst.params["skin"] = "default";
	rst.params["skinLoaderChecksum"] = "";
	rst.params["isAjaxRequest"] = "true";
	rst.params["x"] = 0.17838781489990652;

	return rst;
end

function InitStep1Response(info, response)
	local rst = check12306Response(response);
	if (rst.code < 0) then return rst; end;

	local sp, ep, val, reg = nil, nil, nil, nil;
	reg = "\/\*-secure%s*-%s*([^\*].-)%s*\*\/";
	sp, ep, jsonData = string.find(response.body, reg);

	local jData = cjson.decode(jsonData);
	local wlInstanceId = jData.challenges["wl_antiXSRFRealm"]["WL-Instance-Id"];
	local morCustomRealm = jData.challenges["morCustomRealm"]["WL-Challenge-Data"];

--~ 	local morCustomRealm = getObjectValueByPath(jsonData, "challenges.morCustomRealm.WL-Chanllenge-Data") or "";
--~ 	local wlInstanceId = getObjectValueByPath(jsonData, "challenges.wl_antiXSRFRealm.WL-Instance-Id") or "";
	if morCustomRealm == "" or wlInstanceId == "" then
		rst.code = -1;
		rst.message = "InstanceIdδ�ҵ�";
		return rst;
	end
	info["WL-Instance-Id"] = wlInstanceId;
	info["morCustomRealm"] = BuildCode(morCustomRealm);

	rst.code = 1;
	rst.message = "���ڳ�ʼ��"
	return rst;
end

function InitStep2Request(info)
	local rst = getEmptyReturn();
	rst.url = "https://mobile.12306.cn/otsmobile/apps/services/api/MobileTicket/iphone/init";--������Ҫ�����ֻ����Կ�
	rst.method = "POST";
    rst.info.message ="���ڳ�ʼ��75%";
	rst.header["User-Agent"] = "Mozilla/5.0 (iPhone; CPU iPhone OS 8_2 like Mac OS X) AppleWebKit/600.1.4 (KHTML, like Gecko) Mobile/12D508 (384115952)/Worklight/6.0.0";
    rst.header["X-Requested-With"] = "XMLHttpRequest";
    rst.header["x-wl-platform-version"] = "6.0.0";
    rst.header["x-wl-app-version"] = "2.0";
    rst.header["WL-Instance-Id"] = info["WL-Instance-Id"];

	--����Authorization�ֶ�
	local buffer = {};
	buffer["morCustomRealm"] = info["morCustomRealm"];
	--ƴ��Authorization�ֶ�
	local authorization = "";
	authorization = cjson.encode(buffer);
--~ 	for k, v in pairs(buffer) do
--~ 		authorization = authorization..'"'..k..'":"'..v..'",'
--~ 	end

    rst.header["Authorization"] = authorization;

	--����post�����params
	rst.params["skin"] = "default";
	rst.params["skinLoaderChecksum"] = "";
	rst.params["isAjaxRequest"] = "true";
	rst.params["x"] = 0.3400703438092023;

	return rst;
end

function InitStep2Response(info, response)
	local rst = check12306Response(response);
	if (rst.code < 0) then return rst; end;

	local sp, ep, val, reg = nil, nil, nil, nil;
	reg = "\/\*-secure%s*-%s*([^\*].-)%s*\*\/";
	sp, ep, jsonData = string.find(response.body, reg);

	local jData = cjson.decode(jsonData);
	local token = jData.challenges["wl_deviceNoProvisioningRealm"]["token"];
--~ 	local token = getObjectValueByPath(jsonData, "challenges.wl_deviceNoProvisioningRealm.token") or "";
	if token == "" then
		rst.code = -1;
		rst.message = "tokenδ�ҵ�";
		return rst;
	end
	info["token"] = token;

	rst.code = 1;
	rst.message = "���ڳ�ʼ��"
	return rst;
end

function InitStep3Request(info)
	local rst = getEmptyReturn();
	rst.url = "https://mobile.12306.cn/otsmobile/apps/services/api/MobileTicket/iphone/init";--������Ҫ�����ֻ����Կ�
	rst.method = "POST";
    rst.info.message ="���ڳ�ʼ��100%";
	rst.header["User-Agent"] = "Mozilla/5.0 (iPhone; CPU iPhone OS 8_2 like Mac OS X) AppleWebKit/600.1.4 (KHTML, like Gecko) Mobile/12D508 (384115952)/Worklight/6.0.0";
    rst.header["WL-Instance-Id"] = info["WL-Instance-Id"];
    rst.header["X-Requested-With"] = "XMLHttpRequest";
    rst.header["x-wl-app-version"] = "2.0";
    rst.header["x-wl-platform-version"] = "6.0.0";

	--����ID�ڲ��ֶ�
	local token = '"'..info["token"]..'"';
	local app = '{"id":"MobileTicket", "version":"2.0"}';
	local device = '{"id":"8DD483E3-1867-4DAF-8F9F-848236AC47F8", "os":"8.2", "model":"iPhone5,2", "environment":"iphone"}';

	--����ID�ֶ�
	local buffer = {};
	buffer["token"] = token;
	buffer["app"] = app;
	buffer["device"] = device;
	--ƴID�ֶ�
	local id = "";
	for k, v in pairs(buffer) do
		id = id..'"'..k..'":'..v..','
	end
	id = id.."custom:{},"
	id = '{'..id..'}'

	--����wl_deviceNoProvisioningRealm�ֶ�
	local buffer1 = {};
	buffer1["ID"] = id;
	--ƴdeviceNoProvisioningRealm�ֶ�
	local deviceNoProvisioningRealm = "";
	for k, v in pairs(buffer) do
		deviceNoProvisioningRealm = deviceNoProvisioningRealm..'"'..k..'":'..v..','
	end
	deviceNoProvisioningRealm = '{'..deviceNoProvisioningRealm..'}'

	--����Authorization�ֶ�
	local buffer2 = {};
	buffer2["wl_deviceNoProvisioningRealm"] = deviceNoProvisioningRealm;
	--ƴ��Authorization�ֶ�
	local authorization = "";
	for k, v in pairs(buffer2) do
		authorization = authorization..'"'..k..'":'..v..','
	end
	authorization = '{'..authorization..'}'

    rst.header["Authorization"] = authorization;
	--����post�����params
	rst.params["skin"] = "default";
	rst.params["skinLoaderChecksum"] = "";
	rst.params["isAjaxRequest"] = "true";
	rst.params["x"] = 0.7063577543012798;

	return rst;
end

function InitStep3Response(info, response)
	local rst = check12306Response(response);
	if (rst.code < 0) then return rst; end;
	print("InitStep3Response\nInitStep3Response\nInitStep3Response\n");
	return rst;
end

function doMoBileInitParser()
	local rst = tableToApp;
	local params, response, serverData = tableFromApp.params, tableFromApp.responseData, swapInfo.server_data;


	rst.code = 1;
	rst.message = "";

	if(swapInfo.server_cmd == nil) then
		rst.headsInfo = ReachRequest(serverData);
		swapInfo.server_cmd = "reach";
	elseif(swapInfo.server_cmd == "reach") then
--~ 		print("1");
		local info = ReachResponse(serverData, response);
		rst.code, rst.message, rst.dataInfo = info.code, info.message, nil;
		if (info.code < 0) then
			--������
		else
			rst.headsInfo = InitStep1Request(serverData);
			swapInfo.server_cmd = "initStep1";
		end
	elseif(swapInfo.server_cmd == "initStep1") then
		local info = InitStep1Response(serverData, response);
		rst.code, rst.message, rst.dataInfo = info.code, info.message, nil;
		if (info.code < 0) then
			--������
		else
			rst.headsInfo = InitStep2Request(serverData);
			swapInfo.server_cmd = "initStep2";
		end
	elseif(swapInfo.server_cmd == "initStep2") then
		local info = InitStep2Response(serverData, response);
		rst.code, rst.message, rst.dataInfo = info.code, info.message, nil;
		if (info.code < 0) then
			--������
		else
			rst.headsInfo = InitStep3Request(serverData);
			swapInfo.server_cmd = "initStep3";
		end
	elseif(swapInfo.server_cmd == "initStep3") then
		local info = InitStep3Response(serverData, response);
		rst.code, rst.message, rst.dataInfo = info.code, info.message, nil;
		if (info.code < 0) then
			--������
		end
	else
		rst.code, rst.message = -99, "δ֪����";
	end
end
--]]

---[[12306APP�˲�ѯ��Ʊ�����
function QueryLeftTicketRequest(info)
	local rst = getEmptyHeads();
	info.date = fixDate(info.date);
--~ 	��Fiddler�Ͽ���ͨ�����url��ͨ���������url���Ǻܱ�׼�����˼������������Ǿ����ܵ�ͨ��
--~ 	local url = {
--~ 		"https://mobile.12306.cn/otsmobile/invoke?adapter=CARSMobileServiceAdapterV2&procedure=queryLeftTicket&compressResponse=true",
--~ 		"&parameters=%5B%7B",
--~ 			"%22train_date%22%3A%22",info.date,	--20150413
--~ 			"%22%2C%22purpose_codes%22%3A%22",info.purpose_codes	--00
--~ 			"%22%2C%22from_station%22%3A%22",info.fromStation	--BJP
--~ 			"%22%2C%22to_station%22%3A%22",info.toStation	--SHH
--~ 			"%22%2C%22station_train_code%22%3A%22%22%2C%22start_time_begin%22%3A%220000%22%2C%22start_time_end%22%3A%222400%22%2C%22train_headers%22%3A%22QB%23%22%2C%22train_flag%22%3A%22%22%2C%22seat_type%22%3A%22%22%2C%22seatBack_Type%22%3A%22%22%2C%22ticket_num%22%3A%22%22%2C%22baseDTO.os_type%22%3A%22i%22%2C%22baseDTO.device_no%22%3A%227D88423C-A701-4FC6-A30C-1B338715FDE6%22%2C%22baseDTO.mobile_no%22%3A%22123444%22%2C%22baseDTO.time_str%22%3A%2220150409225715%22%2C"
--~ 	};
	local url = {
		"https://mobile.12306.cn/otsmobile/invoke?adapter=CARSMobileServiceAdapterV2&procedure=queryLeftTicket&compressResponse=true",
		"&parameters=%5B%7B",
			"%22train_date%22%3A%22",info.date,	--20150413
			"%22%2C%22purpose_codes%22%3A%22",info.purpose_codes	--00
			"%22%2C%22from_station%22%3A%22",info.fromStation	--BJP
			"%22%2C%22to_station%22%3A%22",info.toStation	--SHH
			"%22%2C%22station_train_code%22%3A%22%22%2C%22start_time_begin%22%3A%220000%22%2C%22start_time_end%22%3A%222400%22%2C%22train_headers%22%3A%22QB%23%22%2C%22train_flag%22%3A%22%22%2C%22seat_type%22%3A%22%22%2C%22seatBack_Type%22%3A%22%22%2C%22ticket_num%22%3A%22",
			"%22%2C%22baseDTO.os_type%22%3A%22","i",
			"%22%2C%22baseDTO.device_no%22%3A%",info.wlChallengeData.guid2,--227D88423C-A701-4FC6-A30C-1B338715FDE6
			"%22%2C%22baseDTO.mobile_no%22%3A%22","123444",
			"%22%2C%22baseDTO.time_str%22%3A%22",info.wlChallengeData.time,--20150409225715
			"%22%2C"
	};

	rst.request_method = "GET";
	rst.request_url = table.concat(url);
    rst.request_info.request_message ="���ڲ�ѯ";
	rst.request_info["header_User-Agent"] = "Mozilla/5.0 (iPhone; CPU iPhone OS 8_2 like Mac OS X) AppleWebKit/600.1.4 (KHTML, like Gecko) Mobile/12D508 (384115952)/Worklight/6.0.0";
    rst.request_info["header_WL-Instance-Id"] = info["WL-Instance-Id"];
    rst.request_info["header_X-Requested-With"] = "XMLHttpRequest";
    rst.request_info["header_x-wl-app-version"] = "2.0";
    rst.request_info["header_x-wl-platform-version"] = "6.0.0";
	return rst;
end

function QueryLeftTicketResponse(info, response)
	local rst = check12306Response(response);
	if (rst.code < 0) then return rst; end;

	local sp, ep, val, reg = nil, nil, nil, nil;
	reg = "\/\*-secure%s*-%s*([^\*].-)%s*\*\/";
	sp, ep, jsonData = string.find(response.body, reg);

	local list = getObjectValueByPath(jsonData, "ticketResult");
	if (list == nil) then
		rst.code, rst.message = -1, getObjectValueByPath(jsonData, "error_message");--����Ҫ���Ҹ������������������Ĵ�����ʽ
		if (rst.message == nil) then
			rst.message = "û�з��������ĳ���(001)";
		end;
		return rst;
	end

	--���ݸ�ʽת��
	local rst_list = nil;
	for k,v in ipairs(list) do
		v.date = info.date; --���ڴ���
		local obj = buildTrainInfo(v);

		if (obj ~= nil) then
			if (rst_list == nil) then
				rst_list = {}
			end;
			table.insert(rst_list, obj);
		end;
	end

	if (rst_list ~= nil) then
		rst.data.trainList, rst.json = rst_list, nil;
	else
		rst.code, rst.message = -1, "û���ҵ����ϵĳ���";
	end

	return rst;
end

--���ѵ�������12306��������΢��һ�������ѵĳ�ʼ��ѯֻ��ҪtoCode��fromCode, data, trainFlag,��������Ĭ��ֵ
function doMobileQueryLeftTicketParser()
	local rst = tableToApp;
	local params, response, serverData = tableFromApp.params, tableFromApp.responseData, swapInfo.server_data;

	rst.code = 1;
	rst.message = "";
	if(swapInfo.server_cmd == nil) then
		--���Ʋ���
		copyTable(params, serverData);
		local info = checkYuPiaoParams(serverData);
		rst.code, rst.message = info.code, info.message;
		--����Header
		rst.headsInfo = QueryLeftTicketRequest(serverData);
		swapInfo.server_cmd = "queryLeftTicket";
	elseif(swapInfo.server_cmd == "queryLeftTicket") then
		local info = QueryLeftTicketResponse(serverData, response);
		rst.code, rst.message, rst.dataInfo = info.code, info.message, nil;

		if (info.code > 0) then
			rst.dataInfo = info.data.trainList;
		else--if (info.code <= -100) then
			rst.dataInfo = nil;
--~ 		else
--~ 			rst.headsInfo = headsForQueryYuPiao(serverData);
--~ 			swapInfo.server_cmd = "QueryYuPiao";
--~ 			rst.code = 1;
		end

	else
		rst.code, rst.message = -99, "δ֪����";
	end
end
--]]

---[[12306APP�˲�ѯĳ���εľ����г̴����
function QueryStopStationRequest(info)
	local rst = getEmptyHeads();
	info.date = fixDate(info.date);
	if (info.fromCode == nil or (string.len(info.fromCode) ~= 3)) then info.fromCode = "AAA" end;
	if (info.toCode == nil or (string.len(info.toCode) ~= 3)) then info.toCode = "AAA" end;

	rst.request_url = "https://mobile.12306.cn/otsmobile/apps/services/api/MobileTicket/iphone/query";
	rst.request_method = "POST";
    rst.request_info.request_message ="���ڲ�ѯ";
	rst.request_info["header_User-Agent"] 			 = "Mozilla/5.0 (iPhone; CPU iPhone OS 8_2 like Mac OS X) AppleWebKit/600.1.4 (KHTML, like Gecko) Mobile/12D508 (384115952)/Worklight/6.0.0";
	rst.request_info["header_Content-Type"] 		 = "application/x-www-form-urlencoded";
    rst.request_info["header_WL-Instance-Id"] 	 	 = info["WL-Instance-Id"];
    rst.request_info["header_X-Requested-With"] 	 = "XMLHttpRequest";
    rst.request_info["header_x-wl-app-version"] 	 = "2.0";
    rst.request_info["header_x-wl-platform-version"] = "6.0.0";

	--����params��parameters�ֶ�
	local parameters = {};
    local parameter = {};
    parameter["baseDTO.os_type"] 		= "i";
    parameter["baseDTO.device_no"] 		= info.wlChallengeData.guid2;
    parameter["baseDTO.mobile_no"] 		= "123444";
    parameter["baseDTO.time_str"] 		= info.wlChallengeData.time;
    parameter["baseDTO.check_code"] 	= info.wlChallengeData.checkcode;
    parameter["baseDTO.version_no"] 	= "1.1";
    parameter["baseDTO.user_name"] 		= info.username;
    parameter["depart_date"] 			= info.date;			--�����date�ĸ�ʽ��"20150410"��������ʽ����֪���������Ĳ�����ʲô��ʽ��
    parameter["from_station_telecode"] 	= info.fromCode;
    parameter["to_station_telecode"] 	= info.toCode;
    parameter["train_no"] 				= info.trainNo;
    table.insert(parameters,parameter);
    local parametersstr = cjson.encode(parameters);

	--����post�����params
	rst.params["adapter"] 				= "CARSMobileServiceAdapterV2";
	rst.params["procedure"] 			= "stopStationQuery";
	rst.params["parameters"] 			= parametersstr;
	rst.params["compressResponse"] 		= "true";
	rst.params["__wl_deviceCtxVersion"] = "-1";
	rst.params["__wl_deviceCtxSession"] = 107556181428591422209;
	rst.params["isAjaxRequest"] 		= "true";
	rst.params["x"] 					= 0.750862512504682;

	return rst;
end

function QueryStopStationResponse(info, response)
	local rst = check12306Response(response);
	if (rst.code < 0) then return rst; end;

	local sp, ep, val, reg = nil, nil, nil, nil;
	reg = "\/\*-secure%s*-%s*([^\*].-)%s*\*\/";
	sp, ep, jsonData = string.find(response.body, reg);

	local list = getObjectValueByPath(jsonData, "list");

	rst.data.train_no = info.train_no;
	rst.data.station_train_code = nil;
	--���ݸ�ʽת��
	local rst_list = {};
	for k,v in ipairs(list) do
		local obj = {};
		if (rst.data.station_train_code == nil) then
			copyTableValue(v, rst.data, "station_train_code,train_class_name,service_type");
		end
		copyTableValue(v, obj, "station_name,arrive_time,start_time,stopover_time");

		obj.station_no = tonumber(v.station_no);
		obj.stopover_value = getStopoverValue(v.stopover_time);

		table.insert(rst_list, obj);
	end

	--��������
	if (rst.data.station_train_code ~= nil) then
		table.sort(rst_list, function(a, b) return b.station_no > a.station_no end)
		local mm, lm = 0, nil;
		for k,v in ipairs(rst_list) do
			if (lm ~= nil) then mm = mm + calcMinuteStrSpan(lm, v.arrive_time); end
			lm = v.start_time;
			v.total_time = mm;
			mm = mm + v.stopover_value;
		end

		rst.data.stations, rst.json = rst_list, nil;
	else
		--û������
		rst.code, rst.message = -1, "û���ҵ���س���";
	end

	return rst;
end

function doMobileQueryStopStationParser()
	local rst = tableToApp;
	local params, response, serverData = tableFromApp.params, tableFromApp.responseData, swapInfo.server_data;

	rst.code = 1;
	rst.message = "";
	if(swapInfo.server_cmd == nil) then
		--���������֮ǰ�ģ��滻�ɽ���
		local ymd_now = ymdForNow();
		local ymd_min, ymd_max = ymdAddDay(ymd_now, -30), ymdAddDay(ymd_now, 60);
		local ymd_date = ymdForDate(params.date);
		if (ymd_date < ymd_min or ymd_date > ymd_max) then params.date = ymd_date end;

		--���Ʋ���
		copyTable(params, serverData);

		--����Header
		rst.headsInfo = QueryStopStationRequest(serverData);
		swapInfo.server_cmd = "queryStopStation";
	elseif(swapInfo.server_cmd == "queryStopStation") then
		local info = QueryStopStationResponse(serverData, response);
		rst.code, rst.message, rst.dataInfo = info.code, info.message, nil;

		if (info.code > 0) then
			rst.dataInfo = info.data.trainList;
		else
			rst.dataInfo = nil;
		end
	else
		rst.code, rst.message = -99, "δ֪����";
	end
end
--]]

--��ں���
function doParser(source, action, json)
    --��ʼ��
	tableFromApp, tableToApp = cjson.decode(json), {};
    swapInfo = tableFromApp.swapInfo;
    sourceType = source;
	if (swapInfo == nil) then swapInfo = {} end;
    if (swapInfo.server_data == nil) then swapInfo.server_data = {} end;

	--�������Ϣ
	tableToApp.swapInfo = swapInfo;

	if (action == "mobileinit") then
      doMoBileInitParser();						--12306APP�˳�ʼ��
    elseif (action == "mobilequeryleftticket") then
      doMobileQueryLeftTicketParser();			--ͨ��12306APP�˲�ѯ��Ʊ
	elseif (action == "mobilequerystopstation") then
      doMobileQueryStopStationParser();			--ͨ��12306APP�˲�ѯĳ���εľ����г�
    else
      tableToApp.code, tableToApp.message = -1, "���ܽ���"..action;
    end

    if (tableToApp.headsInfo == nil) then
        if (swapInfo ~= nil) then swapInfo.server_data, swapInfo.server_cmd = nil, nil end;
    end
    local rst = cjson.encode(tableToApp);
    tableFromApp,tableToApp,swapInfo = nil, nil, nil;
    return rst;
end


--~ aa = doParser("", "mobileinit", [[{"code":1,"params":"","responseData":{"body":"OK","code":200,"header":""},"swapInfo":{"server_cmd":"reach","server_data":[]}}
--~ ]])
--~ print(aa)

