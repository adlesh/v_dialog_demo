module v_dialog

import ui
import gx
import os
import math

const (
	win_width = 700
	win_height = 385
	nr_cols = 4
	cell_height = 25
	cell_width = 100
	cell_padding = 5
	table_width = cell_width * nr_cols
	kB = 1024
	MB = kB * kB
	GB = kB * kB * kB
)

struct ViewConfig {
mut: 
	x           int
	y           int
	
}

struct GridHeader {
mut:
	column_hdrs       []string
	hdr_x             int
	hdr_y             int
}

struct FilterOption {
mut:
	description string // Text describing the type of extension; i.e bitmap files for .bmp or Images (.bmp; .png) for gro
	extension   string // Semi-colon delimited string of file extensions *.bmp for just bitmap or *.bmp; *.png
}

const (
	canvas_config = ViewConfig {
						x: 280
						y: 20
					}

	header_row = GridHeader{
					hdr_x: canvas_config.x + cell_padding
					hdr_y: canvas_config.y + cell_padding
					column_hdrs: ["File Name", "File Size (kB)"]
				}
				
	search_x = 20
	search_y = 50
	search_y_spacing = 30
	
	search_btn_y = win_height - 2 * search_y_spacing
	search_width = 200
	
	ddown_y = search_y + search_y_spacing
	home_dir = os.home_dir()
)

enum DialogMode { open, create, save }

pub struct FileDialogConfig {
	path       string
	mode       DialogMode
	types      string
	callback   voidptr
}

pub struct FileDialog {
mut:
	search_tbox       &ui.TextBox
	filetype_ddown    &ui.Dropdown
	window            &ui.Window
	callback          voidptr
	search_callback   voidptr
	ddown_callback    voidptr
	path              string
	txt_pos           int
	title             string
	dialogbtn_text    string	
}

pub fn (f FilterOption) filter_str() string {
	return '${f.description} (${f.extension})'
}

fn parse_file_types(pattern string) []FilterOption {
	filter_array := pattern.split('|')
	println(filter_array)
	mut result := []FilterOption
	
	for i := 0; i < filter_array.len - 1; i += 2 {
		result << FilterOption{
						description: filter_array[i].trim(' ')
						extension: filter_array[i+1].trim(' ')
					}
	}
	
	return result
}

pub fn new_filedialog(c &FileDialogConfig) &FileDialog {
	filter_array := parse_file_types(c.types)
	for _, filter in filter_array {
		println(filter.filter_str())
	}
	mut fd := &FileDialog{
		path: c.path
		callback: c.callback
		search_callback: search_callback
	}
	match c.mode {
		.open {
			fd.title = 'Open File'
			fd.dialogbtn_text = 'Open'			
		}
		.create {
			fd.title = 'Create New File'
			fd.dialogbtn_text = 'Create'
		}
		.save {
			fd.title = 'Save File'
			fd.dialogbtn_text = 'Save'
		}
		else {
			println('Oops')
		}
	}
	
	window := ui.new_window({
				width: win_width
				height: win_height
				title: fd.title
				user_ptr: fd
			})
	fd.search_tbox = ui.new_textbox({
		max_len: 200
		x: search_x
		y: search_y
		width: search_width
		placeholder:  fd.path
		parent: window
	})
	 mut filetypes := []ui.DropdownItem
	
	 for _, filetype in filter_array {
		 filetypes << ui.DropdownItem{text: filetype.filter_str()}
	 }
	
	fd.filetype_ddown = ui.new_dropdown({
		parent: window
		x: search_x
		y: ddown_y
		width: 200
		def_text: "Select an option"
		items:  filetypes
	})
	ui.new_button({
		parent: window
		x: search_x + search_width - 150 - cell_padding
		y: search_btn_y
		text: 'Search'
		onclick: fd.search_callback
	})
	ui.new_button({
		parent: window
		x: search_x + search_width -75 + cell_padding
		y: search_btn_y
		text: fd.dialogbtn_text
		onclick: fd.callback
	})
	ui.new_label({
		parent: window
		x: search_x
		y: search_y - fd.search_tbox.height - cell_padding
		text: 'Directory'
	})
	ui.new_canvas({
		parent: window
		x: canvas_config.x
		y: canvas_config.y	
		draw_fn:canvas_draw
	})
	fd.window = window
	ui.run(window)
	return fd	
}

pub fn (d mut FileDialog) close() {
	d.window.glfw_obj.destroy()
}

fn draw_header_row(window &ui.Window) {
	gg := window.ui.gg
	mut ft := window.ui.ft
	x := header_row.hdr_x
	y := header_row.hdr_y
	// Vertical separators
	for i, text in header_row.column_hdrs {
		ft.draw_text_def(x + cell_width * (i)+ cell_padding, y + cell_padding, text)
	}	
}

fn draw_file_row(window &ui.Window, file_path string, row_offset int) {
	gg := window.ui.gg
	mut ft := window.ui.ft
	size := os.file_size(file_path) / kB
	x := header_row.hdr_x
	y := header_row.hdr_y + (row_offset+1) * cell_height
	// Outer border
	gg.draw_empty_rect(x, y, table_width, cell_height, gx.Gray)
	// Vertical separators
	gg.draw_line(x + cell_width, y, x + cell_width, y + cell_height, gx.Gray)
	gg.draw_line(x + cell_width * 2, y, x + cell_width * 2, y + cell_height, gx.Gray)
	gg.draw_line(x + cell_width * 3, y, x + cell_width * 3, y + cell_height, gx.Gray)
	// Text values
	length := int(math.min(file_path.len, 11))
	ellipsis := if length == file_path.len { '' } else { '...' }
	ft.draw_text_def(x + cell_padding, y + cell_padding, file_path[..length]+ellipsis)
	ft.draw_text_def(x + cell_padding +cell_width, y + cell_padding, size.str())
}

fn draw_file_table(window &ui.Window) {
	gg := window.ui.gg
	x := header_row.hdr_x
	gg.draw_rect(x - 20, 0, table_width + 100, 800, gx.white)
	// Outer border
	gg.draw_empty_rect(x, 20, table_width, cell_height, gx.Gray)
}

fn canvas_draw(fd &FileDialog) {
	files := os.ls(fd.path) or {println(fd.path) panic('Something went wrong')}	
	
	draw_file_table(fd.window)
	draw_header_row(fd.window)
	
	for i, file_path in files {
		draw_file_row(fd.window, file_path, i)
	}
}

fn search_callback(fd mut FileDialog)  {
	println(fd.path)
	fd.path = fd.search_tbox.text.replace('~', home_dir).replace('__home', home_dir)
	println(fd.path)
}
