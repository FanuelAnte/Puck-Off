extends MarginContainer

@onready var puck_icon: Sprite2D = %PuckIcon
@onready var dark_icon: Sprite2D = %DarkIcon
@onready var light_icon: Sprite2D = %LightIcon
@onready var grid: NinePatchRect = %Grid
@onready var icons: Control = %Icons

@onready var icons_list: Dictionary = {
	"dark_team": dark_icon, 
	"light_team": light_icon, 
	"puck": puck_icon
}

var grid_scale: int
var markers: Dictionary = {}

func _ready() -> void:
	update_objects_list()
	
func update_objects_list() -> void:
	var map_objects: Array = get_tree().get_nodes_in_group("minimap_objects")
		
	for object: RigidBody2D in map_objects:
		if object.is_in_group("puck"):
			var new_marker: Sprite2D = icons_list["puck"].duplicate()
			icons.add_child(new_marker)
			new_marker.show()
			markers[object] = new_marker
			
		elif object.is_in_group("car"):
			if object.team_color == "Dark":
				var new_marker: Sprite2D
				new_marker = icons_list["dark_team"].duplicate()
				#if object.is_player:
					#new_marker = icons["red_team_player"].duplicate()
				#else:
					#new_marker = icons["red_team"].duplicate()
					
				icons.add_child(new_marker)
				new_marker.show()
				markers[object] = new_marker
			elif object.team_color == "Light":
				var new_marker: Sprite2D
				new_marker = icons_list["light_team"].duplicate()
				#if object.is_player:
					#new_marker = icons["blue_team_player"].duplicate()
				#else:
					#new_marker = icons["blue_team"].duplicate()
					
				icons.add_child(new_marker)
				new_marker.show()
				markers[object] = new_marker
	
func _process(delta: float) -> void:
	for marker: RigidBody2D in markers:
		var object_position: Vector2 = marker.position / 20 + grid.size / 2
		object_position.x = clamp(object_position.x, 0, grid.size.x)
		object_position.y = clamp(object_position.y, 0, grid.size.y)
		markers[marker].position = object_position
		
