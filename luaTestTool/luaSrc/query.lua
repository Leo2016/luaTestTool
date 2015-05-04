require("json");

function query()
	local aa = { ['aa'] = 'a2',
				 ['bb'] = 'b2',
				 ['cc'] = 'c2',
	};
	return aa;
end

function doParse()
	local bb = query();
	return cjson.encode(bb);
end

dd = doParse();
print(dd);
