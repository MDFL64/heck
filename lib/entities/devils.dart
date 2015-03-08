part of entities;

class EntWhipper extends GameEntity {
	Sprite body;
	Sprite leg1;
	Sprite leg2;
	Sprite whip;
	
	num walkCycle=0;
	
	bool flip=false;
	
	bool awake=false;
	int dir=0;
	
	EntWhipper() : super(new Vector(16,64)) {
		body = new Sprite(new Texture.fromImage("img/devil_body.png"));
		leg1 = new Sprite(new Texture.fromImage("img/devil_leg.png"));
		leg2 = new Sprite(new Texture.fromImage("img/devil_leg.png"));
		whip = new Sprite(new Texture.fromImage("img/whip.png"));
		//arm = new Sprite(new Texture.fromImage("img/ply_arm.png"));
		//wepon =  new Sprite(new Texture.fromImage("img/ply_wep.png"));
		
		leg1..pivot.x=4 ..position.x=8 ..position.y=44 ..tint=new Color(0xBBBBBB);
		leg2..pivot.x=4 ..position.x=6 ..position.y=44;
		whip.position..x=14 ..y=33;
		whip.pivot.y=24;
		
		//arm..pivot.x=2 ..pivot.y=2 ..position.x=6 ..position.y=23;
		//wepon..pivot.x=3 ..pivot.y=46 ..position.x=3 ..position.y=17;
		
		body.addChild(leg1);
		body.addChild(leg2);
		body.addChild(whip);
		//body.addChild(arm);
		//arm.addChild(wepon);
		/*Graphics g = new Graphics();
		g.beginFill(new Color(0xFF0000));
    	g.lineStyle(2,new Color(0x00FF00));
    	g.drawRect(0,0,32,64);*/
    	pixObj = body;
    	
    	controlSpeedCap = 200;
        controlAccelAir = 500;
        controlAccelGround = 1500;
        
        maxHealth = health = 10;
       	playerDamage=5;
       	
       	flip=true;
	}
	
	void think(num dt) {
		//Control
		if (!awake) {
			Vector v = ents.player.pos-pos;
	        		
			if (v.lenSqr()<100000) {
				awake=true;
				dir= (random.nextInt(2)==0)?1:-1;
			}
		} else {
			if (random.nextInt(600)==0) {
				dir=-dir;
			}
			control.x=dir;
		}
		
		//End control
		
		//Whip
		Bounds b = clone();
		if (flip) {
			b.pos.x-=126;
            b.dimensions.x=110;
		} else {
			b.pos.x+=16;
			b.dimensions.x=110;
		}
		castDamage(b, 2);
		
		whip.scale.y= timedSin(4);
		whip.scale.x= timedSin(8)/2+.5;
		
		//end
		
		if (control.x!=0)
			flip=control.x<0;
		
		if (!flip) {
			pixObj.scale.x=1.0;
			pixObj.pivot.x=0;
		} else {
			pixObj.scale.x=-1.0;
			pixObj.pivot.x=16;
		}
		
		walkCycle=(walkCycle+.15)%(2*PI);
		
		num vel;
		if (onGround) {
			vel=velocity.x.abs();
			
			leg1.rotation=.003*sin(walkCycle)*vel;
            //arm.rotation=leg1.rotation*.8;
            //arm.scale.y=1.0;
            body.pivot.y=(5+.01*cos(walkCycle*2)*vel).toInt();
		} else {
			//arm.rotation=sin(walkCycle)*.2;
			//leg1.rotation=.4+arm.rotation;
			body.pivot.y=5;
		}
		
		leg2.rotation=-leg1.rotation;
		/*
		leg1.rotation=.004*sin(walkCycle)*vel;
		leg2.rotation=-leg1.rotation;
		arm.rotation=leg1.rotation*.8;
		body.pivot.y=(.01*cos(walkCycle*2)*vel).toInt();
		 */
		
		/*if (Controls.keys[38])
			control.y=-1;
		else if (Controls.keys[40])
			control.y=1;
		else
			control.y=0;*/
	}
}