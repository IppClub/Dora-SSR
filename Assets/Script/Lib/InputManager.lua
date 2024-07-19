-- [tsx]: InputManager.tsx
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ClassExtends = ____lualib.__TS__ClassExtends -- 1
local __TS__ArrayConcat = ____lualib.__TS__ArrayConcat -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local Map = ____lualib.Map -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local ____exports = {} -- 1
local ____DoraX = require("DoraX") -- 1
local React = ____DoraX.React -- 1
local toNode = ____DoraX.toNode -- 1
local useRef = ____DoraX.useRef -- 1
local ____Dora = require("Dora") -- 2
local Node = ____Dora.Node -- 2
local Vec2 = ____Dora.Vec2 -- 2
local emit = ____Dora.emit -- 2
____exports.Trigger = __TS__Class() -- 12
local Trigger = ____exports.Trigger -- 12
Trigger.name = "Trigger" -- 12
function Trigger.prototype.____constructor(self) -- 13
    self.state = "None" -- 14
    self.progress = 0 -- 15
    self.value = false -- 16
end -- 13
local KeyDownTrigger = __TS__Class() -- 27
KeyDownTrigger.name = "KeyDownTrigger" -- 27
__TS__ClassExtends(KeyDownTrigger, ____exports.Trigger) -- 27
function KeyDownTrigger.prototype.____constructor(self, keys) -- 33
    KeyDownTrigger.____super.prototype.____constructor(self) -- 34
    self.keys = keys -- 35
    self.keyStates = {} -- 36
    self.onKeyDown = function(keyName) -- 37
        if not (self.keyStates[keyName] ~= nil) then -- 37
            return -- 39
        end -- 39
        local oldState = true -- 41
        for ____, state in pairs(self.keyStates) do -- 42
            if oldState then -- 42
                oldState = state -- 43
            end -- 43
        end -- 43
        self.keyStates[keyName] = true -- 45
        if not oldState then -- 45
            local newState = true -- 47
            for ____, state in pairs(self.keyStates) do -- 48
                if newState then -- 48
                    newState = state -- 49
                end -- 49
            end -- 49
            if newState then -- 49
                self.state = "Completed" -- 52
                if self.onChange then -- 52
                    self:onChange() -- 54
                end -- 54
                self.state = "None" -- 56
            end -- 56
        end -- 56
    end -- 37
    self.onKeyUp = function(keyName) -- 60
        if not (self.keyStates[keyName] ~= nil) then -- 60
            return -- 62
        end -- 62
        self.keyStates[keyName] = false -- 64
    end -- 60
end -- 33
function KeyDownTrigger.prototype.start(self, manager) -- 67
    manager.keyboardEnabled = true -- 68
    for ____, k in ipairs(self.keys) do -- 69
        self.keyStates[k] = false -- 70
    end -- 70
    manager:slot("KeyDown", self.onKeyDown) -- 72
    manager:slot("KeyUp", self.onKeyUp) -- 73
    self.state = "None" -- 74
end -- 67
function KeyDownTrigger.prototype.stop(self, manager) -- 76
    manager:slot("KeyDown"):remove(self.onKeyDown) -- 77
    manager:slot("KeyUp"):remove(self.onKeyUp) -- 78
    self.state = "None" -- 79
end -- 76
local KeyUpTrigger = __TS__Class() -- 83
KeyUpTrigger.name = "KeyUpTrigger" -- 83
__TS__ClassExtends(KeyUpTrigger, ____exports.Trigger) -- 83
function KeyUpTrigger.prototype.____constructor(self, keys) -- 89
    KeyUpTrigger.____super.prototype.____constructor(self) -- 90
    self.keys = keys -- 91
    self.keyStates = {} -- 92
    self.onKeyDown = function(keyName) -- 93
        if not (self.keyStates[keyName] ~= nil) then -- 93
            return -- 95
        end -- 95
        self.keyStates[keyName] = true -- 97
    end -- 93
    self.onKeyUp = function(keyName) -- 99
        if not (self.keyStates[keyName] ~= nil) then -- 99
            return -- 101
        end -- 101
        local oldState = true -- 103
        for ____, state in pairs(self.keyStates) do -- 104
            if oldState then -- 104
                oldState = state -- 105
            end -- 105
        end -- 105
        self.keyStates[keyName] = false -- 107
        if oldState then -- 107
            self.state = "Completed" -- 109
            if self.onChange then -- 109
                self:onChange() -- 111
            end -- 111
            self.state = "None" -- 113
        end -- 113
    end -- 99
end -- 89
function KeyUpTrigger.prototype.start(self, manager) -- 117
    manager.keyboardEnabled = true -- 118
    for ____, k in ipairs(self.keys) do -- 119
        self.keyStates[k] = false -- 120
    end -- 120
    manager:slot("KeyDown", self.onKeyDown) -- 122
    manager:slot("KeyUp", self.onKeyUp) -- 123
    self.state = "None" -- 124
end -- 117
function KeyUpTrigger.prototype.stop(self, manager) -- 126
    manager:slot("KeyDown"):remove(self.onKeyDown) -- 127
    manager:slot("KeyUp"):remove(self.onKeyUp) -- 128
    self.state = "None" -- 129
end -- 126
local KeyPressedTrigger = __TS__Class() -- 133
KeyPressedTrigger.name = "KeyPressedTrigger" -- 133
__TS__ClassExtends(KeyPressedTrigger, ____exports.Trigger) -- 133
function KeyPressedTrigger.prototype.____constructor(self, keys) -- 139
    KeyPressedTrigger.____super.prototype.____constructor(self) -- 140
    self.keys = keys -- 141
    self.keyStates = {} -- 142
    self.onKeyDown = function(keyName) -- 143
        if not (self.keyStates[keyName] ~= nil) then -- 143
            return -- 145
        end -- 145
        self.keyStates[keyName] = true -- 147
        local allDown = true -- 148
        for ____, down in pairs(self.keyStates) do -- 149
            if allDown then -- 149
                allDown = down -- 150
            end -- 150
        end -- 150
        if allDown then -- 150
            self.state = "Completed" -- 153
        end -- 153
    end -- 143
    self.onKeyUp = function(keyName) -- 156
        if not (self.keyStates[keyName] ~= nil) then -- 156
            return -- 158
        end -- 158
        self.keyStates[keyName] = false -- 160
        local allDown = true -- 161
        for ____, down in pairs(self.keyStates) do -- 162
            if allDown then -- 162
                allDown = down -- 163
            end -- 163
        end -- 163
        if not allDown then -- 163
            self.state = "None" -- 166
        end -- 166
    end -- 156
end -- 139
function KeyPressedTrigger.prototype.onUpdate(self, _) -- 170
    if self.state == "Completed" then -- 170
        if self.onChange then -- 170
            self:onChange() -- 173
        end -- 173
    end -- 173
end -- 170
function KeyPressedTrigger.prototype.start(self, manager) -- 177
    manager.keyboardEnabled = true -- 178
    for ____, k in ipairs(self.keys) do -- 179
        self.keyStates[k] = false -- 180
    end -- 180
    manager:slot("KeyDown", self.onKeyDown) -- 182
    manager:slot("KeyUp", self.onKeyUp) -- 183
    self.state = "None" -- 184
end -- 177
function KeyPressedTrigger.prototype.stop(self, manager) -- 186
    manager:slot("KeyDown"):remove(self.onKeyDown) -- 187
    manager:slot("KeyUp"):remove(self.onKeyUp) -- 188
    self.state = "None" -- 189
end -- 186
local KeyHoldTrigger = __TS__Class() -- 193
KeyHoldTrigger.name = "KeyHoldTrigger" -- 193
__TS__ClassExtends(KeyHoldTrigger, ____exports.Trigger) -- 193
function KeyHoldTrigger.prototype.____constructor(self, key, holdTime) -- 200
    KeyHoldTrigger.____super.prototype.____constructor(self) -- 201
    self.key = key -- 202
    self.holdTime = holdTime -- 203
    self.time = 0 -- 204
    self.onKeyDown = function(keyName) -- 205
        if self.key == keyName then -- 205
            self.time = 0 -- 207
            self.state = "Started" -- 208
            self.progress = 0 -- 209
            if self.onChange then -- 209
                self:onChange() -- 211
            end -- 211
        end -- 211
    end -- 205
    self.onKeyUp = function(keyName) -- 215
        repeat -- 215
            local ____switch50 = self.state -- 215
            local ____cond50 = ____switch50 == "Started" or ____switch50 == "Ongoing" or ____switch50 == "Completed" -- 215
            if ____cond50 then -- 215
                break -- 220
            end -- 220
            do -- 220
                return -- 222
            end -- 222
        until true -- 222
        if self.key == keyName then -- 222
            if self.state == "Completed" then -- 222
                self.state = "None" -- 226
            else -- 226
                self.state = "Canceled" -- 228
            end -- 228
            self.progress = 0 -- 230
            if self.onChange then -- 230
                self:onChange() -- 232
            end -- 232
        end -- 232
    end -- 215
end -- 200
function KeyHoldTrigger.prototype.start(self, manager) -- 237
    manager.keyboardEnabled = true -- 238
    manager:slot("KeyDown", self.onKeyDown) -- 239
    manager:slot("KeyUp", self.onKeyUp) -- 240
    self.state = "None" -- 241
    self.progress = 0 -- 242
end -- 237
function KeyHoldTrigger.prototype.onUpdate(self, deltaTime) -- 244
    repeat -- 244
        local ____switch57 = self.state -- 244
        local ____cond57 = ____switch57 == "Started" or ____switch57 == "Ongoing" -- 244
        if ____cond57 then -- 244
            break -- 248
        end -- 248
        do -- 248
            return -- 250
        end -- 250
    until true -- 250
    self.time = self.time + deltaTime -- 252
    if self.time >= self.holdTime then -- 252
        self.state = "Completed" -- 254
        self.progress = 1 -- 255
    else -- 255
        self.state = "Ongoing" -- 257
        self.progress = math.min(self.time / self.holdTime, 1) -- 258
    end -- 258
    if self.onChange then -- 258
        self:onChange() -- 261
    end -- 261
end -- 244
function KeyHoldTrigger.prototype.stop(self, manager) -- 264
    manager:slot("KeyDown"):remove(self.onKeyDown) -- 265
    manager:slot("KeyUp"):remove(self.onKeyUp) -- 266
    self.state = "None" -- 267
    self.progress = 0 -- 268
end -- 264
local KeyTimedTrigger = __TS__Class() -- 272
KeyTimedTrigger.name = "KeyTimedTrigger" -- 272
__TS__ClassExtends(KeyTimedTrigger, ____exports.Trigger) -- 272
function KeyTimedTrigger.prototype.____constructor(self, key, timeWindow) -- 278
    KeyTimedTrigger.____super.prototype.____constructor(self) -- 279
    self.key = key -- 280
    self.timeWindow = timeWindow -- 281
    self.time = 0 -- 282
    self.onKeyDown = function(keyName) -- 283
        repeat -- 283
            local ____switch64 = self.state -- 283
            local ____cond64 = ____switch64 == "Started" or ____switch64 == "Ongoing" or ____switch64 == "Completed" -- 283
            if ____cond64 then -- 283
                break -- 288
            end -- 288
            do -- 288
                return -- 290
            end -- 290
        until true -- 290
        if self.key == keyName and self.time <= self.timeWindow then -- 290
            self.state = "Completed" -- 293
            self.value = self.time -- 294
            if self.onChange then -- 294
                self:onChange() -- 296
            end -- 296
        end -- 296
    end -- 283
end -- 278
function KeyTimedTrigger.prototype.start(self, manager) -- 301
    manager.keyboardEnabled = true -- 302
    manager:slot("KeyDown", self.onKeyDown) -- 303
    self.state = "Started" -- 304
    self.time = 0 -- 305
    self.progress = 0 -- 306
    self.value = false -- 307
    if self.onChange then -- 307
        self:onChange() -- 309
    end -- 309
end -- 301
function KeyTimedTrigger.prototype.onUpdate(self, deltaTime) -- 312
    repeat -- 312
        local ____switch70 = self.state -- 312
        local ____cond70 = ____switch70 == "Started" or ____switch70 == "Ongoing" or ____switch70 == "Completed" -- 312
        if ____cond70 then -- 312
            break -- 317
        end -- 317
        do -- 317
            return -- 319
        end -- 319
    until true -- 319
    self.time = self.time + deltaTime -- 321
    if self.time >= self.timeWindow then -- 321
        if self.state == "Completed" then -- 321
            self.state = "None" -- 324
            self.progress = 0 -- 325
        else -- 325
            self.state = "Canceled" -- 327
            self.progress = 1 -- 328
        end -- 328
    else -- 328
        self.state = "Ongoing" -- 331
        self.progress = math.min(self.time / self.timeWindow, 1) -- 332
    end -- 332
    if self.onChange then -- 332
        self:onChange() -- 335
    end -- 335
end -- 312
function KeyTimedTrigger.prototype.stop(self, manager) -- 338
    manager:slot("KeyDown"):remove(self.onKeyDown) -- 339
    self.state = "None" -- 340
    self.value = false -- 341
    self.progress = 0 -- 342
end -- 338
local KeyDoubleDownTrigger = __TS__Class() -- 346
KeyDoubleDownTrigger.name = "KeyDoubleDownTrigger" -- 346
__TS__ClassExtends(KeyDoubleDownTrigger, ____exports.Trigger) -- 346
function KeyDoubleDownTrigger.prototype.____constructor(self, key, threshold) -- 352
    KeyDoubleDownTrigger.____super.prototype.____constructor(self) -- 353
    self.key = key -- 354
    self.threshold = threshold -- 355
    self.time = 0 -- 356
    self.onKeyDown = function(keyName) -- 357
        if self.key == keyName then -- 357
            if self.state == "None" then -- 357
                self.time = 0 -- 360
                self.state = "Started" -- 361
                self.progress = 0 -- 362
                if self.onChange then -- 362
                    self:onChange() -- 364
                end -- 364
            else -- 364
                self.state = "Completed" -- 367
                if self.onChange then -- 367
                    self:onChange() -- 369
                end -- 369
                self.state = "None" -- 371
            end -- 371
        end -- 371
    end -- 357
end -- 352
function KeyDoubleDownTrigger.prototype.start(self, manager) -- 376
    manager.keyboardEnabled = true -- 377
    manager:slot("KeyDown", self.onKeyDown) -- 378
    self.state = "None" -- 379
    self.progress = 0 -- 380
end -- 376
function KeyDoubleDownTrigger.prototype.onUpdate(self, deltaTime) -- 382
    repeat -- 382
        local ____switch86 = self.state -- 382
        local ____cond86 = ____switch86 == "Started" or ____switch86 == "Ongoing" -- 382
        if ____cond86 then -- 382
            break -- 386
        end -- 386
        do -- 386
            return -- 388
        end -- 388
    until true -- 388
    self.time = self.time + deltaTime -- 390
    if self.time >= self.threshold then -- 390
        self.state = "None" -- 392
        self.progress = 1 -- 393
    else -- 393
        self.state = "Ongoing" -- 395
        self.progress = math.min(self.time / self.threshold, 1) -- 396
    end -- 396
    if self.onChange then -- 396
        self:onChange() -- 399
    end -- 399
end -- 382
function KeyDoubleDownTrigger.prototype.stop(self, manager) -- 402
    manager:slot("KeyDown"):remove(self.onKeyDown) -- 403
    self.state = "None" -- 404
    self.progress = 0 -- 405
end -- 402
local AnyKeyPressedTrigger = __TS__Class() -- 409
AnyKeyPressedTrigger.name = "AnyKeyPressedTrigger" -- 409
__TS__ClassExtends(AnyKeyPressedTrigger, ____exports.Trigger) -- 409
function AnyKeyPressedTrigger.prototype.____constructor(self) -- 414
    AnyKeyPressedTrigger.____super.prototype.____constructor(self) -- 415
    self.keyStates = {} -- 416
    self.onKeyDown = function(keyName) -- 417
        self.keyStates[keyName] = true -- 418
        self.state = "Completed" -- 419
    end -- 417
    self.onKeyUp = function(keyName) -- 421
        self.keyStates[keyName] = false -- 422
        local down = false -- 423
        for ____, state in pairs(self.keyStates) do -- 424
            if not down then -- 424
                down = state -- 425
            end -- 425
        end -- 425
        if not down then -- 425
            self.state = "None" -- 428
        end -- 428
    end -- 421
end -- 414
function AnyKeyPressedTrigger.prototype.onUpdate(self, _) -- 432
    if self.state == "Completed" then -- 432
        if self.onChange then -- 432
            self:onChange() -- 435
        end -- 435
    end -- 435
end -- 432
function AnyKeyPressedTrigger.prototype.start(self, manager) -- 439
    manager.keyboardEnabled = true -- 440
    manager:slot("KeyDown", self.onKeyDown) -- 441
    manager:slot("KeyUp", self.onKeyUp) -- 442
    self.state = "None" -- 443
end -- 439
function AnyKeyPressedTrigger.prototype.stop(self, manager) -- 445
    manager:slot("KeyDown"):remove(self.onKeyDown) -- 446
    manager:slot("KeyUp", self.onKeyUp) -- 447
    self.state = "None" -- 448
    self.keyStates = {} -- 449
end -- 445
local ButtonDownTrigger = __TS__Class() -- 453
ButtonDownTrigger.name = "ButtonDownTrigger" -- 453
__TS__ClassExtends(ButtonDownTrigger, ____exports.Trigger) -- 453
function ButtonDownTrigger.prototype.____constructor(self, buttons, controllerId) -- 460
    ButtonDownTrigger.____super.prototype.____constructor(self) -- 461
    self.controllerId = controllerId -- 462
    self.buttons = buttons -- 463
    self.buttonStates = {} -- 464
    self.onButtonDown = function(controllerId, buttonName) -- 465
        if self.controllerId ~= controllerId then -- 465
            return -- 467
        end -- 467
        if not (self.buttonStates[buttonName] ~= nil) then -- 467
            return -- 470
        end -- 470
        local oldState = true -- 472
        for ____, state in pairs(self.buttonStates) do -- 473
            if oldState then -- 473
                oldState = state -- 474
            end -- 474
        end -- 474
        self.buttonStates[buttonName] = true -- 476
        if not oldState then -- 476
            local newState = true -- 478
            for ____, state in pairs(self.buttonStates) do -- 479
                if newState then -- 479
                    newState = state -- 480
                end -- 480
            end -- 480
            if newState then -- 480
                self.state = "Completed" -- 483
                if self.onChange then -- 483
                    self:onChange() -- 485
                end -- 485
                self.state = "None" -- 487
            end -- 487
        end -- 487
    end -- 465
    self.onButtonUp = function(controllerId, buttonName) -- 491
        if self.state == "Completed" then -- 491
            return -- 493
        end -- 493
        if self.controllerId ~= controllerId then -- 493
            return -- 496
        end -- 496
        if not (self.buttonStates[buttonName] ~= nil) then -- 496
            return -- 499
        end -- 499
        self.buttonStates[buttonName] = false -- 501
    end -- 491
end -- 460
function ButtonDownTrigger.prototype.start(self, manager) -- 504
    manager.controllerEnabled = true -- 505
    for ____, k in ipairs(self.buttons) do -- 506
        self.buttonStates[k] = false -- 507
    end -- 507
    manager:slot("ButtonDown", self.onButtonDown) -- 509
    manager:slot("ButtonUp", self.onButtonUp) -- 510
    self.state = "None" -- 511
end -- 504
function ButtonDownTrigger.prototype.stop(self, manager) -- 513
    manager:slot("ButtonDown"):remove(self.onButtonDown) -- 514
    manager:slot("ButtonUp"):remove(self.onButtonUp) -- 515
    self.state = "None" -- 516
    self.value = false -- 517
end -- 513
local ButtonUpTrigger = __TS__Class() -- 521
ButtonUpTrigger.name = "ButtonUpTrigger" -- 521
__TS__ClassExtends(ButtonUpTrigger, ____exports.Trigger) -- 521
function ButtonUpTrigger.prototype.____constructor(self, buttons, controllerId) -- 528
    ButtonUpTrigger.____super.prototype.____constructor(self) -- 529
    self.controllerId = controllerId -- 530
    self.buttons = buttons -- 531
    self.buttonStates = {} -- 532
    self.onButtonDown = function(controllerId, buttonName) -- 533
        if self.controllerId ~= controllerId then -- 533
            return -- 535
        end -- 535
        if not (self.buttonStates[buttonName] ~= nil) then -- 535
            return -- 538
        end -- 538
        self.buttonStates[buttonName] = true -- 540
    end -- 533
    self.onButtonUp = function(controllerId, buttonName) -- 542
        if self.controllerId ~= controllerId then -- 542
            return -- 544
        end -- 544
        if not (self.buttonStates[buttonName] ~= nil) then -- 544
            return -- 547
        end -- 547
        local oldState = true -- 549
        for ____, state in pairs(self.buttonStates) do -- 550
            if oldState then -- 550
                oldState = state -- 551
            end -- 551
        end -- 551
        self.buttonStates[buttonName] = false -- 553
        if oldState then -- 553
            self.state = "Completed" -- 555
            if self.onChange then -- 555
                self:onChange() -- 557
            end -- 557
            self.state = "None" -- 559
        end -- 559
    end -- 542
end -- 528
function ButtonUpTrigger.prototype.start(self, manager) -- 563
    manager.controllerEnabled = true -- 564
    for ____, k in ipairs(self.buttons) do -- 565
        self.buttonStates[k] = false -- 566
    end -- 566
    manager:slot("ButtonDown", self.onButtonDown) -- 568
    manager:slot("ButtonUp", self.onButtonUp) -- 569
    self.state = "None" -- 570
end -- 563
function ButtonUpTrigger.prototype.stop(self, manager) -- 572
    manager:slot("ButtonDown"):remove(self.onButtonDown) -- 573
    manager:slot("ButtonUp"):remove(self.onButtonUp) -- 574
    self.state = "None" -- 575
end -- 572
local ButtonPressedTrigger = __TS__Class() -- 579
ButtonPressedTrigger.name = "ButtonPressedTrigger" -- 579
__TS__ClassExtends(ButtonPressedTrigger, ____exports.Trigger) -- 579
function ButtonPressedTrigger.prototype.____constructor(self, buttons, controllerId) -- 586
    ButtonPressedTrigger.____super.prototype.____constructor(self) -- 587
    self.controllerId = controllerId -- 588
    self.buttons = buttons -- 589
    self.buttonStates = {} -- 590
    self.onButtonDown = function(controllerId, buttonName) -- 591
        if self.controllerId ~= controllerId then -- 591
            return -- 593
        end -- 593
        if not (self.buttonStates[buttonName] ~= nil) then -- 593
            return -- 596
        end -- 596
        self.buttonStates[buttonName] = true -- 598
        local allDown = true -- 599
        for ____, down in pairs(self.buttonStates) do -- 600
            if allDown then -- 600
                allDown = down -- 601
            end -- 601
        end -- 601
        if allDown then -- 601
            self.state = "Completed" -- 604
        end -- 604
    end -- 591
    self.onButtonUp = function(controllerId, buttonName) -- 607
        if self.controllerId ~= controllerId then -- 607
            return -- 609
        end -- 609
        if not (self.buttonStates[buttonName] ~= nil) then -- 609
            return -- 612
        end -- 612
        self.buttonStates[buttonName] = false -- 614
        self.state = "None" -- 615
    end -- 607
end -- 586
function ButtonPressedTrigger.prototype.onUpdate(self, _) -- 618
    local allDown = true -- 619
    for ____, down in pairs(self.buttonStates) do -- 620
        if allDown then -- 620
            allDown = down -- 621
        end -- 621
    end -- 621
    if allDown then -- 621
        self.state = "Completed" -- 624
        if self.onChange then -- 624
            self:onChange() -- 626
        end -- 626
        self.state = "None" -- 628
    end -- 628
end -- 618
function ButtonPressedTrigger.prototype.start(self, manager) -- 631
    manager.controllerEnabled = true -- 632
    for ____, k in ipairs(self.buttons) do -- 633
        self.buttonStates[k] = false -- 634
    end -- 634
    manager:slot("ButtonDown", self.onButtonDown) -- 636
    manager:slot("ButtonUp", self.onButtonUp) -- 637
    self.state = "None" -- 638
end -- 631
function ButtonPressedTrigger.prototype.stop(self, manager) -- 640
    manager:slot("ButtonDown"):remove(self.onButtonDown) -- 641
    manager:slot("ButtonUp"):remove(self.onButtonUp) -- 642
    self.state = "None" -- 643
end -- 640
local ButtonHoldTrigger = __TS__Class() -- 647
ButtonHoldTrigger.name = "ButtonHoldTrigger" -- 647
__TS__ClassExtends(ButtonHoldTrigger, ____exports.Trigger) -- 647
function ButtonHoldTrigger.prototype.____constructor(self, button, holdTime, controllerId) -- 655
    ButtonHoldTrigger.____super.prototype.____constructor(self) -- 656
    self.controllerId = controllerId -- 657
    self.button = button -- 658
    self.holdTime = holdTime -- 659
    self.time = 0 -- 660
    self.onButtonDown = function(controllerId, buttonName) -- 661
        if self.controllerId ~= controllerId then -- 661
            return -- 663
        end -- 663
        if self.button == buttonName then -- 663
            self.time = 0 -- 666
            self.state = "Started" -- 667
            self.progress = 0 -- 668
            if self.onChange then -- 668
                self:onChange() -- 670
            end -- 670
        end -- 670
    end -- 661
    self.onButtonUp = function(controllerId, buttonName) -- 674
        if self.controllerId ~= controllerId then -- 674
            return -- 676
        end -- 676
        repeat -- 676
            local ____switch156 = self.state -- 676
            local ____cond156 = ____switch156 == "Started" or ____switch156 == "Ongoing" or ____switch156 == "Completed" -- 676
            if ____cond156 then -- 676
                break -- 682
            end -- 682
            do -- 682
                return -- 684
            end -- 684
        until true -- 684
        if self.button == buttonName then -- 684
            if self.state == "Completed" then -- 684
                self.state = "None" -- 688
            else -- 688
                self.state = "Canceled" -- 690
            end -- 690
            self.progress = 0 -- 692
            if self.onChange then -- 692
                self:onChange() -- 694
            end -- 694
        end -- 694
    end -- 674
end -- 655
function ButtonHoldTrigger.prototype.start(self, manager) -- 699
    manager.controllerEnabled = true -- 700
    manager:slot("ButtonDown", self.onButtonDown) -- 701
    manager:slot("ButtonUp", self.onButtonUp) -- 702
    self.state = "None" -- 703
    self.progress = 0 -- 704
end -- 699
function ButtonHoldTrigger.prototype.onUpdate(self, deltaTime) -- 706
    repeat -- 706
        local ____switch163 = self.state -- 706
        local ____cond163 = ____switch163 == "Started" or ____switch163 == "Ongoing" -- 706
        if ____cond163 then -- 706
            break -- 710
        end -- 710
        do -- 710
            return -- 712
        end -- 712
    until true -- 712
    self.time = self.time + deltaTime -- 714
    if self.time >= self.holdTime then -- 714
        self.state = "Completed" -- 716
        self.progress = 1 -- 717
    else -- 717
        self.state = "Ongoing" -- 719
        self.progress = math.min(self.time / self.holdTime, 1) -- 720
    end -- 720
    if self.onChange then -- 720
        self:onChange() -- 723
    end -- 723
end -- 706
function ButtonHoldTrigger.prototype.stop(self, manager) -- 726
    manager:slot("ButtonDown"):remove(self.onButtonDown) -- 727
    manager:slot("ButtonUp"):remove(self.onButtonUp) -- 728
    self.state = "None" -- 729
    self.progress = 0 -- 730
end -- 726
local ButtonTimedTrigger = __TS__Class() -- 734
ButtonTimedTrigger.name = "ButtonTimedTrigger" -- 734
__TS__ClassExtends(ButtonTimedTrigger, ____exports.Trigger) -- 734
function ButtonTimedTrigger.prototype.____constructor(self, button, timeWindow, controllerId) -- 741
    ButtonTimedTrigger.____super.prototype.____constructor(self) -- 742
    self.controllerId = controllerId -- 743
    self.button = button -- 744
    self.timeWindow = timeWindow -- 745
    self.time = 0 -- 746
    self.onButtonDown = function(controllerId, buttonName) -- 747
        if self.controllerId ~= controllerId then -- 747
            return -- 749
        end -- 749
        repeat -- 749
            local ____switch171 = self.state -- 749
            local ____cond171 = ____switch171 == "Started" or ____switch171 == "Ongoing" or ____switch171 == "Completed" -- 749
            if ____cond171 then -- 749
                break -- 755
            end -- 755
            do -- 755
                return -- 757
            end -- 757
        until true -- 757
        if self.button == buttonName and self.time <= self.timeWindow then -- 757
            self.state = "Completed" -- 760
            self.value = self.time -- 761
            if self.onChange then -- 761
                self:onChange() -- 763
            end -- 763
        end -- 763
    end -- 747
end -- 741
function ButtonTimedTrigger.prototype.start(self, manager) -- 768
    manager.controllerEnabled = true -- 769
    manager:slot("ButtonDown", self.onButtonDown) -- 770
    self.state = "Started" -- 771
    self.progress = 0 -- 772
    self.time = 0 -- 773
    self.value = false -- 774
    if self.onChange then -- 774
        self:onChange() -- 776
    end -- 776
end -- 768
function ButtonTimedTrigger.prototype.onUpdate(self, deltaTime) -- 779
    repeat -- 779
        local ____switch177 = self.state -- 779
        local ____cond177 = ____switch177 == "Started" or ____switch177 == "Ongoing" or ____switch177 == "Completed" -- 779
        if ____cond177 then -- 779
            break -- 784
        end -- 784
        do -- 784
            return -- 786
        end -- 786
    until true -- 786
    self.time = self.time + deltaTime -- 788
    if self.time >= self.timeWindow then -- 788
        if self.state == "Completed" then -- 788
            self.state = "None" -- 791
            self.progress = 0 -- 792
        else -- 792
            self.state = "Canceled" -- 794
            self.progress = 1 -- 795
        end -- 795
    else -- 795
        self.state = "Ongoing" -- 798
        self.progress = math.min(self.time / self.timeWindow, 1) -- 799
    end -- 799
    if self.onChange then -- 799
        self:onChange() -- 802
    end -- 802
end -- 779
function ButtonTimedTrigger.prototype.stop(self, manager) -- 805
    manager:slot("ButtonDown"):remove(self.onButtonDown) -- 806
    self.state = "None" -- 807
    self.progress = 0 -- 808
end -- 805
local ButtonDoubleDownTrigger = __TS__Class() -- 812
ButtonDoubleDownTrigger.name = "ButtonDoubleDownTrigger" -- 812
__TS__ClassExtends(ButtonDoubleDownTrigger, ____exports.Trigger) -- 812
function ButtonDoubleDownTrigger.prototype.____constructor(self, button, threshold, controllerId) -- 819
    ButtonDoubleDownTrigger.____super.prototype.____constructor(self) -- 820
    self.controllerId = controllerId -- 821
    self.button = button -- 822
    self.threshold = threshold -- 823
    self.time = 0 -- 824
    self.onButtonDown = function(controllerId, buttonName) -- 825
        if self.controllerId ~= controllerId then -- 825
            return -- 827
        end -- 827
        if self.button == buttonName then -- 827
            if self.state == "None" then -- 827
                self.time = 0 -- 831
                self.state = "Started" -- 832
                self.progress = 0 -- 833
                if self.onChange then -- 833
                    self:onChange() -- 835
                end -- 835
            else -- 835
                self.state = "Completed" -- 838
                if self.onChange then -- 838
                    self:onChange() -- 840
                end -- 840
                self.state = "None" -- 842
            end -- 842
        end -- 842
    end -- 825
end -- 819
function ButtonDoubleDownTrigger.prototype.start(self, manager) -- 847
    manager.controllerEnabled = true -- 848
    manager:slot("ButtonDown", self.onButtonDown) -- 849
    self.state = "None" -- 850
    self.progress = 0 -- 851
end -- 847
function ButtonDoubleDownTrigger.prototype.onUpdate(self, deltaTime) -- 853
    repeat -- 853
        local ____switch194 = self.state -- 853
        local ____cond194 = ____switch194 == "Started" or ____switch194 == "Ongoing" -- 853
        if ____cond194 then -- 853
            break -- 857
        end -- 857
        do -- 857
            return -- 859
        end -- 859
    until true -- 859
    self.time = self.time + deltaTime -- 861
    if self.time >= self.threshold then -- 861
        self.state = "None" -- 863
        self.progress = 1 -- 864
    else -- 864
        self.state = "Ongoing" -- 866
        self.progress = math.min(self.time / self.threshold, 1) -- 867
    end -- 867
    if self.onChange then -- 867
        self:onChange() -- 870
    end -- 870
end -- 853
function ButtonDoubleDownTrigger.prototype.stop(self, manager) -- 873
    manager:slot("ButtonDown"):remove(self.onButtonDown) -- 874
    self.state = "None" -- 875
    self.progress = 0 -- 876
end -- 873
local AnyButtonPressedTrigger = __TS__Class() -- 880
AnyButtonPressedTrigger.name = "AnyButtonPressedTrigger" -- 880
__TS__ClassExtends(AnyButtonPressedTrigger, ____exports.Trigger) -- 880
function AnyButtonPressedTrigger.prototype.____constructor(self, controllerId) -- 886
    AnyButtonPressedTrigger.____super.prototype.____constructor(self) -- 887
    self.controllerId = controllerId -- 888
    self.buttonStates = {} -- 889
    self.onButtonDown = function(controllerId, buttonName) -- 890
        if self.controllerId ~= controllerId then -- 890
            return -- 892
        end -- 892
        self.buttonStates[buttonName] = true -- 894
        self.state = "Completed" -- 895
    end -- 890
    self.onButtonUp = function(controllerId, buttonName) -- 897
        if self.controllerId ~= controllerId then -- 897
            return -- 899
        end -- 899
        self.buttonStates[buttonName] = false -- 901
        local down = false -- 902
        for ____, state in pairs(self.buttonStates) do -- 903
            if not down then -- 903
                down = state -- 904
            end -- 904
        end -- 904
        if not down then -- 904
            self.state = "None" -- 907
        end -- 907
    end -- 897
end -- 886
function AnyButtonPressedTrigger.prototype.onUpdate(self, _) -- 911
    if self.state == "Completed" then -- 911
        if self.onChange then -- 911
            self:onChange() -- 914
        end -- 914
    end -- 914
end -- 911
function AnyButtonPressedTrigger.prototype.start(self, manager) -- 918
    manager.keyboardEnabled = true -- 919
    manager:slot("ButtonDown", self.onButtonDown) -- 920
    manager:slot("ButtonUp", self.onButtonUp) -- 921
    self.state = "None" -- 922
end -- 918
function AnyButtonPressedTrigger.prototype.stop(self, manager) -- 924
    manager:slot("ButtonDown"):remove(self.onButtonDown) -- 925
    manager:slot("ButtonUp", self.onButtonUp) -- 926
    self.state = "None" -- 927
    self.buttonStates = {} -- 928
end -- 924
local JoyStickTrigger = __TS__Class() -- 937
JoyStickTrigger.name = "JoyStickTrigger" -- 937
__TS__ClassExtends(JoyStickTrigger, ____exports.Trigger) -- 937
function JoyStickTrigger.prototype.____constructor(self, joyStickType, controllerId) -- 943
    JoyStickTrigger.____super.prototype.____constructor(self) -- 944
    self.joyStickType = joyStickType -- 945
    self.controllerId = controllerId -- 946
    self.axis = Vec2.zero -- 947
    self.onAxis = function(controllerId, axisName, value) -- 948
        if self.controllerId ~= controllerId then -- 948
            return -- 950
        end -- 950
        repeat -- 950
            local ____switch214 = self.joyStickType -- 950
            local ____cond214 = ____switch214 == "Left" -- 950
            if ____cond214 then -- 950
                do -- 950
                    repeat -- 950
                        local ____switch216 = axisName -- 950
                        local ____cond216 = ____switch216 == "leftx" -- 950
                        if ____cond216 then -- 950
                            self.axis = Vec2(value, self.axis.y) -- 956
                            break -- 957
                        end -- 957
                        ____cond216 = ____cond216 or ____switch216 == "lefty" -- 957
                        if ____cond216 then -- 957
                            self.axis = Vec2(self.axis.x, value) -- 959
                            break -- 960
                        end -- 960
                    until true -- 960
                    break -- 962
                end -- 962
            end -- 962
            ____cond214 = ____cond214 or ____switch214 == "Right" -- 962
            if ____cond214 then -- 962
                do -- 962
                    repeat -- 962
                        local ____switch218 = axisName -- 962
                        local ____cond218 = ____switch218 == "rightx" -- 962
                        if ____cond218 then -- 962
                            self.axis = Vec2(value, self.axis.y) -- 967
                            break -- 968
                        end -- 968
                        ____cond218 = ____cond218 or ____switch218 == "righty" -- 968
                        if ____cond218 then -- 968
                            self.axis = Vec2(self.axis.x, value) -- 970
                            break -- 971
                        end -- 971
                    until true -- 971
                    break -- 973
                end -- 973
            end -- 973
        until true -- 973
        self.value = self.axis -- 976
        if self:filterAxis() then -- 976
            self.state = "Completed" -- 978
        else -- 978
            self.state = "None" -- 980
        end -- 980
        if self.onChange then -- 980
            self:onChange() -- 983
        end -- 983
    end -- 948
end -- 943
function JoyStickTrigger.prototype.filterAxis(self) -- 987
    return true -- 988
end -- 987
function JoyStickTrigger.prototype.start(self, manager) -- 990
    self.state = "None" -- 991
    self.value = Vec2.zero -- 992
    manager:slot("Axis", self.onAxis) -- 993
end -- 990
function JoyStickTrigger.prototype.stop(self, manager) -- 995
    self.state = "None" -- 996
    self.value = Vec2.zero -- 997
    manager:slot("Axis"):remove(self.onAxis) -- 998
end -- 995
local JoyStickThresholdTrigger = __TS__Class() -- 1002
JoyStickThresholdTrigger.name = "JoyStickThresholdTrigger" -- 1002
__TS__ClassExtends(JoyStickThresholdTrigger, JoyStickTrigger) -- 1002
function JoyStickThresholdTrigger.prototype.____constructor(self, joyStickType, threshold, controllerId) -- 1005
    JoyStickTrigger.prototype.____constructor(self, joyStickType, controllerId) -- 1006
    self.threshold = threshold -- 1007
end -- 1005
function JoyStickThresholdTrigger.prototype.filterAxis(self) -- 1009
    return self.axis.length > self.threshold -- 1010
end -- 1009
local JoyStickDirectionalTrigger = __TS__Class() -- 1014
JoyStickDirectionalTrigger.name = "JoyStickDirectionalTrigger" -- 1014
__TS__ClassExtends(JoyStickDirectionalTrigger, JoyStickTrigger) -- 1014
function JoyStickDirectionalTrigger.prototype.____constructor(self, joyStickType, angle, tolerance, controllerId) -- 1018
    JoyStickTrigger.prototype.____constructor(self, joyStickType, controllerId) -- 1019
    self.direction = angle -- 1020
    self.tolerance = tolerance -- 1021
end -- 1018
function JoyStickDirectionalTrigger.prototype.filterAxis(self) -- 1023
    local currentAngle = -math.deg(math.atan(self.axis.y, self.axis.x)) -- 1024
    return math.abs(currentAngle - self.direction) <= self.tolerance -- 1025
end -- 1023
local JoyStickRangeTrigger = __TS__Class() -- 1029
JoyStickRangeTrigger.name = "JoyStickRangeTrigger" -- 1029
__TS__ClassExtends(JoyStickRangeTrigger, JoyStickTrigger) -- 1029
function JoyStickRangeTrigger.prototype.____constructor(self, joyStickType, minRange, maxRange, controllerId) -- 1033
    JoyStickTrigger.prototype.____constructor(self, joyStickType, controllerId) -- 1034
    self.minRange = math.min(minRange, maxRange) -- 1035
    self.maxRange = math.max(minRange, maxRange) -- 1036
end -- 1033
function JoyStickRangeTrigger.prototype.filterAxis(self) -- 1038
    local magnitude = self.axis.length -- 1039
    return magnitude >= self.minRange and magnitude <= self.maxRange -- 1040
end -- 1038
local SequenceTrigger = __TS__Class() -- 1044
SequenceTrigger.name = "SequenceTrigger" -- 1044
__TS__ClassExtends(SequenceTrigger, ____exports.Trigger) -- 1044
function SequenceTrigger.prototype.____constructor(self, triggers) -- 1047
    SequenceTrigger.____super.prototype.____constructor(self) -- 1048
    self.triggers = triggers -- 1049
    local ____self = self -- 1050
    local function onStateChanged() -- 1051
        ____self:onStateChanged() -- 1052
    end -- 1051
    for ____, trigger in ipairs(triggers) do -- 1054
        trigger.onChange = onStateChanged -- 1055
    end -- 1055
end -- 1047
function SequenceTrigger.prototype.onStateChanged(self) -- 1058
    local completed = true -- 1059
    for ____, trigger in ipairs(self.triggers) do -- 1060
        if trigger.state ~= "Completed" then -- 1060
            completed = false -- 1062
            break -- 1063
        end -- 1063
    end -- 1063
    if completed then -- 1063
        self.state = "Completed" -- 1067
        local newValue = {} -- 1068
        for ____, trigger in ipairs(self.triggers) do -- 1069
            if type(trigger.value) == "table" then -- 1069
                if type(trigger.value) == "userdata" then -- 1069
                    newValue[#newValue + 1] = trigger.value -- 1072
                else -- 1072
                    newValue = __TS__ArrayConcat(newValue, trigger.value) -- 1074
                end -- 1074
            else -- 1074
                newValue[#newValue + 1] = trigger.value -- 1077
            end -- 1077
        end -- 1077
        self.value = newValue -- 1080
        if self.onChange then -- 1080
            self:onChange() -- 1082
        end -- 1082
        return -- 1084
    end -- 1084
    local canceled = false -- 1086
    for ____, trigger in ipairs(self.triggers) do -- 1087
        self.progress = math.max(trigger.progress, self.progress) -- 1088
        if trigger.state == "Canceled" then -- 1088
            canceled = true -- 1090
            break -- 1091
        end -- 1091
    end -- 1091
    if canceled then -- 1091
        self.state = "Canceled" -- 1095
        if self.onChange then -- 1095
            self:onChange() -- 1097
        end -- 1097
        return -- 1099
    end -- 1099
    local onGoing = false -- 1101
    local minProgress = -1 -- 1102
    for ____, trigger in ipairs(self.triggers) do -- 1103
        if trigger.state == "Ongoing" then -- 1103
            minProgress = minProgress < 0 and trigger.progress or math.min(minProgress, trigger.progress) -- 1105
            onGoing = true -- 1106
        end -- 1106
    end -- 1106
    if onGoing then -- 1106
        self.state = "Ongoing" -- 1110
        self.progress = minProgress -- 1111
        if self.onChange then -- 1111
            self:onChange() -- 1113
        end -- 1113
        return -- 1115
    end -- 1115
    for ____, trigger in ipairs(self.triggers) do -- 1117
        if trigger.state == "Started" then -- 1117
            self.state = "Started" -- 1119
            self.progress = 0 -- 1120
            if self.onChange then -- 1120
                self:onChange() -- 1122
            end -- 1122
            return -- 1124
        end -- 1124
    end -- 1124
    self.state = "None" -- 1127
    if self.onChange then -- 1127
        self:onChange() -- 1129
    end -- 1129
end -- 1058
function SequenceTrigger.prototype.start(self, manager) -- 1132
    for ____, trigger in ipairs(self.triggers) do -- 1133
        trigger:start(manager) -- 1134
    end -- 1134
    self.state = "None" -- 1136
    self.progress = 0 -- 1137
    self.value = false -- 1138
end -- 1132
function SequenceTrigger.prototype.onUpdate(self, deltaTime) -- 1140
    for ____, trigger in ipairs(self.triggers) do -- 1141
        if trigger.onUpdate then -- 1141
            trigger:onUpdate(deltaTime) -- 1143
        end -- 1143
    end -- 1143
end -- 1140
function SequenceTrigger.prototype.stop(self, manager) -- 1147
    for ____, trigger in ipairs(self.triggers) do -- 1148
        trigger:stop(manager) -- 1149
    end -- 1149
    self.state = "None" -- 1151
    self.progress = 0 -- 1152
    self.value = false -- 1153
end -- 1147
local SelectorTrigger = __TS__Class() -- 1157
SelectorTrigger.name = "SelectorTrigger" -- 1157
__TS__ClassExtends(SelectorTrigger, ____exports.Trigger) -- 1157
function SelectorTrigger.prototype.____constructor(self, triggers) -- 1160
    SelectorTrigger.____super.prototype.____constructor(self) -- 1161
    self.triggers = triggers -- 1162
    local ____self = self -- 1163
    local function onStateChanged() -- 1164
        ____self:onStateChanged() -- 1165
    end -- 1164
    for ____, trigger in ipairs(triggers) do -- 1167
        trigger.onChange = onStateChanged -- 1168
    end -- 1168
end -- 1160
function SelectorTrigger.prototype.onStateChanged(self) -- 1171
    for ____, trigger in ipairs(self.triggers) do -- 1172
        if trigger.state == "Completed" then -- 1172
            self.state = "Completed" -- 1174
            self.progress = trigger.progress -- 1175
            self.value = trigger.value -- 1176
            if self.onChange then -- 1176
                self:onChange() -- 1178
            end -- 1178
            return -- 1180
        end -- 1180
    end -- 1180
    local onGoing = false -- 1183
    local maxProgress = 0 -- 1184
    for ____, trigger in ipairs(self.triggers) do -- 1185
        if trigger.state == "Ongoing" then -- 1185
            maxProgress = math.max(maxProgress, trigger.progress) -- 1187
            onGoing = true -- 1188
        end -- 1188
    end -- 1188
    if onGoing then -- 1188
        self.state = "Ongoing" -- 1192
        self.progress = maxProgress -- 1193
        if self.onChange then -- 1193
            self:onChange() -- 1195
        end -- 1195
        return -- 1197
    end -- 1197
    for ____, trigger in ipairs(self.triggers) do -- 1199
        if trigger.state == "Started" then -- 1199
            self.state = "Started" -- 1201
            self.progress = 0 -- 1202
            if self.onChange then -- 1202
                self:onChange() -- 1204
            end -- 1204
            return -- 1206
        end -- 1206
    end -- 1206
    local canceled = false -- 1209
    for ____, trigger in ipairs(self.triggers) do -- 1210
        self.progress = math.max(trigger.progress, self.progress) -- 1211
        if trigger.state == "Canceled" then -- 1211
            canceled = true -- 1213
            break -- 1214
        end -- 1214
    end -- 1214
    if canceled then -- 1214
        self.state = "Canceled" -- 1218
        if self.onChange then -- 1218
            self:onChange() -- 1220
        end -- 1220
    end -- 1220
end -- 1171
function SelectorTrigger.prototype.start(self, manager) -- 1224
    for ____, trigger in ipairs(self.triggers) do -- 1225
        trigger:start(manager) -- 1226
    end -- 1226
    self.state = "None" -- 1228
    self.progress = 0 -- 1229
    self.value = false -- 1230
end -- 1224
function SelectorTrigger.prototype.onUpdate(self, deltaTime) -- 1232
    for ____, trigger in ipairs(self.triggers) do -- 1233
        if trigger.onUpdate then -- 1233
            trigger:onUpdate(deltaTime) -- 1235
        end -- 1235
    end -- 1235
end -- 1232
function SelectorTrigger.prototype.stop(self, manager) -- 1239
    for ____, trigger in ipairs(self.triggers) do -- 1240
        trigger:stop(manager) -- 1241
    end -- 1241
    self.state = "None" -- 1243
    self.progress = 0 -- 1244
    self.value = false -- 1245
end -- 1239
local BlockTrigger = __TS__Class() -- 1249
BlockTrigger.name = "BlockTrigger" -- 1249
__TS__ClassExtends(BlockTrigger, ____exports.Trigger) -- 1249
function BlockTrigger.prototype.____constructor(self, trigger) -- 1252
    BlockTrigger.____super.prototype.____constructor(self) -- 1253
    self.trigger = trigger -- 1254
    local ____self = self -- 1255
    trigger.onChange = function() -- 1256
        ____self:onStateChanged() -- 1257
    end -- 1256
end -- 1252
function BlockTrigger.prototype.onStateChanged(self) -- 1260
    if self.trigger.state == "Completed" then -- 1260
        self.state = "Canceled" -- 1262
    else -- 1262
        self.state = "Completed" -- 1264
    end -- 1264
    if self.onChange then -- 1264
        self:onChange() -- 1267
    end -- 1267
    self.state = "Completed" -- 1269
end -- 1260
function BlockTrigger.prototype.start(self, manager) -- 1271
    self.state = "Completed" -- 1272
    self.trigger:start(manager) -- 1273
end -- 1271
function BlockTrigger.prototype.onUpdate(self, deltaTime) -- 1275
    if self.trigger.onUpdate then -- 1275
        self.trigger:onUpdate(deltaTime) -- 1277
    end -- 1277
end -- 1275
function BlockTrigger.prototype.stop(self, manager) -- 1280
    self.state = "Completed" -- 1281
    self.trigger:stop(manager) -- 1282
end -- 1280
do -- 1280
    function Trigger.KeyDown(combineKeys) -- 1287
        if type(combineKeys) == "string" then -- 1287
            combineKeys = {combineKeys} -- 1289
        end -- 1289
        return __TS__New(KeyDownTrigger, combineKeys) -- 1291
    end -- 1287
    function Trigger.KeyUp(combineKeys) -- 1293
        if type(combineKeys) == "string" then -- 1293
            combineKeys = {combineKeys} -- 1295
        end -- 1295
        return __TS__New(KeyUpTrigger, combineKeys) -- 1297
    end -- 1293
    function Trigger.KeyPressed(combineKeys) -- 1299
        if type(combineKeys) == "string" then -- 1299
            combineKeys = {combineKeys} -- 1301
        end -- 1301
        return __TS__New(KeyPressedTrigger, combineKeys) -- 1303
    end -- 1299
    function Trigger.KeyHold(keyName, holdTime) -- 1305
        return __TS__New(KeyHoldTrigger, keyName, holdTime) -- 1306
    end -- 1305
    function Trigger.KeyTimed(keyName, timeWindow) -- 1308
        return __TS__New(KeyTimedTrigger, keyName, timeWindow) -- 1309
    end -- 1308
    function Trigger.KeyDoubleDown(self, key, threshold) -- 1311
        return __TS__New(KeyDoubleDownTrigger, key, threshold or 0.3) -- 1312
    end -- 1311
    function Trigger.AnyKeyPressed(self) -- 1314
        return __TS__New(AnyKeyPressedTrigger) -- 1315
    end -- 1314
    function Trigger.ButtonDown(combineButtons, controllerId) -- 1317
        if type(combineButtons) == "string" then -- 1317
            combineButtons = {combineButtons} -- 1319
        end -- 1319
        return __TS__New(ButtonDownTrigger, combineButtons, controllerId or 0) -- 1321
    end -- 1317
    function Trigger.ButtonUp(combineButtons, controllerId) -- 1323
        if type(combineButtons) == "string" then -- 1323
            combineButtons = {combineButtons} -- 1325
        end -- 1325
        return __TS__New(ButtonUpTrigger, combineButtons, controllerId or 0) -- 1327
    end -- 1323
    function Trigger.ButtonPressed(combineButtons, controllerId) -- 1329
        if type(combineButtons) == "string" then -- 1329
            combineButtons = {combineButtons} -- 1331
        end -- 1331
        return __TS__New(ButtonPressedTrigger, combineButtons, controllerId or 0) -- 1333
    end -- 1329
    function Trigger.ButtonHold(buttonName, holdTime, controllerId) -- 1335
        return __TS__New(ButtonHoldTrigger, buttonName, holdTime, controllerId or 0) -- 1336
    end -- 1335
    function Trigger.ButtonTimed(buttonName, timeWindow, controllerId) -- 1338
        return __TS__New(ButtonTimedTrigger, buttonName, timeWindow, controllerId or 0) -- 1339
    end -- 1338
    function Trigger.ButtonDoubleDown(self, button, threshold, controllerId) -- 1341
        return __TS__New(ButtonDoubleDownTrigger, button, threshold or 0.3, controllerId or 0) -- 1342
    end -- 1341
    function Trigger.AnyButtonPressed(self, controllerId) -- 1344
        return __TS__New(AnyButtonPressedTrigger, controllerId or 0) -- 1345
    end -- 1344
    function Trigger.JoyStick(joyStickType, controllerId) -- 1347
        return __TS__New(JoyStickTrigger, joyStickType, controllerId or 0) -- 1348
    end -- 1347
    function Trigger.JoyStickThreshold(joyStickType, threshold, controllerId) -- 1350
        return __TS__New(JoyStickThresholdTrigger, joyStickType, threshold, controllerId or 0) -- 1351
    end -- 1350
    function Trigger.JoyStickDirectional(joyStickType, angle, tolerance, controllerId) -- 1353
        return __TS__New( -- 1354
            JoyStickDirectionalTrigger, -- 1354
            joyStickType, -- 1354
            angle, -- 1354
            tolerance, -- 1354
            controllerId or 0 -- 1354
        ) -- 1354
    end -- 1353
    function Trigger.JoyStickRange(joyStickType, minRange, maxRange, controllerId) -- 1356
        return __TS__New( -- 1357
            JoyStickRangeTrigger, -- 1357
            joyStickType, -- 1357
            minRange, -- 1357
            maxRange, -- 1357
            controllerId or 0 -- 1357
        ) -- 1357
    end -- 1356
    function Trigger.Sequence(triggers) -- 1359
        return __TS__New(SequenceTrigger, triggers) -- 1360
    end -- 1359
    function Trigger.Selector(triggers) -- 1362
        return __TS__New(SelectorTrigger, triggers) -- 1363
    end -- 1362
    function Trigger.Block(trigger) -- 1365
        return __TS__New(BlockTrigger, trigger) -- 1366
    end -- 1365
end -- 1365
local InputManager = __TS__Class() -- 1380
InputManager.name = "InputManager" -- 1380
function InputManager.prototype.____constructor(self, contexts) -- 1385
    self.manager = Node() -- 1386
    self.contextMap = __TS__New( -- 1387
        Map, -- 1387
        __TS__ArrayMap( -- 1387
            contexts, -- 1387
            function(____, ctx) -- 1387
                for ____, action in ipairs(ctx.actions) do -- 1388
                    local eventName = "Input." .. action.name -- 1389
                    action.trigger.onChange = function() -- 1390
                        local ____action_trigger_0 = action.trigger -- 1391
                        local state = ____action_trigger_0.state -- 1391
                        local progress = ____action_trigger_0.progress -- 1391
                        local value = ____action_trigger_0.value -- 1391
                        emit(eventName, state, progress, value) -- 1392
                    end -- 1390
                end -- 1390
                return {ctx.name, ctx.actions} -- 1395
            end -- 1387
        ) -- 1387
    ) -- 1387
    self.contextStack = {} -- 1397
    self.manager:schedule(function(deltaTime) -- 1398
        if #self.contextStack > 0 then -- 1398
            local lastNames = self.contextStack[#self.contextStack] -- 1400
            for ____, name in ipairs(lastNames) do -- 1401
                do -- 1401
                    local actions = self.contextMap:get(name) -- 1402
                    if actions == nil then -- 1402
                        goto __continue350 -- 1404
                    end -- 1404
                    for ____, action in ipairs(actions) do -- 1406
                        if action.trigger.onUpdate then -- 1406
                            action.trigger:onUpdate(deltaTime) -- 1408
                        end -- 1408
                    end -- 1408
                end -- 1408
                ::__continue350:: -- 1408
            end -- 1408
        end -- 1408
        return false -- 1413
    end) -- 1398
end -- 1385
function InputManager.prototype.getNode(self) -- 1417
    return self.manager -- 1418
end -- 1417
function InputManager.prototype.pushContext(self, contextNames) -- 1421
    if type(contextNames) == "string" then -- 1421
        contextNames = {contextNames} -- 1423
    end -- 1423
    local exist = true -- 1425
    for ____, name in ipairs(contextNames) do -- 1426
        if exist then -- 1426
            exist = self.contextMap:has(name) -- 1427
        end -- 1427
    end -- 1427
    if not exist then -- 1427
        print("[Dora Error] got non-existed context name from " .. table.concat(contextNames, ", ")) -- 1430
        return false -- 1431
    else -- 1431
        if #self.contextStack > 0 then -- 1431
            local lastNames = self.contextStack[#self.contextStack] -- 1434
            for ____, name in ipairs(lastNames) do -- 1435
                do -- 1435
                    local actions = self.contextMap:get(name) -- 1436
                    if actions == nil then -- 1436
                        goto __continue364 -- 1438
                    end -- 1438
                    for ____, action in ipairs(actions) do -- 1440
                        action.trigger:stop(self.manager) -- 1441
                    end -- 1441
                end -- 1441
                ::__continue364:: -- 1441
            end -- 1441
        end -- 1441
        local ____self_contextStack_1 = self.contextStack -- 1441
        ____self_contextStack_1[#____self_contextStack_1 + 1] = contextNames -- 1445
        for ____, name in ipairs(contextNames) do -- 1446
            do -- 1446
                local actions = self.contextMap:get(name) -- 1447
                if actions == nil then -- 1447
                    goto __continue369 -- 1449
                end -- 1449
                for ____, action in ipairs(actions) do -- 1451
                    action.trigger:start(self.manager) -- 1452
                end -- 1452
            end -- 1452
            ::__continue369:: -- 1452
        end -- 1452
        return true -- 1455
    end -- 1455
end -- 1421
function InputManager.prototype.popContext(self, count) -- 1459
    if count == nil then -- 1459
        count = 1 -- 1460
    end -- 1460
    if #self.contextStack < count then -- 1460
        return false -- 1462
    end -- 1462
    for i = 1, count do -- 1462
        local lastNames = self.contextStack[#self.contextStack] -- 1465
        for ____, name in ipairs(lastNames) do -- 1466
            do -- 1466
                local actions = self.contextMap:get(name) -- 1467
                if actions == nil then -- 1467
                    goto __continue377 -- 1469
                end -- 1469
                for ____, action in ipairs(actions) do -- 1471
                    action.trigger:stop(self.manager) -- 1472
                end -- 1472
            end -- 1472
            ::__continue377:: -- 1472
        end -- 1472
        table.remove(self.contextStack) -- 1475
        if #self.contextStack > 0 then -- 1475
            local lastNames = self.contextStack[#self.contextStack] -- 1477
            for ____, name in ipairs(lastNames) do -- 1478
                do -- 1478
                    local actions = self.contextMap:get(name) -- 1479
                    if actions == nil then -- 1479
                        goto __continue383 -- 1481
                    end -- 1481
                    for ____, action in ipairs(actions) do -- 1483
                        action.trigger:start(self.manager) -- 1484
                    end -- 1484
                end -- 1484
                ::__continue383:: -- 1484
            end -- 1484
        end -- 1484
    end -- 1484
    return true -- 1489
end -- 1459
function InputManager.prototype.emitKeyDown(self, keyName) -- 1492
    self.manager:emit("KeyDown", keyName) -- 1493
end -- 1492
function InputManager.prototype.emitKeyUp(self, keyName) -- 1496
    self.manager:emit("KeyUp", keyName) -- 1497
end -- 1496
function InputManager.prototype.emitButtonDown(self, buttonName, controllerId) -- 1500
    self.manager:emit("ButtonDown", controllerId or 0, buttonName) -- 1501
end -- 1500
function InputManager.prototype.emitButtonUp(self, buttonName, controllerId) -- 1504
    self.manager:emit("ButtonUp", controllerId or 0, buttonName) -- 1505
end -- 1504
function InputManager.prototype.emitAxis(self, axisName, value, controllerId) -- 1508
    self.manager:emit("Axis", controllerId or 0, axisName, value) -- 1509
end -- 1508
function InputManager.prototype.destroy(self) -- 1512
    self:getNode():removeFromParent() -- 1513
    self.contextStack = {} -- 1514
end -- 1512
function ____exports.CreateManager(contexts) -- 1518
    return __TS__New(InputManager, contexts) -- 1519
end -- 1518
function ____exports.DPad(self, props) -- 1531
    local ____props_2 = props -- 1538
    local width = ____props_2.width -- 1538
    if width == nil then -- 1538
        width = 40 -- 1533
    end -- 1533
    local height = ____props_2.height -- 1533
    if height == nil then -- 1533
        height = 40 -- 1534
    end -- 1534
    local offset = ____props_2.offset -- 1534
    if offset == nil then -- 1534
        offset = 5 -- 1535
    end -- 1535
    local color = ____props_2.color -- 1535
    if color == nil then -- 1535
        color = 4294967295 -- 1536
    end -- 1536
    local primaryOpacity = ____props_2.primaryOpacity -- 1536
    if primaryOpacity == nil then -- 1536
        primaryOpacity = 0.3 -- 1537
    end -- 1537
    local halfSize = height + width / 2 + offset -- 1539
    local dOffset = height / 2 + width / 2 + offset -- 1540
    local function DPadButton(self, props) -- 1542
        local hw = width / 2 -- 1543
        local drawNode = useRef() -- 1544
        return React:createElement( -- 1545
            "node", -- 1545
            __TS__ObjectAssign( -- 1545
                {}, -- 1545
                props, -- 1546
                { -- 1546
                    width = width, -- 1546
                    height = height, -- 1546
                    onTapBegan = function() -- 1546
                        if drawNode.current then -- 1546
                            drawNode.current.opacity = 1 -- 1549
                        end -- 1549
                    end, -- 1547
                    onTapEnded = function() -- 1547
                        if drawNode.current then -- 1547
                            drawNode.current.opacity = primaryOpacity -- 1554
                        end -- 1554
                    end -- 1552
                } -- 1552
            ), -- 1552
            React:createElement( -- 1552
                "draw-node", -- 1552
                {ref = drawNode, y = -hw, x = hw, opacity = primaryOpacity}, -- 1552
                React:createElement( -- 1552
                    "polygon-shape", -- 1552
                    { -- 1552
                        verts = { -- 1552
                            Vec2(-hw, hw + height), -- 1560
                            Vec2(hw, hw + height), -- 1561
                            Vec2(hw, hw), -- 1562
                            Vec2.zero, -- 1563
                            Vec2(-hw, hw) -- 1564
                        }, -- 1564
                        fillColor = color -- 1564
                    } -- 1564
                ) -- 1564
            ) -- 1564
        ) -- 1564
    end -- 1542
    local function onMount(buttonName) -- 1571
        return function(node) -- 1572
            node:slot( -- 1573
                "TapBegan", -- 1573
                function() return props.inputManager:emitButtonDown(buttonName) end -- 1573
            ) -- 1573
            node:slot( -- 1574
                "TapEnded", -- 1574
                function() return props.inputManager:emitButtonUp(buttonName) end -- 1574
            ) -- 1574
        end -- 1572
    end -- 1571
    return React:createElement( -- 1578
        "align-node", -- 1578
        {style = {width = halfSize * 2, height = halfSize * 2}}, -- 1578
        React:createElement( -- 1578
            "menu", -- 1578
            {x = halfSize, y = halfSize, width = halfSize * 2, height = halfSize * 2}, -- 1578
            React:createElement( -- 1578
                DPadButton, -- 1581
                { -- 1581
                    x = halfSize, -- 1581
                    y = dOffset + halfSize, -- 1581
                    onMount = onMount("dpup") -- 1581
                } -- 1581
            ), -- 1581
            React:createElement( -- 1581
                DPadButton, -- 1582
                { -- 1582
                    x = halfSize, -- 1582
                    y = -dOffset + halfSize, -- 1582
                    angle = 180, -- 1582
                    onMount = onMount("dpdown") -- 1582
                } -- 1582
            ), -- 1582
            React:createElement( -- 1582
                DPadButton, -- 1583
                { -- 1583
                    x = dOffset + halfSize, -- 1583
                    y = halfSize, -- 1583
                    angle = 90, -- 1583
                    onMount = onMount("dpright") -- 1583
                } -- 1583
            ), -- 1583
            React:createElement( -- 1583
                DPadButton, -- 1584
                { -- 1584
                    x = -dOffset + halfSize, -- 1584
                    y = halfSize, -- 1584
                    angle = -90, -- 1584
                    onMount = onMount("dpleft") -- 1584
                } -- 1584
            ) -- 1584
        ) -- 1584
    ) -- 1584
end -- 1531
local function Button(self, props) -- 1601
    local ____props_3 = props -- 1609
    local x = ____props_3.x -- 1609
    local y = ____props_3.y -- 1609
    local onMount = ____props_3.onMount -- 1609
    local text = ____props_3.text -- 1609
    local fontName = ____props_3.fontName -- 1609
    if fontName == nil then -- 1609
        fontName = "sarasa-mono-sc-regular" -- 1605
    end -- 1605
    local buttonSize = ____props_3.buttonSize -- 1605
    local color = ____props_3.color -- 1605
    if color == nil then -- 1605
        color = 4294967295 -- 1607
    end -- 1607
    local primaryOpacity = ____props_3.primaryOpacity -- 1607
    if primaryOpacity == nil then -- 1607
        primaryOpacity = 0.3 -- 1608
    end -- 1608
    local drawNode = useRef() -- 1610
    return React:createElement( -- 1611
        "node", -- 1611
        { -- 1611
            x = x, -- 1611
            y = y, -- 1611
            onMount = onMount, -- 1611
            width = buttonSize * 2, -- 1611
            height = buttonSize * 2, -- 1611
            onTapBegan = function() -- 1611
                if drawNode.current then -- 1611
                    drawNode.current.opacity = 1 -- 1615
                end -- 1615
            end, -- 1613
            onTapEnded = function() -- 1613
                if drawNode.current then -- 1613
                    drawNode.current.opacity = primaryOpacity -- 1620
                end -- 1620
            end -- 1618
        }, -- 1618
        React:createElement( -- 1618
            "draw-node", -- 1618
            {ref = drawNode, x = buttonSize, y = buttonSize, opacity = primaryOpacity}, -- 1618
            React:createElement("dot-shape", {radius = buttonSize, color = color}) -- 1618
        ), -- 1618
        React:createElement("label", { -- 1618
            x = buttonSize, -- 1618
            y = buttonSize, -- 1618
            scaleX = 0.5, -- 1618
            scaleY = 0.5, -- 1618
            color3 = color, -- 1618
            opacity = primaryOpacity + 0.2, -- 1618
            fontName = fontName, -- 1618
            fontSize = buttonSize * 2 -- 1618
        }, text) -- 1618
    ) -- 1618
end -- 1601
function ____exports.JoyStick(self, props) -- 1646
    local hat = useRef() -- 1647
    local ____props_4 = props -- 1657
    local moveSize = ____props_4.moveSize -- 1657
    if moveSize == nil then -- 1657
        moveSize = 70 -- 1649
    end -- 1649
    local hatSize = ____props_4.hatSize -- 1649
    if hatSize == nil then -- 1649
        hatSize = 40 -- 1650
    end -- 1650
    local stickType = ____props_4.stickType -- 1650
    if stickType == nil then -- 1650
        stickType = "Left" -- 1651
    end -- 1651
    local color = ____props_4.color -- 1651
    if color == nil then -- 1651
        color = 4294967295 -- 1652
    end -- 1652
    local primaryOpacity = ____props_4.primaryOpacity -- 1652
    if primaryOpacity == nil then -- 1652
        primaryOpacity = 0.3 -- 1653
    end -- 1653
    local secondaryOpacity = ____props_4.secondaryOpacity -- 1653
    if secondaryOpacity == nil then -- 1653
        secondaryOpacity = 0.1 -- 1654
    end -- 1654
    local fontName = ____props_4.fontName -- 1654
    if fontName == nil then -- 1654
        fontName = "sarasa-mono-sc-regular" -- 1655
    end -- 1655
    local buttonSize = ____props_4.buttonSize -- 1655
    if buttonSize == nil then -- 1655
        buttonSize = 20 -- 1656
    end -- 1656
    local visualBound = math.max(moveSize - hatSize, 0) -- 1658
    local stickButton = stickType == "Left" and "leftstick" or "rightstick" -- 1659
    local function updatePosition(node, location) -- 1661
        if location.length > visualBound then -- 1661
            node.position = location:normalize():mul(visualBound) -- 1663
        else -- 1663
            node.position = location -- 1665
        end -- 1665
        repeat -- 1665
            local ____switch414 = stickType -- 1665
            local ____cond414 = ____switch414 == "Left" -- 1665
            if ____cond414 then -- 1665
                props.inputManager:emitAxis("leftx", node.x / visualBound) -- 1669
                props.inputManager:emitAxis("lefty", node.y / visualBound) -- 1670
                break -- 1671
            end -- 1671
            ____cond414 = ____cond414 or ____switch414 == "Right" -- 1671
            if ____cond414 then -- 1671
                props.inputManager:emitAxis("rightx", node.x / visualBound) -- 1673
                props.inputManager:emitAxis("righty", node.y / visualBound) -- 1674
                break -- 1675
            end -- 1675
        until true -- 1675
    end -- 1661
    local ____React_9 = React -- 1661
    local ____React_createElement_10 = React.createElement -- 1661
    local ____temp_7 = {style = {width = moveSize * 2, height = moveSize * 2}} -- 1661
    local ____temp_8 = React:createElement( -- 1661
        "node", -- 1661
        { -- 1661
            x = moveSize, -- 1661
            y = moveSize, -- 1661
            onTapFilter = function(touch) -- 1661
                local ____touch_5 = touch -- 1683
                local location = ____touch_5.location -- 1683
                if location.length > moveSize then -- 1683
                    touch.enabled = false -- 1685
                end -- 1685
            end, -- 1682
            onTapBegan = function(touch) -- 1682
                if hat.current then -- 1682
                    hat.current.opacity = 1 -- 1690
                    updatePosition(hat.current, touch.location) -- 1691
                end -- 1691
            end, -- 1688
            onTapMoved = function(touch) -- 1688
                if hat.current then -- 1688
                    hat.current.opacity = 1 -- 1696
                    updatePosition(hat.current, touch.location) -- 1697
                end -- 1697
            end, -- 1694
            onTapped = function() -- 1694
                if hat.current then -- 1694
                    hat.current.opacity = primaryOpacity -- 1702
                    updatePosition(hat.current, Vec2.zero) -- 1703
                end -- 1703
            end -- 1700
        }, -- 1700
        React:createElement( -- 1700
            "draw-node", -- 1700
            {opacity = secondaryOpacity}, -- 1700
            React:createElement("dot-shape", {radius = moveSize, color = color}) -- 1700
        ), -- 1700
        React:createElement( -- 1700
            "draw-node", -- 1700
            {ref = hat, opacity = primaryOpacity}, -- 1700
            React:createElement("dot-shape", {radius = hatSize, color = color}) -- 1700
        ) -- 1700
    ) -- 1700
    local ____props_noStickButton_6 -- 1714
    if props.noStickButton then -- 1714
        ____props_noStickButton_6 = nil -- 1714
    else -- 1714
        ____props_noStickButton_6 = React:createElement( -- 1714
            Button, -- 1715
            { -- 1715
                buttonSize = buttonSize, -- 1715
                x = moveSize, -- 1715
                y = moveSize * 2 + buttonSize / 2 + 20, -- 1715
                text = stickType == "Left" and "LS" or "RS", -- 1715
                fontName = fontName, -- 1715
                color = color, -- 1715
                primaryOpacity = primaryOpacity, -- 1715
                onMount = function(node) -- 1715
                    node:slot( -- 1724
                        "TapBegan", -- 1724
                        function() return props.inputManager:emitButtonDown(stickButton) end -- 1724
                    ) -- 1724
                    node:slot( -- 1725
                        "TapEnded", -- 1725
                        function() return props.inputManager:emitButtonUp(stickButton) end -- 1725
                    ) -- 1725
                end -- 1723
            } -- 1723
        ) -- 1723
    end -- 1723
    return ____React_createElement_10( -- 1679
        ____React_9, -- 1679
        "align-node", -- 1679
        ____temp_7, -- 1679
        ____temp_8, -- 1679
        ____props_noStickButton_6 -- 1679
    ) -- 1679
end -- 1646
function ____exports.ButtonPad(self, props) -- 1742
    local ____props_11 = props -- 1749
    local buttonSize = ____props_11.buttonSize -- 1749
    if buttonSize == nil then -- 1749
        buttonSize = 30 -- 1744
    end -- 1744
    local buttonPadding = ____props_11.buttonPadding -- 1744
    if buttonPadding == nil then -- 1744
        buttonPadding = 10 -- 1745
    end -- 1745
    local fontName = ____props_11.fontName -- 1745
    if fontName == nil then -- 1745
        fontName = "sarasa-mono-sc-regular" -- 1746
    end -- 1746
    local color = ____props_11.color -- 1746
    if color == nil then -- 1746
        color = 4294967295 -- 1747
    end -- 1747
    local primaryOpacity = ____props_11.primaryOpacity -- 1747
    if primaryOpacity == nil then -- 1747
        primaryOpacity = 0.3 -- 1748
    end -- 1748
    local width = buttonSize * 5 + buttonPadding * 3 / 2 -- 1750
    local height = buttonSize * 4 + buttonPadding -- 1751
    local function onMount(buttonName) -- 1752
        return function(node) -- 1753
            node:slot( -- 1754
                "TapBegan", -- 1754
                function() return props.inputManager:emitButtonDown(buttonName) end -- 1754
            ) -- 1754
            node:slot( -- 1755
                "TapEnded", -- 1755
                function() return props.inputManager:emitButtonUp(buttonName) end -- 1755
            ) -- 1755
        end -- 1753
    end -- 1752
    return React:createElement( -- 1758
        "align-node", -- 1758
        {style = {width = width, height = height}}, -- 1758
        React:createElement( -- 1758
            "node", -- 1758
            {x = (buttonSize + buttonPadding / 2) / 2 + width / 2, y = buttonSize + buttonPadding / 2 + height / 2}, -- 1758
            React:createElement( -- 1758
                Button, -- 1764
                { -- 1764
                    text = "B", -- 1764
                    fontName = fontName, -- 1764
                    color = color, -- 1764
                    primaryOpacity = primaryOpacity, -- 1764
                    buttonSize = buttonSize, -- 1764
                    x = -buttonSize * 2 - buttonPadding, -- 1764
                    onMount = onMount("b") -- 1764
                } -- 1764
            ), -- 1764
            React:createElement( -- 1764
                Button, -- 1770
                { -- 1770
                    text = "Y", -- 1770
                    fontName = fontName, -- 1770
                    color = color, -- 1770
                    primaryOpacity = primaryOpacity, -- 1770
                    buttonSize = buttonSize, -- 1770
                    onMount = onMount("y") -- 1770
                } -- 1770
            ), -- 1770
            React:createElement( -- 1770
                Button, -- 1774
                { -- 1774
                    text = "A", -- 1774
                    fontName = fontName, -- 1774
                    color = color, -- 1774
                    primaryOpacity = primaryOpacity, -- 1774
                    buttonSize = buttonSize, -- 1774
                    x = -buttonSize - buttonPadding / 2, -- 1774
                    y = -buttonSize * 2 - buttonPadding, -- 1774
                    onMount = onMount("a") -- 1774
                } -- 1774
            ), -- 1774
            React:createElement( -- 1774
                Button, -- 1781
                { -- 1781
                    text = "X", -- 1781
                    fontName = fontName, -- 1781
                    color = color, -- 1781
                    primaryOpacity = primaryOpacity, -- 1781
                    buttonSize = buttonSize, -- 1781
                    x = buttonSize + buttonPadding / 2, -- 1781
                    y = -buttonSize * 2 - buttonPadding, -- 1781
                    onMount = onMount("x") -- 1781
                } -- 1781
            ) -- 1781
        ) -- 1781
    ) -- 1781
end -- 1742
function ____exports.ControlPad(self, props) -- 1801
    local ____props_12 = props -- 1807
    local buttonSize = ____props_12.buttonSize -- 1807
    if buttonSize == nil then -- 1807
        buttonSize = 35 -- 1803
    end -- 1803
    local fontName = ____props_12.fontName -- 1803
    if fontName == nil then -- 1803
        fontName = "sarasa-mono-sc-regular" -- 1804
    end -- 1804
    local color = ____props_12.color -- 1804
    if color == nil then -- 1804
        color = 4294967295 -- 1805
    end -- 1805
    local primaryOpacity = ____props_12.primaryOpacity -- 1805
    if primaryOpacity == nil then -- 1805
        primaryOpacity = 0.3 -- 1806
    end -- 1806
    local function Button(self, props) -- 1808
        local drawNode = useRef() -- 1809
        return React:createElement( -- 1810
            "node", -- 1810
            __TS__ObjectAssign( -- 1810
                {}, -- 1810
                props, -- 1811
                { -- 1811
                    width = buttonSize * 2, -- 1811
                    height = buttonSize, -- 1811
                    onTapBegan = function() -- 1811
                        if drawNode.current then -- 1811
                            drawNode.current.opacity = 1 -- 1814
                        end -- 1814
                    end, -- 1812
                    onTapEnded = function() -- 1812
                        if drawNode.current then -- 1812
                            drawNode.current.opacity = primaryOpacity -- 1819
                        end -- 1819
                    end -- 1817
                } -- 1817
            ), -- 1817
            React:createElement( -- 1817
                "draw-node", -- 1817
                {ref = drawNode, x = buttonSize, y = buttonSize / 2, opacity = primaryOpacity}, -- 1817
                React:createElement("rect-shape", {width = buttonSize * 2, height = buttonSize, fillColor = color}) -- 1817
            ), -- 1817
            React:createElement( -- 1817
                "label", -- 1817
                { -- 1817
                    x = buttonSize, -- 1817
                    y = buttonSize / 2, -- 1817
                    scaleX = 0.5, -- 1817
                    scaleY = 0.5, -- 1817
                    fontName = fontName, -- 1817
                    fontSize = math.floor(buttonSize * 1.5), -- 1817
                    color3 = color, -- 1817
                    opacity = primaryOpacity + 0.2 -- 1817
                }, -- 1817
                props.text -- 1828
            ) -- 1828
        ) -- 1828
    end -- 1808
    local function onMount(buttonName) -- 1832
        return function(node) -- 1833
            node:slot( -- 1834
                "TapBegan", -- 1834
                function() return props.inputManager:emitButtonDown(buttonName) end -- 1834
            ) -- 1834
            node:slot( -- 1835
                "TapEnded", -- 1835
                function() return props.inputManager:emitButtonUp(buttonName) end -- 1835
            ) -- 1835
        end -- 1833
    end -- 1832
    return React:createElement( -- 1838
        "align-node", -- 1838
        {style = {minWidth = buttonSize * 4 + 20, justifyContent = "space-between", flexDirection = "row"}}, -- 1838
        React:createElement( -- 1838
            "align-node", -- 1838
            {style = {width = buttonSize * 2, height = buttonSize}}, -- 1838
            React:createElement( -- 1838
                Button, -- 1841
                { -- 1841
                    text = "Start", -- 1841
                    x = buttonSize, -- 1841
                    y = buttonSize / 2, -- 1841
                    onMount = onMount("start") -- 1841
                } -- 1841
            ) -- 1841
        ), -- 1841
        React:createElement( -- 1841
            "align-node", -- 1841
            {style = {width = buttonSize * 2, height = buttonSize}}, -- 1841
            React:createElement( -- 1841
                Button, -- 1847
                { -- 1847
                    text = "Back", -- 1847
                    x = buttonSize, -- 1847
                    y = buttonSize / 2, -- 1847
                    onMount = onMount("back") -- 1847
                } -- 1847
            ) -- 1847
        ) -- 1847
    ) -- 1847
end -- 1801
function ____exports.CreateControlPad(props) -- 1856
    return toNode(React:createElement( -- 1857
        ____exports.ControlPad, -- 1857
        __TS__ObjectAssign({}, props) -- 1857
    )) -- 1857
end -- 1856
function ____exports.TriggerPad(self, props) -- 1871
    local ____props_13 = props -- 1877
    local buttonSize = ____props_13.buttonSize -- 1877
    if buttonSize == nil then -- 1877
        buttonSize = 35 -- 1873
    end -- 1873
    local fontName = ____props_13.fontName -- 1873
    if fontName == nil then -- 1873
        fontName = "sarasa-mono-sc-regular" -- 1874
    end -- 1874
    local color = ____props_13.color -- 1874
    if color == nil then -- 1874
        color = 4294967295 -- 1875
    end -- 1875
    local primaryOpacity = ____props_13.primaryOpacity -- 1875
    if primaryOpacity == nil then -- 1875
        primaryOpacity = 0.3 -- 1876
    end -- 1876
    local function Button(self, props) -- 1878
        local drawNode = useRef() -- 1879
        return React:createElement( -- 1880
            "node", -- 1880
            __TS__ObjectAssign( -- 1880
                {}, -- 1880
                props, -- 1881
                { -- 1881
                    width = buttonSize * 2, -- 1881
                    height = buttonSize, -- 1881
                    onTapBegan = function() -- 1881
                        if drawNode.current then -- 1881
                            drawNode.current.opacity = 1 -- 1884
                        end -- 1884
                    end, -- 1882
                    onTapEnded = function() -- 1882
                        if drawNode.current then -- 1882
                            drawNode.current.opacity = primaryOpacity -- 1889
                        end -- 1889
                    end -- 1887
                } -- 1887
            ), -- 1887
            React:createElement( -- 1887
                "draw-node", -- 1887
                {ref = drawNode, x = buttonSize, y = buttonSize / 2, opacity = primaryOpacity}, -- 1887
                React:createElement("rect-shape", {width = buttonSize * 2, height = buttonSize, fillColor = color}) -- 1887
            ), -- 1887
            React:createElement( -- 1887
                "label", -- 1887
                { -- 1887
                    x = buttonSize, -- 1887
                    y = buttonSize / 2, -- 1887
                    scaleX = 0.5, -- 1887
                    scaleY = 0.5, -- 1887
                    fontName = fontName, -- 1887
                    fontSize = math.floor(buttonSize * 1.5), -- 1887
                    color3 = color, -- 1887
                    opacity = primaryOpacity + 0.2 -- 1887
                }, -- 1887
                props.text -- 1897
            ) -- 1897
        ) -- 1897
    end -- 1878
    local function onMountAxis(axisName) -- 1901
        return function(node) -- 1902
            node:slot( -- 1903
                "TapBegan", -- 1903
                function() return props.inputManager:emitAxis(axisName, 1, 0) end -- 1903
            ) -- 1903
            node:slot( -- 1904
                "TapEnded", -- 1904
                function() return props.inputManager:emitAxis(axisName, 0, 0) end -- 1904
            ) -- 1904
        end -- 1902
    end -- 1901
    local function onMountButton(buttonName) -- 1907
        return function(node) -- 1908
            node:slot( -- 1909
                "TapBegan", -- 1909
                function() return props.inputManager:emitButtonDown(buttonName, 0) end -- 1909
            ) -- 1909
            node:slot( -- 1910
                "TapEnded", -- 1910
                function() return props.inputManager:emitButtonUp(buttonName, 0) end -- 1910
            ) -- 1910
        end -- 1908
    end -- 1907
    local ____React_25 = React -- 1907
    local ____React_createElement_26 = React.createElement -- 1907
    local ____temp_23 = {style = {minWidth = buttonSize * 4 + 20, justifyContent = "space-between", flexDirection = "row"}} -- 1907
    local ____React_17 = React -- 1907
    local ____React_createElement_18 = React.createElement -- 1907
    local ____temp_15 = {style = {width = buttonSize * 4 + 10, height = buttonSize}} -- 1907
    local ____temp_16 = React:createElement( -- 1907
        Button, -- 1916
        { -- 1916
            text = "LT", -- 1916
            x = buttonSize, -- 1916
            y = buttonSize / 2, -- 1916
            onMount = onMountAxis("lefttrigger") -- 1916
        } -- 1916
    ) -- 1916
    local ____props_noShoulder_14 -- 1920
    if props.noShoulder then -- 1920
        ____props_noShoulder_14 = nil -- 1920
    else -- 1920
        ____props_noShoulder_14 = React:createElement( -- 1920
            Button, -- 1921
            { -- 1921
                text = "LB", -- 1921
                x = buttonSize * 3 + 10, -- 1921
                y = buttonSize / 2, -- 1921
                onMount = onMountButton("leftshoulder") -- 1921
            } -- 1921
        ) -- 1921
    end -- 1921
    local ____React_createElement_18_result_24 = ____React_createElement_18( -- 1921
        ____React_17, -- 1921
        "align-node", -- 1921
        ____temp_15, -- 1921
        ____temp_16, -- 1921
        ____props_noShoulder_14 -- 1921
    ) -- 1921
    local ____React_21 = React -- 1921
    local ____React_createElement_22 = React.createElement -- 1921
    local ____temp_20 = {style = {width = buttonSize * 4 + 10, height = buttonSize}} -- 1921
    local ____props_noShoulder_19 -- 1928
    if props.noShoulder then -- 1928
        ____props_noShoulder_19 = nil -- 1928
    else -- 1928
        ____props_noShoulder_19 = React:createElement( -- 1928
            Button, -- 1929
            { -- 1929
                text = "RB", -- 1929
                x = buttonSize, -- 1929
                y = buttonSize / 2, -- 1929
                onMount = onMountButton("rightshoulder") -- 1929
            } -- 1929
        ) -- 1929
    end -- 1929
    return ____React_createElement_26( -- 1913
        ____React_25, -- 1913
        "align-node", -- 1913
        ____temp_23, -- 1913
        ____React_createElement_18_result_24, -- 1913
        ____React_createElement_22( -- 1913
            ____React_21, -- 1913
            "align-node", -- 1913
            ____temp_20, -- 1913
            ____props_noShoulder_19, -- 1913
            React:createElement( -- 1913
                Button, -- 1934
                { -- 1934
                    text = "RT", -- 1934
                    x = buttonSize * 3 + 10, -- 1934
                    y = buttonSize / 2, -- 1934
                    onMount = onMountAxis("righttrigger") -- 1934
                } -- 1934
            ) -- 1934
        ) -- 1934
    ) -- 1934
end -- 1871
function ____exports.CreateTriggerPad(props) -- 1943
    return toNode(React:createElement( -- 1944
        ____exports.TriggerPad, -- 1944
        __TS__ObjectAssign({}, props) -- 1944
    )) -- 1944
end -- 1943
function ____exports.GamePad(self, props) -- 1964
    local ____props_27 = props -- 1965
    local color = ____props_27.color -- 1965
    local primaryOpacity = ____props_27.primaryOpacity -- 1965
    local secondaryOpacity = ____props_27.secondaryOpacity -- 1965
    local inputManager = ____props_27.inputManager -- 1965
    local ____React_46 = React -- 1965
    local ____React_createElement_47 = React.createElement -- 1965
    local ____temp_44 = {style = {flexDirection = "column-reverse"}, windowRoot = true} -- 1965
    local ____React_40 = React -- 1965
    local ____React_createElement_41 = React.createElement -- 1965
    local ____temp_38 = {style = {margin = 20, justifyContent = "space-between", flexDirection = "row", alignItems = "flex-end"}} -- 1965
    local ____React_31 = React -- 1965
    local ____React_createElement_32 = React.createElement -- 1965
    local ____temp_30 = {style = {justifyContent = "space-between", flexDirection = "row", alignItems = "flex-end"}} -- 1965
    local ____props_noDPad_28 -- 1979
    if props.noDPad then -- 1979
        ____props_noDPad_28 = nil -- 1979
    else -- 1979
        ____props_noDPad_28 = React:createElement(____exports.DPad, {color = color, primaryOpacity = primaryOpacity, inputManager = inputManager}) -- 1979
    end -- 1979
    local ____props_noLeftStick_29 -- 1986
    if props.noLeftStick then -- 1986
        ____props_noLeftStick_29 = nil -- 1986
    else -- 1986
        ____props_noLeftStick_29 = React:createElement( -- 1986
            React.Fragment, -- 1986
            nil, -- 1986
            React:createElement("align-node", {style = {width = 10}}), -- 1986
            React:createElement(____exports.JoyStick, { -- 1986
                stickType = "Left", -- 1986
                color = color, -- 1986
                primaryOpacity = primaryOpacity, -- 1986
                secondaryOpacity = secondaryOpacity, -- 1986
                inputManager = inputManager, -- 1986
                noStickButton = props.noStickButton -- 1986
            }) -- 1986
        ) -- 1986
    end -- 1986
    local ____React_createElement_32_result_39 = ____React_createElement_32( -- 1986
        ____React_31, -- 1986
        "align-node", -- 1986
        ____temp_30, -- 1986
        ____props_noDPad_28, -- 1986
        ____props_noLeftStick_29 -- 1986
    ) -- 1986
    local ____React_36 = React -- 1986
    local ____React_createElement_37 = React.createElement -- 1986
    local ____temp_35 = {style = {justifyContent = "space-between", flexDirection = "row", alignItems = "flex-end"}} -- 1986
    local ____props_noRightStick_33 -- 2003
    if props.noRightStick then -- 2003
        ____props_noRightStick_33 = nil -- 2003
    else -- 2003
        ____props_noRightStick_33 = React:createElement( -- 2003
            React.Fragment, -- 2003
            nil, -- 2003
            React:createElement(____exports.JoyStick, { -- 2003
                stickType = "Right", -- 2003
                color = color, -- 2003
                primaryOpacity = primaryOpacity, -- 2003
                secondaryOpacity = secondaryOpacity, -- 2003
                inputManager = inputManager, -- 2003
                noStickButton = props.noStickButton -- 2003
            }), -- 2003
            React:createElement("align-node", {style = {width = 10}}) -- 2003
        ) -- 2003
    end -- 2003
    local ____props_noButtonPad_34 -- 2014
    if props.noButtonPad then -- 2014
        ____props_noButtonPad_34 = nil -- 2014
    else -- 2014
        ____props_noButtonPad_34 = React:createElement(____exports.ButtonPad, {color = color, primaryOpacity = primaryOpacity, inputManager = inputManager}) -- 2014
    end -- 2014
    local ____React_createElement_41_result_45 = ____React_createElement_41( -- 2014
        ____React_40, -- 2014
        "align-node", -- 2014
        ____temp_38, -- 2014
        ____React_createElement_32_result_39, -- 2014
        ____React_createElement_37( -- 2014
            ____React_36, -- 2014
            "align-node", -- 2014
            ____temp_35, -- 2014
            ____props_noRightStick_33, -- 2014
            ____props_noButtonPad_34 -- 2014
        ) -- 2014
    ) -- 2014
    local ____props_noTriggerPad_42 -- 2023
    if props.noTriggerPad then -- 2023
        ____props_noTriggerPad_42 = nil -- 2023
    else -- 2023
        ____props_noTriggerPad_42 = React:createElement( -- 2023
            "align-node", -- 2023
            {style = {paddingLeft = 20, paddingRight = 20, paddingTop = 20}}, -- 2023
            React:createElement(____exports.TriggerPad, {color = color, noShoulder = props.noShoulder, primaryOpacity = primaryOpacity, inputManager = inputManager}) -- 2023
        ) -- 2023
    end -- 2023
    local ____props_noControlPad_43 -- 2033
    if props.noControlPad then -- 2033
        ____props_noControlPad_43 = nil -- 2033
    else -- 2033
        ____props_noControlPad_43 = React:createElement( -- 2033
            "align-node", -- 2033
            {style = {paddingLeft = 20, paddingRight = 20}}, -- 2033
            React:createElement(____exports.ControlPad, {color = color, primaryOpacity = primaryOpacity, inputManager = inputManager}) -- 2033
        ) -- 2033
    end -- 2033
    return ____React_createElement_47( -- 1966
        ____React_46, -- 1966
        "align-node", -- 1966
        ____temp_44, -- 1966
        ____React_createElement_41_result_45, -- 1966
        ____props_noTriggerPad_42, -- 1966
        ____props_noControlPad_43 -- 1966
    ) -- 1966
end -- 1964
function ____exports.CreateGamePad(props) -- 2046
    return toNode(React:createElement( -- 2047
        ____exports.GamePad, -- 2047
        __TS__ObjectAssign({}, props) -- 2047
    )) -- 2047
end -- 2046
return ____exports -- 2046