class CCParticleBatchNode : public CCNode
{
    static CCParticleBatchNode* createWithTexture(CCTexture2D* tex, unsigned int capacity = 500);
    static CCParticleBatchNode* create(const char* fileImage, unsigned int capacity = 500);
};
