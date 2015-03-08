part of traphouse;

abstract class GameEntity extends Bounds {
	EntityManager ents;
	
	DisplayObject pixObj;
	
	Vector velocity = new Vector();
	
	Vector control = new Vector();
	
	num controlSpeedCap = 0;
	num controlAccelAir = 0;
	num controlAccelGround = 0;
	
	bool onGround = false;
	num groundDampening = 5;
	
	num gravityMultiplier=1;
	
	bool isSolid = true;
	
	num maxHealth = 0;
	num health=0;
	
	num playerDamage=0;
	num enemyDamage=0;
	
	num hurtTimer=0;
	num deadTimer=0;
	
	bool hurtImmune = false;
	
	bool dead=false;
	bool remove=false;
	
	Vector move;
	
	GameEntity(Vector size) : super(size);
	
	bool doDamage(GameEntity other,num dmg) {
		if (other.takeDamage(dmg)) {
			Vector center = new Vector(center_x,center_y);
			Vector other_center = new Vector(other.center_x,other.center_y);
			Vector f = center-other_center;
			f.setLen(300);
			
			other.velocity+=f;
			hitEnemy();
			return true;
		}
		return false;
	}
	
	bool takeDamage(num dmg) {
		if (maxHealth>0 && health>0 && (!hurtImmune || hurtTimer<=0)) {
			health-=dmg;
			hurtTimer=1;
			if (health<=0) {
				onDie();
			}
			return true;
		}
		return false;
	}
	
	bool castDamage(Bounds b,num dmg) {
		bool hit=false;
		ents.ent_list.forEach((GameEntity e) {
			if ((e!=this) && (this==ents.player?true:e==ents.player)) {
				if (b.intersects(e)&&e.takeDamage(dmg)) {
					hit=true;
					return;
				}
			}
		});
		return hit;
	}
	
	void onDie() {
		dead=true;
		deadTimer=2;
		isSolid=false;
		gravityMultiplier=1.0;
		if (pixObj!=null)
			pixObj.scale.y=-1.0;
	}
	
	void hitEnemy() {}
	
	void think(num dt);
	
	void _iThink(num dt) {
		if (!dead)
			think(dt);
		
		if (deadTimer>0) {
			deadTimer-=dt;
			if (deadTimer<=0)
				remove=true;
		}
		
		Random r = new Random();
		if (hurtTimer>0) {
			hurtTimer-=dt;
			if (pixObj!=null)
				pixObj.alpha= r.nextDouble();
		} else if (pixObj!=null)
			pixObj.alpha= 1.0;
			
		
		if (!control.isZero()) { //Control
			Vector c = control.clone();
			c.squareClamp(1);
			c *= dt * (onGround?controlAccelGround:controlAccelAir);
			if (velocity.x.abs()<controlSpeedCap || velocity.x.sign!=control.x.sign)
				velocity.x+=c.x;
			if (velocity.y.abs()<controlSpeedCap || velocity.y.sign!=control.y.sign)
            	velocity.y+=c.y;
		} //else { //Dampening
			num dampening = dt*(onGround?groundDampening:ents.airDampening);
			if (dampening>1)
				dampening=1;
			velocity*=(1-dampening);
		//}
		
		//Gravity
		velocity.y += dt*gravityMultiplier*ents.gravity;
		
		move = velocity*dt;
		
		if (isSolid)
			ents.doCollisions(this);
		else
			pos+=move;
		
		if (pixObj!=null) {
			pixObj.position ..x=pos.x ..y=pos.y;
		}
	}
	
	void collideTile(Tile t) {
		//kek
	}
}

class EntityManager {
	Stage stage = new Stage(new Color(0x293D34));
	DisplayObjectContainer container = new DisplayObjectContainer();
	
	num gravity=980;
	num airDampening = 1;
	
	List<GameEntity> ent_list = [];
	
	GameMap map;
	bool edit_mode=false;
	
	GameEntity player;
	
	InteractionData mouseData;
	bool mouseDown = false;
	
	bool advanceLevel=false;
	int numlives=0;
	int cachelives=0;
	
	Sprite lives;
	Sprite health;
	
	EntityManager() {
		stage.interactive=true;
		stage.onMouseMove.listen((InteractionData d) {
			mouseData=d;
		});
		stage.onMouseDown.listen((InteractionData d) {
			if (d.originalEvent.which==1)
				mouseDown=true;
		});
		stage.onMouseUp.listen((InteractionData d) {
			if (d.originalEvent.which==1)
            	mouseDown=false;
		});
		stage.addChild(container);
		
		//hud
		Sprite h = new Sprite(new Texture.fromImage("img/hud_health.png"));
		h.y=20;
		h.x=20;
		stage.addChild(h);
		
		health = new Sprite(new Texture.fromImage("img/hud_health1.png"));
		health.x=63;
		health.pivot.x=63;
		h.addChild(health);
		
		lives = new Sprite(new Texture.fromImage("img/hud_lives.png"));
		lives.y=40;
		lives.x=20;
		stage.addChild(lives);
	}
	
	void add(GameEntity e) {
		e.ents=this;
		ent_list.add(e);
		
		if (e.pixObj!=null)
			container.addChild(e.pixObj);
	}
	
	void think(num dt) {
		ent_list.forEach((GameEntity e) {
			e._iThink(dt);
			if (e.remove&&e.pixObj!=null) {
				container.removeChild(e.pixObj);
			}
		});
		ent_list.removeWhere((GameEntity e) => e.remove);

		//Hud
		health.scale.x=(player.health/player.maxHealth);
		if (health.scale.x<0)
			health.scale.x=0.0;
		if (numlives!=cachelives) {
			cachelives=numlives;
			if (lives.children.length>0) {
				lives.removeChildren();
				lives.children.clear();
			}
			for (int i=0;i<numlives;i++) {
				Sprite s = new Sprite(new Texture.fromImage("img/hud_lives1.png"));
				s.x=60+i*20;
				lives.addChild(s);
			}
		}
	}
	
	void doCollisions(GameEntity e) {
		map.doCollisions(e);
		if (e.playerDamage>0 && e.intersects(player)) {
			e.doDamage(player, e.playerDamage);
		} else if (e.enemyDamage>0) {
			ent_list.forEach((GameEntity enemy) {
				if (enemy==e || enemy==player)
					return;
				e.doDamage(enemy, e.playerDamage);
			});
		}
	}
	
	//Move this inside of loadmap? Doesnt seem to need to be used anywhere else.
	void reset() {
		ent_list.clear();
		map=null;
		var c = new DisplayObjectContainer();
		stage.addChild(c);
		stage.swapChildren(c, container);
		stage.removeChild(container);
		container=c;
	}
	
	void loadMap(Map mapData) {
		reset();
		add(player);
		
		Color c = new Color.css(mapData["backgroundcolor"]);
		stage.backgroundColor = c;
		stage.setBackgroundColor(c);
		
		map= new GameMap(mapData["width"],mapData["height"],mapData["tilewidth"]);
		List tileSets = mapData["tilesets"];
		tileSets.forEach((Map ts) {
			Map tp = ts["tileproperties"];
			
			int offset = ts["firstgid"];
			Map index = ts["tiles"];
			index.forEach((String s,Map t) {
				int i = int.parse(s)+offset;
				if (map.tile_types.length<=i)
					map.tile_types.length=i+1;
				Tile tile = new Tile();
				
				String img = t["image"];
				img=img.substring(3);
				tile.image = img;
				
				if (tp!=null) {
					Map props = tp[s];
					if (props!=null) {
						String flags = props["flags"];
						if (flags!=null) {
							flags.split(" ").forEach((String f) {
								if (f=="noclip")
									tile.solid=false;
							});
						}
						String damage = props["damage"];
						if (damage!=null) {
							num dmg=num.parse(damage);
							if (dmg!=null)
								tile.damage=dmg;
						}
						tile.action = props["action"];
					}
				}
				

				
				map.tile_types[i]=tile;
			});
		});
		
		List layers = mapData["layers"];
		layers.forEach((Map l) {
			if (l["type"]=="tilelayer") {
				map.data = new List.from(l["data"]);
				map.refreshSprites();
			} else if (l["type"]=="objectgroup") {
				List objs = l["objects"];
				objs.forEach((Map obj) {
					String key = map.tile_types[obj["gid"]].image;
					key=key.substring(8,key.length-4);
					GameEntity e;
					Map props = obj["properties"];
					switch (key) {
						case "util_player":
							e=player;
							break;
						case "util_bat":
							e=new EntBat(props["variant"]);
							break;
						case "util_g":
							e=new EntBigG();
							break;
						case "util_sinner":
							e=new EntSinner(props["extra"]);
							break;
						case "util_whipper":
							e=new EntWhipper();
							break;
						case "util_hf":
                        	e=new EntHotFoot();
                        	break;
						default:
							throw "No such object load handler: "+key;
					}
					e.pos..x=obj["x"]..y=obj["y"];
					if (props["float"]!=null)
						e.gravityMultiplier=0;
					if (key!="util_player")
						add(e);
				});
			}
		});
		
		container.addChild(map.dObj);
	}
}