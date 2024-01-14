class_name Grid extends Node2D

const num_rows = 33
const num_columns = 63

var gol_interval = 0.75
var gol_timer = 0.0

const cell_size = 20.0
const size = Vector2(cell_size, cell_size)

const start_point_x = 10
const start_point_y = 25

var gen_num = 0

var alive_array = []

var running = false

@onready var generation_label = %GenerationLabel
@onready var state_label = %StateLabel

func update_state():
	if running:
		state_label.text = "Running"
	else:
		state_label.text = "Paused"

func update_gen_num():
	generation_label.text = "Gen: " + str(gen_num)

func _ready():
	for i in range(0, num_columns):
		var arr = []
		arr.resize(num_rows)
		arr.fill(false)
		
		alive_array.push_back(arr)


func _draw():
	var c_white = Color("white")
	var c_black = Color("black")
	
	for row in range(0, num_columns):
		for col in range(0, num_rows):
			var x_coord = start_point_x + row * (cell_size + 1)
			var y_coord = start_point_y + col * (cell_size + 1)
			
			var pos = Vector2(x_coord, y_coord)
			var my_rect = Rect2(pos, size)
			
			if alive_array[row][col]:
				draw_rect(my_rect, c_black)
			else:
				draw_rect(my_rect, c_white)


func game_of_life():
	var arr_copy = alive_array.duplicate(true) 	# deep copy enabled
	
	for row in range(0, num_columns):
		for col in range(0, num_rows):
			
			var num_neighbours = count_neighbours(arr_copy, row, col)
			
			if arr_copy[row][col]:
				if num_neighbours < 2 or num_neighbours > 3:
					alive_array[row][col] = false
			else:
				if num_neighbours == 3:
					alive_array[row][col] = true
	gen_num += 1
	update_gen_num()

	queue_redraw()
	


func count_neighbours(arr_copy, row, col):
	var num_neighbours = 0
	
	# check above
	if row > 0:
		if arr_copy[row-1][col]:
			num_neighbours += 1
	
	# check above
	if row < num_columns - 1:
		if arr_copy[row + 1][col]:
			num_neighbours += 1
			
	# check left
	if col > 0:
		if arr_copy[row][col-1]:
			num_neighbours += 1
	
	# check right
	if col < num_rows - 1:
		if arr_copy[row][col+1]:
			num_neighbours += 1
	
	# diaganols
	if row > 0 and col > 0:
		if arr_copy[row-1][col-1]:
			num_neighbours += 1
	
	if row > 0 and col < num_rows - 1:
		if arr_copy[row-1][col+1]:
			num_neighbours += 1
	
	if row < num_columns - 1 and col > 0:
		if arr_copy[row+1][col-1]:
			num_neighbours += 1
	
	# diaganols
	if row < num_columns - 1 and col < num_rows - 1:
		if arr_copy[row+1][col+1]:
			num_neighbours += 1
	
	return num_neighbours


func _process(delta):
	if Input.is_action_just_pressed("space_bar"):
		running = !running
		update_state()
	
	if Input.is_action_just_pressed("reset"):
		running = false
		update_state()
		reset_grid()
		
		
	if running:
		gol_timer += delta
		
		if gol_timer >= gol_interval:
			game_of_life()
			gol_timer = 0.0


func reset_grid():
	for row in range(0, num_columns):
		for col in range(0, num_rows):
			alive_array[row][col] = false
	
	gen_num = 0
	update_gen_num()
	queue_redraw()
	
	
func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos = get_local_mouse_position()
		var row = int((mouse_pos.x - start_point_x) / (cell_size + 1))
		var col = int((mouse_pos.y - start_point_y) / (cell_size + 1))
		
		if row >= 0 and row < num_columns and col >= 0 and col < num_rows:			
			alive_array[row][col] = !alive_array[row][col]
			
			queue_redraw()
