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
local useRef = ____DoraX.useRef -- 1
local ____Dora = require("Dora") -- 2
local Node = ____Dora.Node -- 2
local Vec2 = ____Dora.Vec2 -- 2
local emit = ____Dora.emit -- 2
____exports.Trigger = __TS__Class() -- 17
local Trigger = ____exports.Trigger -- 17
Trigger.name = "Trigger" -- 17
function Trigger.prototype.____constructor(self) -- 18
    self.state = "None" -- 19
    self.progress = 0 -- 20
    self.value = false -- 21
end -- 18
local KeyDownTrigger = __TS__Class() -- 32
KeyDownTrigger.name = "KeyDownTrigger" -- 32
__TS__ClassExtends(KeyDownTrigger, ____exports.Trigger) -- 32
function KeyDownTrigger.prototype.____constructor(self, keys) -- 38
    KeyDownTrigger.____super.prototype.____constructor(self) -- 39
    self.keys = keys -- 40
    self.keyStates = {} -- 41
    self.onKeyDown = function(keyName) -- 42
        if self.state == "Completed" then -- 42
            return -- 44
        end -- 44
        if not (self.keyStates[keyName] ~= nil) then -- 44
            return -- 47
        end -- 47
        local oldState = true -- 49
        for ____, state in pairs(self.keyStates) do -- 50
            if oldState then -- 50
                oldState = state -- 51
            end -- 51
        end -- 51
        self.keyStates[keyName] = true -- 53
        if not oldState then -- 53
            local newState = true -- 55
            for ____, state in pairs(self.keyStates) do -- 56
                if newState then -- 56
                    newState = state -- 57
                end -- 57
            end -- 57
            if newState then -- 57
                self.state = "Completed" -- 60
                self.progress = 1 -- 61
                if self.onChange then -- 61
                    self:onChange() -- 63
                end -- 63
                self.progress = 0 -- 65
                self.state = "None" -- 66
            end -- 66
        end -- 66
    end -- 42
    self.onKeyUp = function(keyName) -- 70
        if self.state == "Completed" then -- 70
            return -- 72
        end -- 72
        if not (self.keyStates[keyName] ~= nil) then -- 72
            return -- 75
        end -- 75
        self.keyStates[keyName] = false -- 77
    end -- 70
end -- 38
function KeyDownTrigger.prototype.start(self, manager) -- 80
    manager.keyboardEnabled = true -- 81
    for ____, k in ipairs(self.keys) do -- 82
        self.keyStates[k] = false -- 83
    end -- 83
    manager:slot("KeyDown", self.onKeyDown) -- 85
    manager:slot("KeyUp", self.onKeyUp) -- 86
    self.state = "None" -- 87
    self.progress = 0 -- 88
end -- 80
function KeyDownTrigger.prototype.stop(self, manager) -- 90
    manager:slot("KeyDown"):remove(self.onKeyDown) -- 91
    manager:slot("KeyUp"):remove(self.onKeyUp) -- 92
    self.state = "None" -- 93
    self.progress = 0 -- 94
end -- 90
local KeyUpTrigger = __TS__Class() -- 98
KeyUpTrigger.name = "KeyUpTrigger" -- 98
__TS__ClassExtends(KeyUpTrigger, ____exports.Trigger) -- 98
function KeyUpTrigger.prototype.____constructor(self, keys) -- 104
    KeyUpTrigger.____super.prototype.____constructor(self) -- 105
    self.keys = keys -- 106
    self.keyStates = {} -- 107
    self.onKeyDown = function(keyName) -- 108
        if self.state == "Completed" then -- 108
            return -- 110
        end -- 110
        if not (self.keyStates[keyName] ~= nil) then -- 110
            return -- 113
        end -- 113
        self.keyStates[keyName] = true -- 115
    end -- 108
    self.onKeyUp = function(keyName) -- 117
        if self.state == "Completed" then -- 117
            return -- 119
        end -- 119
        if not (self.keyStates[keyName] ~= nil) then -- 119
            return -- 122
        end -- 122
        local oldState = true -- 124
        for ____, state in pairs(self.keyStates) do -- 125
            if oldState then -- 125
                oldState = state -- 126
            end -- 126
        end -- 126
        self.keyStates[keyName] = false -- 128
        if oldState then -- 128
            self.state = "Completed" -- 130
            self.progress = 1 -- 131
            if self.onChange then -- 131
                self:onChange() -- 133
            end -- 133
            self.progress = 0 -- 135
            self.state = "None" -- 136
        end -- 136
    end -- 117
end -- 104
function KeyUpTrigger.prototype.start(self, manager) -- 140
    manager.keyboardEnabled = true -- 141
    for ____, k in ipairs(self.keys) do -- 142
        self.keyStates[k] = false -- 143
    end -- 143
    manager:slot("KeyDown", self.onKeyDown) -- 145
    manager:slot("KeyUp", self.onKeyUp) -- 146
    self.state = "None" -- 147
    self.progress = 0 -- 148
end -- 140
function KeyUpTrigger.prototype.stop(self, manager) -- 150
    manager:slot("KeyDown"):remove(self.onKeyDown) -- 151
    manager:slot("KeyUp"):remove(self.onKeyUp) -- 152
    self.state = "None" -- 153
    self.progress = 0 -- 154
end -- 150
local KeyPressedTrigger = __TS__Class() -- 158
KeyPressedTrigger.name = "KeyPressedTrigger" -- 158
__TS__ClassExtends(KeyPressedTrigger, ____exports.Trigger) -- 158
function KeyPressedTrigger.prototype.____constructor(self, keys) -- 164
    KeyPressedTrigger.____super.prototype.____constructor(self) -- 165
    self.keys = keys -- 166
    self.keyStates = {} -- 167
    self.onKeyDown = function(keyName) -- 168
        if not (self.keyStates[keyName] ~= nil) then -- 168
            return -- 170
        end -- 170
        self.keyStates[keyName] = true -- 172
    end -- 168
    self.onKeyUp = function(keyName) -- 174
        if not (self.keyStates[keyName] ~= nil) then -- 174
            return -- 176
        end -- 176
        self.keyStates[keyName] = false -- 178
    end -- 174
end -- 164
function KeyPressedTrigger.prototype.onUpdate(self, _) -- 181
    local allDown = true -- 182
    for ____, down in pairs(self.keyStates) do -- 183
        if allDown then -- 183
            allDown = down -- 184
        end -- 184
    end -- 184
    if allDown then -- 184
        self.state = "Completed" -- 187
        self.progress = 1 -- 188
        if self.onChange then -- 188
            self:onChange() -- 190
        end -- 190
        self.progress = 0 -- 192
        self.state = "None" -- 193
    end -- 193
end -- 181
function KeyPressedTrigger.prototype.start(self, manager) -- 196
    manager.keyboardEnabled = true -- 197
    for ____, k in ipairs(self.keys) do -- 198
        self.keyStates[k] = false -- 199
    end -- 199
    manager:slot("KeyDown", self.onKeyDown) -- 201
    manager:slot("KeyUp", self.onKeyUp) -- 202
    self.state = "None" -- 203
    self.progress = 0 -- 204
end -- 196
function KeyPressedTrigger.prototype.stop(self, manager) -- 206
    manager:slot("KeyDown"):remove(self.onKeyDown) -- 207
    manager:slot("KeyUp"):remove(self.onKeyUp) -- 208
    self.state = "None" -- 209
    self.progress = 0 -- 210
end -- 206
local KeyHoldTrigger = __TS__Class() -- 214
KeyHoldTrigger.name = "KeyHoldTrigger" -- 214
__TS__ClassExtends(KeyHoldTrigger, ____exports.Trigger) -- 214
function KeyHoldTrigger.prototype.____constructor(self, key, holdTime) -- 221
    KeyHoldTrigger.____super.prototype.____constructor(self) -- 222
    self.key = key -- 223
    self.holdTime = holdTime -- 224
    self.time = 0 -- 225
    self.onKeyDown = function(keyName) -- 226
        if self.key == keyName then -- 226
            self.time = 0 -- 228
            self.state = "Started" -- 229
            self.progress = 0 -- 230
            if self.onChange then -- 230
                self:onChange() -- 232
            end -- 232
        end -- 232
    end -- 226
    self.onKeyUp = function(keyName) -- 236
        repeat -- 236
            local ____switch51 = self.state -- 236
            local ____cond51 = ____switch51 == "Started" or ____switch51 == "Ongoing" or ____switch51 == "Completed" -- 236
            if ____cond51 then -- 236
                break -- 241
            end -- 241
            do -- 241
                return -- 243
            end -- 243
        until true -- 243
        if self.key == keyName then -- 243
            if self.state == "Completed" then -- 243
                self.state = "None" -- 247
            else -- 247
                self.state = "Canceled" -- 249
            end -- 249
            self.progress = 0 -- 251
            if self.onChange then -- 251
                self:onChange() -- 253
            end -- 253
        end -- 253
    end -- 236
end -- 221
function KeyHoldTrigger.prototype.start(self, manager) -- 258
    manager.keyboardEnabled = true -- 259
    manager:slot("KeyDown", self.onKeyDown) -- 260
    manager:slot("KeyUp", self.onKeyUp) -- 261
    self.state = "None" -- 262
    self.progress = 0 -- 263
end -- 258
function KeyHoldTrigger.prototype.onUpdate(self, deltaTime) -- 265
    repeat -- 265
        local ____switch58 = self.state -- 265
        local ____cond58 = ____switch58 == "Started" or ____switch58 == "Ongoing" -- 265
        if ____cond58 then -- 265
            break -- 269
        end -- 269
        do -- 269
            return -- 271
        end -- 271
    until true -- 271
    self.time = self.time + deltaTime -- 273
    if self.time >= self.holdTime then -- 273
        self.state = "Completed" -- 275
        self.progress = 1 -- 276
    else -- 276
        self.state = "Ongoing" -- 278
        self.progress = math.min(self.time / self.holdTime, 1) -- 279
    end -- 279
    if self.onChange then -- 279
        self:onChange() -- 282
    end -- 282
end -- 265
function KeyHoldTrigger.prototype.stop(self, manager) -- 285
    manager:slot("KeyDown"):remove(self.onKeyDown) -- 286
    manager:slot("KeyUp"):remove(self.onKeyUp) -- 287
    self.state = "None" -- 288
    self.progress = 0 -- 289
end -- 285
local KeyTimedTrigger = __TS__Class() -- 293
KeyTimedTrigger.name = "KeyTimedTrigger" -- 293
__TS__ClassExtends(KeyTimedTrigger, ____exports.Trigger) -- 293
function KeyTimedTrigger.prototype.____constructor(self, key, timeWindow) -- 299
    KeyTimedTrigger.____super.prototype.____constructor(self) -- 300
    self.key = key -- 301
    self.timeWindow = timeWindow -- 302
    self.time = 0 -- 303
    self.onKeyDown = function(keyName) -- 304
        repeat -- 304
            local ____switch65 = self.state -- 304
            local ____cond65 = ____switch65 == "Started" or ____switch65 == "Ongoing" or ____switch65 == "Completed" -- 304
            if ____cond65 then -- 304
                break -- 309
            end -- 309
            do -- 309
                return -- 311
            end -- 311
        until true -- 311
        if self.key == keyName and self.time <= self.timeWindow then -- 311
            self.state = "Completed" -- 314
            self.value = self.time -- 315
            if self.onChange then -- 315
                self:onChange() -- 317
            end -- 317
        end -- 317
    end -- 304
end -- 299
function KeyTimedTrigger.prototype.start(self, manager) -- 322
    manager.keyboardEnabled = true -- 323
    manager:slot("KeyDown", self.onKeyDown) -- 324
    self.state = "Started" -- 325
    self.progress = 0 -- 326
    self.value = false -- 327
    if self.onChange then -- 327
        self:onChange() -- 329
    end -- 329
end -- 322
function KeyTimedTrigger.prototype.onUpdate(self, deltaTime) -- 332
    repeat -- 332
        local ____switch71 = self.state -- 332
        local ____cond71 = ____switch71 == "Started" or ____switch71 == "Ongoing" or ____switch71 == "Completed" -- 332
        if ____cond71 then -- 332
            break -- 337
        end -- 337
        do -- 337
            return -- 339
        end -- 339
    until true -- 339
    self.time = self.time + deltaTime -- 341
    if self.time >= self.timeWindow then -- 341
        if self.state == "Completed" then -- 341
            self.state = "None" -- 344
            self.progress = 0 -- 345
        else -- 345
            self.state = "Canceled" -- 347
            self.progress = 1 -- 348
        end -- 348
    else -- 348
        self.state = "Ongoing" -- 351
        self.progress = math.min(self.time / self.timeWindow, 1) -- 352
    end -- 352
    if self.onChange then -- 352
        self:onChange() -- 355
    end -- 355
end -- 332
function KeyTimedTrigger.prototype.stop(self, manager) -- 358
    manager:slot("KeyDown"):remove(self.onKeyDown) -- 359
    self.state = "None" -- 360
    self.value = false -- 361
    self.progress = 0 -- 362
end -- 358
local ButtonDownTrigger = __TS__Class() -- 366
ButtonDownTrigger.name = "ButtonDownTrigger" -- 366
__TS__ClassExtends(ButtonDownTrigger, ____exports.Trigger) -- 366
function ButtonDownTrigger.prototype.____constructor(self, buttons, controllerId) -- 373
    ButtonDownTrigger.____super.prototype.____constructor(self) -- 374
    self.controllerId = controllerId -- 375
    self.buttons = buttons -- 376
    self.buttonStates = {} -- 377
    self.onButtonDown = function(controllerId, buttonName) -- 378
        if self.state == "Completed" then -- 378
            return -- 380
        end -- 380
        if self.controllerId ~= controllerId then -- 380
            return -- 383
        end -- 383
        if not (self.buttonStates[buttonName] ~= nil) then -- 383
            return -- 386
        end -- 386
        local oldState = true -- 388
        for ____, state in pairs(self.buttonStates) do -- 389
            if oldState then -- 389
                oldState = state -- 390
            end -- 390
        end -- 390
        self.buttonStates[buttonName] = true -- 392
        if not oldState then -- 392
            local newState = true -- 394
            for ____, state in pairs(self.buttonStates) do -- 395
                if newState then -- 395
                    newState = state -- 396
                end -- 396
            end -- 396
            if newState then -- 396
                self.state = "Completed" -- 399
                self.progress = 1 -- 400
                if self.onChange then -- 400
                    self:onChange() -- 402
                end -- 402
                self.progress = 0 -- 404
                self.state = "None" -- 405
            end -- 405
        end -- 405
    end -- 378
    self.onButtonUp = function(controllerId, buttonName) -- 409
        if self.state == "Completed" then -- 409
            return -- 411
        end -- 411
        if self.controllerId ~= controllerId then -- 411
            return -- 414
        end -- 414
        if not (self.buttonStates[buttonName] ~= nil) then -- 414
            return -- 417
        end -- 417
        self.buttonStates[buttonName] = false -- 419
    end -- 409
end -- 373
function ButtonDownTrigger.prototype.start(self, manager) -- 422
    manager.controllerEnabled = true -- 423
    for ____, k in ipairs(self.buttons) do -- 424
        self.buttonStates[k] = false -- 425
    end -- 425
    manager:slot("ButtonDown", self.onButtonDown) -- 427
    manager:slot("ButtonUp", self.onButtonUp) -- 428
    self.state = "None" -- 429
    self.progress = 0 -- 430
end -- 422
function ButtonDownTrigger.prototype.stop(self, manager) -- 432
    manager:slot("ButtonDown"):remove(self.onButtonDown) -- 433
    manager:slot("ButtonUp"):remove(self.onButtonUp) -- 434
    self.state = "None" -- 435
    self.progress = 0 -- 436
    self.value = false -- 437
end -- 432
local ButtonUpTrigger = __TS__Class() -- 441
ButtonUpTrigger.name = "ButtonUpTrigger" -- 441
__TS__ClassExtends(ButtonUpTrigger, ____exports.Trigger) -- 441
function ButtonUpTrigger.prototype.____constructor(self, buttons, controllerId) -- 448
    ButtonUpTrigger.____super.prototype.____constructor(self) -- 449
    self.controllerId = controllerId -- 450
    self.buttons = buttons -- 451
    self.buttonStates = {} -- 452
    self.onButtonDown = function(controllerId, buttonName) -- 453
        if self.state == "Completed" then -- 453
            return -- 455
        end -- 455
        if self.controllerId ~= controllerId then -- 455
            return -- 458
        end -- 458
        if not (self.buttonStates[buttonName] ~= nil) then -- 458
            return -- 461
        end -- 461
        self.buttonStates[buttonName] = true -- 463
    end -- 453
    self.onButtonUp = function(controllerId, buttonName) -- 465
        if self.state == "Completed" then -- 465
            return -- 467
        end -- 467
        if self.controllerId ~= controllerId then -- 467
            return -- 470
        end -- 470
        if not (self.buttonStates[buttonName] ~= nil) then -- 470
            return -- 473
        end -- 473
        local oldState = true -- 475
        for ____, state in pairs(self.buttonStates) do -- 476
            if oldState then -- 476
                oldState = state -- 477
            end -- 477
        end -- 477
        self.buttonStates[buttonName] = false -- 479
        if oldState then -- 479
            self.state = "Completed" -- 481
            self.progress = 1 -- 482
            if self.onChange then -- 482
                self:onChange() -- 484
            end -- 484
            self.progress = 0 -- 486
            self.state = "None" -- 487
        end -- 487
    end -- 465
end -- 448
function ButtonUpTrigger.prototype.start(self, manager) -- 491
    manager.controllerEnabled = true -- 492
    for ____, k in ipairs(self.buttons) do -- 493
        self.buttonStates[k] = false -- 494
    end -- 494
    manager:slot("ButtonDown", self.onButtonDown) -- 496
    manager:slot("ButtonUp", self.onButtonUp) -- 497
    self.state = "None" -- 498
    self.progress = 0 -- 499
end -- 491
function ButtonUpTrigger.prototype.stop(self, manager) -- 501
    manager:slot("ButtonDown"):remove(self.onButtonDown) -- 502
    manager:slot("ButtonUp"):remove(self.onButtonUp) -- 503
    self.state = "None" -- 504
    self.progress = 0 -- 505
end -- 501
local ButtonPressedTrigger = __TS__Class() -- 509
ButtonPressedTrigger.name = "ButtonPressedTrigger" -- 509
__TS__ClassExtends(ButtonPressedTrigger, ____exports.Trigger) -- 509
function ButtonPressedTrigger.prototype.____constructor(self, buttons, controllerId) -- 516
    ButtonPressedTrigger.____super.prototype.____constructor(self) -- 517
    self.controllerId = controllerId -- 518
    self.buttons = buttons -- 519
    self.buttonStates = {} -- 520
    self.onButtonDown = function(controllerId, buttonName) -- 521
        if self.controllerId ~= controllerId then -- 521
            return -- 523
        end -- 523
        if not (self.buttonStates[buttonName] ~= nil) then -- 523
            return -- 526
        end -- 526
        self.buttonStates[buttonName] = true -- 528
    end -- 521
    self.onButtonUp = function(controllerId, buttonName) -- 530
        if self.controllerId ~= controllerId then -- 530
            return -- 532
        end -- 532
        if not (self.buttonStates[buttonName] ~= nil) then -- 532
            return -- 535
        end -- 535
        self.buttonStates[buttonName] = false -- 537
    end -- 530
end -- 516
function ButtonPressedTrigger.prototype.onUpdate(self, _) -- 540
    local allDown = true -- 541
    for ____, down in pairs(self.buttonStates) do -- 542
        if allDown then -- 542
            allDown = down -- 543
        end -- 543
    end -- 543
    if allDown then -- 543
        self.state = "Completed" -- 546
        self.progress = 1 -- 547
        if self.onChange then -- 547
            self:onChange() -- 549
        end -- 549
        self.progress = 0 -- 551
        self.state = "None" -- 552
    end -- 552
end -- 540
function ButtonPressedTrigger.prototype.start(self, manager) -- 555
    manager.controllerEnabled = true -- 556
    for ____, k in ipairs(self.buttons) do -- 557
        self.buttonStates[k] = false -- 558
    end -- 558
    manager:slot("ButtonDown", self.onButtonDown) -- 560
    manager:slot("ButtonUp", self.onButtonUp) -- 561
    self.state = "None" -- 562
    self.progress = 0 -- 563
end -- 555
function ButtonPressedTrigger.prototype.stop(self, manager) -- 565
    manager:slot("ButtonDown"):remove(self.onButtonDown) -- 566
    manager:slot("ButtonUp"):remove(self.onButtonUp) -- 567
    self.state = "None" -- 568
    self.progress = 0 -- 569
end -- 565
local ButtonHoldTrigger = __TS__Class() -- 573
ButtonHoldTrigger.name = "ButtonHoldTrigger" -- 573
__TS__ClassExtends(ButtonHoldTrigger, ____exports.Trigger) -- 573
function ButtonHoldTrigger.prototype.____constructor(self, button, holdTime, controllerId) -- 581
    ButtonHoldTrigger.____super.prototype.____constructor(self) -- 582
    self.controllerId = controllerId -- 583
    self.button = button -- 584
    self.holdTime = holdTime -- 585
    self.time = 0 -- 586
    self.onButtonDown = function(controllerId, buttonName) -- 587
        if self.controllerId ~= controllerId then -- 587
            return -- 589
        end -- 589
        if self.button == buttonName then -- 589
            self.time = 0 -- 592
            self.state = "Started" -- 593
            self.progress = 0 -- 594
            if self.onChange then -- 594
                self:onChange() -- 596
            end -- 596
        end -- 596
    end -- 587
    self.onButtonUp = function(controllerId, buttonName) -- 600
        if self.controllerId ~= controllerId then -- 600
            return -- 602
        end -- 602
        repeat -- 602
            local ____switch134 = self.state -- 602
            local ____cond134 = ____switch134 == "Started" or ____switch134 == "Ongoing" or ____switch134 == "Completed" -- 602
            if ____cond134 then -- 602
                break -- 608
            end -- 608
            do -- 608
                return -- 610
            end -- 610
        until true -- 610
        if self.button == buttonName then -- 610
            if self.state == "Completed" then -- 610
                self.state = "None" -- 614
            else -- 614
                self.state = "Canceled" -- 616
            end -- 616
            self.progress = 0 -- 618
            if self.onChange then -- 618
                self:onChange() -- 620
            end -- 620
        end -- 620
    end -- 600
end -- 581
function ButtonHoldTrigger.prototype.start(self, manager) -- 625
    manager.controllerEnabled = true -- 626
    manager:slot("ButtonDown", self.onButtonDown) -- 627
    manager:slot("ButtonUp", self.onButtonUp) -- 628
    self.state = "None" -- 629
    self.progress = 0 -- 630
end -- 625
function ButtonHoldTrigger.prototype.onUpdate(self, deltaTime) -- 632
    repeat -- 632
        local ____switch141 = self.state -- 632
        local ____cond141 = ____switch141 == "Started" or ____switch141 == "Ongoing" -- 632
        if ____cond141 then -- 632
            break -- 636
        end -- 636
        do -- 636
            return -- 638
        end -- 638
    until true -- 638
    self.time = self.time + deltaTime -- 640
    if self.time >= self.holdTime then -- 640
        self.state = "Completed" -- 642
        self.progress = 1 -- 643
    else -- 643
        self.state = "Ongoing" -- 645
        self.progress = math.min(self.time / self.holdTime, 1) -- 646
    end -- 646
    if self.onChange then -- 646
        self:onChange() -- 649
    end -- 649
end -- 632
function ButtonHoldTrigger.prototype.stop(self, manager) -- 652
    manager:slot("ButtonDown"):remove(self.onButtonDown) -- 653
    manager:slot("ButtonUp"):remove(self.onButtonUp) -- 654
    self.state = "None" -- 655
    self.progress = 0 -- 656
end -- 652
local ButtonTimedTrigger = __TS__Class() -- 660
ButtonTimedTrigger.name = "ButtonTimedTrigger" -- 660
__TS__ClassExtends(ButtonTimedTrigger, ____exports.Trigger) -- 660
function ButtonTimedTrigger.prototype.____constructor(self, button, timeWindow, controllerId) -- 667
    ButtonTimedTrigger.____super.prototype.____constructor(self) -- 668
    self.controllerId = controllerId -- 669
    self.button = button -- 670
    self.timeWindow = timeWindow -- 671
    self.time = 0 -- 672
    self.onButtonDown = function(controllerId, buttonName) -- 673
        if self.controllerId ~= controllerId then -- 673
            return -- 675
        end -- 675
        repeat -- 675
            local ____switch149 = self.state -- 675
            local ____cond149 = ____switch149 == "Started" or ____switch149 == "Ongoing" or ____switch149 == "Completed" -- 675
            if ____cond149 then -- 675
                break -- 681
            end -- 681
            do -- 681
                return -- 683
            end -- 683
        until true -- 683
        if self.button == buttonName and self.time <= self.timeWindow then -- 683
            self.state = "Completed" -- 686
            self.value = self.time -- 687
            if self.onChange then -- 687
                self:onChange() -- 689
            end -- 689
        end -- 689
    end -- 673
end -- 667
function ButtonTimedTrigger.prototype.start(self, manager) -- 694
    manager.controllerEnabled = true -- 695
    manager:slot("ButtonDown", self.onButtonDown) -- 696
    self.state = "Started" -- 697
    self.progress = 0 -- 698
    self.value = false -- 699
    if self.onChange then -- 699
        self:onChange() -- 701
    end -- 701
end -- 694
function ButtonTimedTrigger.prototype.onUpdate(self, deltaTime) -- 704
    repeat -- 704
        local ____switch155 = self.state -- 704
        local ____cond155 = ____switch155 == "Started" or ____switch155 == "Ongoing" or ____switch155 == "Completed" -- 704
        if ____cond155 then -- 704
            break -- 709
        end -- 709
        do -- 709
            return -- 711
        end -- 711
    until true -- 711
    self.time = self.time + deltaTime -- 713
    if self.time >= self.timeWindow then -- 713
        if self.state == "Completed" then -- 713
            self.state = "None" -- 716
            self.progress = 0 -- 717
        else -- 717
            self.state = "Canceled" -- 719
            self.progress = 1 -- 720
        end -- 720
    else -- 720
        self.state = "Ongoing" -- 723
        self.progress = math.min(self.time / self.timeWindow, 1) -- 724
    end -- 724
    if self.onChange then -- 724
        self:onChange() -- 727
    end -- 727
end -- 704
function ButtonTimedTrigger.prototype.stop(self, manager) -- 730
    manager:slot("ButtonDown"):remove(self.onButtonDown) -- 731
    self.state = "None" -- 732
    self.progress = 0 -- 733
end -- 730
local JoyStickTrigger = __TS__Class() -- 742
JoyStickTrigger.name = "JoyStickTrigger" -- 742
__TS__ClassExtends(JoyStickTrigger, ____exports.Trigger) -- 742
function JoyStickTrigger.prototype.____constructor(self, joyStickType, controllerId) -- 748
    JoyStickTrigger.____super.prototype.____constructor(self) -- 749
    self.joyStickType = joyStickType -- 750
    self.controllerId = controllerId -- 751
    self.axis = Vec2.zero -- 752
    self.onAxis = function(controllerId, axisName, value) -- 753
        if self.controllerId ~= controllerId then -- 753
            return -- 755
        end -- 755
        repeat -- 755
            local ____switch165 = self.joyStickType -- 755
            local ____cond165 = ____switch165 == "Left" -- 755
            if ____cond165 then -- 755
                do -- 755
                    repeat -- 755
                        local ____switch167 = axisName -- 755
                        local ____cond167 = ____switch167 == "leftx" -- 755
                        if ____cond167 then -- 755
                            self.axis = Vec2(value, self.axis.y) -- 761
                            break -- 762
                        end -- 762
                        ____cond167 = ____cond167 or ____switch167 == "lefty" -- 762
                        if ____cond167 then -- 762
                            self.axis = Vec2(self.axis.x, value) -- 764
                            break -- 765
                        end -- 765
                    until true -- 765
                    break -- 767
                end -- 767
            end -- 767
            ____cond165 = ____cond165 or ____switch165 == "Right" -- 767
            if ____cond165 then -- 767
                do -- 767
                    repeat -- 767
                        local ____switch169 = axisName -- 767
                        local ____cond169 = ____switch169 == "rightx" -- 767
                        if ____cond169 then -- 767
                            self.axis = Vec2(value, self.axis.y) -- 772
                            break -- 773
                        end -- 773
                        ____cond169 = ____cond169 or ____switch169 == "righty" -- 773
                        if ____cond169 then -- 773
                            self.axis = Vec2(self.axis.x, value) -- 775
                            break -- 776
                        end -- 776
                    until true -- 776
                    break -- 778
                end -- 778
            end -- 778
        until true -- 778
        self.value = self.axis -- 781
        if self:filterAxis() then -- 781
            self.state = "Completed" -- 783
        else -- 783
            self.state = "None" -- 785
        end -- 785
        if self.onChange then -- 785
            self:onChange() -- 788
        end -- 788
    end -- 753
end -- 748
function JoyStickTrigger.prototype.filterAxis(self) -- 792
    return true -- 793
end -- 792
function JoyStickTrigger.prototype.start(self, manager) -- 795
    self.state = "None" -- 796
    self.value = Vec2.zero -- 797
    manager:slot("Axis", self.onAxis) -- 798
end -- 795
function JoyStickTrigger.prototype.stop(self, manager) -- 800
    self.state = "None" -- 801
    self.value = Vec2.zero -- 802
    manager:slot("Axis"):remove(self.onAxis) -- 803
end -- 800
local JoyStickThresholdTrigger = __TS__Class() -- 807
JoyStickThresholdTrigger.name = "JoyStickThresholdTrigger" -- 807
__TS__ClassExtends(JoyStickThresholdTrigger, JoyStickTrigger) -- 807
function JoyStickThresholdTrigger.prototype.____constructor(self, joyStickType, threshold, controllerId) -- 810
    JoyStickTrigger.prototype.____constructor(self, joyStickType, controllerId) -- 811
    self.threshold = threshold -- 812
end -- 810
function JoyStickThresholdTrigger.prototype.filterAxis(self) -- 814
    return self.axis.length > self.threshold -- 815
end -- 814
local JoyStickDirectionalTrigger = __TS__Class() -- 819
JoyStickDirectionalTrigger.name = "JoyStickDirectionalTrigger" -- 819
__TS__ClassExtends(JoyStickDirectionalTrigger, JoyStickTrigger) -- 819
function JoyStickDirectionalTrigger.prototype.____constructor(self, joyStickType, angle, tolerance, controllerId) -- 823
    JoyStickTrigger.prototype.____constructor(self, joyStickType, controllerId) -- 824
    self.direction = angle -- 825
    self.tolerance = tolerance -- 826
end -- 823
function JoyStickDirectionalTrigger.prototype.filterAxis(self) -- 828
    local currentAngle = -math.deg(math.atan(self.axis.y, self.axis.x)) -- 829
    return math.abs(currentAngle - self.direction) <= self.tolerance -- 830
end -- 828
local JoyStickRangeTrigger = __TS__Class() -- 834
JoyStickRangeTrigger.name = "JoyStickRangeTrigger" -- 834
__TS__ClassExtends(JoyStickRangeTrigger, JoyStickTrigger) -- 834
function JoyStickRangeTrigger.prototype.____constructor(self, joyStickType, minRange, maxRange, controllerId) -- 838
    JoyStickTrigger.prototype.____constructor(self, joyStickType, controllerId) -- 839
    self.minRange = math.min(minRange, maxRange) -- 840
    self.maxRange = math.max(minRange, maxRange) -- 841
end -- 838
function JoyStickRangeTrigger.prototype.filterAxis(self) -- 843
    local magnitude = self.axis.length -- 844
    return magnitude >= self.minRange and magnitude <= self.maxRange -- 845
end -- 843
local SequenceTrigger = __TS__Class() -- 849
SequenceTrigger.name = "SequenceTrigger" -- 849
__TS__ClassExtends(SequenceTrigger, ____exports.Trigger) -- 849
function SequenceTrigger.prototype.____constructor(self, triggers) -- 852
    SequenceTrigger.____super.prototype.____constructor(self) -- 853
    self.triggers = triggers -- 854
    local ____self = self -- 855
    local function onStateChanged() -- 856
        ____self:onStateChanged() -- 857
    end -- 856
    for ____, trigger in ipairs(triggers) do -- 859
        trigger.onChange = onStateChanged -- 860
    end -- 860
end -- 852
function SequenceTrigger.prototype.onStateChanged(self) -- 863
    local completed = true -- 864
    for ____, trigger in ipairs(self.triggers) do -- 865
        if trigger.state ~= "Completed" then -- 865
            completed = false -- 867
            break -- 868
        end -- 868
    end -- 868
    if completed then -- 868
        self.state = "Completed" -- 872
        local newValue = {} -- 873
        for ____, trigger in ipairs(self.triggers) do -- 874
            if type(trigger.value) == "table" then -- 874
                if type(trigger.value) == "userdata" then -- 874
                    newValue[#newValue + 1] = trigger.value -- 877
                else -- 877
                    newValue = __TS__ArrayConcat(newValue, trigger.value) -- 879
                end -- 879
            else -- 879
                newValue[#newValue + 1] = trigger.value -- 882
            end -- 882
        end -- 882
        self.value = newValue -- 885
        self.progress = 1 -- 886
        if self.onChange then -- 886
            self:onChange() -- 888
        end -- 888
        return -- 890
    end -- 890
    local onGoing = false -- 892
    local minProgress = -1 -- 893
    for ____, trigger in ipairs(self.triggers) do -- 894
        if trigger.state == "Ongoing" then -- 894
            minProgress = minProgress < 0 and trigger.progress or math.min(minProgress, trigger.progress) -- 896
            onGoing = true -- 897
        end -- 897
    end -- 897
    if onGoing then -- 897
        self.state = "Ongoing" -- 901
        self.progress = minProgress -- 902
        if self.onChange then -- 902
            self:onChange() -- 904
        end -- 904
        return -- 906
    end -- 906
    for ____, trigger in ipairs(self.triggers) do -- 908
        if trigger.state == "Started" then -- 908
            self.state = "Started" -- 910
            self.progress = 0 -- 911
            if self.onChange then -- 911
                self:onChange() -- 913
            end -- 913
            return -- 915
        end -- 915
    end -- 915
    local canceled = false -- 918
    for ____, trigger in ipairs(self.triggers) do -- 919
        if trigger.state == "Canceled" then -- 919
            canceled = true -- 921
            break -- 922
        end -- 922
    end -- 922
    if canceled then -- 922
        self.state = "Canceled" -- 926
        self.progress = 0 -- 927
        if self.onChange then -- 927
            self:onChange() -- 929
        end -- 929
        return -- 931
    end -- 931
    self.state = "None" -- 933
    self.progress = 0 -- 934
    if self.onChange then -- 934
        self:onChange() -- 936
    end -- 936
end -- 863
function SequenceTrigger.prototype.start(self, manager) -- 939
    for ____, trigger in ipairs(self.triggers) do -- 940
        trigger:start(manager) -- 941
    end -- 941
end -- 939
function SequenceTrigger.prototype.onUpdate(self, deltaTime) -- 944
    for ____, trigger in ipairs(self.triggers) do -- 945
        if trigger.onUpdate then -- 945
            trigger:onUpdate(deltaTime) -- 947
        end -- 947
    end -- 947
end -- 944
function SequenceTrigger.prototype.stop(self, manager) -- 951
    for ____, trigger in ipairs(self.triggers) do -- 952
        trigger:stop(manager) -- 953
    end -- 953
end -- 951
local SelectorTrigger = __TS__Class() -- 958
SelectorTrigger.name = "SelectorTrigger" -- 958
__TS__ClassExtends(SelectorTrigger, ____exports.Trigger) -- 958
function SelectorTrigger.prototype.____constructor(self, triggers) -- 961
    SelectorTrigger.____super.prototype.____constructor(self) -- 962
    self.triggers = triggers -- 963
    local ____self = self -- 964
    local function onStateChanged() -- 965
        ____self:onStateChanged() -- 966
    end -- 965
    for ____, trigger in ipairs(triggers) do -- 968
        trigger.onChange = onStateChanged -- 969
    end -- 969
end -- 961
function SelectorTrigger.prototype.onStateChanged(self) -- 972
    for ____, trigger in ipairs(self.triggers) do -- 973
        if trigger.state == "Completed" then -- 973
            self.state = "Completed" -- 975
            self.progress = trigger.progress -- 976
            self.value = trigger.value -- 977
            if self.onChange then -- 977
                self:onChange() -- 979
            end -- 979
            return -- 981
        end -- 981
    end -- 981
    local onGoing = false -- 984
    local maxProgress = 0 -- 985
    for ____, trigger in ipairs(self.triggers) do -- 986
        if trigger.state == "Ongoing" then -- 986
            maxProgress = math.max(maxProgress, trigger.progress) -- 988
            onGoing = true -- 989
        end -- 989
    end -- 989
    if onGoing then -- 989
        self.state = "Ongoing" -- 993
        self.progress = maxProgress -- 994
        if self.onChange then -- 994
            self:onChange() -- 996
        end -- 996
        return -- 998
    end -- 998
    for ____, trigger in ipairs(self.triggers) do -- 1000
        if trigger.state == "Started" then -- 1000
            self.state = "Started" -- 1002
            self.progress = 0 -- 1003
            if self.onChange then -- 1003
                self:onChange() -- 1005
            end -- 1005
            return -- 1007
        end -- 1007
    end -- 1007
    local canceled = false -- 1010
    for ____, trigger in ipairs(self.triggers) do -- 1011
        if trigger.state == "Canceled" then -- 1011
            canceled = true -- 1013
            break -- 1014
        end -- 1014
    end -- 1014
    if canceled then -- 1014
        self.state = "Canceled" -- 1018
        self.progress = 0 -- 1019
        if self.onChange then -- 1019
            self:onChange() -- 1021
        end -- 1021
    end -- 1021
end -- 972
function SelectorTrigger.prototype.start(self, manager) -- 1025
    for ____, trigger in ipairs(self.triggers) do -- 1026
        trigger:start(manager) -- 1027
    end -- 1027
end -- 1025
function SelectorTrigger.prototype.onUpdate(self, deltaTime) -- 1030
    for ____, trigger in ipairs(self.triggers) do -- 1031
        if trigger.onUpdate then -- 1031
            trigger:onUpdate(deltaTime) -- 1033
        end -- 1033
    end -- 1033
end -- 1030
function SelectorTrigger.prototype.stop(self, manager) -- 1037
    for ____, trigger in ipairs(self.triggers) do -- 1038
        trigger:stop(manager) -- 1039
    end -- 1039
end -- 1037
local BlockTrigger = __TS__Class() -- 1044
BlockTrigger.name = "BlockTrigger" -- 1044
__TS__ClassExtends(BlockTrigger, ____exports.Trigger) -- 1044
function BlockTrigger.prototype.____constructor(self, trigger) -- 1047
    BlockTrigger.____super.prototype.____constructor(self) -- 1048
    self.trigger = trigger -- 1049
    local ____self = self -- 1050
    trigger.onChange = function() -- 1051
        ____self:onStateChanged() -- 1052
    end -- 1051
end -- 1047
function BlockTrigger.prototype.onStateChanged(self) -- 1055
    if self.trigger.state == "Completed" then -- 1055
        self.state = "Canceled" -- 1057
    else -- 1057
        self.state = "Completed" -- 1059
    end -- 1059
    if self.onChange then -- 1059
        self:onChange() -- 1062
    end -- 1062
end -- 1055
function BlockTrigger.prototype.start(self, manager) -- 1065
    self.state = "Completed" -- 1066
    self.trigger:start(manager) -- 1067
end -- 1065
function BlockTrigger.prototype.onUpdate(self, deltaTime) -- 1069
    if self.trigger.onUpdate then -- 1069
        self.trigger:onUpdate(deltaTime) -- 1071
    end -- 1071
end -- 1069
function BlockTrigger.prototype.stop(self, manager) -- 1074
    self.state = "Completed" -- 1075
    self.trigger:stop(manager) -- 1076
end -- 1074
do -- 1074
    function Trigger.KeyDown(combineKeys) -- 1081
        if type(combineKeys) == "string" then -- 1081
            combineKeys = {combineKeys} -- 1083
        end -- 1083
        return __TS__New(KeyDownTrigger, combineKeys) -- 1085
    end -- 1081
    function Trigger.KeyUp(combineKeys) -- 1087
        if type(combineKeys) == "string" then -- 1087
            combineKeys = {combineKeys} -- 1089
        end -- 1089
        return __TS__New(KeyUpTrigger, combineKeys) -- 1091
    end -- 1087
    function Trigger.KeyPressed(combineKeys) -- 1093
        if type(combineKeys) == "string" then -- 1093
            combineKeys = {combineKeys} -- 1095
        end -- 1095
        return __TS__New(KeyPressedTrigger, combineKeys) -- 1097
    end -- 1093
    function Trigger.KeyHold(keyName, holdTime) -- 1099
        return __TS__New(KeyHoldTrigger, keyName, holdTime) -- 1100
    end -- 1099
    function Trigger.KeyTimed(keyName, timeWindow) -- 1102
        return __TS__New(KeyTimedTrigger, keyName, timeWindow) -- 1103
    end -- 1102
    function Trigger.ButtonDown(combineButtons, controllerId) -- 1105
        if type(combineButtons) == "string" then -- 1105
            combineButtons = {combineButtons} -- 1107
        end -- 1107
        return __TS__New(ButtonDownTrigger, combineButtons, controllerId or 0) -- 1109
    end -- 1105
    function Trigger.ButtonUp(combineButtons, controllerId) -- 1111
        if type(combineButtons) == "string" then -- 1111
            combineButtons = {combineButtons} -- 1113
        end -- 1113
        return __TS__New(ButtonUpTrigger, combineButtons, controllerId or 0) -- 1115
    end -- 1111
    function Trigger.ButtonPressed(combineButtons, controllerId) -- 1117
        if type(combineButtons) == "string" then -- 1117
            combineButtons = {combineButtons} -- 1119
        end -- 1119
        return __TS__New(ButtonPressedTrigger, combineButtons, controllerId or 0) -- 1121
    end -- 1117
    function Trigger.ButtonHold(buttonName, holdTime, controllerId) -- 1123
        return __TS__New(ButtonHoldTrigger, buttonName, holdTime, controllerId or 0) -- 1124
    end -- 1123
    function Trigger.ButtonTimed(buttonName, timeWindow, controllerId) -- 1126
        return __TS__New(ButtonTimedTrigger, buttonName, timeWindow, controllerId or 0) -- 1127
    end -- 1126
    function Trigger.JoyStick(joyStickType, controllerId) -- 1129
        return __TS__New(JoyStickTrigger, joyStickType, controllerId or 0) -- 1130
    end -- 1129
    function Trigger.JoyStickThreshold(joyStickType, threshold, controllerId) -- 1132
        return __TS__New(JoyStickThresholdTrigger, joyStickType, threshold, controllerId or 0) -- 1133
    end -- 1132
    function Trigger.JoyStickDirectional(joyStickType, angle, tolerance, controllerId) -- 1135
        return __TS__New( -- 1136
            JoyStickDirectionalTrigger, -- 1136
            joyStickType, -- 1136
            angle, -- 1136
            tolerance, -- 1136
            controllerId or 0 -- 1136
        ) -- 1136
    end -- 1135
    function Trigger.JoyStickRange(joyStickType, minRange, maxRange, controllerId) -- 1138
        return __TS__New( -- 1139
            JoyStickRangeTrigger, -- 1139
            joyStickType, -- 1139
            minRange, -- 1139
            maxRange, -- 1139
            controllerId or 0 -- 1139
        ) -- 1139
    end -- 1138
    function Trigger.Sequence(triggers) -- 1141
        return __TS__New(SequenceTrigger, triggers) -- 1142
    end -- 1141
    function Trigger.Selector(triggers) -- 1144
        return __TS__New(SelectorTrigger, triggers) -- 1145
    end -- 1144
    function Trigger.Block(trigger) -- 1147
        return __TS__New(BlockTrigger, trigger) -- 1148
    end -- 1147
end -- 1147
local InputManager = __TS__Class() -- 1162
InputManager.name = "InputManager" -- 1162
function InputManager.prototype.____constructor(self, contexts) -- 1167
    self.manager = Node() -- 1168
    self.contextMap = __TS__New( -- 1169
        Map, -- 1169
        __TS__ArrayMap( -- 1169
            contexts, -- 1169
            function(____, ctx) -- 1169
                for ____, action in ipairs(ctx.actions) do -- 1170
                    local eventName = "Input." .. action.name -- 1171
                    action.trigger.onChange = function() -- 1172
                        local ____action_trigger_0 = action.trigger -- 1173
                        local state = ____action_trigger_0.state -- 1173
                        local progress = ____action_trigger_0.progress -- 1173
                        local value = ____action_trigger_0.value -- 1173
                        emit(eventName, state, progress, value) -- 1174
                    end -- 1172
                end -- 1172
                return {ctx.name, ctx.actions} -- 1177
            end -- 1169
        ) -- 1169
    ) -- 1169
    self.contextStack = {} -- 1179
    if self.contextMap:has("Default") then -- 1179
        self:pushContext({"Default"}) -- 1181
    end -- 1181
    self.manager:schedule(function(deltaTime) -- 1183
        if #self.contextStack > 0 then -- 1183
            local lastNames = self.contextStack[#self.contextStack] -- 1185
            for ____, name in ipairs(lastNames) do -- 1186
                do -- 1186
                    local actions = self.contextMap:get(name) -- 1187
                    if actions == nil then -- 1187
                        goto __continue298 -- 1189
                    end -- 1189
                    for ____, action in ipairs(actions) do -- 1191
                        if action.trigger.onUpdate then -- 1191
                            action.trigger:onUpdate(deltaTime) -- 1193
                        end -- 1193
                    end -- 1193
                end -- 1193
                ::__continue298:: -- 1193
            end -- 1193
        end -- 1193
        return false -- 1198
    end) -- 1183
end -- 1167
function InputManager.prototype.getNode(self) -- 1202
    return self.manager -- 1203
end -- 1202
function InputManager.prototype.pushContext(self, contextNames) -- 1206
    local exist = true -- 1207
    for ____, name in ipairs(contextNames) do -- 1208
        if exist then -- 1208
            exist = self.contextMap:has(name) -- 1209
        end -- 1209
    end -- 1209
    if not exist then -- 1209
        print("[Dora Error] got non-existed context name from " .. table.concat(contextNames, ", ")) -- 1212
        return false -- 1213
    else -- 1213
        if #self.contextStack > 0 then -- 1213
            local lastNames = self.contextStack[#self.contextStack] -- 1216
            for ____, name in ipairs(lastNames) do -- 1217
                do -- 1217
                    local actions = self.contextMap:get(name) -- 1218
                    if actions == nil then -- 1218
                        goto __continue311 -- 1220
                    end -- 1220
                    for ____, action in ipairs(actions) do -- 1222
                        action.trigger:stop(self.manager) -- 1223
                    end -- 1223
                end -- 1223
                ::__continue311:: -- 1223
            end -- 1223
        end -- 1223
        local ____self_contextStack_1 = self.contextStack -- 1223
        ____self_contextStack_1[#____self_contextStack_1 + 1] = contextNames -- 1227
        for ____, name in ipairs(contextNames) do -- 1228
            do -- 1228
                local actions = self.contextMap:get(name) -- 1229
                if actions == nil then -- 1229
                    goto __continue316 -- 1231
                end -- 1231
                for ____, action in ipairs(actions) do -- 1233
                    action.trigger:start(self.manager) -- 1234
                end -- 1234
            end -- 1234
            ::__continue316:: -- 1234
        end -- 1234
        return true -- 1237
    end -- 1237
end -- 1206
function InputManager.prototype.popContext(self) -- 1241
    if #self.contextStack == 0 then -- 1241
        return false -- 1243
    end -- 1243
    local lastNames = self.contextStack[#self.contextStack] -- 1245
    for ____, name in ipairs(lastNames) do -- 1246
        do -- 1246
            local actions = self.contextMap:get(name) -- 1247
            if actions == nil then -- 1247
                goto __continue323 -- 1249
            end -- 1249
            for ____, action in ipairs(actions) do -- 1251
                action.trigger:stop(self.manager) -- 1252
            end -- 1252
        end -- 1252
        ::__continue323:: -- 1252
    end -- 1252
    table.remove(self.contextStack) -- 1255
    if #self.contextStack > 0 then -- 1255
        local lastNames = self.contextStack[#self.contextStack] -- 1257
        for ____, name in ipairs(lastNames) do -- 1258
            do -- 1258
                local actions = self.contextMap:get(name) -- 1259
                if actions == nil then -- 1259
                    goto __continue329 -- 1261
                end -- 1261
                for ____, action in ipairs(actions) do -- 1263
                    action.trigger:start(self.manager) -- 1264
                end -- 1264
            end -- 1264
            ::__continue329:: -- 1264
        end -- 1264
    end -- 1264
    return true -- 1268
end -- 1241
function InputManager.prototype.emitKeyDown(self, keyName) -- 1271
    self.manager:emit("KeyDown", keyName) -- 1272
end -- 1271
function InputManager.prototype.emitKeyUp(self, keyName) -- 1275
    self.manager:emit("KeyUp", keyName) -- 1276
end -- 1275
function InputManager.prototype.emitButtonDown(self, buttonName, controllerId) -- 1279
    self.manager:emit("ButtonDown", controllerId or 0, buttonName) -- 1280
end -- 1279
function InputManager.prototype.emitButtonUp(self, buttonName, controllerId) -- 1283
    self.manager:emit("ButtonUp", controllerId or 0, buttonName) -- 1284
end -- 1283
function InputManager.prototype.emitAxis(self, axisName, value, controllerId) -- 1287
    self.manager:emit("Axis", controllerId or 0, axisName, value) -- 1288
end -- 1287
function ____exports.CreateInputManager(contexts) -- 1292
    return __TS__New(InputManager, contexts) -- 1293
end -- 1292
function ____exports.DPad(self, props) -- 1305
    local ____props_2 = props -- 1312
    local width = ____props_2.width -- 1312
    if width == nil then -- 1312
        width = 40 -- 1307
    end -- 1307
    local height = ____props_2.height -- 1307
    if height == nil then -- 1307
        height = 40 -- 1308
    end -- 1308
    local offset = ____props_2.offset -- 1308
    if offset == nil then -- 1308
        offset = 5 -- 1309
    end -- 1309
    local color = ____props_2.color -- 1309
    if color == nil then -- 1309
        color = 4294967295 -- 1310
    end -- 1310
    local primaryOpacity = ____props_2.primaryOpacity -- 1310
    if primaryOpacity == nil then -- 1310
        primaryOpacity = 0.3 -- 1311
    end -- 1311
    local halfSize = height + width / 2 + offset -- 1313
    local dOffset = height / 2 + width / 2 + offset -- 1314
    local function DPadButton(self, props) -- 1316
        local hw = width / 2 -- 1317
        local drawNode = useRef() -- 1318
        return React:createElement( -- 1319
            "node", -- 1319
            __TS__ObjectAssign( -- 1319
                {}, -- 1319
                props, -- 1320
                { -- 1320
                    width = width, -- 1320
                    height = height, -- 1320
                    onTapBegan = function() -- 1320
                        if drawNode.current then -- 1320
                            drawNode.current.opacity = 1 -- 1323
                        end -- 1323
                    end, -- 1321
                    onTapEnded = function() -- 1321
                        if drawNode.current then -- 1321
                            drawNode.current.opacity = primaryOpacity -- 1328
                        end -- 1328
                    end -- 1326
                } -- 1326
            ), -- 1326
            React:createElement( -- 1326
                "draw-node", -- 1326
                {ref = drawNode, y = -hw, x = hw, opacity = primaryOpacity}, -- 1326
                React:createElement( -- 1326
                    "polygon-shape", -- 1326
                    { -- 1326
                        verts = { -- 1326
                            Vec2(-hw, hw + height), -- 1334
                            Vec2(hw, hw + height), -- 1335
                            Vec2(hw, hw), -- 1336
                            Vec2.zero, -- 1337
                            Vec2(-hw, hw) -- 1338
                        }, -- 1338
                        fillColor = color -- 1338
                    } -- 1338
                ) -- 1338
            ) -- 1338
        ) -- 1338
    end -- 1316
    local function onMount(buttonName) -- 1345
        return function(node) -- 1346
            node:slot( -- 1347
                "TapBegan", -- 1347
                function() return props.inputManager:emitButtonDown(buttonName) end -- 1347
            ) -- 1347
            node:slot( -- 1348
                "TapEnded", -- 1348
                function() return props.inputManager:emitButtonUp(buttonName) end -- 1348
            ) -- 1348
        end -- 1346
    end -- 1345
    return React:createElement( -- 1352
        "align-node", -- 1352
        {style = {width = halfSize * 2, height = halfSize * 2}}, -- 1352
        React:createElement( -- 1352
            "menu", -- 1352
            {x = halfSize, y = halfSize, width = halfSize * 2, height = halfSize * 2}, -- 1352
            React:createElement( -- 1352
                DPadButton, -- 1355
                { -- 1355
                    x = halfSize, -- 1355
                    y = dOffset + halfSize, -- 1355
                    onMount = onMount("dpup") -- 1355
                } -- 1355
            ), -- 1355
            React:createElement( -- 1355
                DPadButton, -- 1356
                { -- 1356
                    x = halfSize, -- 1356
                    y = -dOffset + halfSize, -- 1356
                    angle = 180, -- 1356
                    onMount = onMount("dpdown") -- 1356
                } -- 1356
            ), -- 1356
            React:createElement( -- 1356
                DPadButton, -- 1357
                { -- 1357
                    x = dOffset + halfSize, -- 1357
                    y = halfSize, -- 1357
                    angle = 90, -- 1357
                    onMount = onMount("dpright") -- 1357
                } -- 1357
            ), -- 1357
            React:createElement( -- 1357
                DPadButton, -- 1358
                { -- 1358
                    x = -dOffset + halfSize, -- 1358
                    y = halfSize, -- 1358
                    angle = -90, -- 1358
                    onMount = onMount("dpleft") -- 1358
                } -- 1358
            ) -- 1358
        ) -- 1358
    ) -- 1358
end -- 1305
function ____exports.JoyStick(self, props) -- 1374
    local hat = useRef() -- 1375
    local ____props_3 = props -- 1383
    local moveSize = ____props_3.moveSize -- 1383
    if moveSize == nil then -- 1383
        moveSize = 70 -- 1377
    end -- 1377
    local hatSize = ____props_3.hatSize -- 1377
    if hatSize == nil then -- 1377
        hatSize = 40 -- 1378
    end -- 1378
    local stickType = ____props_3.stickType -- 1378
    if stickType == nil then -- 1378
        stickType = "Left" -- 1379
    end -- 1379
    local color = ____props_3.color -- 1379
    if color == nil then -- 1379
        color = 4294967295 -- 1380
    end -- 1380
    local primaryOpacity = ____props_3.primaryOpacity -- 1380
    if primaryOpacity == nil then -- 1380
        primaryOpacity = 0.3 -- 1381
    end -- 1381
    local secondaryOpacity = ____props_3.secondaryOpacity -- 1381
    if secondaryOpacity == nil then -- 1381
        secondaryOpacity = 0.1 -- 1382
    end -- 1382
    local visualBound = math.max(moveSize - hatSize, 0) -- 1384
    local function updatePosition(node, location) -- 1386
        if location.length > visualBound then -- 1386
            node.position = location:normalize():mul(visualBound) -- 1388
        else -- 1388
            node.position = location -- 1390
        end -- 1390
        repeat -- 1390
            local ____switch354 = stickType -- 1390
            local ____cond354 = ____switch354 == "Left" -- 1390
            if ____cond354 then -- 1390
                props.inputManager:emitAxis("leftx", node.x / visualBound) -- 1394
                props.inputManager:emitAxis("lefty", node.y / visualBound) -- 1395
                break -- 1396
            end -- 1396
            ____cond354 = ____cond354 or ____switch354 == "Right" -- 1396
            if ____cond354 then -- 1396
                props.inputManager:emitAxis("rightx", node.x / visualBound) -- 1398
                props.inputManager:emitAxis("righty", node.y / visualBound) -- 1399
                break -- 1400
            end -- 1400
        until true -- 1400
    end -- 1386
    return React:createElement( -- 1404
        "align-node", -- 1404
        {style = {width = moveSize * 2, height = moveSize * 2}}, -- 1404
        React:createElement( -- 1404
            "node", -- 1404
            { -- 1404
                x = moveSize, -- 1404
                y = moveSize, -- 1404
                onTapFilter = function(touch) -- 1404
                    local ____touch_4 = touch -- 1408
                    local location = ____touch_4.location -- 1408
                    if location.length > moveSize then -- 1408
                        touch.enabled = false -- 1410
                    end -- 1410
                end, -- 1407
                onTapBegan = function(touch) -- 1407
                    if hat.current then -- 1407
                        hat.current.opacity = 1 -- 1415
                        updatePosition(hat.current, touch.location) -- 1416
                    end -- 1416
                end, -- 1413
                onTapMoved = function(touch) -- 1413
                    if hat.current then -- 1413
                        hat.current.opacity = 1 -- 1421
                        updatePosition(hat.current, touch.location) -- 1422
                    end -- 1422
                end, -- 1419
                onTapped = function() -- 1419
                    if hat.current then -- 1419
                        hat.current.opacity = primaryOpacity -- 1427
                        updatePosition(hat.current, Vec2.zero) -- 1428
                    end -- 1428
                end -- 1425
            }, -- 1425
            React:createElement( -- 1425
                "draw-node", -- 1425
                {opacity = secondaryOpacity}, -- 1425
                React:createElement("dot-shape", {radius = moveSize, color = color}) -- 1425
            ), -- 1425
            React:createElement( -- 1425
                "draw-node", -- 1425
                {ref = hat, opacity = primaryOpacity}, -- 1425
                React:createElement("dot-shape", {radius = hatSize, color = color}) -- 1425
            ) -- 1425
        ) -- 1425
    ) -- 1425
end -- 1374
function ____exports.ButtonPad(self, props) -- 1452
    local ____props_5 = props -- 1459
    local buttonSize = ____props_5.buttonSize -- 1459
    if buttonSize == nil then -- 1459
        buttonSize = 30 -- 1454
    end -- 1454
    local buttonPadding = ____props_5.buttonPadding -- 1454
    if buttonPadding == nil then -- 1454
        buttonPadding = 10 -- 1455
    end -- 1455
    local fontName = ____props_5.fontName -- 1455
    if fontName == nil then -- 1455
        fontName = "sarasa-mono-sc-regular" -- 1456
    end -- 1456
    local color = ____props_5.color -- 1456
    if color == nil then -- 1456
        color = 4294967295 -- 1457
    end -- 1457
    local primaryOpacity = ____props_5.primaryOpacity -- 1457
    if primaryOpacity == nil then -- 1457
        primaryOpacity = 0.3 -- 1458
    end -- 1458
    local function Button(self, props) -- 1460
        local drawNode = useRef() -- 1461
        return React:createElement( -- 1462
            "node", -- 1462
            __TS__ObjectAssign( -- 1462
                {}, -- 1462
                props, -- 1463
                { -- 1463
                    width = buttonSize * 2, -- 1463
                    height = buttonSize * 2, -- 1463
                    onTapBegan = function() -- 1463
                        if drawNode.current then -- 1463
                            drawNode.current.opacity = 1 -- 1466
                        end -- 1466
                    end, -- 1464
                    onTapEnded = function() -- 1464
                        if drawNode.current then -- 1464
                            drawNode.current.opacity = primaryOpacity -- 1471
                        end -- 1471
                    end -- 1469
                } -- 1469
            ), -- 1469
            React:createElement( -- 1469
                "draw-node", -- 1469
                {ref = drawNode, x = buttonSize, y = buttonSize, opacity = primaryOpacity}, -- 1469
                React:createElement("dot-shape", {radius = buttonSize, color = color}) -- 1469
            ), -- 1469
            React:createElement("label", { -- 1469
                x = buttonSize, -- 1469
                y = buttonSize, -- 1469
                scaleX = 0.5, -- 1469
                scaleY = 0.5, -- 1469
                color3 = color, -- 1469
                opacity = primaryOpacity + 0.2, -- 1469
                fontName = fontName, -- 1469
                fontSize = buttonSize * 2 -- 1469
            }, props.text) -- 1469
        ) -- 1469
    end -- 1460
    local width = buttonSize * 5 + buttonPadding * 3 / 2 -- 1483
    local height = buttonSize * 4 + buttonPadding -- 1484
    local function onMount(buttonName) -- 1485
        return function(node) -- 1486
            node:slot( -- 1487
                "TapBegan", -- 1487
                function() return props.inputManager:emitButtonDown(buttonName) end -- 1487
            ) -- 1487
            node:slot( -- 1488
                "TapEnded", -- 1488
                function() return props.inputManager:emitButtonUp(buttonName) end -- 1488
            ) -- 1488
        end -- 1486
    end -- 1485
    return React:createElement( -- 1491
        "align-node", -- 1491
        {style = {width = width, height = height}}, -- 1491
        React:createElement( -- 1491
            "node", -- 1491
            {x = (buttonSize + buttonPadding / 2) / 2 + width / 2, y = buttonSize + buttonPadding / 2 + height / 2}, -- 1491
            React:createElement( -- 1491
                Button, -- 1497
                { -- 1497
                    text = "B", -- 1497
                    x = -buttonSize * 2 - buttonPadding, -- 1497
                    onMount = onMount("b") -- 1497
                } -- 1497
            ), -- 1497
            React:createElement( -- 1497
                Button, -- 1501
                { -- 1501
                    text = "Y", -- 1501
                    onMount = onMount("y") -- 1501
                } -- 1501
            ), -- 1501
            React:createElement( -- 1501
                Button, -- 1502
                { -- 1502
                    text = "A", -- 1502
                    x = -buttonSize - buttonPadding / 2, -- 1502
                    y = -buttonSize * 2 - buttonPadding, -- 1502
                    onMount = onMount("a") -- 1502
                } -- 1502
            ), -- 1502
            React:createElement( -- 1502
                Button, -- 1507
                { -- 1507
                    text = "X", -- 1507
                    x = buttonSize + buttonPadding / 2, -- 1507
                    y = -buttonSize * 2 - buttonPadding, -- 1507
                    onMount = onMount("x") -- 1507
                } -- 1507
            ) -- 1507
        ) -- 1507
    ) -- 1507
end -- 1452
function ____exports.ControlPad(self, props) -- 1525
    local ____props_6 = props -- 1531
    local buttonSize = ____props_6.buttonSize -- 1531
    if buttonSize == nil then -- 1531
        buttonSize = 35 -- 1527
    end -- 1527
    local fontName = ____props_6.fontName -- 1527
    if fontName == nil then -- 1527
        fontName = "sarasa-mono-sc-regular" -- 1528
    end -- 1528
    local color = ____props_6.color -- 1528
    if color == nil then -- 1528
        color = 4294967295 -- 1529
    end -- 1529
    local primaryOpacity = ____props_6.primaryOpacity -- 1529
    if primaryOpacity == nil then -- 1529
        primaryOpacity = 0.3 -- 1530
    end -- 1530
    local function Button(self, props) -- 1532
        local drawNode = useRef() -- 1533
        return React:createElement( -- 1534
            "node", -- 1534
            __TS__ObjectAssign( -- 1534
                {}, -- 1534
                props, -- 1535
                { -- 1535
                    width = buttonSize * 2, -- 1535
                    height = buttonSize, -- 1535
                    onTapBegan = function() -- 1535
                        if drawNode.current then -- 1535
                            drawNode.current.opacity = 1 -- 1538
                        end -- 1538
                    end, -- 1536
                    onTapEnded = function() -- 1536
                        if drawNode.current then -- 1536
                            drawNode.current.opacity = primaryOpacity -- 1543
                        end -- 1543
                    end -- 1541
                } -- 1541
            ), -- 1541
            React:createElement( -- 1541
                "draw-node", -- 1541
                {ref = drawNode, x = buttonSize, y = buttonSize / 2, opacity = primaryOpacity}, -- 1541
                React:createElement("rect-shape", {width = buttonSize * 2, height = buttonSize, fillColor = color}) -- 1541
            ), -- 1541
            React:createElement( -- 1541
                "label", -- 1541
                { -- 1541
                    x = buttonSize, -- 1541
                    y = buttonSize / 2, -- 1541
                    scaleX = 0.5, -- 1541
                    scaleY = 0.5, -- 1541
                    fontName = fontName, -- 1541
                    fontSize = math.floor(buttonSize * 1.5), -- 1541
                    color3 = color, -- 1541
                    opacity = primaryOpacity + 0.2 -- 1541
                }, -- 1541
                props.text -- 1552
            ) -- 1552
        ) -- 1552
    end -- 1532
    local function onMount(buttonName) -- 1556
        return function(node) -- 1557
            node:slot( -- 1558
                "TapBegan", -- 1558
                function() return props.inputManager:emitButtonDown(buttonName) end -- 1558
            ) -- 1558
            node:slot( -- 1559
                "TapEnded", -- 1559
                function() return props.inputManager:emitButtonUp(buttonName) end -- 1559
            ) -- 1559
        end -- 1557
    end -- 1556
    return React:createElement( -- 1562
        "align-node", -- 1562
        {style = {minWidth = buttonSize * 4 + 20, justifyContent = "space-between", flexDirection = "row"}}, -- 1562
        React:createElement( -- 1562
            "align-node", -- 1562
            {style = {width = buttonSize * 2, height = buttonSize}}, -- 1562
            React:createElement( -- 1562
                Button, -- 1565
                { -- 1565
                    text = "Start", -- 1565
                    x = buttonSize, -- 1565
                    y = buttonSize / 2, -- 1565
                    onMount = onMount("start") -- 1565
                } -- 1565
            ) -- 1565
        ), -- 1565
        React:createElement( -- 1565
            "align-node", -- 1565
            {style = {width = buttonSize * 2, height = buttonSize}}, -- 1565
            React:createElement( -- 1565
                Button, -- 1571
                { -- 1571
                    text = "Back", -- 1571
                    x = buttonSize, -- 1571
                    y = buttonSize / 2, -- 1571
                    onMount = onMount("back") -- 1571
                } -- 1571
            ) -- 1571
        ) -- 1571
    ) -- 1571
end -- 1525
function ____exports.TriggerPad(self, props) -- 1588
    local ____props_7 = props -- 1594
    local buttonSize = ____props_7.buttonSize -- 1594
    if buttonSize == nil then -- 1594
        buttonSize = 35 -- 1590
    end -- 1590
    local fontName = ____props_7.fontName -- 1590
    if fontName == nil then -- 1590
        fontName = "sarasa-mono-sc-regular" -- 1591
    end -- 1591
    local color = ____props_7.color -- 1591
    if color == nil then -- 1591
        color = 4294967295 -- 1592
    end -- 1592
    local primaryOpacity = ____props_7.primaryOpacity -- 1592
    if primaryOpacity == nil then -- 1592
        primaryOpacity = 0.3 -- 1593
    end -- 1593
    local function Button(self, props) -- 1595
        local drawNode = useRef() -- 1596
        return React:createElement( -- 1597
            "node", -- 1597
            __TS__ObjectAssign( -- 1597
                {}, -- 1597
                props, -- 1598
                { -- 1598
                    width = buttonSize * 2, -- 1598
                    height = buttonSize, -- 1598
                    onTapBegan = function() -- 1598
                        if drawNode.current then -- 1598
                            drawNode.current.opacity = 1 -- 1601
                        end -- 1601
                    end, -- 1599
                    onTapEnded = function() -- 1599
                        if drawNode.current then -- 1599
                            drawNode.current.opacity = primaryOpacity -- 1606
                        end -- 1606
                    end -- 1604
                } -- 1604
            ), -- 1604
            React:createElement( -- 1604
                "draw-node", -- 1604
                {ref = drawNode, x = buttonSize, y = buttonSize / 2, opacity = primaryOpacity}, -- 1604
                React:createElement("rect-shape", {width = buttonSize * 2, height = buttonSize, fillColor = color}) -- 1604
            ), -- 1604
            React:createElement( -- 1604
                "label", -- 1604
                { -- 1604
                    x = buttonSize, -- 1604
                    y = buttonSize / 2, -- 1604
                    scaleX = 0.5, -- 1604
                    scaleY = 0.5, -- 1604
                    fontName = fontName, -- 1604
                    fontSize = math.floor(buttonSize * 1.5), -- 1604
                    color3 = color, -- 1604
                    opacity = primaryOpacity + 0.2 -- 1604
                }, -- 1604
                props.text -- 1614
            ) -- 1614
        ) -- 1614
    end -- 1595
    local function onMount(axisName) -- 1618
        return function(node) -- 1619
            node:slot( -- 1620
                "TapBegan", -- 1620
                function() return props.inputManager:emitAxis(axisName, 1, 0) end -- 1620
            ) -- 1620
            node:slot( -- 1621
                "TapEnded", -- 1621
                function() return props.inputManager:emitAxis(axisName, 0, 0) end -- 1621
            ) -- 1621
        end -- 1619
    end -- 1618
    return React:createElement( -- 1624
        "align-node", -- 1624
        {style = {minWidth = buttonSize * 4 + 20, justifyContent = "space-between", flexDirection = "row"}}, -- 1624
        React:createElement( -- 1624
            "align-node", -- 1624
            {style = {width = buttonSize * 2, height = buttonSize}}, -- 1624
            React:createElement( -- 1624
                Button, -- 1627
                { -- 1627
                    text = "LT", -- 1627
                    x = buttonSize, -- 1627
                    y = buttonSize / 2, -- 1627
                    onMount = onMount("lefttrigger") -- 1627
                } -- 1627
            ) -- 1627
        ), -- 1627
        React:createElement( -- 1627
            "align-node", -- 1627
            {style = {width = buttonSize * 2, height = buttonSize}}, -- 1627
            React:createElement( -- 1627
                Button, -- 1633
                { -- 1633
                    text = "RT", -- 1633
                    x = buttonSize, -- 1633
                    y = buttonSize / 2, -- 1633
                    onMount = onMount("righttrigger") -- 1633
                } -- 1633
            ) -- 1633
        ) -- 1633
    ) -- 1633
end -- 1588
function ____exports.GamePad(self, props) -- 1655
    local ____props_8 = props -- 1656
    local color = ____props_8.color -- 1656
    local primaryOpacity = ____props_8.primaryOpacity -- 1656
    local secondaryOpacity = ____props_8.secondaryOpacity -- 1656
    local inputManager = ____props_8.inputManager -- 1656
    local ____React_27 = React -- 1656
    local ____React_createElement_28 = React.createElement -- 1656
    local ____temp_25 = {style = {flexDirection = "column-reverse"}, windowRoot = true} -- 1656
    local ____React_21 = React -- 1656
    local ____React_createElement_22 = React.createElement -- 1656
    local ____temp_19 = {style = {margin = 20, justifyContent = "space-between", flexDirection = "row", alignItems = "flex-end"}} -- 1656
    local ____React_12 = React -- 1656
    local ____React_createElement_13 = React.createElement -- 1656
    local ____temp_11 = {style = {justifyContent = "space-between", flexDirection = "row", alignItems = "flex-end"}} -- 1656
    local ____props_noDPad_9 -- 1670
    if props.noDPad then -- 1670
        ____props_noDPad_9 = nil -- 1670
    else -- 1670
        ____props_noDPad_9 = React:createElement(____exports.DPad, {color = color, primaryOpacity = primaryOpacity, inputManager = inputManager}) -- 1670
    end -- 1670
    local ____props_noLeftStick_10 -- 1677
    if props.noLeftStick then -- 1677
        ____props_noLeftStick_10 = nil -- 1677
    else -- 1677
        ____props_noLeftStick_10 = React:createElement( -- 1677
            React.Fragment, -- 1677
            nil, -- 1677
            React:createElement("align-node", {style = {width = 10}}), -- 1677
            React:createElement(____exports.JoyStick, { -- 1677
                stickType = "Left", -- 1677
                color = color, -- 1677
                primaryOpacity = primaryOpacity, -- 1677
                secondaryOpacity = secondaryOpacity, -- 1677
                inputManager = inputManager -- 1677
            }) -- 1677
        ) -- 1677
    end -- 1677
    local ____React_createElement_13_result_20 = ____React_createElement_13( -- 1677
        ____React_12, -- 1677
        "align-node", -- 1677
        ____temp_11, -- 1677
        ____props_noDPad_9, -- 1677
        ____props_noLeftStick_10 -- 1677
    ) -- 1677
    local ____React_17 = React -- 1677
    local ____React_createElement_18 = React.createElement -- 1677
    local ____temp_16 = {style = {justifyContent = "space-between", flexDirection = "row", alignItems = "flex-end"}} -- 1677
    local ____props_noRightStick_14 -- 1693
    if props.noRightStick then -- 1693
        ____props_noRightStick_14 = nil -- 1693
    else -- 1693
        ____props_noRightStick_14 = React:createElement( -- 1693
            React.Fragment, -- 1693
            nil, -- 1693
            React:createElement(____exports.JoyStick, {stickType = "Right", color = color, primaryOpacity = primaryOpacity, inputManager = inputManager}), -- 1693
            React:createElement("align-node", {style = {width = 10}}) -- 1693
        ) -- 1693
    end -- 1693
    local ____props_noButtonPad_15 -- 1702
    if props.noButtonPad then -- 1702
        ____props_noButtonPad_15 = nil -- 1702
    else -- 1702
        ____props_noButtonPad_15 = React:createElement(____exports.ButtonPad, {color = color, primaryOpacity = primaryOpacity, inputManager = inputManager}) -- 1702
    end -- 1702
    local ____React_createElement_22_result_26 = ____React_createElement_22( -- 1702
        ____React_21, -- 1702
        "align-node", -- 1702
        ____temp_19, -- 1702
        ____React_createElement_13_result_20, -- 1702
        ____React_createElement_18( -- 1702
            ____React_17, -- 1702
            "align-node", -- 1702
            ____temp_16, -- 1702
            ____props_noRightStick_14, -- 1702
            ____props_noButtonPad_15 -- 1702
        ) -- 1702
    ) -- 1702
    local ____props_noTriggerPad_23 -- 1711
    if props.noTriggerPad then -- 1711
        ____props_noTriggerPad_23 = nil -- 1711
    else -- 1711
        ____props_noTriggerPad_23 = React:createElement( -- 1711
            "align-node", -- 1711
            {style = {paddingLeft = 20, paddingRight = 20, paddingTop = 20}}, -- 1711
            React:createElement(____exports.TriggerPad, {color = color, primaryOpacity = primaryOpacity, inputManager = inputManager}) -- 1711
        ) -- 1711
    end -- 1711
    local ____props_noControlPad_24 -- 1720
    if props.noControlPad then -- 1720
        ____props_noControlPad_24 = nil -- 1720
    else -- 1720
        ____props_noControlPad_24 = React:createElement( -- 1720
            "align-node", -- 1720
            {style = {paddingLeft = 20, paddingRight = 20}}, -- 1720
            React:createElement(____exports.ControlPad, {color = color, primaryOpacity = primaryOpacity, inputManager = inputManager}) -- 1720
        ) -- 1720
    end -- 1720
    return ____React_createElement_28( -- 1657
        ____React_27, -- 1657
        "align-node", -- 1657
        ____temp_25, -- 1657
        ____React_createElement_22_result_26, -- 1657
        ____props_noTriggerPad_23, -- 1657
        ____props_noControlPad_24 -- 1657
    ) -- 1657
end -- 1655
return ____exports -- 1655