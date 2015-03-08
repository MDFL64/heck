part of traphouse;

class Vector {
	num x,y;
	
	Vector([this.x=0,this.y=0]);
	
	Vector operator + (Vector other) => new Vector(x+other.x,y+other.y);
	Vector operator - (Vector other) => new Vector(x-other.x,y-other.y);
	Vector operator * (num mult) => new Vector(x*mult,y*mult);
	
	Vector clone() => new Vector(x,y);
	
	void squareClamp(num n) {
		if (x>n)
			x=n;
		else if (x<-n)
			x=-n;
		
		if (y>n)
        	y=n;
		else if (y<-n)
        	y=-n;
	}
	
	void setLen(num n) {
		normalize();
		x*=n;
		y*=n;
	}
	
	num lenSqr() => x*x+y*y;
	
	num len() => sqrt(lenSqr());
	
	void normalize() {
		num l = len();
		if (l==0)
			return;
		x/=l;
		y/=l;
	}
	
	bool isZero() => x==0 && y==0;
}