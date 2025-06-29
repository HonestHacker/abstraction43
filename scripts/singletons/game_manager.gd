extends Node
class_name AbstractionGameManager


var player : Player

# This GDScript 2 function helps reorient Point Entities imported from Trenchbroom via Qodot that utilize the "mangle" key value pair.
# This assumes your entities are intended to be -Z forward as per Godot's position system.
# Light and Info_Intermission entities have special orientations in Trenchbroom. If you utilize those key prefixes
# in your entity classnames, you'll want to specify the other mangle type.
static func demangler(properties: Dictionary, mangle_type: int = 0)->Vector3:
	if properties.has("mangle"):
		var mangle: Vector3 = Vector3.ZERO
		if properties["mangle"] is Vector3:
			mangle = properties["mangle"]
		elif properties["mangle"] is String:
			var arr: Array[String] = (properties["mangle"] as String).split(" ")
			for i in maxi(arr.size(), 3):
				mangle[i] = arr[i].to_float()
		match mangle_type:
			0: mangle = Vector3(mangle.x, mangle.y + 180.0, -mangle.z) # common
			1: mangle = Vector3(mangle.y, mangle.x + 180.0, -mangle.z) # lights
			2: mangle = Vector3(-mangle.x, mangle.y + 180.0, -mangle.z) # info_intermission
		return mangle
	elif properties.has("angle"):
		return Vector3(0.0, (properties["angle"] as float) + 180.0, 0.0)
	return Vector3(0.0, 180.0, 0.0)


# Frequently used method allowing entities to load sounds by String on QodotMap build
static func update_sound(path: String)->AudioStream:
	var snd_path: String = "sounds/" + path
	var s: AudioStream = null
	if snd_path.rfind(".wav") > -1 or snd_path.rfind(".ogg") > -1:
		if FileAccess.file_exists("res://" + snd_path) or FileAccess.file_exists("res://" + snd_path + ".import"):
			s = load("res://" + snd_path)
	return s;


# Similar setup to Quake, except we can specify multiple targets and a custom target function.
# Targetnames are really Godot Groups, so we can have multiple entities share a common "targetname" in Trenchbroom.
# Additionally, we can comma delimit multiple targetnames to target multiple groups of entities. Neat.
func use_targets(activator: Node)->void:
	if not "func_godot_properties" in activator:
		return
	var props: Dictionary = activator.func_godot_properties
	var target_nodes: Array[Node]
	var target_names: PackedStringArray = props.get("target", "").split(",")
	for i in target_names.size():
		target_nodes = get_tree().get_nodes_in_group(target_names[i])
		for tn in target_nodes:
			# Be careful when specifying a function since we can't pass arguments to it (without hackarounds of course)
			var f: String = props.get("targetfunc", "")
			if f != "" and tn.has_method(f):
				tn.call(f)
				continue
			if tn.has_method("use"):
				tn.call("use", activator)
	# Because we can trigger multiple entities at once, we get the trigger message from the caller node only,
	# to prevent spam / missed messages / unpredictable behavior...
	if props.has("message"):
		print(props.message)

# Set the targetnames for the entity. We can specify multiple targetnames using comma delimiting.
func set_targetname(ent: Node, targetname: String)->void:
	if ent != null and targetname != "":
		for t in targetname.split(","):
			if t != "":
				ent.add_to_group(t)
