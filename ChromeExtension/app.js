Ext
.setup({
  onReady : function() {

			  var selectedDate = new Date().format('Y-m-d');
			  var calendarView;

			  calendarView = new Ext.ux.TouchCalendarView({
				minDate : new Date("2012-01-04"),
						   maxDate : new Date(),
						   value : new Date(selectedDate),
						   onSelectionChange : function(selectionModel, records) {
							 if (records.length > 0) {
							   selectedDate = records[0].get('date').format('Y-m-d');
							   updateMondai(selectedDate);
							 }
						   }
			  });

			  var background = chrome.extension.getBackgroundPage();

			  function updateMondaiUI() {
				Ext
				  .getCmp('mondai')
				  .update(decodeURIComponent(currentMondai.question).replace('span+class=goken-ul','goken').replace('span','goken'));
				Ext.getCmp('choice1').labelEl
				  .update(decodeURIComponent(currentMondai.choice[0].text));
				Ext.getCmp('choice2').labelEl
				  .update(decodeURIComponent(currentMondai.choice[1].text));
				Ext.getCmp('choice3').labelEl
				  .update(decodeURIComponent(currentMondai.choice[2].text));

				Ext.getCmp('choice1').setValue(
					currentMondai.choice[0].link);
				Ext.getCmp('choice2').setValue(
					currentMondai.choice[1].link);
				Ext.getCmp('choice3').setValue(
					currentMondai.choice[2].link);

			  }

			  var currentMondai;

			  function updateMondai(date) {
				var mondai = localStorage[date];
				if(mondai == undefined || mondai == "") {
				  Ext.Ajax
					.request({
					  url : 'http://kyounonihonngo.sinaapp.com/mondai.php?date=' + date,
					  success : function(response, opts) {
						currentMondai = JSON.parse(response.responseText);
						chrome.browserAction.setBadgeText({text: ''});
						localStorage[date] = response.responseText;
						updateMondaiUI();
					  }});
				}else {
				  currentMondai = JSON.parse(mondai);
				  chrome.browserAction.setBadgeText({text: ''});
				  updateMondaiUI();
				}
			  }

			  var currentResult;

			  function updateResultUI() {
				Ext
				  .getCmp('answer')
				  .setValue(
					  decodeURIComponent(currentResult.explain));
				var imgname = decodeURIComponent(currentResult.image);
				if (imgname.match('huseikai.gif') != null) {
				  Ext
					.getCmp('image')
					.update(
						'<img class="expandedImg" align="center" src="../img/huseikai.gif" />');
				} else {
				  Ext
					.getCmp('image')
					.update(
						'<img class="expandedImg" align="center" src="../img/seikai.gif" />');
				}
			  }
			  var tapHandler = function(btn, evt) {
				background.checkNewMondai();
				inner.setActiveItem(formback, 'slide');
				var url = Ext.getCmp('choice1').getGroupValue();
				var result = localStorage[url];
				if(result == undefined) {
				  Ext.Ajax
					.request({
					  url : 'http://kyounonihonngo.sinaapp.com/result.php?url=' + url,
					  success : function(response, opts) {
						currentResult = JSON.parse(response.responseText);
						localStorage[url]=response.responseText;
						updateResultUI();
					  }
					});
				}else{
				  currentResult = JSON.parse(localStorage[url]);
				  updateResultUI();
				}

			  };

			  var tapHandler2 = function(btn, evt) {
				inner.setActiveItem(form, {
				  type : 'slide',
				  direction : 'right'
				});
			  };

			  var aboutHandler = function(btn, evt) {
				inner.setActiveItem(formabout, {
				  type : 'slide'
				});
			  }

			  var form;
			  var formback;
			  var mondai;
			  var kaisetsu;

			  mondai = {
				standardSubmit : false,
				width: '400px',
				height: '600px',
				items : [ {
				  xtype : 'fieldset',
				  items : [ {
					xtype : 'panel',
					cls : 'white',
					items : [ {
					  xtype : 'container',
					  name : 'mondai',
					  id : 'mondai',
					  html : 'value',
					  cls : 'white',
					  margin : '5px',
					  height: '80px'
					} ] 
				  }]
				}, {
				  xtype : 'fieldset',
				  title : '选项',
				  defaults : {
					xtype : 'radiofield',
					labelWidth : '50%',
					listeners : {
					  afterrender : function(ele) {
									  ele.fieldEl.dom.readOnly = true;
									}
					}
				  },
				  items : [ {
							xtype : 'radiofield',
							name : 'choice',
							id : 'choice1',
							label : 'A',
							checked : true
						  }, {
							xtype : 'radiofield',
							name : 'choice',
							label : 'B',
							id : 'choice2'
						  }, {
							xtype : 'radiofield',
							name : 'choice',
							label : 'C',
							id : 'choice3'
						  } ]
				}, {
				  xtype : 'button',
						ui : 'round',
						text : '查看答案',
						handler : tapHandler

				}, {
				  xtype : 'fieldset',
						items : [ calendarView ]
				} ],
				dockedItems : [ {
								xtype : 'toolbar',
								dock : 'top',
								title : '今日的日本语检定',
								items : [ {
								  text: '关于',
								  ui: 'action',
								  handler: aboutHandler
								},{
								  xtype : 'spacer'
								}, {
								  iconMask: true,
								  ui : 'plain',
								  iconCls : 'bookmarks',
								  handler : function() {
									if (calendarView.hidden == true) {
									  calendarView.show();
									} else {
									  calendarView.hide();
									}

								  }
								} ]
							  } ]
			  };

			  kaisetsu = {
				standardSubmit : false,
				width: '400px',
				height: '600px',
				items : [
				{
				  xtype : 'fieldset',
				  items : [ {
					xtype : 'panel',
					id : 'image',
					height : '100px',
					iconMask : false,
					html : '<img class="expandedImg" align="center" src="../img/seikai.gif"/>'
				  } ]
				},
				{
				  xtype : 'fieldset',
				  items : [ {
					xtype : 'textareafield',
					id : 'answer',
					value : 'value',
					maxRows : 18,
					preventScrollbars: false,
					listeners : {
					  afterrender : function(ele) {
									  ele.fieldEl.dom.readOnly = true;
									}
					}
				  } ]
				} ],
				dockedItems : [ {
								xtype : 'toolbar',
								dock : 'top',
								title : '解答',
								items : [ {
								  iconMask : true,
								  ui : 'back',
								  text : '后退',
								  handler : tapHandler2
								} ]
							  } ]
			  };
			  about = {
				standardSubmit : false,
				width: '400px',
				height: '600px',
				items : [
				{
				  xtype : 'panel',
				  html : '<br><center>今日的日本语检定Chrome插件是由poweruser开发#今日的日本语检定#的Chrome插件，所用数据均来自<a href="javascript:chrome.tabs.create({url:\'http://www.jiji.com\'}, function() {});">時事ドットコム</a>，并<b>不用作商业用途</b>。欢迎指出bug，提出更好修改建议！</center><center>联系作者:<a href="mailto:yangyang.zhao.thu@gmail.com">yangyang.zhao.thu@gmail.com</a><br></center><br><center>此外欢迎使用新浪微博版本，可以发送每日趣题到新浪微博，请访问<a href="javascript:chrome.tabs.create({url:\'http://kyounonihonngo.sinaapp.com/\'}, function() {});">今日的日本语检定</a>来查看更多详情</center><br>',
				},
				{
				  xtype : 'button',
				  ui : 'round',
				  text : '下载新浪微博版本',
				  handler : function() {
					chrome.tabs.create({url:'http://kyounonihonngo.sinaapp.com/app/KyounoNihongo.crx'}, function(){});
				  }
				}			],
				dockedItems : [ {
								xtype : 'toolbar',
								dock : 'top',
								title : '关于',
								items : [ {
								  iconMask : true,
								  ui : 'back',
								  text : '后退',
								  handler : tapHandler2
								}, {
								  xtype: 'spacer'
								}
								]
							  } ]
			  };


			  form = new Ext.form.FormPanel(mondai);

			  formback = new Ext.form.FormPanel(kaisetsu);

			  formabout = new Ext.form.FormPanel(about);

			  var inner = new Ext.Panel({
				layout : 'card',
				  fullscreen : true,
				  width: '400px',
				  height: '600px',
				  items : [ form, formback, formabout ]
			  });
			  inner.show();
			  updateMondai(selectedDate);
			  background.checkNewMondai();
			}
});
