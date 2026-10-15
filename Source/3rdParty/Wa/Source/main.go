package main

import (
	"fmt"
	"os"
	"path/filepath"
	"unsafe"

	"wa-lang.org/wa/internal/app/appbase"
	"wa-lang.org/wa/internal/backends/compiler_wat"
	"wa-lang.org/wa/internal/config"
	"wa-lang.org/wa/internal/format"
	"wa-lang.org/wa/internal/gitjobs"
	"wa-lang.org/wa/internal/loader"
	"wa-lang.org/wa/internal/wat/watutil"
	"wa-lang.org/wa/internal/wat/watutil/watstrip"
)

/*
#include <stdlib.h>
*/
import "C"

func buildApp(input string) (err error) {
	// 路径是否存在
	if !appbase.PathExists(input) {
		return fmt.Errorf("%q not found", input)
	}

	// 构建目录
	if !appbase.IsNativeDir(input) {
		return fmt.Errorf("%q is not valid input path", input)
	}

	// 尝试读取模块信息
	manifest, err := config.LoadManifest(nil, input)
	if err != nil {
		return fmt.Errorf("%q is invalid wa moudle", input)
	}

	outfile := filepath.Join(input, manifest.Pkg.Name+".wasm")

	manifest.Pkg.Target = config.WaOS_wasi

	if err := manifest.Valid(); err != nil {
		return fmt.Errorf("%q is invalid wa module; %v", input, err)
	}

	// 编译出 wat 文件
	_, _, watOutput, err := buildWat(input)
	if err != nil {
		return err
	}

	// 优化 wat 文件
	watOutput, err = watstrip.WatStrip(input, watOutput)
	if err != nil {
		return err
	}

	// wat 编译为 wasm
	wasmBytes, err := watutil.Wat2Wasm(input, watOutput)
	if err != nil {
		return fmt.Errorf("wat2wasm %s failed: %v", input, err)
	}

	// wasm 写到文件
	err = os.WriteFile(outfile, wasmBytes, 0666)
	if err != nil {
		return fmt.Errorf("write %s failed: %v", outfile, err)
	}

	// OK
	return nil
}

func buildWat(filename string) (
	prog *loader.Program, compiler *compiler_wat.Compiler,
	watBytes []byte, err error,
) {
	cfg := config.DefaultConfig()
	cfg.Target = config.WaOS_wasi
	cfg.WaSizes.MaxAlign = 8
	cfg.WaSizes.WordSize = 4

	prog, err = loader.LoadProgram(cfg, filename)
	if err != nil {
		return prog, nil, nil, err
	}

	compiler = compiler_wat.New()
	output, err := compiler.Compile(prog)

	if err != nil {
		return prog, nil, nil, err
	}

	return prog, compiler, []byte(output), nil
}

//export WaBuild
func WaBuild(input *C.char) *C.char {
	err := buildApp(C.GoString(input))
	if err != nil {
		return C.CString(err.Error())
	}
	return C.CString("")
}

//export WaFormat
func WaFormat(input *C.char) *C.char {
	code, changed, err := format.File(nil, C.GoString(input), nil)
	if err != nil {
		return C.CString("")
	}
	if changed {
		return C.CString(string(code))
	}
	return C.CString("")
}

//export WaFreeCString
func WaFreeCString(str *C.char) {
	C.free(unsafe.Pointer(str))
}

//export WaGitStartClone
func WaGitStartClone(url *C.char, path *C.char, branch *C.char, token *C.char, depth C.int) C.longlong {
	return C.longlong(gitjobs.StartClone(
		C.GoString(url),
		C.GoString(path),
		C.GoString(branch),
		C.GoString(token),
		int(depth),
	))
}

//export WaGitStartPull
func WaGitStartPull(path *C.char, branch *C.char, token *C.char, force C.int) C.longlong {
	return C.longlong(gitjobs.StartPull(
		C.GoString(path),
		C.GoString(branch),
		C.GoString(token),
		force != 0,
	))
}

//export WaGitRun
func WaGitRun(repoPath *C.char, command *C.char, optionsJSON *C.char) C.longlong {
	return C.longlong(gitjobs.StartRun(
		C.GoString(repoPath),
		C.GoString(command),
		C.GoString(optionsJSON),
	))
}

//export WaGitPoll
func WaGitPoll(jobID C.longlong) *C.char {
	return C.CString(gitjobs.Poll(int64(jobID)))
}

//export WaGitCancel
func WaGitCancel(jobID C.longlong) C.int {
	if gitjobs.Cancel(int64(jobID)) {
		return 1
	}
	return 0
}

//export WaGitDispose
func WaGitDispose(jobID C.longlong) C.int {
	if gitjobs.Dispose(int64(jobID)) {
		return 1
	}
	return 0
}

func main() {}
