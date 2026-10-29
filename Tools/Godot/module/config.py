def can_build(env, platform):
    return (platform in ("macos", "ios") and env["metal"]) or (platform in ("linuxbsd", "windows", "android", "web") and env["opengl3"])

def configure(env):
    pass
