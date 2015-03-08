part of entities;

class EntHotFoot extends GameEntity {
	Sprite hole;
	Sprite leg1;
	Sprite leg2;
	
	EntHotFoot() : super(new Vector(32,32)) {
		hole = new Sprite(new Texture.fromImage("img/hf_hole.png"));
		leg1 = new Sprite(new Texture.fromImage("img/hf_leg.png"));
		leg2 = new Sprite(new Texture.fromImage("img/hf_leg.png"));
		
		leg1..pivot.x=4 ..position.x=17 ..tint=new Color(0xBBBBBB);
		leg2..pivot.x=4 ..position.x=15;
		
		hole.pivot.y=-28;

		
		//arm..pivot.x=2 ..pivot.y=2 ..position.x=6 ..position.y=23;
		//wepon..pivot.x=3 ..pivot.y=46 ..position.x=3 ..position.y=17;
		
		hole.addChild(leg1);
		hole.addChild(leg2);
		
    	pixObj = hole;
    	
    	gravityMultiplier=0;
        
       	playerDamage=10;
	}
	
	void think(num dt) {
		leg1.rotation=PI+timedSin(2);
		leg2.rotation=-leg1.rotation;
	}
}