class_name Helpers extends Node


static func ensure_dir(path: String):
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
