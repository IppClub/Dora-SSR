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
    self.manager:schedule(function(deltaTime) -- 1180
        if #self.contextStack > 0 then -- 1180
            local lastNames = self.contextStack[#self.contextStack] -- 1182
            for ____, name in ipairs(lastNames) do -- 1183
                do -- 1183
                    local actions = self.contextMap:get(name) -- 1184
                    if actions == nil then -- 1184
                        goto __continue297 -- 1186
                    end -- 1186
                    for ____, action in ipairs(actions) do -- 1188
                        if action.trigger.onUpdate then -- 1188
                            action.trigger:onUpdate(deltaTime) -- 1190
                        end -- 1190
                    end -- 1190
                end -- 1190
                ::__continue297:: -- 1190
            end -- 1190
        end -- 1190
        return false -- 1195
    end) -- 1180
end -- 1167
function InputManager.prototype.getNode(self) -- 1199
    return self.manager -- 1200
end -- 1199
function InputManager.prototype.pushContext(self, contextNames) -- 1203
    if type(contextNames) == "string" then -- 1203
        contextNames = {contextNames} -- 1205
    end -- 1205
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
end -- 1203
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
function InputManager.prototype.destroy(self) -- 1291
    self:getNode():removeFromParent() -- 1292
    self.contextStack = {} -- 1293
end -- 1291
function ____exports.CreateInputManager(contexts) -- 1297
    return __TS__New(InputManager, contexts) -- 1298
end -- 1297
function ____exports.DPad(self, props) -- 1310
    local ____props_2 = props -- 1317
    local width = ____props_2.width -- 1317
    if width == nil then -- 1317
        width = 40 -- 1312
    end -- 1312
    local height = ____props_2.height -- 1312
    if height == nil then -- 1312
        height = 40 -- 1313
    end -- 1313
    local offset = ____props_2.offset -- 1313
    if offset == nil then -- 1313
        offset = 5 -- 1314
    end -- 1314
    local color = ____props_2.color -- 1314
    if color == nil then -- 1314
        color = 4294967295 -- 1315
    end -- 1315
    local primaryOpacity = ____props_2.primaryOpacity -- 1315
    if primaryOpacity == nil then -- 1315
        primaryOpacity = 0.3 -- 1316
    end -- 1316
    local halfSize = height + width / 2 + offset -- 1318
    local dOffset = height / 2 + width / 2 + offset -- 1319
    local function DPadButton(self, props) -- 1321
        local hw = width / 2 -- 1322
        local drawNode = useRef() -- 1323
        return React:createElement( -- 1324
            "node", -- 1324
            __TS__ObjectAssign( -- 1324
                {}, -- 1324
                props, -- 1325
                { -- 1325
                    width = width, -- 1325
                    height = height, -- 1325
                    onTapBegan = function() -- 1325
                        if drawNode.current then -- 1325
                            drawNode.current.opacity = 1 -- 1328
                        end -- 1328
                    end, -- 1326
                    onTapEnded = function() -- 1326
                        if drawNode.current then -- 1326
                            drawNode.current.opacity = primaryOpacity -- 1333
                        end -- 1333
                    end -- 1331
                } -- 1331
            ), -- 1331
            React:createElement( -- 1331
                "draw-node", -- 1331
                {ref = drawNode, y = -hw, x = hw, opacity = primaryOpacity}, -- 1331
                React:createElement( -- 1331
                    "polygon-shape", -- 1331
                    { -- 1331
                        verts = { -- 1331
                            Vec2(-hw, hw + height), -- 1339
                            Vec2(hw, hw + height), -- 1340
                            Vec2(hw, hw), -- 1341
                            Vec2.zero, -- 1342
                            Vec2(-hw, hw) -- 1343
                        }, -- 1343
                        fillColor = color -- 1343
                    } -- 1343
                ) -- 1343
            ) -- 1343
        ) -- 1343
    end -- 1321
    local function onMount(buttonName) -- 1350
        return function(node) -- 1351
            node:slot( -- 1352
                "TapBegan", -- 1352
                function() return props.inputManager:emitButtonDown(buttonName) end -- 1352
            ) -- 1352
            node:slot( -- 1353
                "TapEnded", -- 1353
                function() return props.inputManager:emitButtonUp(buttonName) end -- 1353
            ) -- 1353
        end -- 1351
    end -- 1350
    return React:createElement( -- 1357
        "align-node", -- 1357
        {style = {width = halfSize * 2, height = halfSize * 2}}, -- 1357
        React:createElement( -- 1357
            "menu", -- 1357
            {x = halfSize, y = halfSize, width = halfSize * 2, height = halfSize * 2}, -- 1357
            React:createElement( -- 1357
                DPadButton, -- 1360
                { -- 1360
                    x = halfSize, -- 1360
                    y = dOffset + halfSize, -- 1360
                    onMount = onMount("dpup") -- 1360
                } -- 1360
            ), -- 1360
            React:createElement( -- 1360
                DPadButton, -- 1361
                { -- 1361
                    x = halfSize, -- 1361
                    y = -dOffset + halfSize, -- 1361
                    angle = 180, -- 1361
                    onMount = onMount("dpdown") -- 1361
                } -- 1361
            ), -- 1361
            React:createElement( -- 1361
                DPadButton, -- 1362
                { -- 1362
                    x = dOffset + halfSize, -- 1362
                    y = halfSize, -- 1362
                    angle = 90, -- 1362
                    onMount = onMount("dpright") -- 1362
                } -- 1362
            ), -- 1362
            React:createElement( -- 1362
                DPadButton, -- 1363
                { -- 1363
                    x = -dOffset + halfSize, -- 1363
                    y = halfSize, -- 1363
                    angle = -90, -- 1363
                    onMount = onMount("dpleft") -- 1363
                } -- 1363
            ) -- 1363
        ) -- 1363
    ) -- 1363
end -- 1310
local function Button(self, props) -- 1380
    local ____props_3 = props -- 1388
    local x = ____props_3.x -- 1388
    local y = ____props_3.y -- 1388
    local onMount = ____props_3.onMount -- 1388
    local text = ____props_3.text -- 1388
    local fontName = ____props_3.fontName -- 1388
    if fontName == nil then -- 1388
        fontName = "sarasa-mono-sc-regular" -- 1384
    end -- 1384
    local buttonSize = ____props_3.buttonSize -- 1384
    local color = ____props_3.color -- 1384
    if color == nil then -- 1384
        color = 4294967295 -- 1386
    end -- 1386
    local primaryOpacity = ____props_3.primaryOpacity -- 1386
    if primaryOpacity == nil then -- 1386
        primaryOpacity = 0.3 -- 1387
    end -- 1387
    local drawNode = useRef() -- 1389
    return React:createElement( -- 1390
        "node", -- 1390
        { -- 1390
            x = x, -- 1390
            y = y, -- 1390
            onMount = onMount, -- 1390
            width = buttonSize * 2, -- 1390
            height = buttonSize * 2, -- 1390
            onTapBegan = function() -- 1390
                if drawNode.current then -- 1390
                    drawNode.current.opacity = 1 -- 1394
                end -- 1394
            end, -- 1392
            onTapEnded = function() -- 1392
                if drawNode.current then -- 1392
                    drawNode.current.opacity = primaryOpacity -- 1399
                end -- 1399
            end -- 1397
        }, -- 1397
        React:createElement( -- 1397
            "draw-node", -- 1397
            {ref = drawNode, x = buttonSize, y = buttonSize, opacity = primaryOpacity}, -- 1397
            React:createElement("dot-shape", {radius = buttonSize, color = color}) -- 1397
        ), -- 1397
        React:createElement("label", { -- 1397
            x = buttonSize, -- 1397
            y = buttonSize, -- 1397
            scaleX = 0.5, -- 1397
            scaleY = 0.5, -- 1397
            color3 = color, -- 1397
            opacity = primaryOpacity + 0.2, -- 1397
            fontName = fontName, -- 1397
            fontSize = buttonSize * 2 -- 1397
        }, text) -- 1397
    ) -- 1397
end -- 1380
function ____exports.JoyStick(self, props) -- 1425
    local hat = useRef() -- 1426
    local ____props_4 = props -- 1436
    local moveSize = ____props_4.moveSize -- 1436
    if moveSize == nil then -- 1436
        moveSize = 70 -- 1428
    end -- 1428
    local hatSize = ____props_4.hatSize -- 1428
    if hatSize == nil then -- 1428
        hatSize = 40 -- 1429
    end -- 1429
    local stickType = ____props_4.stickType -- 1429
    if stickType == nil then -- 1429
        stickType = "Left" -- 1430
    end -- 1430
    local color = ____props_4.color -- 1430
    if color == nil then -- 1430
        color = 4294967295 -- 1431
    end -- 1431
    local primaryOpacity = ____props_4.primaryOpacity -- 1431
    if primaryOpacity == nil then -- 1431
        primaryOpacity = 0.3 -- 1432
    end -- 1432
    local secondaryOpacity = ____props_4.secondaryOpacity -- 1432
    if secondaryOpacity == nil then -- 1432
        secondaryOpacity = 0.1 -- 1433
    end -- 1433
    local fontName = ____props_4.fontName -- 1433
    if fontName == nil then -- 1433
        fontName = "sarasa-mono-sc-regular" -- 1434
    end -- 1434
    local buttonSize = ____props_4.buttonSize -- 1434
    if buttonSize == nil then -- 1434
        buttonSize = 20 -- 1435
    end -- 1435
    local visualBound = math.max(moveSize - hatSize, 0) -- 1437
    local stickButton = stickType == "Left" and "leftstick" or "rightstick" -- 1438
    local function updatePosition(node, location) -- 1440
        if location.length > visualBound then -- 1440
            node.position = location:normalize():mul(visualBound) -- 1442
        else -- 1442
            node.position = location -- 1444
        end -- 1444
        repeat -- 1444
            local ____switch360 = stickType -- 1444
            local ____cond360 = ____switch360 == "Left" -- 1444
            if ____cond360 then -- 1444
                props.inputManager:emitAxis("leftx", node.x / visualBound) -- 1448
                props.inputManager:emitAxis("lefty", node.y / visualBound) -- 1449
                break -- 1450
            end -- 1450
            ____cond360 = ____cond360 or ____switch360 == "Right" -- 1450
            if ____cond360 then -- 1450
                props.inputManager:emitAxis("rightx", node.x / visualBound) -- 1452
                props.inputManager:emitAxis("righty", node.y / visualBound) -- 1453
                break -- 1454
            end -- 1454
        until true -- 1454
    end -- 1440
    local ____React_9 = React -- 1440
    local ____React_createElement_10 = React.createElement -- 1440
    local ____temp_7 = {style = {width = moveSize * 2, height = moveSize * 2}} -- 1440
    local ____temp_8 = React:createElement( -- 1440
        "node", -- 1440
        { -- 1440
            x = moveSize, -- 1440
            y = moveSize, -- 1440
            onTapFilter = function(touch) -- 1440
                local ____touch_5 = touch -- 1462
                local location = ____touch_5.location -- 1462
                if location.length > moveSize then -- 1462
                    touch.enabled = false -- 1464
                end -- 1464
            end, -- 1461
            onTapBegan = function(touch) -- 1461
                if hat.current then -- 1461
                    hat.current.opacity = 1 -- 1469
                    updatePosition(hat.current, touch.location) -- 1470
                end -- 1470
            end, -- 1467
            onTapMoved = function(touch) -- 1467
                if hat.current then -- 1467
                    hat.current.opacity = 1 -- 1475
                    updatePosition(hat.current, touch.location) -- 1476
                end -- 1476
            end, -- 1473
            onTapped = function() -- 1473
                if hat.current then -- 1473
                    hat.current.opacity = primaryOpacity -- 1481
                    updatePosition(hat.current, Vec2.zero) -- 1482
                end -- 1482
            end -- 1479
        }, -- 1479
        React:createElement( -- 1479
            "draw-node", -- 1479
            {opacity = secondaryOpacity}, -- 1479
            React:createElement("dot-shape", {radius = moveSize, color = color}) -- 1479
        ), -- 1479
        React:createElement( -- 1479
            "draw-node", -- 1479
            {ref = hat, opacity = primaryOpacity}, -- 1479
            React:createElement("dot-shape", {radius = hatSize, color = color}) -- 1479
        ) -- 1479
    ) -- 1479
    local ____props_noStickButton_6 -- 1493
    if props.noStickButton then -- 1493
        ____props_noStickButton_6 = nil -- 1493
    else -- 1493
        ____props_noStickButton_6 = React:createElement( -- 1493
            Button, -- 1494
            { -- 1494
                buttonSize = buttonSize, -- 1494
                x = moveSize, -- 1494
                y = moveSize * 2 + buttonSize / 2 + 20, -- 1494
                text = stickType == "Left" and "LS" or "RS", -- 1494
                fontName = fontName, -- 1494
                color = color, -- 1494
                primaryOpacity = primaryOpacity, -- 1494
                onMount = function(node) -- 1494
                    node:slot( -- 1503
                        "TapBegan", -- 1503
                        function() return props.inputManager:emitButtonDown(stickButton) end -- 1503
                    ) -- 1503
                    node:slot( -- 1504
                        "TapEnded", -- 1504
                        function() return props.inputManager:emitButtonUp(stickButton) end -- 1504
                    ) -- 1504
                end -- 1502
            } -- 1502
        ) -- 1502
    end -- 1502
    return ____React_createElement_10( -- 1458
        ____React_9, -- 1458
        "align-node", -- 1458
        ____temp_7, -- 1458
        ____temp_8, -- 1458
        ____props_noStickButton_6 -- 1458
    ) -- 1458
end -- 1425
function ____exports.ButtonPad(self, props) -- 1521
    local ____props_11 = props -- 1528
    local buttonSize = ____props_11.buttonSize -- 1528
    if buttonSize == nil then -- 1528
        buttonSize = 30 -- 1523
    end -- 1523
    local buttonPadding = ____props_11.buttonPadding -- 1523
    if buttonPadding == nil then -- 1523
        buttonPadding = 10 -- 1524
    end -- 1524
    local fontName = ____props_11.fontName -- 1524
    if fontName == nil then -- 1524
        fontName = "sarasa-mono-sc-regular" -- 1525
    end -- 1525
    local color = ____props_11.color -- 1525
    if color == nil then -- 1525
        color = 4294967295 -- 1526
    end -- 1526
    local primaryOpacity = ____props_11.primaryOpacity -- 1526
    if primaryOpacity == nil then -- 1526
        primaryOpacity = 0.3 -- 1527
    end -- 1527
    local width = buttonSize * 5 + buttonPadding * 3 / 2 -- 1529
    local height = buttonSize * 4 + buttonPadding -- 1530
    local function onMount(buttonName) -- 1531
        return function(node) -- 1532
            node:slot( -- 1533
                "TapBegan", -- 1533
                function() return props.inputManager:emitButtonDown(buttonName) end -- 1533
            ) -- 1533
            node:slot( -- 1534
                "TapEnded", -- 1534
                function() return props.inputManager:emitButtonUp(buttonName) end -- 1534
            ) -- 1534
        end -- 1532
    end -- 1531
    return React:createElement( -- 1537
        "align-node", -- 1537
        {style = {width = width, height = height}}, -- 1537
        React:createElement( -- 1537
            "node", -- 1537
            {x = (buttonSize + buttonPadding / 2) / 2 + width / 2, y = buttonSize + buttonPadding / 2 + height / 2}, -- 1537
            React:createElement( -- 1537
                Button, -- 1543
                { -- 1543
                    text = "B", -- 1543
                    fontName = fontName, -- 1543
                    color = color, -- 1543
                    primaryOpacity = primaryOpacity, -- 1543
                    buttonSize = buttonSize, -- 1543
                    x = -buttonSize * 2 - buttonPadding, -- 1543
                    onMount = onMount("b") -- 1543
                } -- 1543
            ), -- 1543
            React:createElement( -- 1543
                Button, -- 1549
                { -- 1549
                    text = "Y", -- 1549
                    fontName = fontName, -- 1549
                    color = color, -- 1549
                    primaryOpacity = primaryOpacity, -- 1549
                    buttonSize = buttonSize, -- 1549
                    onMount = onMount("y") -- 1549
                } -- 1549
            ), -- 1549
            React:createElement( -- 1549
                Button, -- 1553
                { -- 1553
                    text = "A", -- 1553
                    fontName = fontName, -- 1553
                    color = color, -- 1553
                    primaryOpacity = primaryOpacity, -- 1553
                    buttonSize = buttonSize, -- 1553
                    x = -buttonSize - buttonPadding / 2, -- 1553
                    y = -buttonSize * 2 - buttonPadding, -- 1553
                    onMount = onMount("a") -- 1553
                } -- 1553
            ), -- 1553
            React:createElement( -- 1553
                Button, -- 1560
                { -- 1560
                    text = "X", -- 1560
                    fontName = fontName, -- 1560
                    color = color, -- 1560
                    primaryOpacity = primaryOpacity, -- 1560
                    buttonSize = buttonSize, -- 1560
                    x = buttonSize + buttonPadding / 2, -- 1560
                    y = -buttonSize * 2 - buttonPadding, -- 1560
                    onMount = onMount("x") -- 1560
                } -- 1560
            ) -- 1560
        ) -- 1560
    ) -- 1560
end -- 1521
function ____exports.ControlPad(self, props) -- 1580
    local ____props_12 = props -- 1586
    local buttonSize = ____props_12.buttonSize -- 1586
    if buttonSize == nil then -- 1586
        buttonSize = 35 -- 1582
    end -- 1582
    local fontName = ____props_12.fontName -- 1582
    if fontName == nil then -- 1582
        fontName = "sarasa-mono-sc-regular" -- 1583
    end -- 1583
    local color = ____props_12.color -- 1583
    if color == nil then -- 1583
        color = 4294967295 -- 1584
    end -- 1584
    local primaryOpacity = ____props_12.primaryOpacity -- 1584
    if primaryOpacity == nil then -- 1584
        primaryOpacity = 0.3 -- 1585
    end -- 1585
    local function Button(self, props) -- 1587
        local drawNode = useRef() -- 1588
        return React:createElement( -- 1589
            "node", -- 1589
            __TS__ObjectAssign( -- 1589
                {}, -- 1589
                props, -- 1590
                { -- 1590
                    width = buttonSize * 2, -- 1590
                    height = buttonSize, -- 1590
                    onTapBegan = function() -- 1590
                        if drawNode.current then -- 1590
                            drawNode.current.opacity = 1 -- 1593
                        end -- 1593
                    end, -- 1591
                    onTapEnded = function() -- 1591
                        if drawNode.current then -- 1591
                            drawNode.current.opacity = primaryOpacity -- 1598
                        end -- 1598
                    end -- 1596
                } -- 1596
            ), -- 1596
            React:createElement( -- 1596
                "draw-node", -- 1596
                {ref = drawNode, x = buttonSize, y = buttonSize / 2, opacity = primaryOpacity}, -- 1596
                React:createElement("rect-shape", {width = buttonSize * 2, height = buttonSize, fillColor = color}) -- 1596
            ), -- 1596
            React:createElement( -- 1596
                "label", -- 1596
                { -- 1596
                    x = buttonSize, -- 1596
                    y = buttonSize / 2, -- 1596
                    scaleX = 0.5, -- 1596
                    scaleY = 0.5, -- 1596
                    fontName = fontName, -- 1596
                    fontSize = math.floor(buttonSize * 1.5), -- 1596
                    color3 = color, -- 1596
                    opacity = primaryOpacity + 0.2 -- 1596
                }, -- 1596
                props.text -- 1607
            ) -- 1607
        ) -- 1607
    end -- 1587
    local function onMount(buttonName) -- 1611
        return function(node) -- 1612
            node:slot( -- 1613
                "TapBegan", -- 1613
                function() return props.inputManager:emitButtonDown(buttonName) end -- 1613
            ) -- 1613
            node:slot( -- 1614
                "TapEnded", -- 1614
                function() return props.inputManager:emitButtonUp(buttonName) end -- 1614
            ) -- 1614
        end -- 1612
    end -- 1611
    return React:createElement( -- 1617
        "align-node", -- 1617
        {style = {minWidth = buttonSize * 4 + 20, justifyContent = "space-between", flexDirection = "row"}}, -- 1617
        React:createElement( -- 1617
            "align-node", -- 1617
            {style = {width = buttonSize * 2, height = buttonSize}}, -- 1617
            React:createElement( -- 1617
                Button, -- 1620
                { -- 1620
                    text = "Start", -- 1620
                    x = buttonSize, -- 1620
                    y = buttonSize / 2, -- 1620
                    onMount = onMount("start") -- 1620
                } -- 1620
            ) -- 1620
        ), -- 1620
        React:createElement( -- 1620
            "align-node", -- 1620
            {style = {width = buttonSize * 2, height = buttonSize}}, -- 1620
            React:createElement( -- 1620
                Button, -- 1626
                { -- 1626
                    text = "Back", -- 1626
                    x = buttonSize, -- 1626
                    y = buttonSize / 2, -- 1626
                    onMount = onMount("back") -- 1626
                } -- 1626
            ) -- 1626
        ) -- 1626
    ) -- 1626
end -- 1580
function ____exports.CreateControlPad(props) -- 1635
    return toNode(React:createElement( -- 1636
        ____exports.ControlPad, -- 1636
        __TS__ObjectAssign({}, props) -- 1636
    )) -- 1636
end -- 1635
function ____exports.TriggerPad(self, props) -- 1650
    local ____props_13 = props -- 1656
    local buttonSize = ____props_13.buttonSize -- 1656
    if buttonSize == nil then -- 1656
        buttonSize = 35 -- 1652
    end -- 1652
    local fontName = ____props_13.fontName -- 1652
    if fontName == nil then -- 1652
        fontName = "sarasa-mono-sc-regular" -- 1653
    end -- 1653
    local color = ____props_13.color -- 1653
    if color == nil then -- 1653
        color = 4294967295 -- 1654
    end -- 1654
    local primaryOpacity = ____props_13.primaryOpacity -- 1654
    if primaryOpacity == nil then -- 1654
        primaryOpacity = 0.3 -- 1655
    end -- 1655
    local function Button(self, props) -- 1657
        local drawNode = useRef() -- 1658
        return React:createElement( -- 1659
            "node", -- 1659
            __TS__ObjectAssign( -- 1659
                {}, -- 1659
                props, -- 1660
                { -- 1660
                    width = buttonSize * 2, -- 1660
                    height = buttonSize, -- 1660
                    onTapBegan = function() -- 1660
                        if drawNode.current then -- 1660
                            drawNode.current.opacity = 1 -- 1663
                        end -- 1663
                    end, -- 1661
                    onTapEnded = function() -- 1661
                        if drawNode.current then -- 1661
                            drawNode.current.opacity = primaryOpacity -- 1668
                        end -- 1668
                    end -- 1666
                } -- 1666
            ), -- 1666
            React:createElement( -- 1666
                "draw-node", -- 1666
                {ref = drawNode, x = buttonSize, y = buttonSize / 2, opacity = primaryOpacity}, -- 1666
                React:createElement("rect-shape", {width = buttonSize * 2, height = buttonSize, fillColor = color}) -- 1666
            ), -- 1666
            React:createElement( -- 1666
                "label", -- 1666
                { -- 1666
                    x = buttonSize, -- 1666
                    y = buttonSize / 2, -- 1666
                    scaleX = 0.5, -- 1666
                    scaleY = 0.5, -- 1666
                    fontName = fontName, -- 1666
                    fontSize = math.floor(buttonSize * 1.5), -- 1666
                    color3 = color, -- 1666
                    opacity = primaryOpacity + 0.2 -- 1666
                }, -- 1666
                props.text -- 1676
            ) -- 1676
        ) -- 1676
    end -- 1657
    local function onMountAxis(axisName) -- 1680
        return function(node) -- 1681
            node:slot( -- 1682
                "TapBegan", -- 1682
                function() return props.inputManager:emitAxis(axisName, 1, 0) end -- 1682
            ) -- 1682
            node:slot( -- 1683
                "TapEnded", -- 1683
                function() return props.inputManager:emitAxis(axisName, 0, 0) end -- 1683
            ) -- 1683
        end -- 1681
    end -- 1680
    local function onMountButton(buttonName) -- 1686
        return function(node) -- 1687
            node:slot( -- 1688
                "TapBegan", -- 1688
                function() return props.inputManager:emitButtonDown(buttonName, 0) end -- 1688
            ) -- 1688
            node:slot( -- 1689
                "TapEnded", -- 1689
                function() return props.inputManager:emitButtonUp(buttonName, 0) end -- 1689
            ) -- 1689
        end -- 1687
    end -- 1686
    local ____React_25 = React -- 1686
    local ____React_createElement_26 = React.createElement -- 1686
    local ____temp_23 = {style = {minWidth = buttonSize * 4 + 20, justifyContent = "space-between", flexDirection = "row"}} -- 1686
    local ____React_17 = React -- 1686
    local ____React_createElement_18 = React.createElement -- 1686
    local ____temp_15 = {style = {width = buttonSize * 4 + 10, height = buttonSize}} -- 1686
    local ____temp_16 = React:createElement( -- 1686
        Button, -- 1695
        { -- 1695
            text = "LT", -- 1695
            x = buttonSize, -- 1695
            y = buttonSize / 2, -- 1695
            onMount = onMountAxis("lefttrigger") -- 1695
        } -- 1695
    ) -- 1695
    local ____props_noShoulder_14 -- 1699
    if props.noShoulder then -- 1699
        ____props_noShoulder_14 = nil -- 1699
    else -- 1699
        ____props_noShoulder_14 = React:createElement( -- 1699
            Button, -- 1700
            { -- 1700
                text = "LB", -- 1700
                x = buttonSize * 3 + 10, -- 1700
                y = buttonSize / 2, -- 1700
                onMount = onMountButton("leftshoulder") -- 1700
            } -- 1700
        ) -- 1700
    end -- 1700
    local ____React_createElement_18_result_24 = ____React_createElement_18( -- 1700
        ____React_17, -- 1700
        "align-node", -- 1700
        ____temp_15, -- 1700
        ____temp_16, -- 1700
        ____props_noShoulder_14 -- 1700
    ) -- 1700
    local ____React_21 = React -- 1700
    local ____React_createElement_22 = React.createElement -- 1700
    local ____temp_20 = {style = {width = buttonSize * 4 + 10, height = buttonSize}} -- 1700
    local ____props_noShoulder_19 -- 1707
    if props.noShoulder then -- 1707
        ____props_noShoulder_19 = nil -- 1707
    else -- 1707
        ____props_noShoulder_19 = React:createElement( -- 1707
            Button, -- 1708
            { -- 1708
                text = "RB", -- 1708
                x = buttonSize, -- 1708
                y = buttonSize / 2, -- 1708
                onMount = onMountButton("rightshoulder") -- 1708
            } -- 1708
        ) -- 1708
    end -- 1708
    return ____React_createElement_26( -- 1692
        ____React_25, -- 1692
        "align-node", -- 1692
        ____temp_23, -- 1692
        ____React_createElement_18_result_24, -- 1692
        ____React_createElement_22( -- 1692
            ____React_21, -- 1692
            "align-node", -- 1692
            ____temp_20, -- 1692
            ____props_noShoulder_19, -- 1692
            React:createElement( -- 1692
                Button, -- 1713
                { -- 1713
                    text = "RT", -- 1713
                    x = buttonSize * 3 + 10, -- 1713
                    y = buttonSize / 2, -- 1713
                    onMount = onMountAxis("righttrigger") -- 1713
                } -- 1713
            ) -- 1713
        ) -- 1713
    ) -- 1713
end -- 1650
function ____exports.CreateTriggerPad(props) -- 1722
    return toNode(React:createElement( -- 1723
        ____exports.TriggerPad, -- 1723
        __TS__ObjectAssign({}, props) -- 1723
    )) -- 1723
end -- 1722
function ____exports.GamePad(self, props) -- 1743
    local ____props_27 = props -- 1744
    local color = ____props_27.color -- 1744
    local primaryOpacity = ____props_27.primaryOpacity -- 1744
    local secondaryOpacity = ____props_27.secondaryOpacity -- 1744
    local inputManager = ____props_27.inputManager -- 1744
    local ____React_46 = React -- 1744
    local ____React_createElement_47 = React.createElement -- 1744
    local ____temp_44 = {style = {flexDirection = "column-reverse"}, windowRoot = true} -- 1744
    local ____React_40 = React -- 1744
    local ____React_createElement_41 = React.createElement -- 1744
    local ____temp_38 = {style = {margin = 20, justifyContent = "space-between", flexDirection = "row", alignItems = "flex-end"}} -- 1744
    local ____React_31 = React -- 1744
    local ____React_createElement_32 = React.createElement -- 1744
    local ____temp_30 = {style = {justifyContent = "space-between", flexDirection = "row", alignItems = "flex-end"}} -- 1744
    local ____props_noDPad_28 -- 1758
    if props.noDPad then -- 1758
        ____props_noDPad_28 = nil -- 1758
    else -- 1758
        ____props_noDPad_28 = React:createElement(____exports.DPad, {color = color, primaryOpacity = primaryOpacity, inputManager = inputManager}) -- 1758
    end -- 1758
    local ____props_noLeftStick_29 -- 1765
    if props.noLeftStick then -- 1765
        ____props_noLeftStick_29 = nil -- 1765
    else -- 1765
        ____props_noLeftStick_29 = React:createElement( -- 1765
            React.Fragment, -- 1765
            nil, -- 1765
            React:createElement("align-node", {style = {width = 10}}), -- 1765
            React:createElement(____exports.JoyStick, { -- 1765
                stickType = "Left", -- 1765
                color = color, -- 1765
                primaryOpacity = primaryOpacity, -- 1765
                secondaryOpacity = secondaryOpacity, -- 1765
                inputManager = inputManager, -- 1765
                noStickButton = props.noStickButton -- 1765
            }) -- 1765
        ) -- 1765
    end -- 1765
    local ____React_createElement_32_result_39 = ____React_createElement_32( -- 1765
        ____React_31, -- 1765
        "align-node", -- 1765
        ____temp_30, -- 1765
        ____props_noDPad_28, -- 1765
        ____props_noLeftStick_29 -- 1765
    ) -- 1765
    local ____React_36 = React -- 1765
    local ____React_createElement_37 = React.createElement -- 1765
    local ____temp_35 = {style = {justifyContent = "space-between", flexDirection = "row", alignItems = "flex-end"}} -- 1765
    local ____props_noRightStick_33 -- 1782
    if props.noRightStick then -- 1782
        ____props_noRightStick_33 = nil -- 1782
    else -- 1782
        ____props_noRightStick_33 = React:createElement( -- 1782
            React.Fragment, -- 1782
            nil, -- 1782
            React:createElement(____exports.JoyStick, { -- 1782
                stickType = "Right", -- 1782
                color = color, -- 1782
                primaryOpacity = primaryOpacity, -- 1782
                secondaryOpacity = secondaryOpacity, -- 1782
                inputManager = inputManager, -- 1782
                noStickButton = props.noStickButton -- 1782
            }), -- 1782
            React:createElement("align-node", {style = {width = 10}}) -- 1782
        ) -- 1782
    end -- 1782
    local ____props_noButtonPad_34 -- 1793
    if props.noButtonPad then -- 1793
        ____props_noButtonPad_34 = nil -- 1793
    else -- 1793
        ____props_noButtonPad_34 = React:createElement(____exports.ButtonPad, {color = color, primaryOpacity = primaryOpacity, inputManager = inputManager}) -- 1793
    end -- 1793
    local ____React_createElement_41_result_45 = ____React_createElement_41( -- 1793
        ____React_40, -- 1793
        "align-node", -- 1793
        ____temp_38, -- 1793
        ____React_createElement_32_result_39, -- 1793
        ____React_createElement_37( -- 1793
            ____React_36, -- 1793
            "align-node", -- 1793
            ____temp_35, -- 1793
            ____props_noRightStick_33, -- 1793
            ____props_noButtonPad_34 -- 1793
        ) -- 1793
    ) -- 1793
    local ____props_noTriggerPad_42 -- 1802
    if props.noTriggerPad then -- 1802
        ____props_noTriggerPad_42 = nil -- 1802
    else -- 1802
        ____props_noTriggerPad_42 = React:createElement( -- 1802
            "align-node", -- 1802
            {style = {paddingLeft = 20, paddingRight = 20, paddingTop = 20}}, -- 1802
            React:createElement(____exports.TriggerPad, {color = color, noShoulder = props.noShoulder, primaryOpacity = primaryOpacity, inputManager = inputManager}) -- 1802
        ) -- 1802
    end -- 1802
    local ____props_noControlPad_43 -- 1812
    if props.noControlPad then -- 1812
        ____props_noControlPad_43 = nil -- 1812
    else -- 1812
        ____props_noControlPad_43 = React:createElement( -- 1812
            "align-node", -- 1812
            {style = {paddingLeft = 20, paddingRight = 20}}, -- 1812
            React:createElement(____exports.ControlPad, {color = color, primaryOpacity = primaryOpacity, inputManager = inputManager}) -- 1812
        ) -- 1812
    end -- 1812
    return ____React_createElement_47( -- 1745
        ____React_46, -- 1745
        "align-node", -- 1745
        ____temp_44, -- 1745
        ____React_createElement_41_result_45, -- 1745
        ____props_noTriggerPad_42, -- 1745
        ____props_noControlPad_43 -- 1745
    ) -- 1745
end -- 1743
function ____exports.CreateGamePad(props) -- 1825
    return toNode(React:createElement( -- 1826
        ____exports.GamePad, -- 1826
        __TS__ObjectAssign({}, props) -- 1826
    )) -- 1826
end -- 1825
return ____exports -- 1825