part of entities;

class EntBat extends GameEntity {
	Sprite body;
	Sprite wing;
	
	num cycle=0;
	
	EntBat([String variant]) : super(new Vector(24,24)) {
		body = new Sprite(new Texture.fromImage("img/bat.png"));
		wing = new Sprite(new Texture.fromImage("img/bat_wing.png"));

		wing.pivot..x = 8 ..y=29;
		wing.position..x = 8 ..y=15;
		wing.rotation = -PI/4;
		
		body.addChild(wing);
		pixObj = body;
		
		controlSpeedCap = 250;
	    controlAccelAir = 1000;
	    gravityMultiplier=0;
	    
	    playerDamage=2;
	    maxHealth = health = 4;
	    
	    if (variant=="fire") {
	    	body.tint=Color.orangeRed;
	    	wing.tint=Color.orangeRed;
	    	playerDamage=4;
	    	
	    	/*Sprite f = new Sprite(new Texture.fromImage("img/bat_firehalo.png"));
	    	f.x=-4;
	    	f.y=-4;
	    	body.addChild(f);*/
	    }
	}

	void think(num dt) {
		cycle+=.1;
		cycle%=2*PI;
		
		body.scale.x=velocity.x>0?1.0:-1.0;
		wing.scale.y=sin(cycle);
		
		control = new Vector(random.nextDouble()*4-2,random.nextDouble()*4-2);
		
		Vector v = ents.player.pos-pos;
		
		if (v.lenSqr()<200000) {
			v.setLen(1);
			control+= v;
		}
	}
}