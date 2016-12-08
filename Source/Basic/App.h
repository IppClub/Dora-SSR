//
//  App.hpp
//  Dorothy
//
//  Created by Li Jin on 2016/12/7.
//  Copyright © 2016年 Dorothy. All rights reserved.
//

#ifndef App_h
#define App_h

struct SDL_Window;

class App
{
public:
	int run();
	virtual void setSdlWindow(SDL_Window* window);
	static int mainLogic(void* userData);
protected:
	static int winWidth;
	static int winHeight;
	static bool running;
};

#endif /* App_h */
