class CCKeyboard
{
	void updateKey(unsigned char key, bool isDown);
	bool isKeyDown(unsigned char key);
	bool isKeyUp(unsigned char key);
	bool isKeyPressed(unsigned char key);
	static CCKeyboard* sharedKeyboard @ create();
};
