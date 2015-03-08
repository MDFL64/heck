part of entities;

class EntSinner extends GameEntity {
	Sprite body;
	
	num cycle=0;
	
	EntSinner([String extra]) : super(new Vector(16,64)) {
		body = new Sprite(new Texture.fromImage("img/sinner.png"));
		
		if (extra!=null) {
			var e = new Sprite(new Texture.fromImage("img/sinner_extras/$extra.png"));
			body.addChild(e);
			e.pivot..x=11..y=27;
		}
		
		pixObj = body;
	}

	void think(num dt) {}
}