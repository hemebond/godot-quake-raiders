extends Resource
class_name Gun

enum GunType {
	AXE,
	SHOTGUN,
	SUPER_SHOTGUN,
	NAILGUN,
	SUPER_NAILGUN,
	GRENADE_LAUNCHER,
	ROCKET_LAUNCHER,
	LIGHTNING_GUN,
}

@export var type : GunType
@export var ammo : Ammo
@export var model : ArrayMesh
