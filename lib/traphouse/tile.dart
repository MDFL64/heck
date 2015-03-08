part of traphouse;

class Tile {
	//String name;
	bool solid=true;
	
	set image (String s) {
		_image=s;
		if (s[8]!="_") {
			texture= new Texture.fromImage(s);
		}
	}
	
	String get image {
		return _image;
	}
	/*
	set edit_image (String s) {
		_edit_image=s;
		edit_texture= new Texture.fromImage(s);
	}
	
	String get edit_image {
		return _edit_image;
	}
	*/
	String _image;
	//String _edit_image;
	//String picker_image;
	
	Texture texture;
	//Texture edit_texture;
	
	int damage=0;
	String action;
	
	//Tile();
	
	/*static List<Tile> list = [
		new Tile("AIR")..solid=false..picker_image="img/map/air.png",
		new Tile("GRASS")..image="img/map/grass.png",
		new Tile("DIRT")..image="img/map/dirt.png",
		new Tile("INVIS")..edit_image="img/map/inviswall.png"
	];
	
	static num size = 32;*/
}