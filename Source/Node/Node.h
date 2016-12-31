/* Copyright (c) 2013 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

NS_DOROTHY_BEGIN

class Node
{
public:
/*
	PROPERTY(int, _zOrder, ZOrder);
	PROPERTY(float, _angle, Angle);
	PROPERTY(float, _scaleX, ScaleX);
	PROPERTY(float, _scaleY, ScaleY);
	tolua_property__common oVec2 position;
	tolua_property__common float positionX;
	tolua_property__common float positionY;
	tolua_property__common float positionZ;
	tolua_property__common float skewX;
	tolua_property__common float skewY;
	tolua_property__bool bool visible;
	tolua_property__common oVec2 anchorPoint @ anchor;
	tolua_property__common CCSize contentSize;
	tolua_property__common float width;
	tolua_property__common float height;
	tolua_property__common int tag;
	tolua_property__common ccColor3 color;
	tolua_property__common float opacity;
	tolua_property__bool bool cascadeOpacity;
	tolua_property__bool bool cascadeColor;
	tolua_property__common CCNode* transformTarget;
	//tolua_property__common CCGLProgram* shaderProgram;
	tolua_property__common CCScheduler* scheduler;
	tolua_property__common CCObject* userObject @ data;
	tolua_readonly tolua_property__common CCNode* parent;
	tolua_readonly tolua_property__common CCArray* children;
	tolua_readonly tolua_property__common CCRect boundingBox;
	tolua_readonly tolua_property__qt const char* description;
	tolua_readonly tolua_property__qt int numberOfRunningActions;
	tolua_readonly tolua_property__bool bool running;

	CCNode* addTo(CCNode* child, int zOrder, int tag);
	CCNode* addTo(CCNode* child, int zOrder);
	CCNode* addTo(CCNode* child);

	void addChild(CCNode* child, int zOrder, int tag);
	void addChild(CCNode* child, int zOrder);
	void addChild(CCNode* child);
	void removeChild(CCNode* child, bool cleanup = true);
	void removeChildByTag(int tag, bool cleanup = true);
	void removeAllChildrenWithCleanup(bool cleanup = true);
	void runAction(CCAction* action);
	void stopAllActions();
	void perform(CCAction* action);
	void stopAction(CCAction* action);
	void cleanup();

	CCNode* getChildByTag(int tag);

	void scheduleUpdateWithPriorityLua @ schedule(tolua_function nHandler, int priority = 0);
	void unscheduleUpdate @ unschedule();
	tolua_readonly tolua_property__bool bool updateScheduled @ scheduled;

	oVec2 convertToNodeSpaceAR @ convertToNodeSpace(oVec2& worldPoint);
	oVec2 convertToWorldSpaceAR @ convertToWorldSpace(oVec2& nodePoint);
	oVec2 convertToGameSpace(oVec2& nodePoint);

	static CCNode* create();
	*/
};

NS_DOROTHY_END
