cjson = require("json")


local jsonstring = [[{"code":1,"params":"","responseData":{"body":"/*-secure-\n{\"challenges\":{\"wl_antiXSRFRealm\":{\"WL-Instance-Id\":\"r6iuppdi6aij9d6p9hklggul84\"},\"morCustomRealm\":{\"WL-Challenge-Data\":\"850143N829873C301066N653429C855665C753989X5134FDB0S084528N001215C551770XF3CF7276S523897N323672XC490ECF1S\"}}}*/","code":200,"header":""},"swapInfo":{"server_cmd":"initStep1","server_data":[]}}]]

print("--------------0000::");
local jsonety = cjson.decode(jsonstring);
print("--------------1111::");
local responseData = jsonety.responseData;
print(responseData)
for k,v in pairs(responseData) do
	print(k, v)
end
print("--------------2222::");
local body = responseData.body;
print("--------------3333::");
