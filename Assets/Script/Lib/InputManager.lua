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
local KeyDoubleDownTrigger = __TS__Class() -- 293
KeyDoubleDownTrigger.name = "KeyDoubleDownTrigger" -- 293
__TS__ClassExtends(KeyDoubleDownTrigger, ____exports.Trigger) -- 293
function KeyDoubleDownTrigger.prototype.____constructor(self, key, threshold) -- 299
    KeyDoubleDownTrigger.____super.prototype.____constructor(self) -- 300
    self.key = key -- 301
    self.threshold = threshold -- 302
    self.time = 0 -- 303
    self.onKeyDown = function(keyName) -- 304
        if self.key == keyName then -- 304
            if self.state == "None" then -- 304
                self.time = 0 -- 307
                self.state = "Started" -- 308
                self.progress = 0 -- 309
                if self.onChange then -- 309
                    self:onChange() -- 311
                end -- 311
            else -- 311
                self.state = "Completed" -- 314
                if self.onChange then -- 314
                    self:onChange() -- 316
                end -- 316
                self.state = "None" -- 318
            end -- 318
        end -- 318
    end -- 304
end -- 299
function KeyDoubleDownTrigger.prototype.start(self, manager) -- 323
    manager.keyboardEnabled = true -- 324
    manager:slot("KeyDown", self.onKeyDown) -- 325
    self.state = "None" -- 326
    self.progress = 0 -- 327
end -- 323
function KeyDoubleDownTrigger.prototype.onUpdate(self, deltaTime) -- 329
    repeat -- 329
        local ____switch72 = self.state -- 329
        local ____cond72 = ____switch72 == "Started" or ____switch72 == "Ongoing" -- 329
        if ____cond72 then -- 329
            break -- 333
        end -- 333
        do -- 333
            return -- 335
        end -- 335
    until true -- 335
    self.time = self.time + deltaTime -- 337
    if self.time >= self.threshold then -- 337
        self.state = "None" -- 339
        self.progress = 1 -- 340
    else -- 340
        self.state = "Ongoing" -- 342
        self.progress = math.min(self.time / self.threshold, 1) -- 343
    end -- 343
    if self.onChange then -- 343
        self:onChange() -- 346
    end -- 346
end -- 329
function KeyDoubleDownTrigger.prototype.stop(self, manager) -- 349
    manager:slot("KeyDown"):remove(self.onKeyDown) -- 350
    self.state = "None" -- 351
    self.progress = 0 -- 352
end -- 349
local KeyTimedTrigger = __TS__Class() -- 356
KeyTimedTrigger.name = "KeyTimedTrigger" -- 356
__TS__ClassExtends(KeyTimedTrigger, ____exports.Trigger) -- 356
function KeyTimedTrigger.prototype.____constructor(self, key, timeWindow) -- 362
    KeyTimedTrigger.____super.prototype.____constructor(self) -- 363
    self.key = key -- 364
    self.timeWindow = timeWindow -- 365
    self.time = 0 -- 366
    self.onKeyDown = function(keyName) -- 367
        repeat -- 367
            local ____switch79 = self.state -- 367
            local ____cond79 = ____switch79 == "Started" or ____switch79 == "Ongoing" or ____switch79 == "Completed" -- 367
            if ____cond79 then -- 367
                break -- 372
            end -- 372
            do -- 372
                return -- 374
            end -- 374
        until true -- 374
        if self.key == keyName and self.time <= self.timeWindow then -- 374
            self.state = "Completed" -- 377
            self.value = self.time -- 378
            if self.onChange then -- 378
                self:onChange() -- 380
            end -- 380
        end -- 380
    end -- 367
end -- 362
function KeyTimedTrigger.prototype.start(self, manager) -- 385
    manager.keyboardEnabled = true -- 386
    manager:slot("KeyDown", self.onKeyDown) -- 387
    self.state = "Started" -- 388
    self.progress = 0 -- 389
    self.value = false -- 390
    if self.onChange then -- 390
        self:onChange() -- 392
    end -- 392
end -- 385
function KeyTimedTrigger.prototype.onUpdate(self, deltaTime) -- 395
    repeat -- 395
        local ____switch85 = self.state -- 395
        local ____cond85 = ____switch85 == "Started" or ____switch85 == "Ongoing" or ____switch85 == "Completed" -- 395
        if ____cond85 then -- 395
            break -- 400
        end -- 400
        do -- 400
            return -- 402
        end -- 402
    until true -- 402
    self.time = self.time + deltaTime -- 404
    if self.time >= self.timeWindow then -- 404
        if self.state == "Completed" then -- 404
            self.state = "None" -- 407
            self.progress = 0 -- 408
        else -- 408
            self.state = "Canceled" -- 410
            self.progress = 1 -- 411
        end -- 411
    else -- 411
        self.state = "Ongoing" -- 414
        self.progress = math.min(self.time / self.timeWindow, 1) -- 415
    end -- 415
    if self.onChange then -- 415
        self:onChange() -- 418
    end -- 418
end -- 395
function KeyTimedTrigger.prototype.stop(self, manager) -- 421
    manager:slot("KeyDown"):remove(self.onKeyDown) -- 422
    self.state = "None" -- 423
    self.value = false -- 424
    self.progress = 0 -- 425
end -- 421
local ButtonDownTrigger = __TS__Class() -- 429
ButtonDownTrigger.name = "ButtonDownTrigger" -- 429
__TS__ClassExtends(ButtonDownTrigger, ____exports.Trigger) -- 429
function ButtonDownTrigger.prototype.____constructor(self, buttons, controllerId) -- 436
    ButtonDownTrigger.____super.prototype.____constructor(self) -- 437
    self.controllerId = controllerId -- 438
    self.buttons = buttons -- 439
    self.buttonStates = {} -- 440
    self.onButtonDown = function(controllerId, buttonName) -- 441
        if self.state == "Completed" then -- 441
            return -- 443
        end -- 443
        if self.controllerId ~= controllerId then -- 443
            return -- 446
        end -- 446
        if not (self.buttonStates[buttonName] ~= nil) then -- 446
            return -- 449
        end -- 449
        local oldState = true -- 451
        for ____, state in pairs(self.buttonStates) do -- 452
            if oldState then -- 452
                oldState = state -- 453
            end -- 453
        end -- 453
        self.buttonStates[buttonName] = true -- 455
        if not oldState then -- 455
            local newState = true -- 457
            for ____, state in pairs(self.buttonStates) do -- 458
                if newState then -- 458
                    newState = state -- 459
                end -- 459
            end -- 459
            if newState then -- 459
                self.state = "Completed" -- 462
                self.progress = 1 -- 463
                if self.onChange then -- 463
                    self:onChange() -- 465
                end -- 465
                self.progress = 0 -- 467
                self.state = "None" -- 468
            end -- 468
        end -- 468
    end -- 441
    self.onButtonUp = function(controllerId, buttonName) -- 472
        if self.state == "Completed" then -- 472
            return -- 474
        end -- 474
        if self.controllerId ~= controllerId then -- 474
            return -- 477
        end -- 477
        if not (self.buttonStates[buttonName] ~= nil) then -- 477
            return -- 480
        end -- 480
        self.buttonStates[buttonName] = false -- 482
    end -- 472
end -- 436
function ButtonDownTrigger.prototype.start(self, manager) -- 485
    manager.controllerEnabled = true -- 486
    for ____, k in ipairs(self.buttons) do -- 487
        self.buttonStates[k] = false -- 488
    end -- 488
    manager:slot("ButtonDown", self.onButtonDown) -- 490
    manager:slot("ButtonUp", self.onButtonUp) -- 491
    self.state = "None" -- 492
    self.progress = 0 -- 493
end -- 485
function ButtonDownTrigger.prototype.stop(self, manager) -- 495
    manager:slot("ButtonDown"):remove(self.onButtonDown) -- 496
    manager:slot("ButtonUp"):remove(self.onButtonUp) -- 497
    self.state = "None" -- 498
    self.progress = 0 -- 499
    self.value = false -- 500
end -- 495
local ButtonUpTrigger = __TS__Class() -- 504
ButtonUpTrigger.name = "ButtonUpTrigger" -- 504
__TS__ClassExtends(ButtonUpTrigger, ____exports.Trigger) -- 504
function ButtonUpTrigger.prototype.____constructor(self, buttons, controllerId) -- 511
    ButtonUpTrigger.____super.prototype.____constructor(self) -- 512
    self.controllerId = controllerId -- 513
    self.buttons = buttons -- 514
    self.buttonStates = {} -- 515
    self.onButtonDown = function(controllerId, buttonName) -- 516
        if self.state == "Completed" then -- 516
            return -- 518
        end -- 518
        if self.controllerId ~= controllerId then -- 518
            return -- 521
        end -- 521
        if not (self.buttonStates[buttonName] ~= nil) then -- 521
            return -- 524
        end -- 524
        self.buttonStates[buttonName] = true -- 526
    end -- 516
    self.onButtonUp = function(controllerId, buttonName) -- 528
        if self.state == "Completed" then -- 528
            return -- 530
        end -- 530
        if self.controllerId ~= controllerId then -- 530
            return -- 533
        end -- 533
        if not (self.buttonStates[buttonName] ~= nil) then -- 533
            return -- 536
        end -- 536
        local oldState = true -- 538
        for ____, state in pairs(self.buttonStates) do -- 539
            if oldState then -- 539
                oldState = state -- 540
            end -- 540
        end -- 540
        self.buttonStates[buttonName] = false -- 542
        if oldState then -- 542
            self.state = "Completed" -- 544
            self.progress = 1 -- 545
            if self.onChange then -- 545
                self:onChange() -- 547
            end -- 547
            self.progress = 0 -- 549
            self.state = "None" -- 550
        end -- 550
    end -- 528
end -- 511
function ButtonUpTrigger.prototype.start(self, manager) -- 554
    manager.controllerEnabled = true -- 555
    for ____, k in ipairs(self.buttons) do -- 556
        self.buttonStates[k] = false -- 557
    end -- 557
    manager:slot("ButtonDown", self.onButtonDown) -- 559
    manager:slot("ButtonUp", self.onButtonUp) -- 560
    self.state = "None" -- 561
    self.progress = 0 -- 562
end -- 554
function ButtonUpTrigger.prototype.stop(self, manager) -- 564
    manager:slot("ButtonDown"):remove(self.onButtonDown) -- 565
    manager:slot("ButtonUp"):remove(self.onButtonUp) -- 566
    self.state = "None" -- 567
    self.progress = 0 -- 568
end -- 564
local ButtonPressedTrigger = __TS__Class() -- 572
ButtonPressedTrigger.name = "ButtonPressedTrigger" -- 572
__TS__ClassExtends(ButtonPressedTrigger, ____exports.Trigger) -- 572
function ButtonPressedTrigger.prototype.____constructor(self, buttons, controllerId) -- 579
    ButtonPressedTrigger.____super.prototype.____constructor(self) -- 580
    self.controllerId = controllerId -- 581
    self.buttons = buttons -- 582
    self.buttonStates = {} -- 583
    self.onButtonDown = function(controllerId, buttonName) -- 584
        if self.controllerId ~= controllerId then -- 584
            return -- 586
        end -- 586
        if not (self.buttonStates[buttonName] ~= nil) then -- 586
            return -- 589
        end -- 589
        self.buttonStates[buttonName] = true -- 591
    end -- 584
    self.onButtonUp = function(controllerId, buttonName) -- 593
        if self.controllerId ~= controllerId then -- 593
            return -- 595
        end -- 595
        if not (self.buttonStates[buttonName] ~= nil) then -- 595
            return -- 598
        end -- 598
        self.buttonStates[buttonName] = false -- 600
    end -- 593
end -- 579
function ButtonPressedTrigger.prototype.onUpdate(self, _) -- 603
    local allDown = true -- 604
    for ____, down in pairs(self.buttonStates) do -- 605
        if allDown then -- 605
            allDown = down -- 606
        end -- 606
    end -- 606
    if allDown then -- 606
        self.state = "Completed" -- 609
        self.progress = 1 -- 610
        if self.onChange then -- 610
            self:onChange() -- 612
        end -- 612
        self.progress = 0 -- 614
        self.state = "None" -- 615
    end -- 615
end -- 603
function ButtonPressedTrigger.prototype.start(self, manager) -- 618
    manager.controllerEnabled = true -- 619
    for ____, k in ipairs(self.buttons) do -- 620
        self.buttonStates[k] = false -- 621
    end -- 621
    manager:slot("ButtonDown", self.onButtonDown) -- 623
    manager:slot("ButtonUp", self.onButtonUp) -- 624
    self.state = "None" -- 625
    self.progress = 0 -- 626
end -- 618
function ButtonPressedTrigger.prototype.stop(self, manager) -- 628
    manager:slot("ButtonDown"):remove(self.onButtonDown) -- 629
    manager:slot("ButtonUp"):remove(self.onButtonUp) -- 630
    self.state = "None" -- 631
    self.progress = 0 -- 632
end -- 628
local ButtonHoldTrigger = __TS__Class() -- 636
ButtonHoldTrigger.name = "ButtonHoldTrigger" -- 636
__TS__ClassExtends(ButtonHoldTrigger, ____exports.Trigger) -- 636
function ButtonHoldTrigger.prototype.____constructor(self, button, holdTime, controllerId) -- 644
    ButtonHoldTrigger.____super.prototype.____constructor(self) -- 645
    self.controllerId = controllerId -- 646
    self.button = button -- 647
    self.holdTime = holdTime -- 648
    self.time = 0 -- 649
    self.onButtonDown = function(controllerId, buttonName) -- 650
        if self.controllerId ~= controllerId then -- 650
            return -- 652
        end -- 652
        if self.button == buttonName then -- 652
            self.time = 0 -- 655
            self.state = "Started" -- 656
            self.progress = 0 -- 657
            if self.onChange then -- 657
                self:onChange() -- 659
            end -- 659
        end -- 659
    end -- 650
    self.onButtonUp = function(controllerId, buttonName) -- 663
        if self.controllerId ~= controllerId then -- 663
            return -- 665
        end -- 665
        repeat -- 665
            local ____switch148 = self.state -- 665
            local ____cond148 = ____switch148 == "Started" or ____switch148 == "Ongoing" or ____switch148 == "Completed" -- 665
            if ____cond148 then -- 665
                break -- 671
            end -- 671
            do -- 671
                return -- 673
            end -- 673
        until true -- 673
        if self.button == buttonName then -- 673
            if self.state == "Completed" then -- 673
                self.state = "None" -- 677
            else -- 677
                self.state = "Canceled" -- 679
            end -- 679
            self.progress = 0 -- 681
            if self.onChange then -- 681
                self:onChange() -- 683
            end -- 683
        end -- 683
    end -- 663
end -- 644
function ButtonHoldTrigger.prototype.start(self, manager) -- 688
    manager.controllerEnabled = true -- 689
    manager:slot("ButtonDown", self.onButtonDown) -- 690
    manager:slot("ButtonUp", self.onButtonUp) -- 691
    self.state = "None" -- 692
    self.progress = 0 -- 693
end -- 688
function ButtonHoldTrigger.prototype.onUpdate(self, deltaTime) -- 695
    repeat -- 695
        local ____switch155 = self.state -- 695
        local ____cond155 = ____switch155 == "Started" or ____switch155 == "Ongoing" -- 695
        if ____cond155 then -- 695
            break -- 699
        end -- 699
        do -- 699
            return -- 701
        end -- 701
    until true -- 701
    self.time = self.time + deltaTime -- 703
    if self.time >= self.holdTime then -- 703
        self.state = "Completed" -- 705
        self.progress = 1 -- 706
    else -- 706
        self.state = "Ongoing" -- 708
        self.progress = math.min(self.time / self.holdTime, 1) -- 709
    end -- 709
    if self.onChange then -- 709
        self:onChange() -- 712
    end -- 712
end -- 695
function ButtonHoldTrigger.prototype.stop(self, manager) -- 715
    manager:slot("ButtonDown"):remove(self.onButtonDown) -- 716
    manager:slot("ButtonUp"):remove(self.onButtonUp) -- 717
    self.state = "None" -- 718
    self.progress = 0 -- 719
end -- 715
local ButtonTimedTrigger = __TS__Class() -- 723
ButtonTimedTrigger.name = "ButtonTimedTrigger" -- 723
__TS__ClassExtends(ButtonTimedTrigger, ____exports.Trigger) -- 723
function ButtonTimedTrigger.prototype.____constructor(self, button, timeWindow, controllerId) -- 730
    ButtonTimedTrigger.____super.prototype.____constructor(self) -- 731
    self.controllerId = controllerId -- 732
    self.button = button -- 733
    self.timeWindow = timeWindow -- 734
    self.time = 0 -- 735
    self.onButtonDown = function(controllerId, buttonName) -- 736
        if self.controllerId ~= controllerId then -- 736
            return -- 738
        end -- 738
        repeat -- 738
            local ____switch163 = self.state -- 738
            local ____cond163 = ____switch163 == "Started" or ____switch163 == "Ongoing" or ____switch163 == "Completed" -- 738
            if ____cond163 then -- 738
                break -- 744
            end -- 744
            do -- 744
                return -- 746
            end -- 746
        until true -- 746
        if self.button == buttonName and self.time <= self.timeWindow then -- 746
            self.state = "Completed" -- 749
            self.value = self.time -- 750
            if self.onChange then -- 750
                self:onChange() -- 752
            end -- 752
        end -- 752
    end -- 736
end -- 730
function ButtonTimedTrigger.prototype.start(self, manager) -- 757
    manager.controllerEnabled = true -- 758
    manager:slot("ButtonDown", self.onButtonDown) -- 759
    self.state = "Started" -- 760
    self.progress = 0 -- 761
    self.value = false -- 762
    if self.onChange then -- 762
        self:onChange() -- 764
    end -- 764
end -- 757
function ButtonTimedTrigger.prototype.onUpdate(self, deltaTime) -- 767
    repeat -- 767
        local ____switch169 = self.state -- 767
        local ____cond169 = ____switch169 == "Started" or ____switch169 == "Ongoing" or ____switch169 == "Completed" -- 767
        if ____cond169 then -- 767
            break -- 772
        end -- 772
        do -- 772
            return -- 774
        end -- 774
    until true -- 774
    self.time = self.time + deltaTime -- 776
    if self.time >= self.timeWindow then -- 776
        if self.state == "Completed" then -- 776
            self.state = "None" -- 779
            self.progress = 0 -- 780
        else -- 780
            self.state = "Canceled" -- 782
            self.progress = 1 -- 783
        end -- 783
    else -- 783
        self.state = "Ongoing" -- 786
        self.progress = math.min(self.time / self.timeWindow, 1) -- 787
    end -- 787
    if self.onChange then -- 787
        self:onChange() -- 790
    end -- 790
end -- 767
function ButtonTimedTrigger.prototype.stop(self, manager) -- 793
    manager:slot("ButtonDown"):remove(self.onButtonDown) -- 794
    self.state = "None" -- 795
    self.progress = 0 -- 796
end -- 793
local ButtonDoubleDownTrigger = __TS__Class() -- 800
ButtonDoubleDownTrigger.name = "ButtonDoubleDownTrigger" -- 800
__TS__ClassExtends(ButtonDoubleDownTrigger, ____exports.Trigger) -- 800
function ButtonDoubleDownTrigger.prototype.____constructor(self, button, threshold, controllerId) -- 807
    ButtonDoubleDownTrigger.____super.prototype.____constructor(self) -- 808
    self.controllerId = controllerId -- 809
    self.button = button -- 810
    self.threshold = threshold -- 811
    self.time = 0 -- 812
    self.onButtonDown = function(controllerId, buttonName) -- 813
        if self.controllerId ~= controllerId then -- 813
            return -- 815
        end -- 815
        if self.button == buttonName then -- 815
            if self.state == "None" then -- 815
                self.time = 0 -- 819
                self.state = "Started" -- 820
                self.progress = 0 -- 821
                if self.onChange then -- 821
                    self:onChange() -- 823
                end -- 823
            else -- 823
                self.state = "Completed" -- 826
                if self.onChange then -- 826
                    self:onChange() -- 828
                end -- 828
                self.state = "None" -- 830
            end -- 830
        end -- 830
    end -- 813
end -- 807
function ButtonDoubleDownTrigger.prototype.start(self, manager) -- 835
    manager.controllerEnabled = true -- 836
    manager:slot("ButtonDown", self.onButtonDown) -- 837
    self.state = "None" -- 838
    self.progress = 0 -- 839
end -- 835
function ButtonDoubleDownTrigger.prototype.onUpdate(self, deltaTime) -- 841
    repeat -- 841
        local ____switch186 = self.state -- 841
        local ____cond186 = ____switch186 == "Started" or ____switch186 == "Ongoing" -- 841
        if ____cond186 then -- 841
            break -- 845
        end -- 845
        do -- 845
            return -- 847
        end -- 847
    until true -- 847
    self.time = self.time + deltaTime -- 849
    if self.time >= self.threshold then -- 849
        self.state = "None" -- 851
        self.progress = 1 -- 852
    else -- 852
        self.state = "Ongoing" -- 854
        self.progress = math.min(self.time / self.threshold, 1) -- 855
    end -- 855
    if self.onChange then -- 855
        self:onChange() -- 858
    end -- 858
end -- 841
function ButtonDoubleDownTrigger.prototype.stop(self, manager) -- 861
    manager:slot("ButtonDown"):remove(self.onButtonDown) -- 862
    self.state = "None" -- 863
    self.progress = 0 -- 864
end -- 861
local JoyStickTrigger = __TS__Class() -- 873
JoyStickTrigger.name = "JoyStickTrigger" -- 873
__TS__ClassExtends(JoyStickTrigger, ____exports.Trigger) -- 873
function JoyStickTrigger.prototype.____constructor(self, joyStickType, controllerId) -- 879
    JoyStickTrigger.____super.prototype.____constructor(self) -- 880
    self.joyStickType = joyStickType -- 881
    self.controllerId = controllerId -- 882
    self.axis = Vec2.zero -- 883
    self.onAxis = function(controllerId, axisName, value) -- 884
        if self.controllerId ~= controllerId then -- 884
            return -- 886
        end -- 886
        repeat -- 886
            local ____switch194 = self.joyStickType -- 886
            local ____cond194 = ____switch194 == "Left" -- 886
            if ____cond194 then -- 886
                do -- 886
                    repeat -- 886
                        local ____switch196 = axisName -- 886
                        local ____cond196 = ____switch196 == "leftx" -- 886
                        if ____cond196 then -- 886
                            self.axis = Vec2(value, self.axis.y) -- 892
                            break -- 893
                        end -- 893
                        ____cond196 = ____cond196 or ____switch196 == "lefty" -- 893
                        if ____cond196 then -- 893
                            self.axis = Vec2(self.axis.x, value) -- 895
                            break -- 896
                        end -- 896
                    until true -- 896
                    break -- 898
                end -- 898
            end -- 898
            ____cond194 = ____cond194 or ____switch194 == "Right" -- 898
            if ____cond194 then -- 898
                do -- 898
                    repeat -- 898
                        local ____switch198 = axisName -- 898
                        local ____cond198 = ____switch198 == "rightx" -- 898
                        if ____cond198 then -- 898
                            self.axis = Vec2(value, self.axis.y) -- 903
                            break -- 904
                        end -- 904
                        ____cond198 = ____cond198 or ____switch198 == "righty" -- 904
                        if ____cond198 then -- 904
                            self.axis = Vec2(self.axis.x, value) -- 906
                            break -- 907
                        end -- 907
                    until true -- 907
                    break -- 909
                end -- 909
            end -- 909
        until true -- 909
        self.value = self.axis -- 912
        if self:filterAxis() then -- 912
            self.state = "Completed" -- 914
        else -- 914
            self.state = "None" -- 916
        end -- 916
        if self.onChange then -- 916
            self:onChange() -- 919
        end -- 919
    end -- 884
end -- 879
function JoyStickTrigger.prototype.filterAxis(self) -- 923
    return true -- 924
end -- 923
function JoyStickTrigger.prototype.start(self, manager) -- 926
    self.state = "None" -- 927
    self.value = Vec2.zero -- 928
    manager:slot("Axis", self.onAxis) -- 929
end -- 926
function JoyStickTrigger.prototype.stop(self, manager) -- 931
    self.state = "None" -- 932
    self.value = Vec2.zero -- 933
    manager:slot("Axis"):remove(self.onAxis) -- 934
end -- 931
local JoyStickThresholdTrigger = __TS__Class() -- 938
JoyStickThresholdTrigger.name = "JoyStickThresholdTrigger" -- 938
__TS__ClassExtends(JoyStickThresholdTrigger, JoyStickTrigger) -- 938
function JoyStickThresholdTrigger.prototype.____constructor(self, joyStickType, threshold, controllerId) -- 941
    JoyStickTrigger.prototype.____constructor(self, joyStickType, controllerId) -- 942
    self.threshold = threshold -- 943
end -- 941
function JoyStickThresholdTrigger.prototype.filterAxis(self) -- 945
    return self.axis.length > self.threshold -- 946
end -- 945
local JoyStickDirectionalTrigger = __TS__Class() -- 950
JoyStickDirectionalTrigger.name = "JoyStickDirectionalTrigger" -- 950
__TS__ClassExtends(JoyStickDirectionalTrigger, JoyStickTrigger) -- 950
function JoyStickDirectionalTrigger.prototype.____constructor(self, joyStickType, angle, tolerance, controllerId) -- 954
    JoyStickTrigger.prototype.____constructor(self, joyStickType, controllerId) -- 955
    self.direction = angle -- 956
    self.tolerance = tolerance -- 957
end -- 954
function JoyStickDirectionalTrigger.prototype.filterAxis(self) -- 959
    local currentAngle = -math.deg(math.atan(self.axis.y, self.axis.x)) -- 960
    return math.abs(currentAngle - self.direction) <= self.tolerance -- 961
end -- 959
local JoyStickRangeTrigger = __TS__Class() -- 965
JoyStickRangeTrigger.name = "JoyStickRangeTrigger" -- 965
__TS__ClassExtends(JoyStickRangeTrigger, JoyStickTrigger) -- 965
function JoyStickRangeTrigger.prototype.____constructor(self, joyStickType, minRange, maxRange, controllerId) -- 969
    JoyStickTrigger.prototype.____constructor(self, joyStickType, controllerId) -- 970
    self.minRange = math.min(minRange, maxRange) -- 971
    self.maxRange = math.max(minRange, maxRange) -- 972
end -- 969
function JoyStickRangeTrigger.prototype.filterAxis(self) -- 974
    local magnitude = self.axis.length -- 975
    return magnitude >= self.minRange and magnitude <= self.maxRange -- 976
end -- 974
local SequenceTrigger = __TS__Class() -- 980
SequenceTrigger.name = "SequenceTrigger" -- 980
__TS__ClassExtends(SequenceTrigger, ____exports.Trigger) -- 980
function SequenceTrigger.prototype.____constructor(self, triggers) -- 983
    SequenceTrigger.____super.prototype.____constructor(self) -- 984
    self.triggers = triggers -- 985
    local ____self = self -- 986
    local function onStateChanged() -- 987
        ____self:onStateChanged() -- 988
    end -- 987
    for ____, trigger in ipairs(triggers) do -- 990
        trigger.onChange = onStateChanged -- 991
    end -- 991
end -- 983
function SequenceTrigger.prototype.onStateChanged(self) -- 994
    local completed = true -- 995
    for ____, trigger in ipairs(self.triggers) do -- 996
        if trigger.state ~= "Completed" then -- 996
            completed = false -- 998
            break -- 999
        end -- 999
    end -- 999
    if completed then -- 999
        self.state = "Completed" -- 1003
        local newValue = {} -- 1004
        for ____, trigger in ipairs(self.triggers) do -- 1005
            if type(trigger.value) == "table" then -- 1005
                if type(trigger.value) == "userdata" then -- 1005
                    newValue[#newValue + 1] = trigger.value -- 1008
                else -- 1008
                    newValue = __TS__ArrayConcat(newValue, trigger.value) -- 1010
                end -- 1010
            else -- 1010
                newValue[#newValue + 1] = trigger.value -- 1013
            end -- 1013
        end -- 1013
        self.value = newValue -- 1016
        self.progress = 1 -- 1017
        if self.onChange then -- 1017
            self:onChange() -- 1019
        end -- 1019
        return -- 1021
    end -- 1021
    local onGoing = false -- 1023
    local minProgress = -1 -- 1024
    for ____, trigger in ipairs(self.triggers) do -- 1025
        if trigger.state == "Ongoing" then -- 1025
            minProgress = minProgress < 0 and trigger.progress or math.min(minProgress, trigger.progress) -- 1027
            onGoing = true -- 1028
        end -- 1028
    end -- 1028
    if onGoing then -- 1028
        self.state = "Ongoing" -- 1032
        self.progress = minProgress -- 1033
        if self.onChange then -- 1033
            self:onChange() -- 1035
        end -- 1035
        return -- 1037
    end -- 1037
    for ____, trigger in ipairs(self.triggers) do -- 1039
        if trigger.state == "Started" then -- 1039
            self.state = "Started" -- 1041
            self.progress = 0 -- 1042
            if self.onChange then -- 1042
                self:onChange() -- 1044
            end -- 1044
            return -- 1046
        end -- 1046
    end -- 1046
    local canceled = false -- 1049
    for ____, trigger in ipairs(self.triggers) do -- 1050
        if trigger.state == "Canceled" then -- 1050
            canceled = true -- 1052
            break -- 1053
        end -- 1053
    end -- 1053
    if canceled then -- 1053
        self.state = "Canceled" -- 1057
        self.progress = 0 -- 1058
        if self.onChange then -- 1058
            self:onChange() -- 1060
        end -- 1060
        return -- 1062
    end -- 1062
    self.state = "None" -- 1064
    self.progress = 0 -- 1065
    if self.onChange then -- 1065
        self:onChange() -- 1067
    end -- 1067
end -- 994
function SequenceTrigger.prototype.start(self, manager) -- 1070
    for ____, trigger in ipairs(self.triggers) do -- 1071
        trigger:start(manager) -- 1072
    end -- 1072
end -- 1070
function SequenceTrigger.prototype.onUpdate(self, deltaTime) -- 1075
    for ____, trigger in ipairs(self.triggers) do -- 1076
        if trigger.onUpdate then -- 1076
            trigger:onUpdate(deltaTime) -- 1078
        end -- 1078
    end -- 1078
end -- 1075
function SequenceTrigger.prototype.stop(self, manager) -- 1082
    for ____, trigger in ipairs(self.triggers) do -- 1083
        trigger:stop(manager) -- 1084
    end -- 1084
end -- 1082
local SelectorTrigger = __TS__Class() -- 1089
SelectorTrigger.name = "SelectorTrigger" -- 1089
__TS__ClassExtends(SelectorTrigger, ____exports.Trigger) -- 1089
function SelectorTrigger.prototype.____constructor(self, triggers) -- 1092
    SelectorTrigger.____super.prototype.____constructor(self) -- 1093
    self.triggers = triggers -- 1094
    local ____self = self -- 1095
    local function onStateChanged() -- 1096
        ____self:onStateChanged() -- 1097
    end -- 1096
    for ____, trigger in ipairs(triggers) do -- 1099
        trigger.onChange = onStateChanged -- 1100
    end -- 1100
end -- 1092
function SelectorTrigger.prototype.onStateChanged(self) -- 1103
    for ____, trigger in ipairs(self.triggers) do -- 1104
        if trigger.state == "Completed" then -- 1104
            self.state = "Completed" -- 1106
            self.progress = trigger.progress -- 1107
            self.value = trigger.value -- 1108
            if self.onChange then -- 1108
                self:onChange() -- 1110
            end -- 1110
            return -- 1112
        end -- 1112
    end -- 1112
    local onGoing = false -- 1115
    local maxProgress = 0 -- 1116
    for ____, trigger in ipairs(self.triggers) do -- 1117
        if trigger.state == "Ongoing" then -- 1117
            maxProgress = math.max(maxProgress, trigger.progress) -- 1119
            onGoing = true -- 1120
        end -- 1120
    end -- 1120
    if onGoing then -- 1120
        self.state = "Ongoing" -- 1124
        self.progress = maxProgress -- 1125
        if self.onChange then -- 1125
            self:onChange() -- 1127
        end -- 1127
        return -- 1129
    end -- 1129
    for ____, trigger in ipairs(self.triggers) do -- 1131
        if trigger.state == "Started" then -- 1131
            self.state = "Started" -- 1133
            self.progress = 0 -- 1134
            if self.onChange then -- 1134
                self:onChange() -- 1136
            end -- 1136
            return -- 1138
        end -- 1138
    end -- 1138
    local canceled = false -- 1141
    for ____, trigger in ipairs(self.triggers) do -- 1142
        if trigger.state == "Canceled" then -- 1142
            canceled = true -- 1144
            break -- 1145
        end -- 1145
    end -- 1145
    if canceled then -- 1145
        self.state = "Canceled" -- 1149
        self.progress = 0 -- 1150
        if self.onChange then -- 1150
            self:onChange() -- 1152
        end -- 1152
    end -- 1152
end -- 1103
function SelectorTrigger.prototype.start(self, manager) -- 1156
    for ____, trigger in ipairs(self.triggers) do -- 1157
        trigger:start(manager) -- 1158
    end -- 1158
end -- 1156
function SelectorTrigger.prototype.onUpdate(self, deltaTime) -- 1161
    for ____, trigger in ipairs(self.triggers) do -- 1162
        if trigger.onUpdate then -- 1162
            trigger:onUpdate(deltaTime) -- 1164
        end -- 1164
    end -- 1164
end -- 1161
function SelectorTrigger.prototype.stop(self, manager) -- 1168
    for ____, trigger in ipairs(self.triggers) do -- 1169
        trigger:stop(manager) -- 1170
    end -- 1170
end -- 1168
local BlockTrigger = __TS__Class() -- 1175
BlockTrigger.name = "BlockTrigger" -- 1175
__TS__ClassExtends(BlockTrigger, ____exports.Trigger) -- 1175
function BlockTrigger.prototype.____constructor(self, trigger) -- 1178
    BlockTrigger.____super.prototype.____constructor(self) -- 1179
    self.trigger = trigger -- 1180
    local ____self = self -- 1181
    trigger.onChange = function() -- 1182
        ____self:onStateChanged() -- 1183
    end -- 1182
end -- 1178
function BlockTrigger.prototype.onStateChanged(self) -- 1186
    if self.trigger.state == "Completed" then -- 1186
        self.state = "Canceled" -- 1188
    else -- 1188
        self.state = "Completed" -- 1190
    end -- 1190
    if self.onChange then -- 1190
        self:onChange() -- 1193
    end -- 1193
end -- 1186
function BlockTrigger.prototype.start(self, manager) -- 1196
    self.state = "Completed" -- 1197
    self.trigger:start(manager) -- 1198
end -- 1196
function BlockTrigger.prototype.onUpdate(self, deltaTime) -- 1200
    if self.trigger.onUpdate then -- 1200
        self.trigger:onUpdate(deltaTime) -- 1202
    end -- 1202
end -- 1200
function BlockTrigger.prototype.stop(self, manager) -- 1205
    self.state = "Completed" -- 1206
    self.trigger:stop(manager) -- 1207
end -- 1205
do -- 1205
    function Trigger.KeyDown(combineKeys) -- 1212
        if type(combineKeys) == "string" then -- 1212
            combineKeys = {combineKeys} -- 1214
        end -- 1214
        return __TS__New(KeyDownTrigger, combineKeys) -- 1216
    end -- 1212
    function Trigger.KeyUp(combineKeys) -- 1218
        if type(combineKeys) == "string" then -- 1218
            combineKeys = {combineKeys} -- 1220
        end -- 1220
        return __TS__New(KeyUpTrigger, combineKeys) -- 1222
    end -- 1218
    function Trigger.KeyPressed(combineKeys) -- 1224
        if type(combineKeys) == "string" then -- 1224
            combineKeys = {combineKeys} -- 1226
        end -- 1226
        return __TS__New(KeyPressedTrigger, combineKeys) -- 1228
    end -- 1224
    function Trigger.KeyHold(keyName, holdTime) -- 1230
        return __TS__New(KeyHoldTrigger, keyName, holdTime) -- 1231
    end -- 1230
    function Trigger.KeyTimed(keyName, timeWindow) -- 1233
        return __TS__New(KeyTimedTrigger, keyName, timeWindow) -- 1234
    end -- 1233
    function Trigger.KeyDoubleDown(self, key, threshold) -- 1236
        return __TS__New(KeyDoubleDownTrigger, key, threshold or 0.3) -- 1237
    end -- 1236
    function Trigger.ButtonDown(combineButtons, controllerId) -- 1239
        if type(combineButtons) == "string" then -- 1239
            combineButtons = {combineButtons} -- 1241
        end -- 1241
        return __TS__New(ButtonDownTrigger, combineButtons, controllerId or 0) -- 1243
    end -- 1239
    function Trigger.ButtonUp(combineButtons, controllerId) -- 1245
        if type(combineButtons) == "string" then -- 1245
            combineButtons = {combineButtons} -- 1247
        end -- 1247
        return __TS__New(ButtonUpTrigger, combineButtons, controllerId or 0) -- 1249
    end -- 1245
    function Trigger.ButtonPressed(combineButtons, controllerId) -- 1251
        if type(combineButtons) == "string" then -- 1251
            combineButtons = {combineButtons} -- 1253
        end -- 1253
        return __TS__New(ButtonPressedTrigger, combineButtons, controllerId or 0) -- 1255
    end -- 1251
    function Trigger.ButtonHold(buttonName, holdTime, controllerId) -- 1257
        return __TS__New(ButtonHoldTrigger, buttonName, holdTime, controllerId or 0) -- 1258
    end -- 1257
    function Trigger.ButtonTimed(buttonName, timeWindow, controllerId) -- 1260
        return __TS__New(ButtonTimedTrigger, buttonName, timeWindow, controllerId or 0) -- 1261
    end -- 1260
    function Trigger.ButtonDoubleDown(self, button, threshold, controllerId) -- 1263
        return __TS__New(ButtonDoubleDownTrigger, button, threshold or 0.3, controllerId or 0) -- 1264
    end -- 1263
    function Trigger.JoyStick(joyStickType, controllerId) -- 1266
        return __TS__New(JoyStickTrigger, joyStickType, controllerId or 0) -- 1267
    end -- 1266
    function Trigger.JoyStickThreshold(joyStickType, threshold, controllerId) -- 1269
        return __TS__New(JoyStickThresholdTrigger, joyStickType, threshold, controllerId or 0) -- 1270
    end -- 1269
    function Trigger.JoyStickDirectional(joyStickType, angle, tolerance, controllerId) -- 1272
        return __TS__New( -- 1273
            JoyStickDirectionalTrigger, -- 1273
            joyStickType, -- 1273
            angle, -- 1273
            tolerance, -- 1273
            controllerId or 0 -- 1273
        ) -- 1273
    end -- 1272
    function Trigger.JoyStickRange(joyStickType, minRange, maxRange, controllerId) -- 1275
        return __TS__New( -- 1276
            JoyStickRangeTrigger, -- 1276
            joyStickType, -- 1276
            minRange, -- 1276
            maxRange, -- 1276
            controllerId or 0 -- 1276
        ) -- 1276
    end -- 1275
    function Trigger.Sequence(triggers) -- 1278
        return __TS__New(SequenceTrigger, triggers) -- 1279
    end -- 1278
    function Trigger.Selector(triggers) -- 1281
        return __TS__New(SelectorTrigger, triggers) -- 1282
    end -- 1281
    function Trigger.Block(trigger) -- 1284
        return __TS__New(BlockTrigger, trigger) -- 1285
    end -- 1284
end -- 1284
local InputManager = __TS__Class() -- 1299
InputManager.name = "InputManager" -- 1299
function InputManager.prototype.____constructor(self, contexts) -- 1304
    self.manager = Node() -- 1305
    self.contextMap = __TS__New( -- 1306
        Map, -- 1306
        __TS__ArrayMap( -- 1306
            contexts, -- 1306
            function(____, ctx) -- 1306
                for ____, action in ipairs(ctx.actions) do -- 1307
                    local eventName = "Input." .. action.name -- 1308
                    action.trigger.onChange = function() -- 1309
                        local ____action_trigger_0 = action.trigger -- 1310
                        local state = ____action_trigger_0.state -- 1310
                        local progress = ____action_trigger_0.progress -- 1310
                        local value = ____action_trigger_0.value -- 1310
                        emit(eventName, state, progress, value) -- 1311
                    end -- 1309
                end -- 1309
                return {ctx.name, ctx.actions} -- 1314
            end -- 1306
        ) -- 1306
    ) -- 1306
    self.contextStack = {} -- 1316
    self.manager:schedule(function(deltaTime) -- 1317
        if #self.contextStack > 0 then -- 1317
            local lastNames = self.contextStack[#self.contextStack] -- 1319
            for ____, name in ipairs(lastNames) do -- 1320
                do -- 1320
                    local actions = self.contextMap:get(name) -- 1321
                    if actions == nil then -- 1321
                        goto __continue328 -- 1323
                    end -- 1323
                    for ____, action in ipairs(actions) do -- 1325
                        if action.trigger.onUpdate then -- 1325
                            action.trigger:onUpdate(deltaTime) -- 1327
                        end -- 1327
                    end -- 1327
                end -- 1327
                ::__continue328:: -- 1327
            end -- 1327
        end -- 1327
        return false -- 1332
    end) -- 1317
end -- 1304
function InputManager.prototype.getNode(self) -- 1336
    return self.manager -- 1337
end -- 1336
function InputManager.prototype.pushContext(self, contextNames) -- 1340
    if type(contextNames) == "string" then -- 1340
        contextNames = {contextNames} -- 1342
    end -- 1342
    local exist = true -- 1344
    for ____, name in ipairs(contextNames) do -- 1345
        if exist then -- 1345
            exist = self.contextMap:has(name) -- 1346
        end -- 1346
    end -- 1346
    if not exist then -- 1346
        print("[Dora Error] got non-existed context name from " .. table.concat(contextNames, ", ")) -- 1349
        return false -- 1350
    else -- 1350
        if #self.contextStack > 0 then -- 1350
            local lastNames = self.contextStack[#self.contextStack] -- 1353
            for ____, name in ipairs(lastNames) do -- 1354
                do -- 1354
                    local actions = self.contextMap:get(name) -- 1355
                    if actions == nil then -- 1355
                        goto __continue342 -- 1357
                    end -- 1357
                    for ____, action in ipairs(actions) do -- 1359
                        action.trigger:stop(self.manager) -- 1360
                    end -- 1360
                end -- 1360
                ::__continue342:: -- 1360
            end -- 1360
        end -- 1360
        local ____self_contextStack_1 = self.contextStack -- 1360
        ____self_contextStack_1[#____self_contextStack_1 + 1] = contextNames -- 1364
        for ____, name in ipairs(contextNames) do -- 1365
            do -- 1365
                local actions = self.contextMap:get(name) -- 1366
                if actions == nil then -- 1366
                    goto __continue347 -- 1368
                end -- 1368
                for ____, action in ipairs(actions) do -- 1370
                    action.trigger:start(self.manager) -- 1371
                end -- 1371
            end -- 1371
            ::__continue347:: -- 1371
        end -- 1371
        return true -- 1374
    end -- 1374
end -- 1340
function InputManager.prototype.popContext(self) -- 1378
    if #self.contextStack == 0 then -- 1378
        return false -- 1380
    end -- 1380
    local lastNames = self.contextStack[#self.contextStack] -- 1382
    for ____, name in ipairs(lastNames) do -- 1383
        do -- 1383
            local actions = self.contextMap:get(name) -- 1384
            if actions == nil then -- 1384
                goto __continue354 -- 1386
            end -- 1386
            for ____, action in ipairs(actions) do -- 1388
                action.trigger:stop(self.manager) -- 1389
            end -- 1389
        end -- 1389
        ::__continue354:: -- 1389
    end -- 1389
    table.remove(self.contextStack) -- 1392
    if #self.contextStack > 0 then -- 1392
        local lastNames = self.contextStack[#self.contextStack] -- 1394
        for ____, name in ipairs(lastNames) do -- 1395
            do -- 1395
                local actions = self.contextMap:get(name) -- 1396
                if actions == nil then -- 1396
                    goto __continue360 -- 1398
                end -- 1398
                for ____, action in ipairs(actions) do -- 1400
                    action.trigger:start(self.manager) -- 1401
                end -- 1401
            end -- 1401
            ::__continue360:: -- 1401
        end -- 1401
    end -- 1401
    return true -- 1405
end -- 1378
function InputManager.prototype.emitKeyDown(self, keyName) -- 1408
    self.manager:emit("KeyDown", keyName) -- 1409
end -- 1408
function InputManager.prototype.emitKeyUp(self, keyName) -- 1412
    self.manager:emit("KeyUp", keyName) -- 1413
end -- 1412
function InputManager.prototype.emitButtonDown(self, buttonName, controllerId) -- 1416
    self.manager:emit("ButtonDown", controllerId or 0, buttonName) -- 1417
end -- 1416
function InputManager.prototype.emitButtonUp(self, buttonName, controllerId) -- 1420
    self.manager:emit("ButtonUp", controllerId or 0, buttonName) -- 1421
end -- 1420
function InputManager.prototype.emitAxis(self, axisName, value, controllerId) -- 1424
    self.manager:emit("Axis", controllerId or 0, axisName, value) -- 1425
end -- 1424
function InputManager.prototype.destroy(self) -- 1428
    self:getNode():removeFromParent() -- 1429
    self.contextStack = {} -- 1430
end -- 1428
function ____exports.CreateInputManager(contexts) -- 1434
    return __TS__New(InputManager, contexts) -- 1435
end -- 1434
function ____exports.DPad(self, props) -- 1447
    local ____props_2 = props -- 1454
    local width = ____props_2.width -- 1454
    if width == nil then -- 1454
        width = 40 -- 1449
    end -- 1449
    local height = ____props_2.height -- 1449
    if height == nil then -- 1449
        height = 40 -- 1450
    end -- 1450
    local offset = ____props_2.offset -- 1450
    if offset == nil then -- 1450
        offset = 5 -- 1451
    end -- 1451
    local color = ____props_2.color -- 1451
    if color == nil then -- 1451
        color = 4294967295 -- 1452
    end -- 1452
    local primaryOpacity = ____props_2.primaryOpacity -- 1452
    if primaryOpacity == nil then -- 1452
        primaryOpacity = 0.3 -- 1453
    end -- 1453
    local halfSize = height + width / 2 + offset -- 1455
    local dOffset = height / 2 + width / 2 + offset -- 1456
    local function DPadButton(self, props) -- 1458
        local hw = width / 2 -- 1459
        local drawNode = useRef() -- 1460
        return React:createElement( -- 1461
            "node", -- 1461
            __TS__ObjectAssign( -- 1461
                {}, -- 1461
                props, -- 1462
                { -- 1462
                    width = width, -- 1462
                    height = height, -- 1462
                    onTapBegan = function() -- 1462
                        if drawNode.current then -- 1462
                            drawNode.current.opacity = 1 -- 1465
                        end -- 1465
                    end, -- 1463
                    onTapEnded = function() -- 1463
                        if drawNode.current then -- 1463
                            drawNode.current.opacity = primaryOpacity -- 1470
                        end -- 1470
                    end -- 1468
                } -- 1468
            ), -- 1468
            React:createElement( -- 1468
                "draw-node", -- 1468
                {ref = drawNode, y = -hw, x = hw, opacity = primaryOpacity}, -- 1468
                React:createElement( -- 1468
                    "polygon-shape", -- 1468
                    { -- 1468
                        verts = { -- 1468
                            Vec2(-hw, hw + height), -- 1476
                            Vec2(hw, hw + height), -- 1477
                            Vec2(hw, hw), -- 1478
                            Vec2.zero, -- 1479
                            Vec2(-hw, hw) -- 1480
                        }, -- 1480
                        fillColor = color -- 1480
                    } -- 1480
                ) -- 1480
            ) -- 1480
        ) -- 1480
    end -- 1458
    local function onMount(buttonName) -- 1487
        return function(node) -- 1488
            node:slot( -- 1489
                "TapBegan", -- 1489
                function() return props.inputManager:emitButtonDown(buttonName) end -- 1489
            ) -- 1489
            node:slot( -- 1490
                "TapEnded", -- 1490
                function() return props.inputManager:emitButtonUp(buttonName) end -- 1490
            ) -- 1490
        end -- 1488
    end -- 1487
    return React:createElement( -- 1494
        "align-node", -- 1494
        {style = {width = halfSize * 2, height = halfSize * 2}}, -- 1494
        React:createElement( -- 1494
            "menu", -- 1494
            {x = halfSize, y = halfSize, width = halfSize * 2, height = halfSize * 2}, -- 1494
            React:createElement( -- 1494
                DPadButton, -- 1497
                { -- 1497
                    x = halfSize, -- 1497
                    y = dOffset + halfSize, -- 1497
                    onMount = onMount("dpup") -- 1497
                } -- 1497
            ), -- 1497
            React:createElement( -- 1497
                DPadButton, -- 1498
                { -- 1498
                    x = halfSize, -- 1498
                    y = -dOffset + halfSize, -- 1498
                    angle = 180, -- 1498
                    onMount = onMount("dpdown") -- 1498
                } -- 1498
            ), -- 1498
            React:createElement( -- 1498
                DPadButton, -- 1499
                { -- 1499
                    x = dOffset + halfSize, -- 1499
                    y = halfSize, -- 1499
                    angle = 90, -- 1499
                    onMount = onMount("dpright") -- 1499
                } -- 1499
            ), -- 1499
            React:createElement( -- 1499
                DPadButton, -- 1500
                { -- 1500
                    x = -dOffset + halfSize, -- 1500
                    y = halfSize, -- 1500
                    angle = -90, -- 1500
                    onMount = onMount("dpleft") -- 1500
                } -- 1500
            ) -- 1500
        ) -- 1500
    ) -- 1500
end -- 1447
local function Button(self, props) -- 1517
    local ____props_3 = props -- 1525
    local x = ____props_3.x -- 1525
    local y = ____props_3.y -- 1525
    local onMount = ____props_3.onMount -- 1525
    local text = ____props_3.text -- 1525
    local fontName = ____props_3.fontName -- 1525
    if fontName == nil then -- 1525
        fontName = "sarasa-mono-sc-regular" -- 1521
    end -- 1521
    local buttonSize = ____props_3.buttonSize -- 1521
    local color = ____props_3.color -- 1521
    if color == nil then -- 1521
        color = 4294967295 -- 1523
    end -- 1523
    local primaryOpacity = ____props_3.primaryOpacity -- 1523
    if primaryOpacity == nil then -- 1523
        primaryOpacity = 0.3 -- 1524
    end -- 1524
    local drawNode = useRef() -- 1526
    return React:createElement( -- 1527
        "node", -- 1527
        { -- 1527
            x = x, -- 1527
            y = y, -- 1527
            onMount = onMount, -- 1527
            width = buttonSize * 2, -- 1527
            height = buttonSize * 2, -- 1527
            onTapBegan = function() -- 1527
                if drawNode.current then -- 1527
                    drawNode.current.opacity = 1 -- 1531
                end -- 1531
            end, -- 1529
            onTapEnded = function() -- 1529
                if drawNode.current then -- 1529
                    drawNode.current.opacity = primaryOpacity -- 1536
                end -- 1536
            end -- 1534
        }, -- 1534
        React:createElement( -- 1534
            "draw-node", -- 1534
            {ref = drawNode, x = buttonSize, y = buttonSize, opacity = primaryOpacity}, -- 1534
            React:createElement("dot-shape", {radius = buttonSize, color = color}) -- 1534
        ), -- 1534
        React:createElement("label", { -- 1534
            x = buttonSize, -- 1534
            y = buttonSize, -- 1534
            scaleX = 0.5, -- 1534
            scaleY = 0.5, -- 1534
            color3 = color, -- 1534
            opacity = primaryOpacity + 0.2, -- 1534
            fontName = fontName, -- 1534
            fontSize = buttonSize * 2 -- 1534
        }, text) -- 1534
    ) -- 1534
end -- 1517
function ____exports.JoyStick(self, props) -- 1562
    local hat = useRef() -- 1563
    local ____props_4 = props -- 1573
    local moveSize = ____props_4.moveSize -- 1573
    if moveSize == nil then -- 1573
        moveSize = 70 -- 1565
    end -- 1565
    local hatSize = ____props_4.hatSize -- 1565
    if hatSize == nil then -- 1565
        hatSize = 40 -- 1566
    end -- 1566
    local stickType = ____props_4.stickType -- 1566
    if stickType == nil then -- 1566
        stickType = "Left" -- 1567
    end -- 1567
    local color = ____props_4.color -- 1567
    if color == nil then -- 1567
        color = 4294967295 -- 1568
    end -- 1568
    local primaryOpacity = ____props_4.primaryOpacity -- 1568
    if primaryOpacity == nil then -- 1568
        primaryOpacity = 0.3 -- 1569
    end -- 1569
    local secondaryOpacity = ____props_4.secondaryOpacity -- 1569
    if secondaryOpacity == nil then -- 1569
        secondaryOpacity = 0.1 -- 1570
    end -- 1570
    local fontName = ____props_4.fontName -- 1570
    if fontName == nil then -- 1570
        fontName = "sarasa-mono-sc-regular" -- 1571
    end -- 1571
    local buttonSize = ____props_4.buttonSize -- 1571
    if buttonSize == nil then -- 1571
        buttonSize = 20 -- 1572
    end -- 1572
    local visualBound = math.max(moveSize - hatSize, 0) -- 1574
    local stickButton = stickType == "Left" and "leftstick" or "rightstick" -- 1575
    local function updatePosition(node, location) -- 1577
        if location.length > visualBound then -- 1577
            node.position = location:normalize():mul(visualBound) -- 1579
        else -- 1579
            node.position = location -- 1581
        end -- 1581
        repeat -- 1581
            local ____switch391 = stickType -- 1581
            local ____cond391 = ____switch391 == "Left" -- 1581
            if ____cond391 then -- 1581
                props.inputManager:emitAxis("leftx", node.x / visualBound) -- 1585
                props.inputManager:emitAxis("lefty", node.y / visualBound) -- 1586
                break -- 1587
            end -- 1587
            ____cond391 = ____cond391 or ____switch391 == "Right" -- 1587
            if ____cond391 then -- 1587
                props.inputManager:emitAxis("rightx", node.x / visualBound) -- 1589
                props.inputManager:emitAxis("righty", node.y / visualBound) -- 1590
                break -- 1591
            end -- 1591
        until true -- 1591
    end -- 1577
    local ____React_9 = React -- 1577
    local ____React_createElement_10 = React.createElement -- 1577
    local ____temp_7 = {style = {width = moveSize * 2, height = moveSize * 2}} -- 1577
    local ____temp_8 = React:createElement( -- 1577
        "node", -- 1577
        { -- 1577
            x = moveSize, -- 1577
            y = moveSize, -- 1577
            onTapFilter = function(touch) -- 1577
                local ____touch_5 = touch -- 1599
                local location = ____touch_5.location -- 1599
                if location.length > moveSize then -- 1599
                    touch.enabled = false -- 1601
                end -- 1601
            end, -- 1598
            onTapBegan = function(touch) -- 1598
                if hat.current then -- 1598
                    hat.current.opacity = 1 -- 1606
                    updatePosition(hat.current, touch.location) -- 1607
                end -- 1607
            end, -- 1604
            onTapMoved = function(touch) -- 1604
                if hat.current then -- 1604
                    hat.current.opacity = 1 -- 1612
                    updatePosition(hat.current, touch.location) -- 1613
                end -- 1613
            end, -- 1610
            onTapped = function() -- 1610
                if hat.current then -- 1610
                    hat.current.opacity = primaryOpacity -- 1618
                    updatePosition(hat.current, Vec2.zero) -- 1619
                end -- 1619
            end -- 1616
        }, -- 1616
        React:createElement( -- 1616
            "draw-node", -- 1616
            {opacity = secondaryOpacity}, -- 1616
            React:createElement("dot-shape", {radius = moveSize, color = color}) -- 1616
        ), -- 1616
        React:createElement( -- 1616
            "draw-node", -- 1616
            {ref = hat, opacity = primaryOpacity}, -- 1616
            React:createElement("dot-shape", {radius = hatSize, color = color}) -- 1616
        ) -- 1616
    ) -- 1616
    local ____props_noStickButton_6 -- 1630
    if props.noStickButton then -- 1630
        ____props_noStickButton_6 = nil -- 1630
    else -- 1630
        ____props_noStickButton_6 = React:createElement( -- 1630
            Button, -- 1631
            { -- 1631
                buttonSize = buttonSize, -- 1631
                x = moveSize, -- 1631
                y = moveSize * 2 + buttonSize / 2 + 20, -- 1631
                text = stickType == "Left" and "LS" or "RS", -- 1631
                fontName = fontName, -- 1631
                color = color, -- 1631
                primaryOpacity = primaryOpacity, -- 1631
                onMount = function(node) -- 1631
                    node:slot( -- 1640
                        "TapBegan", -- 1640
                        function() return props.inputManager:emitButtonDown(stickButton) end -- 1640
                    ) -- 1640
                    node:slot( -- 1641
                        "TapEnded", -- 1641
                        function() return props.inputManager:emitButtonUp(stickButton) end -- 1641
                    ) -- 1641
                end -- 1639
            } -- 1639
        ) -- 1639
    end -- 1639
    return ____React_createElement_10( -- 1595
        ____React_9, -- 1595
        "align-node", -- 1595
        ____temp_7, -- 1595
        ____temp_8, -- 1595
        ____props_noStickButton_6 -- 1595
    ) -- 1595
end -- 1562
function ____exports.ButtonPad(self, props) -- 1658
    local ____props_11 = props -- 1665
    local buttonSize = ____props_11.buttonSize -- 1665
    if buttonSize == nil then -- 1665
        buttonSize = 30 -- 1660
    end -- 1660
    local buttonPadding = ____props_11.buttonPadding -- 1660
    if buttonPadding == nil then -- 1660
        buttonPadding = 10 -- 1661
    end -- 1661
    local fontName = ____props_11.fontName -- 1661
    if fontName == nil then -- 1661
        fontName = "sarasa-mono-sc-regular" -- 1662
    end -- 1662
    local color = ____props_11.color -- 1662
    if color == nil then -- 1662
        color = 4294967295 -- 1663
    end -- 1663
    local primaryOpacity = ____props_11.primaryOpacity -- 1663
    if primaryOpacity == nil then -- 1663
        primaryOpacity = 0.3 -- 1664
    end -- 1664
    local width = buttonSize * 5 + buttonPadding * 3 / 2 -- 1666
    local height = buttonSize * 4 + buttonPadding -- 1667
    local function onMount(buttonName) -- 1668
        return function(node) -- 1669
            node:slot( -- 1670
                "TapBegan", -- 1670
                function() return props.inputManager:emitButtonDown(buttonName) end -- 1670
            ) -- 1670
            node:slot( -- 1671
                "TapEnded", -- 1671
                function() return props.inputManager:emitButtonUp(buttonName) end -- 1671
            ) -- 1671
        end -- 1669
    end -- 1668
    return React:createElement( -- 1674
        "align-node", -- 1674
        {style = {width = width, height = height}}, -- 1674
        React:createElement( -- 1674
            "node", -- 1674
            {x = (buttonSize + buttonPadding / 2) / 2 + width / 2, y = buttonSize + buttonPadding / 2 + height / 2}, -- 1674
            React:createElement( -- 1674
                Button, -- 1680
                { -- 1680
                    text = "B", -- 1680
                    fontName = fontName, -- 1680
                    color = color, -- 1680
                    primaryOpacity = primaryOpacity, -- 1680
                    buttonSize = buttonSize, -- 1680
                    x = -buttonSize * 2 - buttonPadding, -- 1680
                    onMount = onMount("b") -- 1680
                } -- 1680
            ), -- 1680
            React:createElement( -- 1680
                Button, -- 1686
                { -- 1686
                    text = "Y", -- 1686
                    fontName = fontName, -- 1686
                    color = color, -- 1686
                    primaryOpacity = primaryOpacity, -- 1686
                    buttonSize = buttonSize, -- 1686
                    onMount = onMount("y") -- 1686
                } -- 1686
            ), -- 1686
            React:createElement( -- 1686
                Button, -- 1690
                { -- 1690
                    text = "A", -- 1690
                    fontName = fontName, -- 1690
                    color = color, -- 1690
                    primaryOpacity = primaryOpacity, -- 1690
                    buttonSize = buttonSize, -- 1690
                    x = -buttonSize - buttonPadding / 2, -- 1690
                    y = -buttonSize * 2 - buttonPadding, -- 1690
                    onMount = onMount("a") -- 1690
                } -- 1690
            ), -- 1690
            React:createElement( -- 1690
                Button, -- 1697
                { -- 1697
                    text = "X", -- 1697
                    fontName = fontName, -- 1697
                    color = color, -- 1697
                    primaryOpacity = primaryOpacity, -- 1697
                    buttonSize = buttonSize, -- 1697
                    x = buttonSize + buttonPadding / 2, -- 1697
                    y = -buttonSize * 2 - buttonPadding, -- 1697
                    onMount = onMount("x") -- 1697
                } -- 1697
            ) -- 1697
        ) -- 1697
    ) -- 1697
end -- 1658
function ____exports.ControlPad(self, props) -- 1717
    local ____props_12 = props -- 1723
    local buttonSize = ____props_12.buttonSize -- 1723
    if buttonSize == nil then -- 1723
        buttonSize = 35 -- 1719
    end -- 1719
    local fontName = ____props_12.fontName -- 1719
    if fontName == nil then -- 1719
        fontName = "sarasa-mono-sc-regular" -- 1720
    end -- 1720
    local color = ____props_12.color -- 1720
    if color == nil then -- 1720
        color = 4294967295 -- 1721
    end -- 1721
    local primaryOpacity = ____props_12.primaryOpacity -- 1721
    if primaryOpacity == nil then -- 1721
        primaryOpacity = 0.3 -- 1722
    end -- 1722
    local function Button(self, props) -- 1724
        local drawNode = useRef() -- 1725
        return React:createElement( -- 1726
            "node", -- 1726
            __TS__ObjectAssign( -- 1726
                {}, -- 1726
                props, -- 1727
                { -- 1727
                    width = buttonSize * 2, -- 1727
                    height = buttonSize, -- 1727
                    onTapBegan = function() -- 1727
                        if drawNode.current then -- 1727
                            drawNode.current.opacity = 1 -- 1730
                        end -- 1730
                    end, -- 1728
                    onTapEnded = function() -- 1728
                        if drawNode.current then -- 1728
                            drawNode.current.opacity = primaryOpacity -- 1735
                        end -- 1735
                    end -- 1733
                } -- 1733
            ), -- 1733
            React:createElement( -- 1733
                "draw-node", -- 1733
                {ref = drawNode, x = buttonSize, y = buttonSize / 2, opacity = primaryOpacity}, -- 1733
                React:createElement("rect-shape", {width = buttonSize * 2, height = buttonSize, fillColor = color}) -- 1733
            ), -- 1733
            React:createElement( -- 1733
                "label", -- 1733
                { -- 1733
                    x = buttonSize, -- 1733
                    y = buttonSize / 2, -- 1733
                    scaleX = 0.5, -- 1733
                    scaleY = 0.5, -- 1733
                    fontName = fontName, -- 1733
                    fontSize = math.floor(buttonSize * 1.5), -- 1733
                    color3 = color, -- 1733
                    opacity = primaryOpacity + 0.2 -- 1733
                }, -- 1733
                props.text -- 1744
            ) -- 1744
        ) -- 1744
    end -- 1724
    local function onMount(buttonName) -- 1748
        return function(node) -- 1749
            node:slot( -- 1750
                "TapBegan", -- 1750
                function() return props.inputManager:emitButtonDown(buttonName) end -- 1750
            ) -- 1750
            node:slot( -- 1751
                "TapEnded", -- 1751
                function() return props.inputManager:emitButtonUp(buttonName) end -- 1751
            ) -- 1751
        end -- 1749
    end -- 1748
    return React:createElement( -- 1754
        "align-node", -- 1754
        {style = {minWidth = buttonSize * 4 + 20, justifyContent = "space-between", flexDirection = "row"}}, -- 1754
        React:createElement( -- 1754
            "align-node", -- 1754
            {style = {width = buttonSize * 2, height = buttonSize}}, -- 1754
            React:createElement( -- 1754
                Button, -- 1757
                { -- 1757
                    text = "Start", -- 1757
                    x = buttonSize, -- 1757
                    y = buttonSize / 2, -- 1757
                    onMount = onMount("start") -- 1757
                } -- 1757
            ) -- 1757
        ), -- 1757
        React:createElement( -- 1757
            "align-node", -- 1757
            {style = {width = buttonSize * 2, height = buttonSize}}, -- 1757
            React:createElement( -- 1757
                Button, -- 1763
                { -- 1763
                    text = "Back", -- 1763
                    x = buttonSize, -- 1763
                    y = buttonSize / 2, -- 1763
                    onMount = onMount("back") -- 1763
                } -- 1763
            ) -- 1763
        ) -- 1763
    ) -- 1763
end -- 1717
function ____exports.CreateControlPad(props) -- 1772
    return toNode(React:createElement( -- 1773
        ____exports.ControlPad, -- 1773
        __TS__ObjectAssign({}, props) -- 1773
    )) -- 1773
end -- 1772
function ____exports.TriggerPad(self, props) -- 1787
    local ____props_13 = props -- 1793
    local buttonSize = ____props_13.buttonSize -- 1793
    if buttonSize == nil then -- 1793
        buttonSize = 35 -- 1789
    end -- 1789
    local fontName = ____props_13.fontName -- 1789
    if fontName == nil then -- 1789
        fontName = "sarasa-mono-sc-regular" -- 1790
    end -- 1790
    local color = ____props_13.color -- 1790
    if color == nil then -- 1790
        color = 4294967295 -- 1791
    end -- 1791
    local primaryOpacity = ____props_13.primaryOpacity -- 1791
    if primaryOpacity == nil then -- 1791
        primaryOpacity = 0.3 -- 1792
    end -- 1792
    local function Button(self, props) -- 1794
        local drawNode = useRef() -- 1795
        return React:createElement( -- 1796
            "node", -- 1796
            __TS__ObjectAssign( -- 1796
                {}, -- 1796
                props, -- 1797
                { -- 1797
                    width = buttonSize * 2, -- 1797
                    height = buttonSize, -- 1797
                    onTapBegan = function() -- 1797
                        if drawNode.current then -- 1797
                            drawNode.current.opacity = 1 -- 1800
                        end -- 1800
                    end, -- 1798
                    onTapEnded = function() -- 1798
                        if drawNode.current then -- 1798
                            drawNode.current.opacity = primaryOpacity -- 1805
                        end -- 1805
                    end -- 1803
                } -- 1803
            ), -- 1803
            React:createElement( -- 1803
                "draw-node", -- 1803
                {ref = drawNode, x = buttonSize, y = buttonSize / 2, opacity = primaryOpacity}, -- 1803
                React:createElement("rect-shape", {width = buttonSize * 2, height = buttonSize, fillColor = color}) -- 1803
            ), -- 1803
            React:createElement( -- 1803
                "label", -- 1803
                { -- 1803
                    x = buttonSize, -- 1803
                    y = buttonSize / 2, -- 1803
                    scaleX = 0.5, -- 1803
                    scaleY = 0.5, -- 1803
                    fontName = fontName, -- 1803
                    fontSize = math.floor(buttonSize * 1.5), -- 1803
                    color3 = color, -- 1803
                    opacity = primaryOpacity + 0.2 -- 1803
                }, -- 1803
                props.text -- 1813
            ) -- 1813
        ) -- 1813
    end -- 1794
    local function onMountAxis(axisName) -- 1817
        return function(node) -- 1818
            node:slot( -- 1819
                "TapBegan", -- 1819
                function() return props.inputManager:emitAxis(axisName, 1, 0) end -- 1819
            ) -- 1819
            node:slot( -- 1820
                "TapEnded", -- 1820
                function() return props.inputManager:emitAxis(axisName, 0, 0) end -- 1820
            ) -- 1820
        end -- 1818
    end -- 1817
    local function onMountButton(buttonName) -- 1823
        return function(node) -- 1824
            node:slot( -- 1825
                "TapBegan", -- 1825
                function() return props.inputManager:emitButtonDown(buttonName, 0) end -- 1825
            ) -- 1825
            node:slot( -- 1826
                "TapEnded", -- 1826
                function() return props.inputManager:emitButtonUp(buttonName, 0) end -- 1826
            ) -- 1826
        end -- 1824
    end -- 1823
    local ____React_25 = React -- 1823
    local ____React_createElement_26 = React.createElement -- 1823
    local ____temp_23 = {style = {minWidth = buttonSize * 4 + 20, justifyContent = "space-between", flexDirection = "row"}} -- 1823
    local ____React_17 = React -- 1823
    local ____React_createElement_18 = React.createElement -- 1823
    local ____temp_15 = {style = {width = buttonSize * 4 + 10, height = buttonSize}} -- 1823
    local ____temp_16 = React:createElement( -- 1823
        Button, -- 1832
        { -- 1832
            text = "LT", -- 1832
            x = buttonSize, -- 1832
            y = buttonSize / 2, -- 1832
            onMount = onMountAxis("lefttrigger") -- 1832
        } -- 1832
    ) -- 1832
    local ____props_noShoulder_14 -- 1836
    if props.noShoulder then -- 1836
        ____props_noShoulder_14 = nil -- 1836
    else -- 1836
        ____props_noShoulder_14 = React:createElement( -- 1836
            Button, -- 1837
            { -- 1837
                text = "LB", -- 1837
                x = buttonSize * 3 + 10, -- 1837
                y = buttonSize / 2, -- 1837
                onMount = onMountButton("leftshoulder") -- 1837
            } -- 1837
        ) -- 1837
    end -- 1837
    local ____React_createElement_18_result_24 = ____React_createElement_18( -- 1837
        ____React_17, -- 1837
        "align-node", -- 1837
        ____temp_15, -- 1837
        ____temp_16, -- 1837
        ____props_noShoulder_14 -- 1837
    ) -- 1837
    local ____React_21 = React -- 1837
    local ____React_createElement_22 = React.createElement -- 1837
    local ____temp_20 = {style = {width = buttonSize * 4 + 10, height = buttonSize}} -- 1837
    local ____props_noShoulder_19 -- 1844
    if props.noShoulder then -- 1844
        ____props_noShoulder_19 = nil -- 1844
    else -- 1844
        ____props_noShoulder_19 = React:createElement( -- 1844
            Button, -- 1845
            { -- 1845
                text = "RB", -- 1845
                x = buttonSize, -- 1845
                y = buttonSize / 2, -- 1845
                onMount = onMountButton("rightshoulder") -- 1845
            } -- 1845
        ) -- 1845
    end -- 1845
    return ____React_createElement_26( -- 1829
        ____React_25, -- 1829
        "align-node", -- 1829
        ____temp_23, -- 1829
        ____React_createElement_18_result_24, -- 1829
        ____React_createElement_22( -- 1829
            ____React_21, -- 1829
            "align-node", -- 1829
            ____temp_20, -- 1829
            ____props_noShoulder_19, -- 1829
            React:createElement( -- 1829
                Button, -- 1850
                { -- 1850
                    text = "RT", -- 1850
                    x = buttonSize * 3 + 10, -- 1850
                    y = buttonSize / 2, -- 1850
                    onMount = onMountAxis("righttrigger") -- 1850
                } -- 1850
            ) -- 1850
        ) -- 1850
    ) -- 1850
end -- 1787
function ____exports.CreateTriggerPad(props) -- 1859
    return toNode(React:createElement( -- 1860
        ____exports.TriggerPad, -- 1860
        __TS__ObjectAssign({}, props) -- 1860
    )) -- 1860
end -- 1859
function ____exports.GamePad(self, props) -- 1880
    local ____props_27 = props -- 1881
    local color = ____props_27.color -- 1881
    local primaryOpacity = ____props_27.primaryOpacity -- 1881
    local secondaryOpacity = ____props_27.secondaryOpacity -- 1881
    local inputManager = ____props_27.inputManager -- 1881
    local ____React_46 = React -- 1881
    local ____React_createElement_47 = React.createElement -- 1881
    local ____temp_44 = {style = {flexDirection = "column-reverse"}, windowRoot = true} -- 1881
    local ____React_40 = React -- 1881
    local ____React_createElement_41 = React.createElement -- 1881
    local ____temp_38 = {style = {margin = 20, justifyContent = "space-between", flexDirection = "row", alignItems = "flex-end"}} -- 1881
    local ____React_31 = React -- 1881
    local ____React_createElement_32 = React.createElement -- 1881
    local ____temp_30 = {style = {justifyContent = "space-between", flexDirection = "row", alignItems = "flex-end"}} -- 1881
    local ____props_noDPad_28 -- 1895
    if props.noDPad then -- 1895
        ____props_noDPad_28 = nil -- 1895
    else -- 1895
        ____props_noDPad_28 = React:createElement(____exports.DPad, {color = color, primaryOpacity = primaryOpacity, inputManager = inputManager}) -- 1895
    end -- 1895
    local ____props_noLeftStick_29 -- 1902
    if props.noLeftStick then -- 1902
        ____props_noLeftStick_29 = nil -- 1902
    else -- 1902
        ____props_noLeftStick_29 = React:createElement( -- 1902
            React.Fragment, -- 1902
            nil, -- 1902
            React:createElement("align-node", {style = {width = 10}}), -- 1902
            React:createElement(____exports.JoyStick, { -- 1902
                stickType = "Left", -- 1902
                color = color, -- 1902
                primaryOpacity = primaryOpacity, -- 1902
                secondaryOpacity = secondaryOpacity, -- 1902
                inputManager = inputManager, -- 1902
                noStickButton = props.noStickButton -- 1902
            }) -- 1902
        ) -- 1902
    end -- 1902
    local ____React_createElement_32_result_39 = ____React_createElement_32( -- 1902
        ____React_31, -- 1902
        "align-node", -- 1902
        ____temp_30, -- 1902
        ____props_noDPad_28, -- 1902
        ____props_noLeftStick_29 -- 1902
    ) -- 1902
    local ____React_36 = React -- 1902
    local ____React_createElement_37 = React.createElement -- 1902
    local ____temp_35 = {style = {justifyContent = "space-between", flexDirection = "row", alignItems = "flex-end"}} -- 1902
    local ____props_noRightStick_33 -- 1919
    if props.noRightStick then -- 1919
        ____props_noRightStick_33 = nil -- 1919
    else -- 1919
        ____props_noRightStick_33 = React:createElement( -- 1919
            React.Fragment, -- 1919
            nil, -- 1919
            React:createElement(____exports.JoyStick, { -- 1919
                stickType = "Right", -- 1919
                color = color, -- 1919
                primaryOpacity = primaryOpacity, -- 1919
                secondaryOpacity = secondaryOpacity, -- 1919
                inputManager = inputManager, -- 1919
                noStickButton = props.noStickButton -- 1919
            }), -- 1919
            React:createElement("align-node", {style = {width = 10}}) -- 1919
        ) -- 1919
    end -- 1919
    local ____props_noButtonPad_34 -- 1930
    if props.noButtonPad then -- 1930
        ____props_noButtonPad_34 = nil -- 1930
    else -- 1930
        ____props_noButtonPad_34 = React:createElement(____exports.ButtonPad, {color = color, primaryOpacity = primaryOpacity, inputManager = inputManager}) -- 1930
    end -- 1930
    local ____React_createElement_41_result_45 = ____React_createElement_41( -- 1930
        ____React_40, -- 1930
        "align-node", -- 1930
        ____temp_38, -- 1930
        ____React_createElement_32_result_39, -- 1930
        ____React_createElement_37( -- 1930
            ____React_36, -- 1930
            "align-node", -- 1930
            ____temp_35, -- 1930
            ____props_noRightStick_33, -- 1930
            ____props_noButtonPad_34 -- 1930
        ) -- 1930
    ) -- 1930
    local ____props_noTriggerPad_42 -- 1939
    if props.noTriggerPad then -- 1939
        ____props_noTriggerPad_42 = nil -- 1939
    else -- 1939
        ____props_noTriggerPad_42 = React:createElement( -- 1939
            "align-node", -- 1939
            {style = {paddingLeft = 20, paddingRight = 20, paddingTop = 20}}, -- 1939
            React:createElement(____exports.TriggerPad, {color = color, noShoulder = props.noShoulder, primaryOpacity = primaryOpacity, inputManager = inputManager}) -- 1939
        ) -- 1939
    end -- 1939
    local ____props_noControlPad_43 -- 1949
    if props.noControlPad then -- 1949
        ____props_noControlPad_43 = nil -- 1949
    else -- 1949
        ____props_noControlPad_43 = React:createElement( -- 1949
            "align-node", -- 1949
            {style = {paddingLeft = 20, paddingRight = 20}}, -- 1949
            React:createElement(____exports.ControlPad, {color = color, primaryOpacity = primaryOpacity, inputManager = inputManager}) -- 1949
        ) -- 1949
    end -- 1949
    return ____React_createElement_47( -- 1882
        ____React_46, -- 1882
        "align-node", -- 1882
        ____temp_44, -- 1882
        ____React_createElement_41_result_45, -- 1882
        ____props_noTriggerPad_42, -- 1882
        ____props_noControlPad_43 -- 1882
    ) -- 1882
end -- 1880
function ____exports.CreateGamePad(props) -- 1962
    return toNode(React:createElement( -- 1963
        ____exports.GamePad, -- 1963
        __TS__ObjectAssign({}, props) -- 1963
    )) -- 1963
end -- 1962
return ____exports -- 1962