part of traphouse;

class GameMap {
	int w,h;
	int tileSize;
	List<int> data;
	List<Sprite> sprites;
	List<Tile> tile_types=[];
	
	DisplayObjectContainer dObj=new DisplayObjectContainer();
	
	Bounds bounds;
	
	GameMap(this.w,this.h,this.tileSize) {
		data= new List.filled(w*h,0);
		sprites= new List.filled(w*h,null);
		bounds= new Bounds(new Vector(w*tileSize,h*tileSize));
		
		Tile air = new Tile();
		air.solid=false;
		tile_types.add(air);
		
		refreshSprites();
	}
	
	void refreshSprites() {
		if (dObj.children.length>0) {
			dObj.removeChildren();
			dObj.children.clear(); //This is seriously one of the most impressivly
			//broken libraries ever
		}
		
		sprites.fillRange(0,w*h,null);
		for (int x = 0;x<w;x++) {
			for (int y = 0;y<h;y++) {
				updateSprite(x,y);
			}
		}
		Graphics gtop = new Graphics();
		gtop.beginFill(new Color(0));
		gtop.drawRect(-4000, -4000, w*tileSize+8000, 4000);
		dObj.addChild(gtop);
		
		Graphics gbottom = new Graphics();
		gbottom.beginFill(new Color(0));
		gbottom.drawRect(-4000, h*tileSize, w*tileSize+8000, 4000);
		dObj.addChild(gbottom);
		
		Graphics gleft = new Graphics();
		gleft.beginFill(new Color(0));
		gleft.drawRect(w*tileSize, 0, 4000, h*tileSize);
		dObj.addChild(gleft);
		
		Graphics gright = new Graphics();
		gright.beginFill(new Color(0));
		gright.drawRect(-4000, 0, 4000, h*tileSize);
		dObj.addChild(gright);
	}
	
	void updateSprite(int x,int y) {
		int i = x+y*w;
		int n = data[i];
		Texture t= tile_types[n].texture;
		
		Sprite s = sprites[i];
		
		if (s!=null) {
			if (t!=null) {
				s.setTexture(t);
			} else {
				dObj.removeChild(s);
				sprites[i]=null;
			}
		} else {
			if (t!=null) {
				s=new Sprite(t);
				dObj.addChild(s);
				sprites[i]=s;
				s.x=x*tileSize;
				s.y=y*tileSize;
			}
		}
	}
	
	void setTile(int x,int y, int n) {
		data[x+y*w]=n;
		updateSprite(x,y);
	}
	
	void setTileRaw(int i, int n) {
		data[i]=n;
		updateSprite(i%w,(i/h).floor());
	}
	
	int getTile(int x,int y) => data[x+y*w];
	
	void doCollisions(GameEntity e) {
		if (e.intersects(bounds)) {
			e.onGround=false;
			
			num left = getMin(e.left,w);
            num right = getMax(e.right,w);
            
            bool solvedY=false;
			if (e.move.y>0) {
				num start = getMax(e.bottom,h);
				num end = getMax(e.bottom+e.move.y,h);
				
				for (int y=start;y<=end;y++) {
					for (int x=left;x<=right;x++) {
						if (tile_types[getTile(x,y)].solid) {
							e.velocity.y=0;
							e.pos.y=y*tileSize-e.dimensions.y;
							solvedY=true;
							e.onGround=true;
							
							e.collideTile(tile_types[getTile(x,y)]);
							
							break;
						}
					}
					if (solvedY)
						break;
				}
			} else if (e.move.y<0) {
				num start = getMin(e.top,h);
				num end = getMin(e.top+e.move.y,h);
				
				for (int y=start;y>=end;y--) {
					num edge = (y+1)*tileSize;
					for (int x=left;x<=right;x++) {
						if (tile_types[getTile(x,y)].solid) {
							e.velocity.y=0;
							e.pos.y=(y+1)*tileSize;
							solvedY=true;
							
							e.collideTile(tile_types[getTile(x,y)]);
							
							break;
						}
					}
					if (solvedY)
						break;
				}
			}
			if (!solvedY)
				e.pos.y+=e.move.y;
			
			num top = getMin(e.top,h);
			num bottom = getMax(e.bottom,h);
			
			bool solvedX=false;
			if (e.move.x>0) {
				num start = getMax(e.right,w);
				num end = getMax(e.right+e.move.x,w);
				
				for (int x=start;x<=end;x++) {
					for (int y=top;y<=bottom;y++) {
						if (tile_types[getTile(x,y)].solid) {
							e.velocity.x=0;
							e.pos.x=x*tileSize-e.dimensions.x;
							solvedX=true;
							
							e.collideTile(tile_types[getTile(x,y)]);
							
							break;
						}
					}
					if (solvedX)
						break;
				}
			} else if (e.move.x<0) {
				num start = getMin(e.left,w);
				num end = getMin(e.left+e.move.x,w);
				
				for (int x=start;x>=end;x--) {
					for (int y=top;y<=bottom;y++) {
						if (tile_types[getTile(x,y)].solid) {
							e.velocity.x=0;
							e.pos.x=(x+1)*tileSize;
							solvedX=true;
							
							e.collideTile(tile_types[getTile(x,y)]);
							
							break;
						}
					}
					if (solvedX)
						break;
				}
			}
			if (!solvedX)
				e.pos.x+=e.move.x;
		} else {
			e.pos+=e.move;
		}
	}
	
	int getMin(num n, num upper) {
		int r = (n/tileSize).floor();
		if (r<0)
			r=0;
		else if (r>=upper)
			r=upper-1;
		return r;
	}
	
	int getMax(num n, num upper) {
		num r = n/tileSize;
		
		if (r.toInt()==r)
			r=r.floor()-1;
		else
			r=r.floor();
		
		if (r<0)
			r=0;
		else if (r>=upper)
			r=upper-1;
		
		return r;
	}
}