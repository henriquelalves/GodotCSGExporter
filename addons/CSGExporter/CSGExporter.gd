tool
extends EditorPlugin

var exporter_button_scene = preload("CSGExporterMenuButton.tscn")
var exporter_button = null

func _enter_tree():
	exporter_button = exporter_button_scene.instance()
	add_control_to_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, exporter_button)
	exporter_button.hide()
	exporter_button.connect("finished_exporting", self, "_on_finished_exporting")

func handles(object):
	var is_exportable_csg = object is CSGShape and object.is_root_shape()
	
	if is_exportable_csg:
		exporter_button.show()
		exporter_button.focused_csg_mesh = object
	else:
		exporter_button.hide()
	
	return is_exportable_csg

func _on_finished_exporting():
	get_editor_interface().get_resource_filesystem().scan()

func clear():
	exporter_button.hide()

func make_visible(visible):
	exporter_button.visible = visible

func _exit_tree():
	if (exporter_button):
		remove_control_from_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_MENU, exporter_button)
		exporter_button.queue_free()
