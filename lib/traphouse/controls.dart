part of traphouse;

class Controls {
	static List<bool> keys = new List.filled(256,false);
	static List<bool> keys_pressed = new List.filled(256,false);
	static List<bool> keys_released = new List.filled(256,false);
	
	static bool debug = false;
	
	static void init() {
		window.addEventListener("keydown", (KeyboardEvent e) {
			if (!keys[e.which]) {
				keys_pressed[e.which]=true;
				if (debug)
                	print("Pressed: " + e.which.toString());
			}
			keys[e.which]=true;
		});
		window.addEventListener("keyup", (KeyboardEvent e) {
			keys_released[e.which]=true;
			keys[e.which]=false;
			if (debug)
            	print("Released: " + e.which.toString());
		});
	}
	
	static void endFrame() {
		keys_pressed.fillRange(0, 256, false);
		keys_released.fillRange(0, 256, false);
	}
}