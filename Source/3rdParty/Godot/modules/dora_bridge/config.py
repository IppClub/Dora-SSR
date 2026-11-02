def can_build(env, platform):
    return (platform in ("macos", "ios") and env["metal"]) or (platform in ("linuxbsd", "android", "web") and env["opengl3"]) or (platform == "windows" and (env["opengl3"] or env["d3d12"]))

def configure(env):
    pass
