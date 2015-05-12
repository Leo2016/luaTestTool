--日期修正
function dateAddDay(date, day, fmt)
	if (fmt == nil) then fmt = "%Y%m%d" end;
	if (date == nil) then return date end;
	local reg, sp, ep, ty, tm, td;
	local isok = 0;

	if (isok == 0) then
		sp, ep, ty, tm, td = string.find(date, "^(%d%d%d%d)(%d%d)(%d%d)$");
		if (sp ~= nil) then isok = 1 end;
	end

	if (isok == 0) then
		local str = string.gsub(string.gsub(string.gsub(date, "年", "y"), "月", "m"), "日", "d");
		sp, ep, ty, tm, td = string.find(str, "(%d+)[y%-](%d+)[m%-](%d+)");
		if (sp ~= nil) then isok = 1 end;
	end

	if (isok == 0) then return date end;

	td = td + day;
	local rst = os.date(fmt, os.time({year = ty, month = tm, day = td}));
	return rst;
end

function fixDate(date, fmt) return dateAddDay(date, 0, fmt); end;

aa = "20150512"
bb = fixDate(aa)
print(bb)
info = {}
	local url = {
			'https://mobile.12306.cn/otsmobile/invoke?adapter=CARSMobileServiceAdapterV2&procedure=queryLeftTicket&compressResponse=true&parameters=%5B%7B%22train_date%22%3A%22',
			info.date,
			'%22%2C%22purpose_codes%22%3A%2200%22%2C%22from_station%22%3A%22',
			info.fromCode,
			'%22%2C%22to_station%22%3A%22',
			info.toCode,
			'%22%2C%22station_train_code%22%3A%22%22%2C%22start_time_begin%22%3A%22',
			info.startTime,
			'%22%2C%22start_time_end%22%3A%22',
			info.endTime,
			'%22%2C%22train_headers%22%3A%22QB%23%22%2C%22train_flag%22%3A%22%22%2C%22seat_type%22%3A%22%22%2C%22seatBack_Type%22%3A%22%22%2C%22ticket_num%22%3A%22%22%2C%22baseDTO.os_type%22%3A%22i%22%2C%22baseDTO.device_no%22%3A%227D88423C-A701-4FC6-A30C-1B338715FDE6%22%2C%22baseDTO.mobile_no%22%3A%22123444%22%2C%22baseDTO.time_str%22%3A%2220150409225715%22%2C%22baseDTO.check_code%22%3A%22437e0cccc99d3bb0fb225da8bac90ceb%22%2C%22baseDTO.version_no%22%3A%221.1%22%2C%22baseDTO.user_name%22%3A%22w810.cc%40gmail.com%22%7D%5D&__wl_deviceCtxVersion=-1&__wl_deviceCtxSession=107556181428591422209&isAjaxRequest=true&x=0.7115434680599719'
	};
