function cacheResulturl(url) {
	Ext.Ajax
		.request({
			url : 'http://kyounonihonngo.sinaapp.com/result.php?url=' + url,
		success : function(response, opts) {
			try {
				currentResult = JSON.parse(response.responseText);
				if (currentResult) {
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
	var today = date_format(new Date());
	var doneToday = localStorage[today];
	if( doneToday == undefined ) {
		Ext.Ajax
			.request({
				url : 'http://kyounonihonngo.sinaapp.com/mondai.php?date=' + today,
				success : function(response, opts) {
					try {
						currentMondai = JSON.parse(response.responseText);
						if (currentMondai) {
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
