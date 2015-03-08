part of traphouse;

class Bounds {
	Vector pos;
	Vector dimensions;
	
	num get left => pos.x;
	num get right => pos.x+dimensions.x;
	
	num get top => pos.y;
	num get bottom => pos.y+dimensions.y;
	
	num get center_x => pos.x+dimensions.x/2;
	num get center_y => pos.y+dimensions.y/2;
	
	Bounds(this.dimensions, [this.pos]) {
		if (this.pos==null)
			this.pos=new Vector(0,0);
	}
	
	bool intersects_x(Bounds other) => (right>other.left && other.right>left);
	bool intersects_y(Bounds other) => (bottom>other.top && other.bottom>top);
	
	bool intersects(Bounds other) => intersects_x(other) && intersects_y(other);
	
	Bounds clone() => new Bounds(dimensions.clone(),pos.clone());
	
	num test_x(Bounds other) {
		num shift;
		if (center_x>other.center_x) {
			shift = other.right-left;
			if (shift<0)
				return 0;
		} else {
			shift = other.left-right;
			if (shift>0)
				return 0;
		}
		return shift;
	}
	
	num test_y(Bounds other) {
		num shift;
		if (center_y>other.center_y) {
			shift = other.bottom-top;
			if (shift<0)
				return 0;
		} else {
			shift = other.top-bottom;
			if (shift>0)
				return 0;
		}
		return shift;
	}
	
	int static_collide(Bounds other) {
		num shiftX = test_x(other);
		num shiftY = test_y(other);
		
		if (shiftX!=0 && shiftY!=0) {
			if (shiftX.abs()>shiftY.abs()) {
				pos.y+=shiftY;
				return shiftY>0?1:4;
			} else if (shiftX.abs()<shiftY.abs()) {
				pos.x+=shiftX;
				return shiftX<0?2:8;
			} else {
				pos.x+=shiftX;
				pos.y+=shiftY;
				return shiftY>0?1:4 + shiftX<0?2:8;
			}
		}
		return 0;
	}
}