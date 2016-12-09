module oCache
{
	class oAnimationCache @ Animation
	{
		static tolua_outside bool oAnimationCache_load @ load( const char* filename );
		static tolua_outside bool oAnimationCache_update @ update(const char* name, const char* content);
		static tolua_outside bool oAnimationCache_unload @ unload( const char* filename = nullptr);
		static tolua_outside void oAnimationCache_removeUnused @ removeUnused();
	};
	
	class oParticleCache @ Particle
	{
		static tolua_outside bool oParticleCache_load @ load( const char* filename );
		static tolua_outside bool oParticleCache_update @ update(const char* name, const char* content);
		static tolua_outside bool oParticleCache_unload @ unload( const char* filename = nullptr );
		static tolua_outside void oParticleCache_removeUnused @ removeUnused();
	};

	class oEffectCache @ Effect
	{
		static tolua_outside bool oEffectCache_load @ load( const char* filename );
		static tolua_outside bool oEffectCache_update @ update(const char* content);
		static tolua_outside const char* oEffectCache_getFileByName @ getFileByName(const char* name);
		static tolua_outside bool oEffectCache_unload @ unload();
	};

	class oModelCache @ Model
	{
		static tolua_outside bool oModelCache_load @ load( const char* filename );
		static tolua_outside bool oModelCache_update @ update(const char* name, const char* content);
		static tolua_outside bool oModelCache_unload @ unload( const char* filename = nullptr );
		static tolua_outside void oModelCache_removeUnused @ removeUnused();
		static tolua_outside void oModelCache_getData @ getData( const char* filename);
		static tolua_outside void oModelCache_loadData @ loadData( const char* filename, tolua_table table_idx);
		static tolua_outside void oModelCache_save @ save(const char* itemName, const char* targetName);
		static tolua_outside void oModelCache_getClipFile @ getClipFile(const char* filename);
		static tolua_outside void oModelCache_getLookNames @ getLookNames(const char* filename);
		static tolua_outside void oModelCache_getAnimationNames @ getAnimationNames(const char* filename);
	};

	class oClipCache @ Clip
	{
		static tolua_outside bool oClipCache_load @ load( const char* filename );
		static tolua_outside bool oClipCache_update @ update(const char* name, const char* content);
		static tolua_outside bool oClipCache_unload @ unload( const char* filename = nullptr );
		static tolua_outside void oClipCache_removeUnused @ removeUnused();
		static tolua_outside void oClipCache_getNames @ getNames(const char* filename);
		static tolua_outside void oClipCache_getTextureFile @ getTextureFile(const char* filename);
	};

	void oCache_clear @ clear();
	void oCache_removeUnused @ removeUnused();
	module Pool
	{
		int oCache_poolCollect @ collect();
		tolua_readonly tolua_property__qt int oCache_poolSize @ size;
	}
}
