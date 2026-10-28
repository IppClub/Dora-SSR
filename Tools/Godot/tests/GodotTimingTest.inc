// Included in the native harness namespace, sharing capture/create helpers.
int startTimingTest() {
    const auto buffer=SharedApplication.getBufferSize();
    fprintf(stderr,"GODOT_TIMING_VIEW width=%d height=%d scale=1.25\n",int(buffer.width),int(buffer.height));
    std::filesystem::create_directories(std::filesystem::u8path(output));
    SharedDirector.setClearColor(Dora::Color(0xff192331));
    SharedDirector.beginGameCapture();
    if (!createNode()) { result=2; stopGodotTest(); return 1; }
    auto controller=Dora::Node::create();SharedDirector.getUI()->addChild(controller);
    auto tick=std::make_shared<int>(0);
    controller->schedule([tick](double) {
        if (capturePending) return false;
        ++*tick;
        if (!godot || !godot->getLastError().empty()) { result=2; stopGodotTest();return true; }
        auto key=[](const char *name) {godot->sendKey(name,true);godot->sendKey(name,false);};
        auto sample=[&](const char *name) {
            key("F5");
            const auto size=godot->getViewportSize();
            fprintf(stderr,"GODOT_TIMING_CAPTURE name=%s width=%.0f height=%.0f\n",name,size.width,size.height);
            capture(name);
        };
        if (*tick==45) godot->resume();
        if (*tick==90) sample("normal-a.png");
        if (*tick==150) sample("normal-b.png");
        if (*tick==180) key("F2");
        if (*tick==240) sample("quarter-a.png");
        if (*tick==300) sample("quarter-b.png");
        if (*tick==330) key("F3");
        if (*tick==390) sample("double-a.png");
        if (*tick==450) sample("double-b.png");
        if (*tick==480) { key("F1");godot->pause(); }
        if (*tick==540) sample("paused-a.png");
        if (*tick==600) sample("paused-b.png");
        if (*tick==620) godot->resume();
        if (*tick==630) key("F4");
        if (*tick==690) sample("freeze-a.png");
        if (*tick==710 && !godot->resizeViewport(800,450)) result=2;
        if (*tick==760) sample("freeze-resized.png");
        if (*tick==780 && !godot->resizeViewport(640,360)) result=2;
        if (*tick==830) sample("freeze-b.png");
        if (*tick==850) key("F1");
        if (*tick==910) sample("resumed-a.png");
        if (*tick==970) sample("resumed-b.png");
        if (*tick==1000) {
            if (captures!=13 || !godot->isRunning()) result=2;
            fprintf(stderr,"GODOT_TIMING_TEST frames=1000 captures=%d result=%d\n",captures,result);
            stopGodotTest();return true;
        }
        return false;
    });
    return 1;
}
