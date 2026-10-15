/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */


using System.Runtime.InteropServices;
using int64_t = long;
using int32_t = int;

namespace Dora
{
	internal static partial class Native
	{
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void dbparams_release(int64_t raw);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void dbparams_add(int64_t self, int64_t params_);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t dbparams_new();
	}
} // namespace Dora

namespace Dora
{
	public partial class DBParams
	{
		private DBParams(long raw)
		{
			if (raw == 0) throw new InvalidOperationException("failed to create DBParams");
			Raw = raw;
		}
		~DBParams()
		{
			Native.dbparams_release(Raw);
		}
		internal long Raw { get; private set; }
		internal static DBParams From(long raw)
		{
			return new DBParams(raw);
		}
		public void Add(Array params_)
		{
			Native.dbparams_add(Raw, params_.Raw);
		}
		public DBParams() : this(Native.dbparams_new()) { }
	}
} // namespace Dora
