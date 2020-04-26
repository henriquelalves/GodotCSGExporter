tool
extends MenuButton

enum EXPORT_TYPE {OBJ}

signal finished_exporting

var focused_csg_mesh : CSGShape
var file_dialog : FileDialog
var export_type

func _ready():
	get_popup().connect("index_pressed", self, "_on_popup_index_pressed")
	
	file_dialog = $FileDialog
	file_dialog.mode = FileDialog.MODE_SAVE_FILE
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.connect("file_selected", self, "_on_file_selected")

func _on_popup_index_pressed(id : int):
	if (id == 0):
		export_type = EXPORT_TYPE.OBJ
		file_dialog.show()

func _on_file_selected(path : String):
	if (export_type == EXPORT_TYPE.OBJ):
		_save_mesh_to_obj(path)

func _save_mesh_to_obj(path : String):
	# Variables
	var objcont = "" #.obj content
	var matcont = "" #.mat content
	var csgMesh= focused_csg_mesh.get_meshes();
	var vertcount=0
	
	# OBJ Headers
	objcont+="mtllib "+path.get_file() + ".mtl\n"
	objcont+="o ./" + path.get_file() + "\n";
	
	# Blank material
	var blank_material = SpatialMaterial.new()
	blank_material.resource_name = "BlankMaterial"
	
	#Get surfaces and mesh info
	for t in range(csgMesh[-1].get_surface_count()):
		var surface = csgMesh[-1].surface_get_arrays(t)
		var verts = surface[0]
		var UVs = surface[4]
		var normals = surface[1]
		var mat : SpatialMaterial = csgMesh[-1].surface_get_material(t)
		if (mat == null):
			mat = blank_material
		var faces = []
		
		#create_faces_from_verts (Triangles)
		var tempv=0
		for v in range(verts.size()):
			if tempv%3==0:
				faces.append([])
			faces[-1].append(v+1)
			tempv+=1
			tempv= tempv%3
		
		#add verticies
		var tempvcount =0
		for ver in verts:
			objcont+=str("v ",ver[0],' ',ver[1],' ',ver[2])+"\n"
			tempvcount +=1
			
		#add UVs
		for uv in UVs:
			objcont+=str("vt ",uv[0],' ',uv[1])+"\n"
		for norm in normals:
			objcont+=str("vn ",norm[0],' ',norm[1],' ',norm[2])+"\n"
		
		#add groups and materials
		objcont+="g surface"+str(t)+"\n"
		
		objcont+="usemtl "+str(mat)+"\n"
		
		#add faces
		for face in faces:
			objcont+=str("f ", face[2]+vertcount,"/",face[2]+vertcount,"/",face[2]+vertcount,
			' ',face[1]+vertcount,"/",face[1]+vertcount,"/",face[1]+vertcount,
			' ',face[0]+vertcount,"/",face[0]+vertcount,"/",face[0]+vertcount)+"\n"
		#update verts
		vertcount+=tempvcount
		
		matcont+=str("newmtl "+str(mat))+'\n'
		matcont+=str("Kd ",mat.albedo_color.r," ",mat.albedo_color.g," ",mat.albedo_color.b)+'\n'
		matcont+=str("Ke ",mat.emission.r," ",mat.emission.g," ",mat.emission.b)+'\n'
		matcont+=str("d ",mat.albedo_color.a)+"\n"

	#Write to files
	var objfile = File.new()
	objfile.open(path + ".obj", File.WRITE)
	objfile.store_string(objcont)
	objfile.close()
	
	var mtlfile = File.new()
	mtlfile.open(path + ".mtl", File.WRITE)
	mtlfile.store_string(matcont)
	mtlfile.close()
	
	#output message
	print("CSG Mesh Exported")
	emit_signal("finished_exporting")
