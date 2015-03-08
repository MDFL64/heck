part of entities;


class EntBigG extends GameEntity {
	num countdown_to_the_countdown=5;
	DrawBigG dbg;
	
	EntBigG() : super(new Vector(10,10)) {
		dbg = new DrawBigG(false);
		pixObj = dbg.g;
		pixObj.rotation=-.1;
		
		controlAccelAir=300;
		controlSpeedCap=400;
		gravityMultiplier=0;
	}
	
	think(num dt) {
		dbg.think(dt);
		
		control.x=1;
		control.y=-.5;
		
		countdown_to_the_countdown-=dt;
		if (countdown_to_the_countdown<0)
			remove=true;
	}
}


class DrawBigG {
	DisplayObjectContainer g;
	Sprite body;
	Sprite wing1;
	Sprite wing2;
	Sprite hand1;
	Sprite hand2;
	
	DrawBigG(bool rider) {
		g = new DisplayObjectContainer();
		
		body = new Sprite(new Texture.fromImage("img/big_g.png"));
		wing1 = new Sprite(new Texture.fromImage("img/big_g_wing.png"));
		wing2 = new Sprite(new Texture.fromImage("img/big_g_wing.png"));
        hand1 = new Sprite(new Texture.fromImage("img/big_g_hand.png"));
        hand2 = new Sprite(new Texture.fromImage("img/big_g_hand.png"));
        
        wing1.pivot..x=250..y=160;
        wing2.pivot..x=250..y=160;
        wing1..x=320..y=60;
        wing2..x=330..y=60;
        wing1.rotation=-.05;
        wing2.rotation=.05;
        wing1.tint=new Color(0x777777);
        
        hand1.pivot..x=5..y=5;
        hand2.pivot..x=5..y=5;
        hand1..x=340..y=70;
        hand2..x=345..y=70;
        hand1.tint=new Color(0x777777);
        
        g.addChild(wing1);
        g.addChild(hand1);
        g.addChild(body);
        g.addChild(wing2);
        g.addChild(hand2);
        
        if (rider) {
        	Sprite r = new Sprite(new Texture.fromImage("img/dragon_rider.png"));
        	r..x=350..y=6;
        	g.addChild(r);
        }
	}
	
	void think(num dt) {
		g.pivot..x=260..y=(60+timedSin(.5)*20).toInt();
		wing1.scale.y=timedSin(1);
		wing2.scale.y=timedSin(1);
		hand1.rotation=timedSin(.7)/4;
		hand2.rotation=-timedSin(.7)/4;
	}
}