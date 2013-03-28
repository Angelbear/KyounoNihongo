function cacheResulturl(url) {
	Ext.Ajax
		.request({
			url : 'http://kyounonihonngo.sinaapp.com/result.php?url=' + url,
		success : function(response, opts) {
			try {
				currentResult = JSON.parse(response.responseText);
				if (currentResult && currentResult != 'false') {
					localStorage[url]=response.responseText;
				}
			} catch (e) {
			}
		}
		});
}

function date_format(d) {
	var dd = d.getDate();
	var mm = d.getMonth()+1;//January is 0!
	var yyyy = d.getFullYear();
	if (dd < 10) { dd = '0' + dd; }
	if (mm < 10) { mm = '0' + mm; }
	return yyyy + "-" + mm + "-" + dd;
}

function checkNewMondai() {
	var maxValue;
	var today = new Date();
	var yesterday = new Date(new Date().setDate(new Date().getDate()-1));
	if (today.getHours() > 2) {
		maxValue = today;
	} else {
		maxValue = yesterday;
	}
	var today_str = date_format(maxValue);
	var doneToday = localStorage[today_str];
	if( doneToday == undefined ) {
		Ext.Ajax
			.request({
				url : 'http://kyounonihonngo.sinaapp.com/mondai.php?date=' + today_str,
				success : function(response, opts) {
					try {
						currentMondai = JSON.parse(response.responseText);
						if (currentMondai && currentMondai != 'false') {
							localStorage[today] = response.responseText;
						}
						cacheResulturl(currentMondai.choice[0].link);
						cacheResulturl(currentMondai.choice[1].link);
						cacheResulturl(currentMondai.choice[2].link);
					} catch (e) {
					}
				}});
		chrome.browserAction.setBadgeText({text: '1'});
	}
}
