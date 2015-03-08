part of entities;

class EntPlayer extends GameEntity {
	Sprite body;
	Sprite leg1;
	Sprite leg2;
	Sprite arm;
	Sprite wepon;
	
	num walkCycle=0;
	
	bool attackDown=false;
	num attackSide=0;
	num attackUp=0;
	
	bool flip=false;
	
	EntPlayer() : super(new Vector(16,64)) {
		body = new Sprite(new Texture.fromImage("img/ply_body.png"));
		leg1 = new Sprite(new Texture.fromImage("img/ply_leg.png"));
		leg2 = new Sprite(new Texture.fromImage("img/ply_leg.png"));
		arm = new Sprite(new Texture.fromImage("img/ply_arm.png"));
		wepon =  new Sprite(new Texture.fromImage("img/ply_wep.png"));
		
		leg1..pivot.x=4 ..position.x=8 ..position.y=39 ..tint=new Color(0xBBBBBB);
		leg2..pivot.x=4 ..position.x=6 ..position.y=39;
		
		arm..pivot.x=2 ..pivot.y=2 ..position.x=6 ..position.y=23;
		wepon..pivot.x=3 ..pivot.y=46 ..position.x=3 ..position.y=17;
		
		body.addChild(leg1);
		body.addChild(leg2);
		body.addChild(arm);
		arm.addChild(wepon);
		/*Graphics g = new Graphics();
		g.beginFill(new Color(0xFF0000));
    	g.lineStyle(2,new Color(0x00FF00));
    	g.drawRect(0,0,32,64);*/
    	pixObj = body;
    	
    	controlSpeedCap = 300;
        controlAccelAir = 500;
        controlAccelGround = 1500;
        
        maxHealth = health = 30;
        hurtImmune=true;
	}
	
	void think(num dt) {
		if (Controls.keys[37])
			control.x=-1;
		else if (Controls.keys[39])
			control.x=1;
		else
			control.x=0;
		
		if (Controls.keys_pressed[90] && onGround)
			velocity.y=-700;
		
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
            arm.rotation=leg1.rotation*.8;
            arm.scale.y=1.0;
            body.pivot.y=(.01*cos(walkCycle*2)*vel).toInt();
		} else {
			arm.rotation=sin(walkCycle)*.2;
			leg1.rotation=.4+arm.rotation;
			body.pivot.y=0;
		}
		
		if (attackDown || (attackSide>0) || (attackUp>0)) {
			wepon.rotation=PI;
			if (attackDown) {
				arm.rotation=0.0;
				
				Bounds b = clone();
				b.pos.y+=50;
				
				if (onGround || castDamage(b,10))
					attackDown=false;
			} else if (attackSide>0) {
				arm.rotation=-1-attackSide*10;
				
				Bounds b = clone();
				b.pos.x+=flip?-66.0:50.0;
				
				if (castDamage(b,5))
                	attackSide=0;
				else
					attackSide-=dt;
			} else if (attackUp>0) {
				arm.rotation=-2-attackUp*10;
				
				Bounds b = clone();
				b.pos.y-=50;
				
				if (castDamage(b,5))
					attackUp=0;
				else
					attackUp-=dt;
			}
		} else {
			wepon.rotation=1.4;
			if (Controls.keys_pressed[88]) {
				if (Controls.keys[40] && !onGround) {
					attackDown=true;
					velocity.y=300.0;
				} else if (Controls.keys[38]) {
					attackUp=.2;
				} else {
					attackSide=.2;
				}
			}
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
	
	void collideTile(Tile t) {
		if (t.damage>0)
        	takeDamage(t.damage);
		if (t.action=="nextlevel")
        	ents.advanceLevel=true;
	}
	
	void restore() {
		dead=false;
		remove=false;
		health=maxHealth;
		deadTimer=0;
		hurtTimer=0;
		isSolid=true;
		pixObj.scale.y=1.0;
	}
}