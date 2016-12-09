class CCParticleSystem  @ CCParticle : public CCNode
{
	tolua_property__bool bool autoRemoveOnFinish @ autoRemove;
	static tolua_readonly tolua_property__common CCTexture2D* defaultTexture;

    void resetSystem @ start();
    void stopSystem @ stop();

    static CCParticleSystem* create(const char* plistFile);

	static CCParticleSystem* fire(unsigned int totalParticle = 250);
};
