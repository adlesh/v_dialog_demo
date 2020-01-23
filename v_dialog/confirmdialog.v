module v_dialog

import ui

const (
	btn_y       =      int(.65 * _win_height)
	label_y     =      int(.25 * _win_height)
	label_x     =      int(.1 * _win_width)
	confirm_x   =      81
	decline_x   =      171
	_win_width  =      248
	_win_height =      100
	
)

pub struct ConfirmConfig {
mut:
	confirm_click    voidptr
	decline_click    voidptr
	title            string
	label            string
	confirm_text     string
	decline_text     string
}

pub struct ConfirmDialog {
mut:
	window           &ui.Window
	result           bool
	confirm_click    voidptr
	decline_click    voidptr
	title            string
	label            string
	confirm_text     string
	decline_text     string
}

pub fn new_confirmdialog(c ConfirmConfig) &ConfirmDialog {
	mut dialog := &ConfirmDialog {
						confirm_click: c.confirm_click,
						decline_click: c.decline_click,
						title: c.title,
						confirm_text: c.confirm_text,
						decline_text: c.decline_text,
						label: c.label					
					}
					
	window := ui.new_window({
		width: _win_width
		height: _win_height
		title: dialog.title
		user_ptr: dialog
	})
	ui.new_label({
		x: label_x
		y: label_y
		text: dialog.label
		parent: window
	})

	dialog.result = false
	
	ui.new_button({
		x: confirm_x
		y: btn_y
		parent: window
		text: dialog.confirm_text
		onclick: dialog.confirm_click
	})
	
	ui.new_button({
		x: decline_x
		y: btn_y
		parent: window
		text: dialog.decline_text
		onclick: dialog.decline_click
	})
	
	dialog.window = window
	ui.run(window)
	return dialog
}

pub fn (c mut ConfirmDialog) confirm() {
	c.set_result(true)
}

pub fn (c mut ConfirmDialog) decline() {
	c.set_result(false)
}
pub fn (c ConfirmDialog) get_result() bool {
	return c.result
}

fn (c mut ConfirmDialog) set_result(b bool) {
	c.result = b
}

pub fn (c mut ConfirmDialog) close() {
	c.window.glfw_obj.destroy()
}

// Demo below

// fn main() {
	// dialog := new_confirm({
		// confirm_click: btn_confirm_click,
		// decline_click: btn_decline_click,
		// title: 'Confirm?',
		// confirm_text: 'Confirm',
		// decline_text: 'Decline',
		// label: 'Are you sure you want to continue?'	
	// })
// }

// fn btn_confirm_click(app mut ConfirmDialog) {
	// app.confirm()
	// println(app.get_result())
// }

// fn btn_decline_click(app mut ConfirmDialog) {
	// app.decline()
	// println(app.get_result())
// }
