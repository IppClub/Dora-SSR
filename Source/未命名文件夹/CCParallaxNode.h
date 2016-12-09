class CCParallaxNode: public CCNode
{
    void addChild(CCNode* child, unsigned int z, oVec2 ratio, oVec2 offset);

    static CCParallaxNode* create();
};
