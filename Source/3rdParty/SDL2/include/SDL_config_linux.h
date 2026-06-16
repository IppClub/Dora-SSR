/*
  Simple DirectMedia Layer
  Copyright (C) 1997-2024 Sam Lantinga <slouken@libsdl.org>

  This software is provided 'as-is', without any express or implied
  warranty.  In no event will the authors be held liable for any damages
  arising from the use of this software.

  Permission is granted to anyone to use this software for any purpose,
  including commercial applications, and to alter it and redistribute it
  freely, subject to the following restrictions:

  1. The origin of this software must not be misrepresented; you must not
     claim that you wrote the original software. If you use this software
     in a product, an acknowledgment in the product documentation would be
     appreciated but is not required.
  2. Altered source versions must be plainly marked as such, and must not be
     misrepresented as being the original software.
  3. This notice may not be removed or altered from any source distribution.
*/

#ifndef SDL_config_linux_h_
#define SDL_config_linux_h_
#define SDL_config_h_

#include "SDL_platform.h"

#ifdef __LP64__
#define SIZEOF_VOIDP 8
#else
#define SIZEOF_VOIDP 4
#endif

#define SDL_BYTEORDER 1234

#define STDC_HEADERS 1
#define HAVE_ALLOCA_H 1
#define HAVE_CTYPE_H 1
#define HAVE_DLFCN_H 1
#define HAVE_INTTYPES_H 1
#define HAVE_LIMITS_H 1
#define HAVE_MALLOC_H 1
#define HAVE_MATH_H 1
#define HAVE_MEMORY_H 1
#define HAVE_SIGNAL_H 1
#define HAVE_STDARG_H 1
#define HAVE_STDINT_H 1
#define HAVE_STDIO_H 1
#define HAVE_STDLIB_H 1
#define HAVE_STRINGS_H 1
#define HAVE_STRING_H 1
#define HAVE_SYS_TYPES_H 1
#define HAVE_UNISTD_H 1

#define HAVE_DLOPEN 1
#define HAVE_MALLOC 1
#define HAVE_CALLOC 1
#define HAVE_REALLOC 1
#define HAVE_FREE 1
#define HAVE_ALLOCA 1
#define HAVE_GETENV 1
#define HAVE_SETENV 1
#define HAVE_PUTENV 1
#define HAVE_UNSETENV 1
#define HAVE_QSORT 1
#define HAVE_BSEARCH 1
#define HAVE_ABS 1
#define HAVE_BCOPY 1
#define HAVE_MEMSET 1
#define HAVE_MEMCPY 1
#define HAVE_MEMMOVE 1
#define HAVE_STRLEN 1
#define HAVE_STRCHR 1
#define HAVE_STRRCHR 1
#define HAVE_STRSTR 1
#define HAVE_STRTOL 1
#define HAVE_STRTOUL 1
#define HAVE_STRTOLL 1
#define HAVE_STRTOULL 1
#define HAVE_ATOI 1
#define HAVE_ATOF 1
#define HAVE_STRCMP 1
#define HAVE_STRNCMP 1
#define HAVE_STRCASECMP 1
#define HAVE_STRNCASECMP 1
#define HAVE_VSSCANF 1
#define HAVE_VSNPRINTF 1
#define HAVE_M_PI 1
#define HAVE_CEIL 1
#define HAVE_COPYSIGN 1
#define HAVE_COS 1
#define HAVE_COSF 1
#define HAVE_EXP 1
#define HAVE_FABS 1
#define HAVE_FLOOR 1
#define HAVE_LOG 1
#define HAVE_LOG10 1
#define HAVE_LROUND 1
#define HAVE_LROUNDF 1
#define HAVE_ROUND 1
#define HAVE_ROUNDF 1
#define HAVE_SCALBN 1
#define HAVE_SIN 1
#define HAVE_SINF 1
#define HAVE_SQRT 1
#define HAVE_SQRTF 1
#define HAVE_TAN 1
#define HAVE_TANF 1
#define HAVE_TRUNC 1
#define HAVE_TRUNCF 1
#define HAVE_SIGACTION 1
#define HAVE_SA_SIGACTION 1
#define HAVE_SETJMP 1
#define HAVE_NANOSLEEP 1
#define HAVE_CLOCK_GETTIME 1

#define SDL_AUDIO_DRIVER_ALSA 1
#define SDL_AUDIO_DRIVER_ALSA_DYNAMIC "libasound.so.2"
#define SDL_AUDIO_DRIVER_DUMMY 1
#define SDL_AUDIO_DRIVER_DISK 1
#define SDL_AUDIO_DRIVER_PIPEWIRE 1
#define SDL_AUDIO_DRIVER_PIPEWIRE_DYNAMIC "libpipewire-0.3.so.0"
#define SDL_AUDIO_DRIVER_PULSEAUDIO 1
#define SDL_AUDIO_DRIVER_PULSEAUDIO_DYNAMIC "libpulse.so.0"

#define SDL_INPUT_LINUXEV 1
#define SDL_INPUT_LINUXKD 1
#define SDL_JOYSTICK_LINUX 1
#define SDL_JOYSTICK_VIRTUAL 1
#define SDL_HAPTIC_LINUX 1
#define SDL_HIDAPI_DISABLED 1
#define SDL_SENSOR_DUMMY 1

#define SDL_LOADSO_DLOPEN 1

#define SDL_THREAD_PTHREAD 1
#define SDL_THREAD_PTHREAD_RECURSIVE_MUTEX_NP 1

#define SDL_TIMER_UNIX 1
#define SDL_FILESYSTEM_UNIX 1
#define SDL_POWER_LINUX 1

#define HAVE_DBUS_DBUS_H 1
#define HAVE_FCITX 1
#define SDL_USE_LIBDBUS 1
#define SDL_USE_IME 1

#define SDL_VIDEO_DRIVER_DUMMY 1
#define SDL_VIDEO_DRIVER_WAYLAND 1
#define SDL_VIDEO_DRIVER_WAYLAND_DYNAMIC "libwayland-client.so.0"
#define SDL_VIDEO_DRIVER_WAYLAND_DYNAMIC_CURSOR "libwayland-cursor.so.0"
#define SDL_VIDEO_DRIVER_WAYLAND_DYNAMIC_EGL "libwayland-egl.so.1"
#define SDL_VIDEO_DRIVER_WAYLAND_DYNAMIC_LIBDECOR "libdecor-0.so.0"
#define SDL_VIDEO_DRIVER_WAYLAND_DYNAMIC_XKBCOMMON "libxkbcommon.so.0"
#define SDL_VIDEO_DRIVER_WAYLAND_QT_TOUCH 1
#define SDL_VIDEO_DRIVER_X11 1
#define SDL_VIDEO_DRIVER_X11_DYNAMIC "libX11.so.6"
#define SDL_VIDEO_DRIVER_X11_DYNAMIC_XCURSOR "libXcursor.so.1"
#define SDL_VIDEO_DRIVER_X11_DYNAMIC_XEXT "libXext.so.6"
#define SDL_VIDEO_DRIVER_X11_DYNAMIC_XFIXES "libXfixes.so.3"
#define SDL_VIDEO_DRIVER_X11_DYNAMIC_XINPUT2 "libXi.so.6"
#define SDL_VIDEO_DRIVER_X11_DYNAMIC_XRANDR "libXrandr.so.2"
#define SDL_VIDEO_DRIVER_X11_DYNAMIC_XSS "libXss.so.1"
#define SDL_VIDEO_DRIVER_X11_HAS_XKBKEYCODETOKEYSYM 1
#define SDL_VIDEO_DRIVER_X11_SUPPORTS_GENERIC_EVENTS 1
#define SDL_VIDEO_DRIVER_X11_XCURSOR 1
#define SDL_VIDEO_DRIVER_X11_XDBE 1
#define SDL_VIDEO_DRIVER_X11_XFIXES 1
#define SDL_VIDEO_DRIVER_X11_XINPUT2 1
#define SDL_VIDEO_DRIVER_X11_XINPUT2_SUPPORTS_MULTITOUCH 1
#define SDL_VIDEO_DRIVER_X11_XRANDR 1
#define SDL_VIDEO_DRIVER_X11_XSCRNSAVER 1
#define SDL_VIDEO_DRIVER_X11_XSHAPE 1
#define SDL_VIDEO_OPENGL 1
#define SDL_VIDEO_OPENGL_EGL 1
#define SDL_VIDEO_OPENGL_GLX 1
#define SDL_VIDEO_OPENGL_ES2 1
#define SDL_VIDEO_VULKAN 1

#define SDL_HAVE_LIBDECOR_GET_MIN_MAX 1
#define HAVE_LIBDECOR_H 1
#define HAVE_LINUX_VERSION_H 1
#define HAVE_SYS_INOTIFY_H 1
#define HAVE_INOTIFY 1

#endif /* SDL_config_linux_h_ */
