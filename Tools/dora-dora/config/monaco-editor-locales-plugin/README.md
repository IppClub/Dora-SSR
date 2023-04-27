# monaco-editor-locales-plugin
A webpack plugin for monaco-editor locales setting

[https://github.com/xxxxst/monaco-editor-locales-plugin](https://github.com/xxxxst/monaco-editor-locales-plugin)

<h2 align="center">Install</h2>

```bash
npm install --save-dev monaco-editor-locales-plugin
```

<h2 align="center">Usage</h2>

**webpack config**
```js
module.exports = {
    ...
    plugins: [
        new MonacoLocalesPlugin({
            /**
             * support languages list, .eg ["de"]
             * embed language base on monaco-editor@0.14.6
             * all available embed languages: de,es,fr,it,ja,ko,ru,zh-cn,zh-tw
             * just add what you need to reduce the size
             */
            languages: [],
            /**
             * default language name, .eg "de"
             * use function string to set dynamic, .eg "getLanguageSetting()"
            */
            defaultLanguage: "",
            //defaultLanguage: "getLanguageSetting()",
            /**
             * log on console if unmatched
             */
            logUnmatched: false,
            /**
             * self languages map, .eg {"zh-cn": {"Find": "查找", "Search": "搜索"}, "de":{}, ... }
             */
            mapLanguage: {},
        })
    ]
}
```

if the param "defaultLanguage" set as a function,it will be called at the monaco-editor library loaded.

therefore if the user want to change language,they need to refresh the page.

html code usage:
```html
<html>
    <head>
    <script language="javascript" src="https://code.jquery.com/jquery-1.11.3.min.js"></script>
    <script language="javascript" src="https://cdnjs.cloudflare.com/ajax/libs/jquery-cookie/1.4.1/jquery.cookie.min.js"></script>

    <script type="text/javascript">
        //save data before refresh
        $.cookie('language', "zh-cn");

        //make sure that the function be declared before monaco-editor lib loaded
        function getLanguageSetting(){
            return $.cookie('language');
        }
    </script>

    <!-- monaco-editor lib -->
    <script language="javascript" src="./static/js/vendor.dll.js"></script>
    ...
    </head>
</html>
```

<h2>important</h2>
This is not the best way to do it. Because this is a direct change to monaco-editor's source code-
"monaco-editor/esm/vs/nls.js",

## License

[MIT ©xxxxst](LICENSE)

Copyright (c) 2018-present, xxxxst
