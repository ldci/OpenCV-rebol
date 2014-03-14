#! /usr/bin/rebol
REBOL [
	Title:		"RebGUI widget tour"
	Owner:		"Ashley G. Trüter"
	Purpose:	"Demonstrates all stable RebGUI widgets in action."
	History: {
		14	Renamed Picture category to Graphic
			Added pie-chart under 'Graphic'
		16	do %rebgui-ctx.r before %rebgui.r
			Removed word / path parenthesis that are no longer needed
		17	Removed compose/deep/only
			Removed several inline () from data blocks
		25	Reinstated include
		40	Added colors/button
			Build# now appears in title
		48	Added input-grid and panel to demo
		49	Added spinner widget
		51	Replaced appearance settings with request-ui
		52	Minor testing changes
		53	New button changes
		60	Fixes for new default button size
		62	Added menu widget and request-menu
		63	Added link widget
		65	Cleaned up comments
			Removed input-grid and recoded splash call
		68	Fixed drop-list/tuple problems
		69	Added symbol & calendar & tooltip widgets
		71	Minor update to requestor example code
		72	Added request-spellcheck
		74	Updated timer action
		75	Widget Ref uses new examine func
		76	Rewrote func-help
		78	Added chat widget
		83	Added request-progress
		86	Spelling error corrected (Graham)
		95	Added request-char
		107	Added tree widget and 'up and 'down symbols
		108	Added scroll-panel
			Added sheet
		110	Removed "Functions" tab (now incorporated into RebDOC)
		112	Added heading and pill
		117	Moved configure to bottom of screen
			Added call to RebDOC
	}
]

do %rebgui.r

;	show splash screen

splash %images/logo.png

;	compose pie-chart data

pie-data: compose [
	"Red" red 1
	"Red-Green" (red + green) 1
	"Green" green 1
	"Green-Blue" (green + blue) 1
	"Blue" blue 1
	"Blue-Red" (blue + red) 1
]

;	wrap display in a func so it can be called by request-ui

do show-tour: make function! [] [

display rejoin ["Widget Tour (build#" ctx-rebgui/build ")"] [
	image %images/logo.png tip "RebGUI logo"
	return
	tab-panel #HW data [
		"Static" [
			text "These widgets don't directly react to mouse events."
			return
			tab-panel #LVHW data [
				"Title-Group" [
					tight
					tg: title-group %images/setup.png #LHW data "RebGUI Widget Tour" {This script demonstrates groups of RebGUI widgets, each in a separate tab preceded by a brief explanation. The explanatory text is followed by a tab-panel showing each widget in alphabetical order.^/^/If you want to experiment with the look & feel of RebGUI then click the button marked as such above these tabs, make your changes, then click "Save" to see them take effect. Note that clicking "Save" will create a file named %ui.dat which will be loaded whenever you run RebGUI.}
				]
				"Bar" [
					text "Some text above a bar."
					return
					bar
					return
					text "Some text below a bar."
				]
				"Box" [
					box 20x20 red #HW
					box 20x20 green #HWX
					return
					box 20x20 blue #WY
					box 20x20 yellow #WXY
				]
				"Chat" [
					ex-chat: chat 150x50 #HW options [limit 10] data [
						"Graham" leaf "A chat widget would be good." red 14-Apr-2007/12:42:55
						"Ashley" purple "Something like AltME?" none 15-May-2007/9:23:04
						"Graham" leaf "Yes, and it must have:^/^/Multi-line support." none 15-May-2007/10:33:42
						"Ashley" purple "And:^/^/^-Tabs?" none 15-May-2007/11:01:34
						"Ashley" purple "I'll see what I can do." yello 15-May-2007/11:05:20
					]
					return
					group-box "Controls" #Y data [
						button-size 25
						button "Submit" 		[ex-chat/append-message "Demo" none ex-chat-area/text none to date! reform [now/date now/time]]
						ex-chat-area: area #V 75x6 "Type your message here."
						after 1
						button "Set User color"	[ex-chat/set-user-color ex-chat/rows blue]
						button "Set Msg text"	[ex-chat/set-message-text ex-chat/rows form now/time/precise]
						button "Set Msg color"	[ex-chat/set-message-color ex-chat/rows yello]
					]
				]
				"Heading" [
					heading "This is a heading."
					return
					text "Heading is derived from text, but twice the size."
				]
				"Label" [
					label "This is a label."
					return
					text "Label is derived from text, but bold."
				]
				"Pill" [
					pill 20x20 red #HW
					pill 20x20 green #HWX
					return
					pill 20x20 blue #WY
					pill 20x20 yellow #WXY
				]
				"Progress" [
					after 1
					text "This is a progress bar."
					ex-progress: progress
					text "This slider lets you set it."
					slider 50x5 options [ratio .05] [set-data ex-progress face/data]
				]
				"Text" [
					text-size 40
					after 2
					text "text"
					text "This is some text."
					text "text text-color blue"
					text "This is some blue text." text-color blue
					text "text bold"
					text "This is some bold text." bold
					text "text italic"
					text "This is some italic text." italic
					text "text underline"
					text "This is some underline text." underline
				]
				"Tooltip" [
					tooltip 40x-1 {This is a "static" tooltip, probably not very useful outside of its intended [dynamic] role; but might be handy for displays where a constant reminder/help bubble is required.}
				]
			]
		]
		"Field" [
			text "These widgets use the edit/feel to process keystrokes."
			return
			tab-panel #LVHW data [
				"Area" [
					text "Click in the area below then press Ctrl+S to spellcheck it."
					return
					area #L "Tge big bad wolf.^/Heere is a secownd line of text."
					return
					text "You may want to install a dictionary from here:"
					link "www.dobeash.com/RebGUI/dictionary/"
					return
					text 80 #L "The dictionary file needs to be unzipped and placed in the %dictionary/ directory, and the %locale.dat file must have its 'language set to the same name."
				]
				"Field" [
					after 1
					field "Some text."
					field "Some more text."
					text "Edit the above text then use Ctrl-Z and / or Esc to restore it."
				]
				"Password" [
					after 1
					field "Some text." font [size: to integer! ctx-rebgui/sizes/font * 1.5 name: font-fixed]
					password "Some text."
					password "Some text."
				]
				"Spinner" [
					text "Top arrow to increment, bottom arrow to decrement."
					return
					after 2
					text 20 "Default"	spinner
					text 20 "Money"		spinner options [$0 $10 $1] data $5
					text 20 "Decimal"	spinner options [0.0 1.0 .1]
					text 20 "Char"		spinner options [#"A" #"Z" 1]
					text 20 "Time"		spinner options [9:00 18:00 0:30]
					tooltip 100 "Note that you can also use the mouse scroll-wheel to increment/decrement. Doing this while Ctrl is held will increment/decrement to the max/min value."
				]
			]
		]
		"Click" [
			text "These widgets react to a mouse click."
			return
			tab-panel #LVHW data [
				"Arrow" [
					arrow data 'up
					arrow data 'down
					arrow data 'left
					arrow data 'right
					return
					arrow 25 data 'up
					arrow 25 data 'down
					arrow 25 data 'left
					arrow 25 data 'right
				]
				"Button" [
					button "Info" options [info]
					button "Red" red text-color white
					button "Green" green
					button "Blue" blue text-color white
					button "Yellow" yellow
					button "White" white
					return
					button 75x25 "Big Button" #HW
				]
				"Link" [
					text-size 25
					after 2
					text "Default link"	link
					text "URL"			link http://www.dobeash.com
					text "Text & URL"	link "RebGUI" http://www.dobeash.com/rebgui
				]
				"Slider" [
					space 0x0
					ex-slider: box 25x25 red
					pad 25
					slider 5x50 data .5 [ex-slider/size/y: max ctx-rebgui/sizes/cell to integer! face/data * face/size/y show ex-slider]
					return
					slider 50x5 data .5 options [arrows] [ex-slider/size/x: max ctx-rebgui/sizes/cell to integer! face/data * face/size/x show ex-slider]
				]
				"Symbol" [
					text "These symbols use the Webdings font, otherwise default ASCII character graphics."
					return
					symbol data 'start
					symbol data 'rewind
					symbol data 'left
					symbol data 'pause
					symbol data 'stop
					symbol data 'record
					symbol data 'right
					symbol data 'forward
					symbol data 'end
					symbol data 'up
					symbol data 'down
					return
					symbol 10 data 'start
					symbol 10 data 'rewind
					symbol 10 data 'left
					symbol 10 data 'pause
					symbol 10 data 'stop
					symbol 10 data 'record
					symbol 10 data 'right
					symbol 10 data 'forward
					symbol 10 data 'end
					symbol 10 data 'up
					symbol 10 #HW data 'down
					return
					text "The symbol widget also accepts text and scales it to the height of the widget."
					return
					symbol -1 "Some text"
					return
					symbol -1x10 "Some text"
					return
				]
			]
		]
		"List" [
			text "These widgets show column(s) of values from which row(s) can be selected."
			return
			tab-panel #LVHW data [
				"Calendar" [
					calendar [set-text ex-status face/data]
					text 40x-1 #L "The calendar widget is also used by the request-date function."
				]
				"Drop-List" [
					drop-list "Black" data ["Red" "Green" "Blue"] [set-color ex-drop-list get to word! face/text]
					ex-drop-list: box 20x20 black
				]
				"Edit-List" [
					edit-list "Black" data ["Red" "Green" "Blue"] [set-color ex-edit-list attempt [get to word! face/text]]
					ex-edit-list: box 20x20 black
				]
				"Sheet" [
					ex-sheet: sheet data [A1 1 A2 2 A3 "=A1 + A2"] options [size 4x4]
					return
					button "Load" [ex-sheet/load-data to block! ex-sheet-field/text]
					button "Save" [ex-sheet/save-data set-text ex-sheet-field mold/only ex-sheet/data]
					ex-sheet-field: field 50 {A1 2 B1 2 C1 "=A1 + B1"}
				]
				"Table" [
					ex-table: table 60x40 #HW options ["ID" right .3 "Number" left .4 "Char" center .3] data [
						1 "One"		a
						2 "Two"		b
						3 "Three"	c
						4 "Four"	d
						5 "Five"	e
						6 "Six"		f
						7 "Seven"	g
						8 "Eight"	h
						9 "Nine"	i
						10 "Ten"	j
					]
					text 40 #LX {Note: Clicking on a column label will sort that column, while dragging a divider will resize the columns before and after it.}
					return
					button "Single" #Y [
						either find ex-table/options 'multi [
							remove find ex-table/options 'multi
						][
							insert tail ex-table/options 'multi
						]
						face/text: pick ["Multi" "Single"] either find ex-table/options 'multi [true] [false]
						show face
					]
					button "Add Row" #Y [
						insert tail ex-table/data reduce [random 100 form now/time random #"Z"]
						ex-table/redraw
					]
				]
				"Text-List" [
					label 15 "Month"
					ex-text-list-text: text 50
					return
					label 15 "Months"
					ex-text-list: text-list 60x40 #HW data system/locale/months [
						set-text ex-text-list-text face/selected
					]
					text 40 #LX {Note: "Single" allows one row at a time to be selected, whilst "Multi" supports multi-row selection via Ctrl+click, Shift+click and Ctrl+A keystrokes.}
					return
					button "Single" #Y [
						either find ex-text-list/options 'multi [
							remove find ex-text-list/options 'multi
						][
							insert tail ex-text-list/options 'multi
						]
						face/text: pick ["Multi" "Single"] either find ex-text-list/options 'multi [true] [false]
						show face
					]
					button "Add Row" #Y [
						insert tail ex-text-list/data form now/time/precise
						ex-text-list/redraw
					]
				]
				"Tree" [
					text 50 "This tree returns face/text when clicked."
					text 50 "This tree has options [expand] and returns face/data when clicked."
					return
					tree 50x25 data ["Pets" ["Cat" "Dog"] "Numbers" [1 2 3]] [
						set-text ex-tree-text face/text
					]
					scroll-panel 50x25 data [
						tree data ["Pets" ["Cat" "Dog"] "Numbers" [1 2 3]] options [resize expand] [
							set-text ex-tree-text mold face/data
						]
					]
					return
					ex-tree-text: text 100
				]
			]
		]
		"State" [
			text "These widgets have two (on & off) or three (true, false & none) states."
			return
			tab-panel #LVHW data [
				"Check" [
					after 1
					check "A check option" data true
					check "with options [info]" options [info] data false
					text "Note: A tristate widget toggled by left and right mouse clicks."
				]
				"Check-Group" [
					text "Vertical alignment"
					return
					check-group 30 data ["Item 1" true "Item 2" false "Item 3" none]
					return
					text 40 "Horizontal alignment"
					check-group 60x5 data ["Item 1" true "Item 2" false "Item 3" none]
					return
					text 40 "with options [info]"
					check-group 60x5 options [info] data ["Item 1" true "Item 2" false "Item 3" none]
				]
				"LED" [
					ex-led: led "A simple LED"
					return
					button "True"	[set-data ex-led true]
					button "False"	[set-data ex-led false]
					button "None"	[set-data ex-led none]
				]
				"LED-Group" [
					text "Vertical alignment"
					return
					led-group 30 data ["Item 1" true "Item 2" false "Item 3" none]
					return
					text "Horizontal alignment"
					return
					ex-led-group: led-group 60x5 data ["Item 1" true "Item 2" false "Item 3" none]
					return
					button 20 "Random" [
						repeat i 3 [
							poke ex-led-group/data i random/only reduce [true false none]
						]
						show ex-led-group
					]
				]
				"Radio-Group" [
					after 1
					text "Vertical alignment"
					radio-group 30 data ["Item 1" "Item 2" "Item 3"]
					text "Horizontal alignment"
					radio-group 60x5 data [none "Item 1" "Item 2" "Item 3"]
					text "Horizontal alignment (with default)"
					r: radio-group 60x5 data [1 "Item 1" "Item 2" "Item 3"]
					button "Random" [r/select-item random 3]
				]
			]
		]
		"Graphic" [
			text "These widgets display one or more images."
			return
			tab-panel #LVHW data [
				"Anim" [
					anim data [%images/go-previous.png %images/go-next.png]
				]
				"Image" [
					image %images/setup.png
					image 50x50 %images/go-next.png
				]
				"Pie-Chart" [
					text 40 "Note that the pie-chart is scalable, change window size to see this."
					tab-panel #HW data [
						"no-label"	[pie-chart 60x60 #HW options [no-label] data pie-data]
						"Default"	[pie-chart 60x60 #HW data pie-data]
						"start"		[pie-chart 60x60 #HW options [start -30] data pie-data]
						"explode"	[pie-chart 60x60 #HW options [start -30 explode 10] data pie-data]
					]
				]
			]
		]
		"Grouping" [
			text "These widgets are used to group other widgets."
			return
			tab-panel #LVHW data [
				"Group-Box" [
					group-box "A group of widgets" #W data [
						after 2
						text 20 #W "Gender"
						drop-list 30 #W "Male" data ["Male" "Female"]
						text 20 "Name"
						field #W 30
						text 20 "Password"
						password #W 30 "RebGUI"
					]
				]
				"Menu" [
					tight
					after 1
					menu #LW data [
						"Color" [
							"Red"		[ex-menu/font/color: red		show ex-menu]
							"Green"		[ex-menu/font/color: green		show ex-menu]
							"Blue"		[ex-menu/font/color: blue		show ex-menu]
							"Black"		[ex-menu/font/color: black		show ex-menu]
						]
						"Align" [
							"Left"		[ex-menu/font/align: 'left		show ex-menu]
							"Center"	[ex-menu/font/align: 'center	show ex-menu]
							"Right"		[ex-menu/font/align: 'right		show ex-menu]
						]
						"Style" [
							"Normal"	[ex-menu/font/style: none		show ex-menu]
							"Bold"		[ex-menu/font/style: 'bold		show ex-menu]
							"Italic"	[ex-menu/font/style: 'italic	show ex-menu]
							"Underline"	[ex-menu/font/style: 'underline	show ex-menu]
						]
 					]
					ex-menu: text #LVHW white "Sample" 100x40 font [align: 'center valign: 'middle size: 36]
				]
				"Panel" [
					panel #W sky data [
						after 2
						text 20 #W "Gender"
						drop-list 30 #W "Male" data ["Male" "Female"]
						text 20 "Name"
						field #W 30
						text 20 "Password"
						password #W 30 "RebGUI"
					]
				]
				"Scroll-Panel"	[
					scroll-panel data [sheet]
					scroll-panel data [image %images/logo.png]
				]
				"Splitter"	[
					space 0x0
					text 41x15 tan "Some text above a splitter."
					return
					splitter 41x1
					return
					text 41x15 tan "Some text below a splitter."
					at 43x0
					text 20x31 wheat "Some text before a splitter."
					splitter 1x31
					text 20x31 wheat "Some text after a splitter."
				]
				"Tab-Panel"	[
					tab-panel #HW data [
						"Static" [text (form now/time/precise)]
						action [
							face/color: get random/only system/locale/colors
							face/pane/1/text: form now/time/precise
						]
						"Dynamic" [text 40]
					]
				]
				"Tool-Bar" [
					tight
					tool-bar #LW data [
						"Open"		%images/document-open.png	[
							if var: request-file/only [set-text ex-status to-local-file var]
						]
						"Save"		%images/document-save.png	[set-text ex-status "Save"]
						"Print"		%images/document-print.png	[set-text ex-status "Print"]
						pad 2 none
						"Home"		%images/go-first.png		[set-text ex-status "Home"]
						"Back"		%images/go-previous.png		[set-text ex-status "Back"]
						"Forward"	%images/go-next.png			[set-text ex-status "Forward"]
						"End"		%images/go-last.png			[set-text ex-status "End"]
					]
				]
			]
		]
	]
	reverse
	button #XY "Close" [quit]
	button #XY 25 "RebDOC" [unview/all do %RebDOC.r]
	button #XY 25 "Look & Feel" [if request-ui [unview/all show-tour]]
	ex-status: text black 95 #WY data ["|" "/" "--" "\"] font [color: green] rate 1 feel [
		engage: make function! [face act event] [
			all [event/type = 'time face/action/on-click face]
		]
	][
		set-text face reform [
			either ctx-rebgui/edit/insert? ["INS"]["OVR"]
			to integer! system/stats / 1024
			"KB's used ..."
			first face/data
		]
		face/data: next face/data
		if tail? face/data [face/data: head face/data]
		recycle
	] tip "RebGUI stats"
]

]

do-events