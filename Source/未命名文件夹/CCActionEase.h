module CCEase
{
	static tolua_outside CCActionInterval* CCEaseIn::create @ holdIn(CCActionInterval* pAction, float fRate);
	static tolua_outside CCActionInterval* CCEaseOut::create @ holdOut(CCActionInterval* pAction, float fRate);
	static tolua_outside CCActionInterval* CCEaseInOut::create @ holdInOut(CCActionInterval* pAction, float fRate);
	static tolua_outside CCActionInterval* CCEaseExponentialIn::create @ exponentialIn(CCActionInterval* pAction);
	static tolua_outside CCActionInterval* CCEaseExponentialOut::create @ exponentialOut(CCActionInterval* pAction);
	static tolua_outside CCActionInterval* CCEaseExponentialInOut::create @ exponentialInOut(CCActionInterval* pAction);
	static tolua_outside CCActionInterval* CCEaseSineIn::create @ sineIn(CCActionInterval* pAction);
	static tolua_outside CCActionInterval* CCEaseSineOut::create @ sineOut(CCActionInterval* pAction);
	static tolua_outside CCActionInterval* CCEaseSineInOut::create @ sineInOut(CCActionInterval* pAction);
	static tolua_outside CCActionInterval* CCEaseElasticIn::create @ elasticIn(CCActionInterval *pAction, float fPeriod = 0.3);
	static tolua_outside CCActionInterval* CCEaseElasticOut::create @ elasticOut(CCActionInterval *pAction, float fPeriod = 0.3);
	static tolua_outside CCActionInterval* CCEaseElasticInOut::create @ elasticInOut(CCActionInterval *pAction, float fPeriod = 0.3);
	static tolua_outside CCActionInterval* CCEaseBounceIn::create @ bounceIn(CCActionInterval* pAction);
	static tolua_outside CCActionInterval* CCEaseBounceOut::create @ bounceOut(CCActionInterval* pAction);
	static tolua_outside CCActionInterval* CCEaseBounceInOut::create @ bounceInOut(CCActionInterval* pAction);
	static tolua_outside CCActionInterval* CCEaseBackIn::create @ backIn(CCActionInterval* pAction);
	static tolua_outside CCActionInterval* CCEaseBackOut::create @ backOut(CCActionInterval* pAction);
	static tolua_outside CCActionInterval* CCEaseBackInOut::create @ backInOut(CCActionInterval* pAction);
}
