def can_build(env, platform):
    return platform == "macos" and env["metal"]

def configure(env):
    pass
