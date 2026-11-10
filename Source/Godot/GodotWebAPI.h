// Copyright (c) 2026 Dora SSR contributors. MIT license (see repository LICENSE).
#pragma once
#include "Godot/GodotBridgeGL.h"
#include "Godot/GodotBridgeGLTargets.h"
#include "Godot/GodotBridgeAudio.h"
#include "Godot/GodotBridgeOutput.h"
#include "Godot/GodotBridgeIME.h"
#include "Godot/GodotBridgeProject.h"
#include <string>
namespace Dora {
std::pair<bool,std::string> callGodotWebService(const DoraGodotConfig &,const std::string &,const std::string &,bool);
bool loadGodotWebAPI(DoraGodotAPI &,DoraGodotGLAPI &,DoraGodotAudioAPI &,DoraGodotGLTargetsAPI &,DoraGodotOutputAPI &,DoraGodotIMEAPI &,DoraGodotProjectAPI &,std::string &);
}
