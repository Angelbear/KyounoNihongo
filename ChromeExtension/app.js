Ext
.setup({
	icon : 'img/icon_2x.png',
	tabletStartupScreen : 'img/tablet_startup.png',
	phoneStartupScreen : 'img/phone_startup.png',
	glossOnIcon : false,
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
		var oauth = background.oauth;
	
		function Ouath(){
		  if (oauth.hasToken())
		  {
				alert("�Ѿ���Ȩ");
		  }else{
				background.authorize();
		  }
		}
		
		function checkNewMondai() {
			var today = new Date().format('Y-m-d');
			var doneToday = localStorage[today];
			if( doneToday == undefined ) {
				chrome.browserAction.setBadgeText({text: '1'}); 
			}else{
				chrome.browserAction.setBadgeText({text: ''}); 
			}
		}

		var currentMondai;
		function updateMondai(date) {
			Ext.Ajax
					.request({
						url : 'http://kyounonihonngo.sinaapp.com/mondai.php?date=' + date,
						success : function(response, opts) {
							currentMondai = eval('('
									+ response.responseText + ')');
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
					});
		}

		var currentResult;
		var tapHandler = function(btn, evt) {
			localStorage[selectedDate] = true;
			checkNewMondai();
			inner.setActiveItem(formback, 'slide');
			var url = Ext.getCmp('choice1').getGroupValue();
			Ext.Ajax
					.request({
						url : 'http://kyounonihonngo.sinaapp.com/result.php?url=' + url,
						success : function(response, opts) {
							currentResult = eval('('
									+ response.responseText + ')');
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
					});

		};

		var tapHandler2 = function(btn, evt) {
			inner.setActiveItem(form, {
				type : 'slide',
				direction : 'right'
			});
		};

		var shareHandler = function(btn, evt) {
		  if(currentMondai) {
			var weibo = decodeURIComponent(currentMondai.question).replace('<span+class=goken-ul>','<').replace('</span>','>') + " 1." + decodeURIComponent(currentMondai.choice[0].text) + " 2." + decodeURIComponent(currentMondai.choice[1].text) + " 3." + decodeURIComponent(currentMondai.choice[2].text);
			
			weibo = weibo + "\t" + selectedDate + "��#���յ��ձ���춨#" + "http://kyounonihonngo.sinaapp.com/gokenlist.php?date="+selectedDate;
			background.updateWeibo(weibo);
		  }
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
				title : 'ѡ��',
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
				text : '�鿴��',
				handler : tapHandler

			}, {
				xtype : 'fieldset',
				items : [ calendarView ]
			} ],
			dockedItems : [ {
				xtype : 'toolbar',
				dock : 'top',
				title : '���յ��ձ���춨',
				items : [ {
					text: '����',
					ui: 'action',
					handler: aboutHandler
				},{
					xtype : 'spacer'
				}, {
					iconMask : true,
					ui : 'plain',
					iconCls : 'bookmarks',
					handler : function() {
						Ouath();
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
							maxRows : 16,
							preventScrollbars: false,
							listeners : {
								afterrender : function(ele) {
									ele.fieldEl.dom.readOnly = true;
								}
							}
						} ]
					} ,{
						xtype : 'button',
						ui : 'round',
						text : '��������΢��',
						handler : shareHandler

					}],
			dockedItems : [ {
				xtype : 'toolbar',
				dock : 'top',
				title : '���',
				items : [ {
					iconMask : true,
					ui : 'back',
					text : '����',
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
							html : '<center>kyounonihonngo.sinaapp.com����ChaosYang�������յ��ձ���춨����ҳ�Ϳͻ��ˣ��������ݾ�����<a href="http://www.jiji.com" media="handheld" rel=external>�r�¥ɥåȥ���</a>����<b>��������ҵ��;</b>����ӭָ��bug����������޸Ľ��飡</center><center>��ϵ����:<a href="mailto:yangyang.zhao.thu@gmail.com">yangyang.zhao.thu@gmail.com</a><br></center>',
						} ],
				dockedItems : [ {
					xtype : 'toolbar',
					dock : 'top',
					title : '����',
					items : [ {
						iconMask : true,
						ui : 'back',
						text : '����',
						handler : tapHandler2
					} ]
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
		checkNewMondai();
	}
});
