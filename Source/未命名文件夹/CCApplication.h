enum ccLanguageType {};
module CCLanguageType
{
    #define kLanguageEnglish @ English
    #define kLanguageChinese @ Chinese
    #define kLanguageFrench @ French
    #define kLanguageItalian @ Italian
    #define kLanguageGerman @ German
    #define kLanguageSpanish @ Spanish
    #define kLanguageRussian @ Russian
    #define kLanguageKorean @ Korean
    #define kLanguageJapanese @ Japanese
    #define kLanguageHungarian @ Hungarian
    #define kLanguagePortuguese @ Portuguese
    #define kLanguageArabic @ Arabic
}

enum TargetPlatform {};
module CCTargetPlatform
{
    #define kTargetWindows @ Windows
    #define kTargetMacOS @ MacOS
    #define kTargetAndroid @ Android
    #define kTargetIphone @ Iphone
    #define kTargetIpad @ Ipad
}

class CCApplication
{
	enum
	{
		EnterBackground,
		EnterForeground,
		LowMemoryWarning
	};

	tolua_readonly tolua_property__common ccLanguageType currentLanguage;
	tolua_readonly tolua_property__common TargetPlatform targetPlatform;
	tolua_property__common tolua_function scriptHandler @ eventHandler;

	static CCApplication* sharedApplication @ create();
};
