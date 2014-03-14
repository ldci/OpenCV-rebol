#! /usr/bin/rebol
REBOL [
	Title:		"RebGUI Documentation"
	Owner:		"Ashley G. Trüter"
	Purpose:	"Documents & demonstrates RebGUI widgets, requestors and functions."
	History: {
		110	Initial release
		111	References new requestors object
		112	Added color panel
		117	Added space after drop-list, edit-list and menu widgets
	}
]

do %rebgui.r

make object! [

	widgets:	sort find first ctx-rebgui/widgets 'anim
	requestors:	find first ctx-rebgui/requestors 'alert
	functions:	find first ctx-rebgui/functions 'append-widget
	objects:	copy [rebface ctx-rebgui/behaviors ctx-rebgui/colors ctx-rebgui/edit ctx-rebgui/effects ctx-rebgui/locale* ctx-rebgui/on-fkey ctx-rebgui/sizes ctx-rebgui/subface]

	sizes: make object! [
		view:		to integer! (length? mold/only get ctx-rebgui/view*) / 1024
		locale:		to integer! (length? mold/only get ctx-rebgui/locale*) / 1024
		rebgui:		to integer! (length? mold/only get ctx-rebgui) / 1024 - view - locale
		widgets:	to integer! (length? mold/only get ctx-rebgui/widgets) / 1024
		requestors:	to integer! (length? mold/only get ctx-rebgui/requestors) / 1024
		functions:	to integer! (length? mold/only get ctx-rebgui/functions) / 1024
		objects:	rebgui - widgets - requestors - functions
	]
	
	func-help: make function! ['word /local s p1 p2] [
		p1: :print
		p2: :prin
		s: make string! 4096
		print: make function! [data] [insert tail s form reduce data insert tail s "^/"]
		prin: make function! [data] [insert tail s form reduce data]
		help :word
		print: :p1
		prin: :p2
		trim/tail s
	]

	show-ref: make function! [word face /widget /requestor /object /local txt lnk lay arg] [
		all [word? word word: to word! word]
		txt: either widget [examine/no-print :word] [func-help :word]
		lnk: case [
			widget		[http://trac.geekisp.com/rebgui/browser/widgets/]
			requestor	[http://trac.geekisp.com/rebgui/browser/requestors/]
			object		[http://trac.geekisp.com/rebgui/browser/]
			true		[http://trac.geekisp.com/rebgui/browser/functions/]
		]
		if requestor [
			arg: switch/default word [
				request-menu		[[ face ["A" [] "B" [] "C" []] ]]
				request-progress	[[ 10 [loop 10 [wait .5 step]] ]]
				request-spellcheck	[[ make rebface [text: "wordz"] ]]
				splash				[[ %images/logo.png unview ]]
			][
				copy "Text."
			]
		]
		lay: compose/deep [
			after 1
			heading (either object [form word] [uppercase/part form word 1])
			panel 150 data [
				after 2
				label 20 "Source"	link (rejoin [lnk either object [%rebgui-ctx] [word] %.r])
				label 20 "Size"		text (remove reform [to money! (length? mold/only get either widget [ctx-rebgui/widgets/:word] [either word? word [word] [do word]]) / 1024 "Kb"])
			]
		]
		all [
			widget
			insert tail lay compose/deep [panel 150 data [(load trim second parse/all txt "^/")]]
			all [
				find [drop-list edit-list menu] word
				insert tail last lay 'return
				insert tail last lay 'text
			]
		]
		all [
			requestor
			insert tail lay compose/deep [panel 150 data [button 45x15 (form word) [(word) (arg)]]]
		]
		insert tail lay [panel 150 data [text txt font [name: font-fixed]]]
		lay: ctx-rebgui/layout/only lay
		face/pane/1/pane: lay
		face/pane/1/size: lay/size
		face/action/on-resize face
		if scroll/picked = 2 [face/pane/2/data: 0]
		show face
	]

	scroll: none

	do show-tour: make function! [] [
		display "RebGUI Documentation" [
			image %images/logo.png tip "RebGUI logo"
			return
			tab-panel data [
				"Widgets" [
					text-list 40x112 data widgets [
						show-ref/widget face/selected page1
					]
					page1: scroll-panel 162x112 options [offset] data [
						after 1
						heading "Widgets"
						panel 150 data [
							after 2
							label 20 "Source"	link http://trac.geekisp.com/rebgui/browser/rebgui-widgets.r
							label 20 "Size"		text (reform [sizes/widgets "Kb"])
							label 20 "Number"	text (form length? widgets)
						]
						panel 150 data [
							text (func-help ctx-rebgui/widgets) font [name: font-fixed]
						]
					]
				]
				"Requestors" [
					text-list 40x112 data requestors [
						show-ref/requestor face/selected page2
					]
					page2: scroll-panel 162x112 options [offset] data [
						after 1
						heading "Requestors"
						panel 150 data [
							after 2
							label 20 "Source"	link http://trac.geekisp.com/rebgui/browser/rebgui-requestors.r
							label 20 "Size"		text (reform [sizes/requestors "Kb"])
							label 20 "Number"	text (form length? requestors)
						]
						panel 150 data [
							text (func-help ctx-rebgui/requestors) font [name: font-fixed]
						]
					]
				]
				"Functions" [
					text-list 40x112 data functions [
						show-ref face/selected page3
					]
					page3: scroll-panel 162x112 options [offset] data [
						after 1
						heading "Functions"
						panel 150 data [
							after 2
							label 20 "Source"	link http://trac.geekisp.com/rebgui/browser/rebgui-functions.r
							label 20 "Size"		text (reform [sizes/functions "Kb"])
							label 20 "Number"	text (form length? functions)
						]
						panel 150 data [
							text (func-help ctx-rebgui/functions) font [name: font-fixed]
						]
					]
				]
				"Objects" [
					text-list 40x112 data objects [
						show-ref/object face/selected page4
					]
					page4: scroll-panel 162x112 options [offset] data [
						after 1
						heading "Objects"
						panel 150 data [
							after 2
							label 20 "Source"	link http://trac.geekisp.com/rebgui/browser/rebgui-ctx.r
							label 20 "Size"		text (reform [sizes/objects "Kb"])
							label 20 "Number"	text (form length? objects)
						]
						panel 150 data [
							text (func-help ctx-rebgui) font [name: font-fixed]
						]
					]
				]
				"Colors" [
					group-box "Theme" data [
						label-size 25x10
						text-size -1x10
						after 3
						label "page"			pill ctx-rebgui/colors/page			text "Main background^/Reversed text"
						label "text"			pill ctx-rebgui/colors/text			text "Normal text"
						label "theme-light"		pill ctx-rebgui/colors/theme-light	text "Over / selection background"
						label "theme-dark"		pill ctx-rebgui/colors/theme-dark	text "Heading background^/Edit edge"
						label "state-light"		pill ctx-rebgui/colors/state-light	text "Temporary state (e.g. button down)"
						label "state-dark"		pill ctx-rebgui/colors/state-dark	text "Permanent state (e.g. radio selection)"
						label "outline-light"  pill ctx-rebgui/colors/outline-light	text "Info background^/Non-edit edge^/Slider background"
						label "outline-dark"	pill ctx-rebgui/colors/outline-dark	text "Informational text"
					]
				]
			]
			return
			bar
			reverse
			button "Close"	[quit]
			button "UI"		[if request-ui [unview/all show-tour]]
			button "Stats"	[
				display "Stats" [
					label-size 20
					after 2
					label "Memory"	text (reform [to integer! system/stats / 1024 / 1024 "Mb"])
					label "Source"	text (reform [sizes/rebgui "Kb"])
					pie-chart 40x40 data [
						"Widgets"		red		sizes/widgets
						"Requestors"	green	sizes/requestors
						"Functions"		blue	sizes/functions
						"Objects"		yellow	sizes/objects
					]
					return
					bar
					reverse
					button "Close" [unview/only face/parent-face]
				]
			]
			scroll: radio-group 30x5 data [1 "Sticky" "Reset"]
			label "Scroll:"
		]
	]
]

do-events