//go:build js && wasm

package main

import (
	"syscall/js"

	wa "wa-lang.org/wa"
)

var exportedFunctions []js.Func

func asyncString(call func() string) js.Value {
	promiseConstructor := js.Global().Get("Promise")
	executor := js.FuncOf(func(_ js.Value, args []js.Value) interface{} {
		resolve := args[0]
		go func() {
			resolve.Invoke(call())
		}()
		return nil
	})
	exportedFunctions = append(exportedFunctions, executor)
	return promiseConstructor.New(executor)
}

func exportAsyncString(target js.Value, name string, call func(string) string) {
	function := js.FuncOf(func(_ js.Value, args []js.Value) interface{} {
		if len(args) == 0 {
			return asyncString(func() string { return "missing path argument" })
		}
		path := args[0].String()
		return asyncString(func() string { return call(path) })
	})
	exportedFunctions = append(exportedFunctions, function)
	target.Set(name, function)
}

func main() {
	api := js.Global().Get("DoraWa")
	if !api.Truthy() {
		api = js.Global().Get("Object").New()
		js.Global().Set("DoraWa", api)
	}

	exportAsyncString(api, "build", wa.WaBuild)
	exportAsyncString(api, "format", wa.WaFormat)

	select {}
}
