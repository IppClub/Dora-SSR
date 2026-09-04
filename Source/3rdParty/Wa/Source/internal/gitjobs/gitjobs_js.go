//go:build js

package gitjobs

// Git jobs use go-git, filesystem primitives, and native network transports.
// The browser Wa module intentionally keeps the compiler and formatter
// available while reporting Git as unsupported to its caller.

func StartClone(string, string, string, string, int) int64 { return 0 }

func StartPull(string, string, string, bool) int64 { return 0 }

func StartRun(string, string, string) int64 { return 0 }

func Poll(int64) string {
	return `{"state":"error","error":"Git is unavailable in the browser"}`
}

func Cancel(int64) bool { return false }

func Dispose(int64) bool { return false }
