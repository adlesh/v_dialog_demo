import v_dialog
import os
import ui

const (
	win_width = 208 
	win_height = 46
)

struct App {
mut:
	counter  &ui.TextBox
	window   &ui.Window
}

fn main() {
	mut app := &App{}
	
	window := ui.new_window({
		width: win_width
		height: win_height
		title: 'v_dialog demo'
		user_ptr: app
	})
	ui.new_button({
		x: 13
		y: 14
		parent: window
		text: 'Confirm'
		onclick: confirm_click
	})
	ui.new_button({
		x: 85
		y: 14
		parent: window
		text: 'Open'
		onclick: open_click
	})
	ui.new_button({
		x: 146
		y: 14
		parent: window
		text: 'Save'
		onclick: save_click
	})
	app.window = window
	ui.run(window)
}

fn open_click(app mut App) {
	config := &v_dialog.FileDialogConfig{
						path: os.getwd()
						mode: .open
						types: 'Images | *.bmp; *.png | All Files | *.*'
						callback: open_file
					}
					
	dialog := v_dialog.new_filedialog(config)					
}

fn save_click(app mut App) {
	config := &v_dialog.FileDialogConfig{
		path: os.getwd()
		mode: .save
		types: 'Images | *.bmp; *.png | All Files | *.*'
		callback: save_file
	}
	
	dialog := v_dialog.new_filedialog(config)
}

fn open_file(d mut v_dialog.FileDialog) {
	println('Opening')
	d.close()
}

fn save_file(d mut v_dialog.FileDialog) {
	println('Saving')
	d.close()
}

fn confirm_click(app mut App) {
	dialog := v_dialog.new_confirmdialog({
		confirm_click: btn_confirm_click,
		decline_click: btn_decline_click,
		title: 'Confirm?',
		confirm_text: 'Confirm',
		decline_text: 'Decline',
		label: 'Are you sure you want to continue?'
	})
}

fn btn_confirm_click(app mut v_dialog.ConfirmDialog) {
	app.confirm()
	println(app.get_result())
	app.close()
}

fn btn_decline_click(app mut v_dialog.ConfirmDialog) {
	app.decline()
	println(app.get_result())
	app.close()
}