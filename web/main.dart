import 'dart:html';
import 'dart:math';
import 'dart:js';
import 'dart:convert';
import 'package:pixi_dart/pixi.dart';

import 'package:heck/traphouse.dart';
import 'package:heck/entities.dart';

JsObject stats;

Renderer render;
EntityManager ents = new EntityManager();

Menu menu;
MenuDeath menu_death;
MenuWin menu_win;

List mapFiles= [];

num currentLevel=-1;
int last_level=3;

void hookFrame(num last_t) {
	window.requestAnimationFrame((num t) {
		num dt = (t-last_t)/1000;
		if (dt>.1)
			dt=.1;
		
		stats.callMethod("begin");
		
		if (currentLevel>=0) {
			//Update Ents
			ents.think(dt);
			
			//Camera
			Vector cam = ents.player.pos;
			
			num pmax = ents.map.tileSize/2;
			
			if (render.width<ents.map.w*ents.map.tileSize) {
				ents.container.x-= (ents.container.x + cam.x - render.width/2)/10;
				num xmin = render.width-(ents.map.w+.5)*ents.map.tileSize;
				
				if (ents.container.x>pmax)
					ents.container.x=pmax;
				else if (ents.container.x<xmin)
					ents.container.x=xmin;
			} else {
				ents.container.x= render.width/2 - ents.map.w*ents.map.tileSize/2;
			}
			
			if (render.height<ents.map.h*ents.map.tileSize) {
				ents.container.y-= (ents.container.y + cam.y - render.height/2)/10;
				num ymin = render.height-(ents.map.h+.5)*ents.map.tileSize;
				
				if (ents.container.y<=ymin)
					ents.container.y=ymin;
				else if (ents.container.y>pmax)
					ents.container.y=pmax;
			} else {
				ents.container.y= render.height/2 - ents.map.h*ents.map.tileSize/2;
			}
			
			//Draw
			render.render(ents.stage);
		} else if (currentLevel==-1) {
			menu.update(dt);
		} else if (currentLevel==-2) {
			menu_death.update(dt);
		} else if (currentLevel==-3) {
			menu_win.update(dt);
		}
		
		if (ents.advanceLevel||Controls.keys_pressed[220]) {
			ents.advanceLevel=false;
			advanceLevel();
		} else if (ents.player.remove) {
			EntPlayer ply = ents.player;
			ply.restore();
			ents.numlives--;
			menu_death.setup(currentLevel,ents.numlives);
			currentLevel=-2;
		}
		
		stats.callMethod("end");
		
		Controls.endFrame();
		hookFrame(t);
	});
}

void resizeStage([Event e]) {
	render.resize(window.innerWidth,window.innerHeight);
}


void startGame() {
	currentLevel=-1;
	ents.numlives=5;
	advanceLevel();
}

void advanceLevel() {
	currentLevel++;
	if (currentLevel<mapFiles.length) {
		ents.loadMap(mapFiles[currentLevel]);
	} else {
		EntPlayer ply = ents.player;
		ply.restore();
		currentLevel=-3;
	}
}

void download_map(int n) {
	HttpRequest.getString("maps/level$n.json").then((String json) {
		mapFiles.add(JSON.decode(json));
		n++;
		if (n<=last_level)
			download_map(n);
	});
}

void main() {
	//Controls
	Controls.init();
	
	//Setup renderer
	render = new Renderer.autoDetect(width: 1000,height: 800);
    querySelector("#game_container").append(render.view);
    resizeStage();
    window.onResize.listen(resizeStage);
    
    //Setup stats
	stats = new JsObject(context["Stats"]);
	Element stats_element = stats["domElement"];
	stats_element.style..position = "absolute" ..right="0" ..top="0";
	querySelector("#game_container").append(stats_element);
	
	//Map
	download_map(0);
	
	//Ents
    EntPlayer ply = new EntPlayer();
    ents.add(ply);
    ents.player=ply;
    
    //Menu
    menu = new Menu();
    menu_death = new MenuDeath();
    menu_win = new MenuWin();
    
    //ents.loadMap(mapFile);
	
	/*EntBat bat = new EntBat();
	bat.pos.x = 200;
	bat.pos.y = 100;
	
	ents.add(bat);*/
	
	//Start rendering
	hookFrame(0);
}

class Menu {
	Stage stage = new Stage();
	Sprite title1;
	Sprite title2;
	Sprite info;
	Sprite start;
	
	DrawBigG big_g;
	
	num t = 2;
	
	Menu() {
		title1 = new Sprite(new Texture.fromImage("img/menu/title1.png"));
		title2 = new Sprite(new Texture.fromImage("img/menu/title2.png"));
		info = new Sprite(new Texture.fromImage("img/menu/info.png"));
		start = new Sprite(new Texture.fromImage("img/menu/start.png"));
		
		big_g = new DrawBigG(true);
		
		start.alpha=0.00;
		//info.pivot..x=256 ..y=500;
		
		stage.addChild(title1);
		stage.addChild(title2);
		stage.addChild(info);
		stage.addChild(start);
		stage.addChild(big_g.g);
	}
	
	void update(num dt) {
		if (t>0) {
			t-=dt;
			if (t<0)
				t=0;
		}
		num cx = render.width/2-256;
		num cy = render.height/2-256;
		title1.x=cx-t*500;
		title1.y=cy;
		title2.x=cx+t*500;
        title2.y=cy;
        info.x = cx;
        info.y = cy;
        info.scale.x = (2-t)/2;
        info.rotation = (t*3).toDouble();
        start.x=cx;
        start.y=cy;
        
        big_g.g.x=cx+260;
        big_g.g.y=cy+300;
        
        if (mapFiles.length>0) {
        	start.alpha= .6+timedSin(1)*.4;
        	if (Controls.keys_pressed[90])
        		startGame();
        }
        
        
        big_g.think(dt);
        
		render.render(stage);
	}
}

class MenuDeath {
	Stage stage=new Stage();
	Sprite img;
	Sprite img2;
	
	int level;
	int lives;
	
	MenuDeath() {
		img= new Sprite(new Texture.fromImage("img/menu/death.png"));
		img2= new Sprite(new Texture.fromImage("img/menu/loss.png"));
		stage.addChild(img);
		stage.addChild(img2);
	}
	
	void setup(int level,int lives) {
		this.level=level;
		this.lives=lives;
		
		if (img.children.length>0) {
			img.removeChildren();
			img.children.clear();
		}
		
		for (int i=0;i<ents.numlives;i++) {
			Sprite s = new Sprite(new Texture.fromImage("img/hud_lives1.png"));
			s.x=180+i*40;
			s.y=250;
			s.scale..x=2.0..y=2.0;
			img.addChild(s);
		}
		
		img2.visible=lives==0;
	}
	
	void update(num dt) {
		num cx = render.width/2-256;
        num cy = render.height/2-256;
        
        img.position..x=cx..y=cy;
        img2.position..x=cx..y=cy;
        
		if (Controls.keys_pressed[90]) {
			if (lives==0)
				currentLevel=-1;
			else {
				currentLevel=level-1;
				advanceLevel();
			}
		}
		
		render.render(stage);
	}
}

class MenuWin {
	Stage stage=new Stage();
	Sprite img;
	
	MenuWin() {
		img= new Sprite(new Texture.fromImage("img/menu/win.png"));
		stage.addChild(img);
	}
	
	void update(num dt) {
		num cx = render.width/2-256;
        num cy = render.height/2-256;
        
        img.position..x=cx..y=cy;
                
		if (Controls.keys_pressed[90])
			currentLevel=-1;
		
		render.render(stage);
	}
}