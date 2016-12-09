class CCArray: public CCObject
{
	static CCArray* create();
	static CCArray* createWithArray(CCArray* otherArray);
	static CCArray* createWithCapacity(unsigned int capacity);
	static tolua_outside CCArray* CCArray_create @ create(CCObject* objects[tolua_len]);

	tolua_readonly tolua_property__qt unsigned int count;
	tolua_readonly tolua_property__qt unsigned int capacity;
	tolua_readonly tolua_property__qt CCObject* lastObject @ last;
	tolua_readonly tolua_property__qt CCObject* randomObject;

	bool isEqualToArray @ equals(CCArray* pOtherArray);
	bool containsObject @ contains(CCObject* object);
	void addObject @ add(CCObject* object);
	void addObjectsFromArray @ addRange(CCArray* otherArray);
	void removeLastObject @ removeLast();
	void removeObject @ remove(CCObject* object);
	void removeObjectsInArray @ removeFrom(CCArray* otherArray);
	void removeAllObjects @ clear();
	void fastRemoveObject @ fastRemove(CCObject* object);
	void exchangeObject @ swap(CCObject* object1, CCObject* object2);
	void reverseObjects @ reverse();
	void reduceMemoryFootprint @ shrink();

	tolua_outside unsigned int CCArray_index @ index(CCObject* object);
	tolua_outside CCObject* CArray_get @ get(unsigned int index);
	tolua_outside void CArray_insert @ insert(CCObject* object, unsigned int index);
	tolua_outside void CArray_removeAt @ removeAt(unsigned int index);
	tolua_outside void CArray_exchange @ exchange(unsigned int index1, unsigned int index2);
	tolua_outside void CArray_fastRemoveAt @ fastRemoveAt(unsigned int index);
	tolua_outside void CArray_set @ set(unsigned int uIndex, CCObject* pObject);
};
