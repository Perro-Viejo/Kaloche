extends Node

signal control_toggled(props) # { disable_camera: bool, ... }
signal camera_shaked(strength)
signal camera_moved(distance)
signal camera_moved_to(target_position)
signal camera_zoomed(scale)
signal camera_disabled(is_disabled)
signal fish_caught(pos)
