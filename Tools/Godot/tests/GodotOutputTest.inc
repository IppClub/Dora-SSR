// Real source-driven output changes; capture the final Dora composite and route
// the test click through SDL -> Dora Touch -> node -> Godot GUI.
int startOutputTest() {
    const auto buffer=SharedApplication.getBufferSize();
    fprintf(stderr,"GODOT_OUTPUT_VIEW width=%d height=%d scale=0.85 x=40 y=-20\n",int(buffer.width),int(buffer.height));
    std::filesystem::create_directories(std::filesystem::u8path(output));
    SharedDirector.setClearColor(Dora::Color(0xff192331));SharedDirector.beginGameCapture();
    if (!createNode()) { result=2;stopGodotTest();return 1; }
    godot->setScaleX(.85f);godot->setScaleY(.85f);godot->setPosition({40,-20});
    auto controller=Dora::Node::create();SharedDirector.getUI()->addChild(controller);
    auto tick=std::make_shared<int>(0);
    controller->schedule([tick](double) {
        if (capturePending) return false;
        ++*tick;
        if (!godot || !godot->getLastError().empty()) { result=2;stopGodotTest();return true; }
        if (*tick==60) godot->resume();
        if (*tick==90) {
            const bool startup=environmentUtf8("DORA_GODOT_TEST_OUTPUT_STARTUP")=="1";
            const auto size=godot->getViewportSize();const auto *texture=godot->getTexture();
            if (!godot->isRunning() || size.width!=(startup?720:640) || size.height!=(startup?480:360)
                || !texture || texture->getWidth()!=size.width || texture->getHeight()!=size.height) result=2;
            fprintf(stderr,"GODOT_OUTPUT_STARTUP width=%.0f height=%.0f result=%d\n",size.width,size.height,result);
        }
        if (*tick>=120 && *tick<1240) {
            const int phase=(*tick-120)/140+1,local=(*tick-120)%140;
            const int widths[]={800,800,800,800,800,720,640,720};
            const int heights[]={450,600,600,600,600,480,360,480};
            if (local==0) { const auto key="F"+std::to_string(phase);godot->sendKey(key,true);godot->sendKey(key,false); }
            if (local==60) {
                const auto size=godot->getViewportSize();
                const auto *texture=godot->getTexture();
                if (!godot->isRunning() || size.width!=widths[phase-1] || size.height!=heights[phase-1]
                    || !texture || texture->getWidth()!=size.width || texture->getHeight()!=size.height) result=2;
                fprintf(stderr,"GODOT_OUTPUT_SIZE phase=%d width=%.0f height=%.0f result=%d\n",phase,size.width,size.height,result);
                const int px[]={80,200,200,200,200,200,80,180};
                const int py[]={60,225,225,200,150,180,60,173};
                godot->convertToWindowSpace({float(px[phase-1]),size.height-py[phase-1]},[phase](const Dora::Vec2 &p) {
                    const auto window=SDL_GetWindowID(SharedApplication.getSDLWindow());
                    SDL_Event down{},up{};
                    const bool mouse=(Dora::Touch::getSource()&Dora::Touch::FromMouse)!=0;
                    if (mouse) {
                        down.type=SDL_MOUSEBUTTONDOWN;down.button.windowID=window;
                        down.button.button=SDL_BUTTON_LEFT;down.button.state=SDL_PRESSED;
                        down.button.x=int(std::lround(p.x));down.button.y=int(std::lround(p.y));
                        up=down;up.type=SDL_MOUSEBUTTONUP;up.button.state=SDL_RELEASED;
                    } else {
                        // SDL's native mouse-to-touch conversion happens before
                        // SDL_PushEvent. Match that event class on touch-source
                        // platforms instead of injecting mouse events they ignore.
                        const auto win=SharedApplication.getWinSize();
                        down.type=SDL_FINGERDOWN;down.tfinger.windowID=window;
                        down.tfinger.touchId=SDL_MOUSE_TOUCHID;down.tfinger.fingerId=1;
                        down.tfinger.x=p.x/win.width;down.tfinger.y=p.y/win.height;down.tfinger.pressure=1;
                        up=down;up.type=SDL_FINGERUP;up.tfinger.pressure=0;
                    }
                    if (SDL_PushEvent(&down)!=1 || SDL_PushEvent(&up)!=1) result=2;
                    fprintf(stderr,"GODOT_OUTPUT_SDL phase=%d x=%.3f y=%.3f kind=%s\n",phase,p.x,p.y,mouse?"mouse":"touch");
                });
            }
            if (local==80 || local==110) capture("phase-"+std::to_string(phase)+(local==80?"-a.png":"-b.png"));
        }
        if (*tick==1260) {
            if (captures!=16 || !godot->isRunning()) result=2;
            fprintf(stderr,"GODOT_OUTPUT_TEST frames=1260 captures=%d result=%d\n",captures,result);
            stopGodotTest();return true;
        }
        return false;
    });return 1;
}
