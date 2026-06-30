-- [tsx]: InputManager.tsx
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ArraySplice = ____lualib.__TS__ArraySplice -- 1
local __TS__ClassExtends = ____lualib.__TS__ClassExtends -- 1
local __TS__ArrayConcat = ____lualib.__TS__ArrayConcat -- 1
local __TS__New = ____lualib.__TS__New -- 1
local Map = ____lualib.Map -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local ____exports = {} -- 1
local ____DoraX = require("DoraX") -- 1
local React = ____DoraX.React -- 1
local toNode = ____DoraX.toNode -- 1
local reference = ____DoraX.reference -- 1
local ____Dora = require("Dora") -- 2
local Node = ____Dora.Node -- 2
local Vec2 = ____Dora.Vec2 -- 2
local emit = ____Dora.emit -- 2
____exports.Trigger = __TS__Class() -- 16
local Trigger = ____exports.Trigger -- 16
Trigger.name = "Trigger" -- 16
function Trigger.prototype.____constructor(self) -- 17
	self.state = "None" -- 18
	self.progress = 0 -- 19
	self.value = false -- 20
	self.listeners = {} -- 21
end -- 17
function Trigger.prototype.addListener(self, listener) -- 29
	local ____self_listeners_0 = self.listeners -- 29
	____self_listeners_0[#____self_listeners_0 + 1] = listener -- 30
end -- 29
function Trigger.prototype.removeListener(self, listener) -- 32
	do -- 32
		local i = #self.listeners - 1 -- 33
		while i >= 0 do -- 33
			if self.listeners[i + 1] == listener then -- 33
				__TS__ArraySplice(self.listeners, i, 1) -- 35
			end -- 35
			i = i - 1 -- 33
		end -- 33
	end -- 33
end -- 32
function Trigger.prototype.notifyChange(self) -- 39
	if self.onChange then -- 39
		self:onChange() -- 41
	end -- 41
	local listeners = {table.unpack(self.listeners)} -- 43
	for ____, listener in ipairs(listeners) do -- 44
		listener(self) -- 45
	end -- 45
end -- 39
local KeyDownTrigger = __TS__Class() -- 52
KeyDownTrigger.name = "KeyDownTrigger" -- 52
__TS__ClassExtends(KeyDownTrigger, ____exports.Trigger) -- 52
function KeyDownTrigger.prototype.____constructor(self, keys) -- 58
	KeyDownTrigger.____super.prototype.____constructor(self) -- 59
	self.keys = keys -- 60
	self.keyStates = {} -- 61
	self.onKeyDown = function(keyName) -- 62
		if not (self.keyStates[keyName] ~= nil) then -- 62
			return -- 64
		end -- 64
		local oldState = true -- 66
		for ____, state in pairs(self.keyStates) do -- 67
			if oldState then -- 67
				oldState = state -- 68
			end -- 68
		end -- 68
		self.keyStates[keyName] = true -- 70
		if not oldState then -- 70
			local newState = true -- 72
			for ____, state in pairs(self.keyStates) do -- 73
				if newState then -- 73
					newState = state -- 74
				end -- 74
			end -- 74
			if newState then -- 74
				self.state = "Completed" -- 77
				self:notifyChange() -- 78
				self.state = "None" -- 79
			end -- 79
		end -- 79
	end -- 62
	self.onKeyUp = function(keyName) -- 83
		if not (self.keyStates[keyName] ~= nil) then -- 83
			return -- 85
		end -- 85
		self.keyStates[keyName] = false -- 87
	end -- 83
end -- 58
function KeyDownTrigger.prototype.start(self, manager) -- 90
	manager.keyboardEnabled = true -- 91
	for ____, k in ipairs(self.keys) do -- 92
		self.keyStates[k] = false -- 93
	end -- 93
	manager:slot("KeyDown", self.onKeyDown) -- 95
	manager:slot("KeyUp", self.onKeyUp) -- 96
	self.state = "None" -- 97
end -- 90
function KeyDownTrigger.prototype.stop(self, manager) -- 99
	manager:slot("KeyDown"):remove(self.onKeyDown) -- 100
	manager:slot("KeyUp"):remove(self.onKeyUp) -- 101
	self.state = "None" -- 102
end -- 99
local KeyUpTrigger = __TS__Class() -- 106
KeyUpTrigger.name = "KeyUpTrigger" -- 106
__TS__ClassExtends(KeyUpTrigger, ____exports.Trigger) -- 106
function KeyUpTrigger.prototype.____constructor(self, keys) -- 112
	KeyUpTrigger.____super.prototype.____constructor(self) -- 113
	self.keys = keys -- 114
	self.keyStates = {} -- 115
	self.onKeyDown = function(keyName) -- 116
		if not (self.keyStates[keyName] ~= nil) then -- 116
			return -- 118
		end -- 118
		self.keyStates[keyName] = true -- 120
	end -- 116
	self.onKeyUp = function(keyName) -- 122
		if not (self.keyStates[keyName] ~= nil) then -- 122
			return -- 124
		end -- 124
		local oldState = true -- 126
		for ____, state in pairs(self.keyStates) do -- 127
			if oldState then -- 127
				oldState = state -- 128
			end -- 128
		end -- 128
		self.keyStates[keyName] = false -- 130
		if oldState then -- 130
			self.state = "Completed" -- 132
			self:notifyChange() -- 133
			self.state = "None" -- 134
		end -- 134
	end -- 122
end -- 112
function KeyUpTrigger.prototype.start(self, manager) -- 138
	manager.keyboardEnabled = true -- 139
	for ____, k in ipairs(self.keys) do -- 140
		self.keyStates[k] = false -- 141
	end -- 141
	manager:slot("KeyDown", self.onKeyDown) -- 143
	manager:slot("KeyUp", self.onKeyUp) -- 144
	self.state = "None" -- 145
end -- 138
function KeyUpTrigger.prototype.stop(self, manager) -- 147
	manager:slot("KeyDown"):remove(self.onKeyDown) -- 148
	manager:slot("KeyUp"):remove(self.onKeyUp) -- 149
	self.state = "None" -- 150
end -- 147
local KeyPressedTrigger = __TS__Class() -- 154
KeyPressedTrigger.name = "KeyPressedTrigger" -- 154
__TS__ClassExtends(KeyPressedTrigger, ____exports.Trigger) -- 154
function KeyPressedTrigger.prototype.____constructor(self, keys) -- 160
	KeyPressedTrigger.____super.prototype.____constructor(self) -- 161
	self.keys = keys -- 162
	self.keyStates = {} -- 163
	self.onKeyDown = function(keyName) -- 164
		if not (self.keyStates[keyName] ~= nil) then -- 164
			return -- 166
		end -- 166
		self.keyStates[keyName] = true -- 168
		local allDown = true -- 169
		for ____, down in pairs(self.keyStates) do -- 170
			if allDown then -- 170
				allDown = down -- 171
			end -- 171
		end -- 171
		if allDown then -- 171
			self.state = "Completed" -- 174
		end -- 174
	end -- 164
	self.onKeyUp = function(keyName) -- 177
		if not (self.keyStates[keyName] ~= nil) then -- 177
			return -- 179
		end -- 179
		self.keyStates[keyName] = false -- 181
		local allDown = true -- 182
		for ____, down in pairs(self.keyStates) do -- 183
			if allDown then -- 183
				allDown = down -- 184
			end -- 184
		end -- 184
		if not allDown then -- 184
			self.state = "None" -- 187
		end -- 187
	end -- 177
end -- 160
function KeyPressedTrigger.prototype.onUpdate(self, _) -- 191
	if self.state == "Completed" then -- 191
		self:notifyChange() -- 193
	end -- 193
end -- 191
function KeyPressedTrigger.prototype.start(self, manager) -- 196
	manager.keyboardEnabled = true -- 197
	for ____, k in ipairs(self.keys) do -- 198
		self.keyStates[k] = false -- 199
	end -- 199
	manager:slot("KeyDown", self.onKeyDown) -- 201
	manager:slot("KeyUp", self.onKeyUp) -- 202
	self.state = "None" -- 203
end -- 196
function KeyPressedTrigger.prototype.stop(self, manager) -- 205
	manager:slot("KeyDown"):remove(self.onKeyDown) -- 206
	manager:slot("KeyUp"):remove(self.onKeyUp) -- 207
	self.state = "None" -- 208
end -- 205
local KeyHoldTrigger = __TS__Class() -- 212
KeyHoldTrigger.name = "KeyHoldTrigger" -- 212
__TS__ClassExtends(KeyHoldTrigger, ____exports.Trigger) -- 212
function KeyHoldTrigger.prototype.____constructor(self, key, holdTime) -- 219
	KeyHoldTrigger.____super.prototype.____constructor(self) -- 220
	self.key = key -- 221
	self.holdTime = holdTime -- 222
	self.time = 0 -- 223
	self.onKeyDown = function(keyName) -- 224
		if self.key == keyName then -- 224
			self.time = 0 -- 226
			self.state = "Started" -- 227
			self.progress = 0 -- 228
			self:notifyChange() -- 229
		end -- 229
	end -- 224
	self.onKeyUp = function(keyName) -- 232
		repeat -- 232
			local ____switch55 = self.state -- 232
			local ____cond55 = ____switch55 == "Started" or ____switch55 == "Ongoing" or ____switch55 == "Completed" -- 232
			if ____cond55 then -- 232
				break -- 237
			end -- 237
			do -- 237
				return -- 239
			end -- 239
		until true -- 239
		if self.key == keyName then -- 239
			if self.state == "Completed" then -- 239
				self.state = "None" -- 243
			else -- 243
				self.state = "Canceled" -- 245
			end -- 245
			self.progress = 0 -- 247
			self:notifyChange() -- 248
		end -- 248
	end -- 232
end -- 219
function KeyHoldTrigger.prototype.start(self, manager) -- 252
	manager.keyboardEnabled = true -- 253
	manager:slot("KeyDown", self.onKeyDown) -- 254
	manager:slot("KeyUp", self.onKeyUp) -- 255
	self.state = "None" -- 256
	self.progress = 0 -- 257
end -- 252
function KeyHoldTrigger.prototype.onUpdate(self, deltaTime) -- 259
	repeat -- 259
		local ____switch61 = self.state -- 259
		local ____cond61 = ____switch61 == "Started" or ____switch61 == "Ongoing" -- 259
		if ____cond61 then -- 259
			break -- 263
		end -- 263
		do -- 263
			return -- 265
		end -- 265
	until true -- 265
	self.time = self.time + deltaTime -- 267
	if self.time >= self.holdTime then -- 267
		self.state = "Completed" -- 269
		self.progress = 1 -- 270
	else -- 270
		self.state = "Ongoing" -- 272
		self.progress = math.min(self.time / self.holdTime, 1) -- 273
	end -- 273
	self:notifyChange() -- 275
end -- 259
function KeyHoldTrigger.prototype.stop(self, manager) -- 277
	manager:slot("KeyDown"):remove(self.onKeyDown) -- 278
	manager:slot("KeyUp"):remove(self.onKeyUp) -- 279
	self.state = "None" -- 280
	self.progress = 0 -- 281
end -- 277
local KeyTimedTrigger = __TS__Class() -- 285
KeyTimedTrigger.name = "KeyTimedTrigger" -- 285
__TS__ClassExtends(KeyTimedTrigger, ____exports.Trigger) -- 285
function KeyTimedTrigger.prototype.____constructor(self, key, timeWindow) -- 291
	KeyTimedTrigger.____super.prototype.____constructor(self) -- 292
	self.key = key -- 293
	self.timeWindow = timeWindow -- 294
	self.time = 0 -- 295
	self.onKeyDown = function(keyName) -- 296
		repeat -- 296
			local ____switch67 = self.state -- 296
			local ____cond67 = ____switch67 == "Started" or ____switch67 == "Ongoing" or ____switch67 == "Completed" -- 296
			if ____cond67 then -- 296
				break -- 301
			end -- 301
			do -- 301
				return -- 303
			end -- 303
		until true -- 303
		if self.key == keyName and self.time <= self.timeWindow then -- 303
			self.state = "Completed" -- 306
			self.value = self.time -- 307
			self:notifyChange() -- 308
		end -- 308
	end -- 296
end -- 291
function KeyTimedTrigger.prototype.start(self, manager) -- 312
	manager.keyboardEnabled = true -- 313
	manager:slot("KeyDown", self.onKeyDown) -- 314
	self.state = "Started" -- 315
	self.time = 0 -- 316
	self.progress = 0 -- 317
	self.value = false -- 318
	self:notifyChange() -- 319
end -- 312
function KeyTimedTrigger.prototype.onUpdate(self, deltaTime) -- 321
	repeat -- 321
		local ____switch71 = self.state -- 321
		local ____cond71 = ____switch71 == "Started" or ____switch71 == "Ongoing" or ____switch71 == "Completed" -- 321
		if ____cond71 then -- 321
			break -- 326
		end -- 326
		do -- 326
			return -- 328
		end -- 328
	until true -- 328
	self.time = self.time + deltaTime -- 330
	if self.time >= self.timeWindow then -- 330
		if self.state == "Completed" then -- 330
			self.state = "None" -- 333
			self.progress = 0 -- 334
		else -- 334
			self.state = "Canceled" -- 336
			self.progress = 1 -- 337
		end -- 337
	else -- 337
		self.state = "Ongoing" -- 340
		self.progress = math.min(self.time / self.timeWindow, 1) -- 341
	end -- 341
	self:notifyChange() -- 343
end -- 321
function KeyTimedTrigger.prototype.stop(self, manager) -- 345
	manager:slot("KeyDown"):remove(self.onKeyDown) -- 346
	self.state = "None" -- 347
	self.value = false -- 348
	self.progress = 0 -- 349
end -- 345
local KeyDoubleDownTrigger = __TS__Class() -- 353
KeyDoubleDownTrigger.name = "KeyDoubleDownTrigger" -- 353
__TS__ClassExtends(KeyDoubleDownTrigger, ____exports.Trigger) -- 353
function KeyDoubleDownTrigger.prototype.____constructor(self, key, threshold) -- 359
	KeyDoubleDownTrigger.____super.prototype.____constructor(self) -- 360
	self.key = key -- 361
	self.threshold = threshold -- 362
	self.time = 0 -- 363
	self.onKeyDown = function(keyName) -- 364
		if self.key == keyName then -- 364
			if self.state == "None" then -- 364
				self.time = 0 -- 367
				self.state = "Started" -- 368
				self.progress = 0 -- 369
				self:notifyChange() -- 370
			else -- 370
				self.state = "Completed" -- 372
				self:notifyChange() -- 373
				self.state = "None" -- 374
			end -- 374
		end -- 374
	end -- 364
end -- 359
function KeyDoubleDownTrigger.prototype.start(self, manager) -- 379
	manager.keyboardEnabled = true -- 380
	manager:slot("KeyDown", self.onKeyDown) -- 381
	self.state = "None" -- 382
	self.progress = 0 -- 383
end -- 379
function KeyDoubleDownTrigger.prototype.onUpdate(self, deltaTime) -- 385
	repeat -- 385
		local ____switch84 = self.state -- 385
		local ____cond84 = ____switch84 == "Started" or ____switch84 == "Ongoing" -- 385
		if ____cond84 then -- 385
			break -- 389
		end -- 389
		do -- 389
			return -- 391
		end -- 391
	until true -- 391
	self.time = self.time + deltaTime -- 393
	if self.time >= self.threshold then -- 393
		self.state = "None" -- 395
		self.progress = 1 -- 396
	else -- 396
		self.state = "Ongoing" -- 398
		self.progress = math.min(self.time / self.threshold, 1) -- 399
	end -- 399
	self:notifyChange() -- 401
end -- 385
function KeyDoubleDownTrigger.prototype.stop(self, manager) -- 403
	manager:slot("KeyDown"):remove(self.onKeyDown) -- 404
	self.state = "None" -- 405
	self.progress = 0 -- 406
end -- 403
local AnyKeyPressedTrigger = __TS__Class() -- 410
AnyKeyPressedTrigger.name = "AnyKeyPressedTrigger" -- 410
__TS__ClassExtends(AnyKeyPressedTrigger, ____exports.Trigger) -- 410
function AnyKeyPressedTrigger.prototype.____constructor(self) -- 415
	AnyKeyPressedTrigger.____super.prototype.____constructor(self) -- 416
	self.keyStates = {} -- 417
	self.onKeyDown = function(keyName) -- 418
		self.keyStates[keyName] = true -- 419
		self.state = "Completed" -- 420
	end -- 418
	self.onKeyUp = function(keyName) -- 422
		self.keyStates[keyName] = false -- 423
		local down = false -- 424
		for ____, state in pairs(self.keyStates) do -- 425
			if not down then -- 425
				down = state -- 426
			end -- 426
		end -- 426
		if not down then -- 426
			self.state = "None" -- 429
		end -- 429
	end -- 422
end -- 415
function AnyKeyPressedTrigger.prototype.onUpdate(self, _) -- 433
	if self.state == "Completed" then -- 433
		self:notifyChange() -- 435
	end -- 435
end -- 433
function AnyKeyPressedTrigger.prototype.start(self, manager) -- 438
	manager.keyboardEnabled = true -- 439
	manager:slot("KeyDown", self.onKeyDown) -- 440
	manager:slot("KeyUp", self.onKeyUp) -- 441
	self.state = "None" -- 442
end -- 438
function AnyKeyPressedTrigger.prototype.stop(self, manager) -- 444
	manager:slot("KeyDown"):remove(self.onKeyDown) -- 445
	manager:slot("KeyUp", self.onKeyUp) -- 446
	self.state = "None" -- 447
	self.keyStates = {} -- 448
end -- 444
local ButtonDownTrigger = __TS__Class() -- 452
ButtonDownTrigger.name = "ButtonDownTrigger" -- 452
__TS__ClassExtends(ButtonDownTrigger, ____exports.Trigger) -- 452
function ButtonDownTrigger.prototype.____constructor(self, buttons, controllerId) -- 459
	ButtonDownTrigger.____super.prototype.____constructor(self) -- 460
	self.controllerId = controllerId -- 461
	self.buttons = buttons -- 462
	self.buttonStates = {} -- 463
	self.onButtonDown = function(controllerId, buttonName) -- 464
		if self.controllerId ~= controllerId then -- 464
			return -- 466
		end -- 466
		if not (self.buttonStates[buttonName] ~= nil) then -- 466
			return -- 469
		end -- 469
		local oldState = true -- 471
		for ____, state in pairs(self.buttonStates) do -- 472
			if oldState then -- 472
				oldState = state -- 473
			end -- 473
		end -- 473
		self.buttonStates[buttonName] = true -- 475
		if not oldState then -- 475
			local newState = true -- 477
			for ____, state in pairs(self.buttonStates) do -- 478
				if newState then -- 478
					newState = state -- 479
				end -- 479
			end -- 479
			if newState then -- 479
				self.state = "Completed" -- 482
				self:notifyChange() -- 483
				self.state = "None" -- 484
			end -- 484
		end -- 484
	end -- 464
	self.onButtonUp = function(controllerId, buttonName) -- 488
		if self.state == "Completed" then -- 488
			return -- 490
		end -- 490
		if self.controllerId ~= controllerId then -- 490
			return -- 493
		end -- 493
		if not (self.buttonStates[buttonName] ~= nil) then -- 493
			return -- 496
		end -- 496
		self.buttonStates[buttonName] = false -- 498
	end -- 488
end -- 459
function ButtonDownTrigger.prototype.start(self, manager) -- 501
	manager.controllerEnabled = true -- 502
	for ____, k in ipairs(self.buttons) do -- 503
		self.buttonStates[k] = false -- 504
	end -- 504
	manager:slot("ButtonDown", self.onButtonDown) -- 506
	manager:slot("ButtonUp", self.onButtonUp) -- 507
	self.state = "None" -- 508
end -- 501
function ButtonDownTrigger.prototype.stop(self, manager) -- 510
	manager:slot("ButtonDown"):remove(self.onButtonDown) -- 511
	manager:slot("ButtonUp"):remove(self.onButtonUp) -- 512
	self.state = "None" -- 513
	self.value = false -- 514
end -- 510
local ButtonUpTrigger = __TS__Class() -- 518
ButtonUpTrigger.name = "ButtonUpTrigger" -- 518
__TS__ClassExtends(ButtonUpTrigger, ____exports.Trigger) -- 518
function ButtonUpTrigger.prototype.____constructor(self, buttons, controllerId) -- 525
	ButtonUpTrigger.____super.prototype.____constructor(self) -- 526
	self.controllerId = controllerId -- 527
	self.buttons = buttons -- 528
	self.buttonStates = {} -- 529
	self.onButtonDown = function(controllerId, buttonName) -- 530
		if self.controllerId ~= controllerId then -- 530
			return -- 532
		end -- 532
		if not (self.buttonStates[buttonName] ~= nil) then -- 532
			return -- 535
		end -- 535
		self.buttonStates[buttonName] = true -- 537
	end -- 530
	self.onButtonUp = function(controllerId, buttonName) -- 539
		if self.controllerId ~= controllerId then -- 539
			return -- 541
		end -- 541
		if not (self.buttonStates[buttonName] ~= nil) then -- 541
			return -- 544
		end -- 544
		local oldState = true -- 546
		for ____, state in pairs(self.buttonStates) do -- 547
			if oldState then -- 547
				oldState = state -- 548
			end -- 548
		end -- 548
		self.buttonStates[buttonName] = false -- 550
		if oldState then -- 550
			self.state = "Completed" -- 552
			self:notifyChange() -- 553
			self.state = "None" -- 554
		end -- 554
	end -- 539
end -- 525
function ButtonUpTrigger.prototype.start(self, manager) -- 558
	manager.controllerEnabled = true -- 559
	for ____, k in ipairs(self.buttons) do -- 560
		self.buttonStates[k] = false -- 561
	end -- 561
	manager:slot("ButtonDown", self.onButtonDown) -- 563
	manager:slot("ButtonUp", self.onButtonUp) -- 564
	self.state = "None" -- 565
end -- 558
function ButtonUpTrigger.prototype.stop(self, manager) -- 567
	manager:slot("ButtonDown"):remove(self.onButtonDown) -- 568
	manager:slot("ButtonUp"):remove(self.onButtonUp) -- 569
	self.state = "None" -- 570
end -- 567
local ButtonPressedTrigger = __TS__Class() -- 574
ButtonPressedTrigger.name = "ButtonPressedTrigger" -- 574
__TS__ClassExtends(ButtonPressedTrigger, ____exports.Trigger) -- 574
function ButtonPressedTrigger.prototype.____constructor(self, buttons, controllerId) -- 581
	ButtonPressedTrigger.____super.prototype.____constructor(self) -- 582
	self.controllerId = controllerId -- 583
	self.buttons = buttons -- 584
	self.buttonStates = {} -- 585
	self.onButtonDown = function(controllerId, buttonName) -- 586
		if self.controllerId ~= controllerId then -- 586
			return -- 588
		end -- 588
		if not (self.buttonStates[buttonName] ~= nil) then -- 588
			return -- 591
		end -- 591
		self.buttonStates[buttonName] = true -- 593
		local allDown = true -- 594
		for ____, down in pairs(self.buttonStates) do -- 595
			if allDown then -- 595
				allDown = down -- 596
			end -- 596
		end -- 596
		if allDown then -- 596
			self.state = "Completed" -- 599
		end -- 599
	end -- 586
	self.onButtonUp = function(controllerId, buttonName) -- 602
		if self.controllerId ~= controllerId then -- 602
			return -- 604
		end -- 604
		if not (self.buttonStates[buttonName] ~= nil) then -- 604
			return -- 607
		end -- 607
		self.buttonStates[buttonName] = false -- 609
		self.state = "None" -- 610
	end -- 602
end -- 581
function ButtonPressedTrigger.prototype.onUpdate(self, _) -- 613
	local allDown = true -- 614
	for ____, down in pairs(self.buttonStates) do -- 615
		if allDown then -- 615
			allDown = down -- 616
		end -- 616
	end -- 616
	if allDown then -- 616
		self.state = "Completed" -- 619
		self:notifyChange() -- 620
		self.state = "None" -- 621
	end -- 621
end -- 613
function ButtonPressedTrigger.prototype.start(self, manager) -- 624
	manager.controllerEnabled = true -- 625
	for ____, k in ipairs(self.buttons) do -- 626
		self.buttonStates[k] = false -- 627
	end -- 627
	manager:slot("ButtonDown", self.onButtonDown) -- 629
	manager:slot("ButtonUp", self.onButtonUp) -- 630
	self.state = "None" -- 631
end -- 624
function ButtonPressedTrigger.prototype.stop(self, manager) -- 633
	manager:slot("ButtonDown"):remove(self.onButtonDown) -- 634
	manager:slot("ButtonUp"):remove(self.onButtonUp) -- 635
	self.state = "None" -- 636
end -- 633
local ButtonHoldTrigger = __TS__Class() -- 640
ButtonHoldTrigger.name = "ButtonHoldTrigger" -- 640
__TS__ClassExtends(ButtonHoldTrigger, ____exports.Trigger) -- 640
function ButtonHoldTrigger.prototype.____constructor(self, button, holdTime, controllerId) -- 648
	ButtonHoldTrigger.____super.prototype.____constructor(self) -- 649
	self.controllerId = controllerId -- 650
	self.button = button -- 651
	self.holdTime = holdTime -- 652
	self.time = 0 -- 653
	self.onButtonDown = function(controllerId, buttonName) -- 654
		if self.controllerId ~= controllerId then -- 654
			return -- 656
		end -- 656
		if self.button == buttonName then -- 656
			self.time = 0 -- 659
			self.state = "Started" -- 660
			self.progress = 0 -- 661
			self:notifyChange() -- 662
		end -- 662
	end -- 654
	self.onButtonUp = function(controllerId, buttonName) -- 665
		if self.controllerId ~= controllerId then -- 665
			return -- 667
		end -- 667
		repeat -- 667
			local ____switch148 = self.state -- 667
			local ____cond148 = ____switch148 == "Started" or ____switch148 == "Ongoing" or ____switch148 == "Completed" -- 667
			if ____cond148 then -- 667
				break -- 673
			end -- 673
			do -- 673
				return -- 675
			end -- 675
		until true -- 675
		if self.button == buttonName then -- 675
			if self.state == "Completed" then -- 675
				self.state = "None" -- 679
			else -- 679
				self.state = "Canceled" -- 681
			end -- 681
			self.progress = 0 -- 683
			self:notifyChange() -- 684
		end -- 684
	end -- 665
end -- 648
function ButtonHoldTrigger.prototype.start(self, manager) -- 688
	manager.controllerEnabled = true -- 689
	manager:slot("ButtonDown", self.onButtonDown) -- 690
	manager:slot("ButtonUp", self.onButtonUp) -- 691
	self.state = "None" -- 692
	self.progress = 0 -- 693
end -- 688
function ButtonHoldTrigger.prototype.onUpdate(self, deltaTime) -- 695
	repeat -- 695
		local ____switch154 = self.state -- 695
		local ____cond154 = ____switch154 == "Started" or ____switch154 == "Ongoing" -- 695
		if ____cond154 then -- 695
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
	self:notifyChange() -- 711
end -- 695
function ButtonHoldTrigger.prototype.stop(self, manager) -- 713
	manager:slot("ButtonDown"):remove(self.onButtonDown) -- 714
	manager:slot("ButtonUp"):remove(self.onButtonUp) -- 715
	self.state = "None" -- 716
	self.progress = 0 -- 717
end -- 713
local ButtonTimedTrigger = __TS__Class() -- 721
ButtonTimedTrigger.name = "ButtonTimedTrigger" -- 721
__TS__ClassExtends(ButtonTimedTrigger, ____exports.Trigger) -- 721
function ButtonTimedTrigger.prototype.____constructor(self, button, timeWindow, controllerId) -- 728
	ButtonTimedTrigger.____super.prototype.____constructor(self) -- 729
	self.controllerId = controllerId -- 730
	self.button = button -- 731
	self.timeWindow = timeWindow -- 732
	self.time = 0 -- 733
	self.onButtonDown = function(controllerId, buttonName) -- 734
		if self.controllerId ~= controllerId then -- 734
			return -- 736
		end -- 736
		repeat -- 736
			local ____switch161 = self.state -- 736
			local ____cond161 = ____switch161 == "Started" or ____switch161 == "Ongoing" or ____switch161 == "Completed" -- 736
			if ____cond161 then -- 736
				break -- 742
			end -- 742
			do -- 742
				return -- 744
			end -- 744
		until true -- 744
		if self.button == buttonName and self.time <= self.timeWindow then -- 744
			self.state = "Completed" -- 747
			self.value = self.time -- 748
			self:notifyChange() -- 749
		end -- 749
	end -- 734
end -- 728
function ButtonTimedTrigger.prototype.start(self, manager) -- 753
	manager.controllerEnabled = true -- 754
	manager:slot("ButtonDown", self.onButtonDown) -- 755
	self.state = "Started" -- 756
	self.progress = 0 -- 757
	self.time = 0 -- 758
	self.value = false -- 759
	self:notifyChange() -- 760
end -- 753
function ButtonTimedTrigger.prototype.onUpdate(self, deltaTime) -- 762
	repeat -- 762
		local ____switch165 = self.state -- 762
		local ____cond165 = ____switch165 == "Started" or ____switch165 == "Ongoing" or ____switch165 == "Completed" -- 762
		if ____cond165 then -- 762
			break -- 767
		end -- 767
		do -- 767
			return -- 769
		end -- 769
	until true -- 769
	self.time = self.time + deltaTime -- 771
	if self.time >= self.timeWindow then -- 771
		if self.state == "Completed" then -- 771
			self.state = "None" -- 774
			self.progress = 0 -- 775
		else -- 775
			self.state = "Canceled" -- 777
			self.progress = 1 -- 778
		end -- 778
	else -- 778
		self.state = "Ongoing" -- 781
		self.progress = math.min(self.time / self.timeWindow, 1) -- 782
	end -- 782
	self:notifyChange() -- 784
end -- 762
function ButtonTimedTrigger.prototype.stop(self, manager) -- 786
	manager:slot("ButtonDown"):remove(self.onButtonDown) -- 787
	self.state = "None" -- 788
	self.progress = 0 -- 789
end -- 786
local ButtonDoubleDownTrigger = __TS__Class() -- 793
ButtonDoubleDownTrigger.name = "ButtonDoubleDownTrigger" -- 793
__TS__ClassExtends(ButtonDoubleDownTrigger, ____exports.Trigger) -- 793
function ButtonDoubleDownTrigger.prototype.____constructor(self, button, threshold, controllerId) -- 800
	ButtonDoubleDownTrigger.____super.prototype.____constructor(self) -- 801
	self.controllerId = controllerId -- 802
	self.button = button -- 803
	self.threshold = threshold -- 804
	self.time = 0 -- 805
	self.onButtonDown = function(controllerId, buttonName) -- 806
		if self.controllerId ~= controllerId then -- 806
			return -- 808
		end -- 808
		if self.button == buttonName then -- 808
			if self.state == "None" then -- 808
				self.time = 0 -- 812
				self.state = "Started" -- 813
				self.progress = 0 -- 814
				self:notifyChange() -- 815
			else -- 815
				self.state = "Completed" -- 817
				self:notifyChange() -- 818
				self.state = "None" -- 819
			end -- 819
		end -- 819
	end -- 806
end -- 800
function ButtonDoubleDownTrigger.prototype.start(self, manager) -- 824
	manager.controllerEnabled = true -- 825
	manager:slot("ButtonDown", self.onButtonDown) -- 826
	self.state = "None" -- 827
	self.progress = 0 -- 828
end -- 824
function ButtonDoubleDownTrigger.prototype.onUpdate(self, deltaTime) -- 830
	repeat -- 830
		local ____switch179 = self.state -- 830
		local ____cond179 = ____switch179 == "Started" or ____switch179 == "Ongoing" -- 830
		if ____cond179 then -- 830
			break -- 834
		end -- 834
		do -- 834
			return -- 836
		end -- 836
	until true -- 836
	self.time = self.time + deltaTime -- 838
	if self.time >= self.threshold then -- 838
		self.state = "None" -- 840
		self.progress = 1 -- 841
	else -- 841
		self.state = "Ongoing" -- 843
		self.progress = math.min(self.time / self.threshold, 1) -- 844
	end -- 844
	self:notifyChange() -- 846
end -- 830
function ButtonDoubleDownTrigger.prototype.stop(self, manager) -- 848
	manager:slot("ButtonDown"):remove(self.onButtonDown) -- 849
	self.state = "None" -- 850
	self.progress = 0 -- 851
end -- 848
local AnyButtonPressedTrigger = __TS__Class() -- 855
AnyButtonPressedTrigger.name = "AnyButtonPressedTrigger" -- 855
__TS__ClassExtends(AnyButtonPressedTrigger, ____exports.Trigger) -- 855
function AnyButtonPressedTrigger.prototype.____constructor(self, controllerId) -- 861
	AnyButtonPressedTrigger.____super.prototype.____constructor(self) -- 862
	self.controllerId = controllerId -- 863
	self.buttonStates = {} -- 864
	self.onButtonDown = function(controllerId, buttonName) -- 865
		if self.controllerId ~= controllerId then -- 865
			return -- 867
		end -- 867
		self.buttonStates[buttonName] = true -- 869
		self.state = "Completed" -- 870
	end -- 865
	self.onButtonUp = function(controllerId, buttonName) -- 872
		if self.controllerId ~= controllerId then -- 872
			return -- 874
		end -- 874
		self.buttonStates[buttonName] = false -- 876
		local down = false -- 877
		for ____, state in pairs(self.buttonStates) do -- 878
			if not down then -- 878
				down = state -- 879
			end -- 879
		end -- 879
		if not down then -- 879
			self.state = "None" -- 882
		end -- 882
	end -- 872
end -- 861
function AnyButtonPressedTrigger.prototype.onUpdate(self, _) -- 886
	if self.state == "Completed" then -- 886
		self:notifyChange() -- 888
	end -- 888
end -- 886
function AnyButtonPressedTrigger.prototype.start(self, manager) -- 891
	manager.keyboardEnabled = true -- 892
	manager:slot("ButtonDown", self.onButtonDown) -- 893
	manager:slot("ButtonUp", self.onButtonUp) -- 894
	self.state = "None" -- 895
end -- 891
function AnyButtonPressedTrigger.prototype.stop(self, manager) -- 897
	manager:slot("ButtonDown"):remove(self.onButtonDown) -- 898
	manager:slot("ButtonUp", self.onButtonUp) -- 899
	self.state = "None" -- 900
	self.buttonStates = {} -- 901
end -- 897
local JoyStickTrigger = __TS__Class() -- 910
JoyStickTrigger.name = "JoyStickTrigger" -- 910
__TS__ClassExtends(JoyStickTrigger, ____exports.Trigger) -- 910
function JoyStickTrigger.prototype.____constructor(self, joyStickType, controllerId) -- 916
	JoyStickTrigger.____super.prototype.____constructor(self) -- 917
	self.joyStickType = joyStickType -- 918
	self.controllerId = controllerId -- 919
	self.axis = Vec2.zero -- 920
	self.onAxis = function(controllerId, axisName, value) -- 921
		if self.controllerId ~= controllerId then -- 921
			return -- 923
		end -- 923
		repeat -- 923
			local ____switch197 = self.joyStickType -- 923
			local ____cond197 = ____switch197 == "Left" -- 923
			if ____cond197 then -- 923
				do -- 923
					repeat -- 923
						local ____switch199 = axisName -- 923
						local ____cond199 = ____switch199 == "leftx" -- 923
						if ____cond199 then -- 923
							self.axis = Vec2(value, self.axis.y) -- 929
							break -- 930
						end -- 930
						____cond199 = ____cond199 or ____switch199 == "lefty" -- 930
						if ____cond199 then -- 930
							self.axis = Vec2(self.axis.x, value) -- 932
							break -- 933
						end -- 933
					until true -- 933
					break -- 935
				end -- 935
			end -- 935
			____cond197 = ____cond197 or ____switch197 == "Right" -- 935
			if ____cond197 then -- 935
				do -- 935
					repeat -- 935
						local ____switch201 = axisName -- 935
						local ____cond201 = ____switch201 == "rightx" -- 935
						if ____cond201 then -- 935
							self.axis = Vec2(value, self.axis.y) -- 940
							break -- 941
						end -- 941
						____cond201 = ____cond201 or ____switch201 == "righty" -- 941
						if ____cond201 then -- 941
							self.axis = Vec2(self.axis.x, value) -- 943
							break -- 944
						end -- 944
					until true -- 944
					break -- 946
				end -- 946
			end -- 946
		until true -- 946
		self.value = self.axis -- 949
		if self:filterAxis() then -- 949
			self.state = "Completed" -- 951
		else -- 951
			self.state = "None" -- 953
		end -- 953
		self:notifyChange() -- 955
	end -- 921
end -- 916
function JoyStickTrigger.prototype.filterAxis(self) -- 958
	return true -- 959
end -- 958
function JoyStickTrigger.prototype.start(self, manager) -- 961
	self.state = "None" -- 962
	self.value = Vec2.zero -- 963
	manager:slot("Axis", self.onAxis) -- 964
end -- 961
function JoyStickTrigger.prototype.stop(self, manager) -- 966
	self.state = "None" -- 967
	self.value = Vec2.zero -- 968
	manager:slot("Axis"):remove(self.onAxis) -- 969
end -- 966
local JoyStickThresholdTrigger = __TS__Class() -- 973
JoyStickThresholdTrigger.name = "JoyStickThresholdTrigger" -- 973
__TS__ClassExtends(JoyStickThresholdTrigger, JoyStickTrigger) -- 973
function JoyStickThresholdTrigger.prototype.____constructor(self, joyStickType, threshold, controllerId) -- 976
	JoyStickTrigger.prototype.____constructor(self, joyStickType, controllerId) -- 977
	self.threshold = threshold -- 978
end -- 976
function JoyStickThresholdTrigger.prototype.filterAxis(self) -- 980
	return self.axis.length > self.threshold -- 981
end -- 980
local JoyStickDirectionalTrigger = __TS__Class() -- 985
JoyStickDirectionalTrigger.name = "JoyStickDirectionalTrigger" -- 985
__TS__ClassExtends(JoyStickDirectionalTrigger, JoyStickTrigger) -- 985
function JoyStickDirectionalTrigger.prototype.____constructor(self, joyStickType, angle, tolerance, controllerId) -- 989
	JoyStickTrigger.prototype.____constructor(self, joyStickType, controllerId) -- 990
	self.direction = angle -- 991
	self.tolerance = tolerance -- 992
end -- 989
function JoyStickDirectionalTrigger.prototype.filterAxis(self) -- 994
	local currentAngle = -math.deg(math.atan(self.axis.y, self.axis.x)) -- 995
	return math.abs(currentAngle - self.direction) <= self.tolerance -- 996
end -- 994
local JoyStickRangeTrigger = __TS__Class() -- 1000
JoyStickRangeTrigger.name = "JoyStickRangeTrigger" -- 1000
__TS__ClassExtends(JoyStickRangeTrigger, JoyStickTrigger) -- 1000
function JoyStickRangeTrigger.prototype.____constructor(self, joyStickType, minRange, maxRange, controllerId) -- 1004
	JoyStickTrigger.prototype.____constructor(self, joyStickType, controllerId) -- 1005
	self.minRange = math.min(minRange, maxRange) -- 1006
	self.maxRange = math.max(minRange, maxRange) -- 1007
end -- 1004
function JoyStickRangeTrigger.prototype.filterAxis(self) -- 1009
	local magnitude = self.axis.length -- 1010
	return magnitude >= self.minRange and magnitude <= self.maxRange -- 1011
end -- 1009
local SequenceTrigger = __TS__Class() -- 1015
SequenceTrigger.name = "SequenceTrigger" -- 1015
__TS__ClassExtends(SequenceTrigger, ____exports.Trigger) -- 1015
function SequenceTrigger.prototype.____constructor(self, triggers) -- 1018
	SequenceTrigger.____super.prototype.____constructor(self) -- 1019
	self.triggers = triggers -- 1020
	local ____self = self -- 1021
	local function onStateChanged() -- 1022
		____self:onStateChanged() -- 1023
	end -- 1022
	for ____, trigger in ipairs(triggers) do -- 1025
		trigger:addListener(onStateChanged) -- 1026
	end -- 1026
end -- 1018
function SequenceTrigger.prototype.onStateChanged(self) -- 1029
	local completed = true -- 1030
	for ____, trigger in ipairs(self.triggers) do -- 1031
		if trigger.state ~= "Completed" then -- 1031
			completed = false -- 1033
			break -- 1034
		end -- 1034
	end -- 1034
	if completed then -- 1034
		self.state = "Completed" -- 1038
		local newValue = {} -- 1039
		for ____, trigger in ipairs(self.triggers) do -- 1040
			if type(trigger.value) == "table" then -- 1040
				if type(trigger.value) == "userdata" then -- 1040
					newValue[#newValue + 1] = trigger.value -- 1043
				else -- 1043
					newValue = __TS__ArrayConcat(newValue, trigger.value) -- 1045
				end -- 1045
			else -- 1045
				newValue[#newValue + 1] = trigger.value -- 1048
			end -- 1048
		end -- 1048
		self.value = newValue -- 1051
		self:notifyChange() -- 1052
		return -- 1053
	end -- 1053
	local canceled = false -- 1055
	for ____, trigger in ipairs(self.triggers) do -- 1056
		self.progress = math.max(trigger.progress, self.progress) -- 1057
		if trigger.state == "Canceled" then -- 1057
			canceled = true -- 1059
			break -- 1060
		end -- 1060
	end -- 1060
	if canceled then -- 1060
		self.state = "Canceled" -- 1064
		self:notifyChange() -- 1065
		return -- 1066
	end -- 1066
	local onGoing = false -- 1068
	local minProgress = -1 -- 1069
	for ____, trigger in ipairs(self.triggers) do -- 1070
		if trigger.state == "Ongoing" then -- 1070
			minProgress = minProgress < 0 and trigger.progress or math.min(minProgress, trigger.progress) -- 1072
			onGoing = true -- 1073
		end -- 1073
	end -- 1073
	if onGoing then -- 1073
		self.state = "Ongoing" -- 1077
		self.progress = minProgress -- 1078
		self:notifyChange() -- 1079
		return -- 1080
	end -- 1080
	for ____, trigger in ipairs(self.triggers) do -- 1082
		if trigger.state == "Started" then -- 1082
			self.state = "Started" -- 1084
			self.progress = 0 -- 1085
			self:notifyChange() -- 1086
			return -- 1087
		end -- 1087
	end -- 1087
	self.state = "None" -- 1090
	self:notifyChange() -- 1091
end -- 1029
function SequenceTrigger.prototype.start(self, manager) -- 1093
	for ____, trigger in ipairs(self.triggers) do -- 1094
		trigger:start(manager) -- 1095
	end -- 1095
	self.state = "None" -- 1097
	self.progress = 0 -- 1098
	self.value = false -- 1099
end -- 1093
function SequenceTrigger.prototype.onUpdate(self, deltaTime) -- 1101
	for ____, trigger in ipairs(self.triggers) do -- 1102
		if trigger.onUpdate then -- 1102
			trigger:onUpdate(deltaTime) -- 1104
		end -- 1104
	end -- 1104
end -- 1101
function SequenceTrigger.prototype.stop(self, manager) -- 1108
	for ____, trigger in ipairs(self.triggers) do -- 1109
		trigger:stop(manager) -- 1110
	end -- 1110
	self.state = "None" -- 1112
	self.progress = 0 -- 1113
	self.value = false -- 1114
end -- 1108
local SelectorTrigger = __TS__Class() -- 1118
SelectorTrigger.name = "SelectorTrigger" -- 1118
__TS__ClassExtends(SelectorTrigger, ____exports.Trigger) -- 1118
function SelectorTrigger.prototype.____constructor(self, triggers) -- 1121
	SelectorTrigger.____super.prototype.____constructor(self) -- 1122
	self.triggers = triggers -- 1123
	local ____self = self -- 1124
	local function onStateChanged() -- 1125
		____self:onStateChanged() -- 1126
	end -- 1125
	for ____, trigger in ipairs(triggers) do -- 1128
		trigger:addListener(onStateChanged) -- 1129
	end -- 1129
end -- 1121
function SelectorTrigger.prototype.onStateChanged(self) -- 1132
	for ____, trigger in ipairs(self.triggers) do -- 1133
		if trigger.state == "Completed" then -- 1133
			self.state = "Completed" -- 1135
			self.progress = trigger.progress -- 1136
			self.value = trigger.value -- 1137
			self:notifyChange() -- 1138
			return -- 1139
		end -- 1139
	end -- 1139
	local onGoing = false -- 1142
	local maxProgress = 0 -- 1143
	for ____, trigger in ipairs(self.triggers) do -- 1144
		if trigger.state == "Ongoing" then -- 1144
			maxProgress = math.max(maxProgress, trigger.progress) -- 1146
			onGoing = true -- 1147
		end -- 1147
	end -- 1147
	if onGoing then -- 1147
		self.state = "Ongoing" -- 1151
		self.progress = maxProgress -- 1152
		self:notifyChange() -- 1153
		return -- 1154
	end -- 1154
	for ____, trigger in ipairs(self.triggers) do -- 1156
		if trigger.state == "Started" then -- 1156
			self.state = "Started" -- 1158
			self.progress = 0 -- 1159
			self:notifyChange() -- 1160
			return -- 1161
		end -- 1161
	end -- 1161
	local canceled = false -- 1164
	for ____, trigger in ipairs(self.triggers) do -- 1165
		self.progress = math.max(trigger.progress, self.progress) -- 1166
		if trigger.state == "Canceled" then -- 1166
			canceled = true -- 1168
			break -- 1169
		end -- 1169
	end -- 1169
	if canceled then -- 1169
		self.state = "Canceled" -- 1173
		self:notifyChange() -- 1174
	end -- 1174
end -- 1132
function SelectorTrigger.prototype.start(self, manager) -- 1177
	for ____, trigger in ipairs(self.triggers) do -- 1178
		trigger:start(manager) -- 1179
	end -- 1179
	self.state = "None" -- 1181
	self.progress = 0 -- 1182
	self.value = false -- 1183
end -- 1177
function SelectorTrigger.prototype.onUpdate(self, deltaTime) -- 1185
	for ____, trigger in ipairs(self.triggers) do -- 1186
		if trigger.onUpdate then -- 1186
			trigger:onUpdate(deltaTime) -- 1188
		end -- 1188
	end -- 1188
end -- 1185
function SelectorTrigger.prototype.stop(self, manager) -- 1192
	for ____, trigger in ipairs(self.triggers) do -- 1193
		trigger:stop(manager) -- 1194
	end -- 1194
	self.state = "None" -- 1196
	self.progress = 0 -- 1197
	self.value = false -- 1198
end -- 1192
local BlockTrigger = __TS__Class() -- 1202
BlockTrigger.name = "BlockTrigger" -- 1202
__TS__ClassExtends(BlockTrigger, ____exports.Trigger) -- 1202
function BlockTrigger.prototype.____constructor(self, trigger) -- 1205
	BlockTrigger.____super.prototype.____constructor(self) -- 1206
	self.trigger = trigger -- 1207
	local ____self = self -- 1208
	trigger:addListener(function() -- 1209
		____self:onStateChanged() -- 1210
	end) -- 1209
end -- 1205
function BlockTrigger.prototype.onStateChanged(self) -- 1213
	if self.trigger.state == "Completed" then -- 1213
		self.state = "Canceled" -- 1215
	else -- 1215
		self.state = "Completed" -- 1217
	end -- 1217
	self:notifyChange() -- 1219
end -- 1213
function BlockTrigger.prototype.start(self, manager) -- 1221
	self.state = "Completed" -- 1222
	self.trigger:start(manager) -- 1223
end -- 1221
function BlockTrigger.prototype.onUpdate(self, deltaTime) -- 1225
	if self.trigger.onUpdate then -- 1225
		self.trigger:onUpdate(deltaTime) -- 1227
	end -- 1227
end -- 1225
function BlockTrigger.prototype.stop(self, manager) -- 1230
	self.state = "Completed" -- 1231
	self.trigger:stop(manager) -- 1232
end -- 1230
do -- 1230
	function Trigger.KeyDown(combineKeys) -- 1369
		if type(combineKeys) == "string" then -- 1369
			combineKeys = {combineKeys} -- 1371
		end -- 1371
		return __TS__New(KeyDownTrigger, combineKeys) -- 1373
	end -- 1369
	function Trigger.KeyUp(combineKeys) -- 1375
		if type(combineKeys) == "string" then -- 1375
			combineKeys = {combineKeys} -- 1377
		end -- 1377
		return __TS__New(KeyUpTrigger, combineKeys) -- 1379
	end -- 1375
	function Trigger.KeyPressed(combineKeys) -- 1381
		if type(combineKeys) == "string" then -- 1381
			combineKeys = {combineKeys} -- 1383
		end -- 1383
		return __TS__New(KeyPressedTrigger, combineKeys) -- 1385
	end -- 1381
	function Trigger.KeyHold(keyName, holdTime) -- 1387
		return __TS__New(KeyHoldTrigger, keyName, holdTime) -- 1388
	end -- 1387
	function Trigger.KeyDoubleDown(key, threshold) -- 1393
		return __TS__New(KeyDoubleDownTrigger, key, threshold or 0.3) -- 1394
	end -- 1393
	function Trigger.ButtonDown(combineButtons, controllerId) -- 1399
		if type(combineButtons) == "string" then -- 1399
			combineButtons = {combineButtons} -- 1401
		end -- 1401
		return __TS__New(ButtonDownTrigger, combineButtons, controllerId or 0) -- 1403
	end -- 1399
	function Trigger.ButtonUp(combineButtons, controllerId) -- 1405
		if type(combineButtons) == "string" then -- 1405
			combineButtons = {combineButtons} -- 1407
		end -- 1407
		return __TS__New(ButtonUpTrigger, combineButtons, controllerId or 0) -- 1409
	end -- 1405
	function Trigger.ButtonPressed(combineButtons, controllerId) -- 1411
		if type(combineButtons) == "string" then -- 1411
			combineButtons = {combineButtons} -- 1413
		end -- 1413
		return __TS__New(ButtonPressedTrigger, combineButtons, controllerId or 0) -- 1415
	end -- 1411
	function Trigger.ButtonHold(buttonName, holdTime, controllerId) -- 1417
		return __TS__New(ButtonHoldTrigger, buttonName, holdTime, controllerId or 0) -- 1418
	end -- 1417
	function Trigger.ButtonDoubleDown(button, threshold, controllerId) -- 1423
		return __TS__New(ButtonDoubleDownTrigger, button, threshold or 0.3, controllerId or 0) -- 1424
	end -- 1423
	local function isBindingList(input) -- 1241
		return input.key == nil and input.button == nil -- 1242
	end -- 1241
	local function select(triggers) -- 1245
		return #triggers == 1 and triggers[1] or __TS__New(SelectorTrigger, triggers) -- 1246
	end -- 1245
	local function sequence(triggers) -- 1248
		return #triggers == 1 and triggers[1] or __TS__New(SequenceTrigger, triggers) -- 1249
	end -- 1248
	local function down(input) -- 1251
		local key = input.key -- 1252
		if key ~= nil then -- 1252
			return Trigger.KeyDown(key) -- 1254
		end -- 1254
		local buttonInput = input -- 1256
		return Trigger.ButtonDown(buttonInput.button, buttonInput.controllerId) -- 1257
	end -- 1251
	local function up(input) -- 1259
		local key = input.key -- 1260
		if key ~= nil then -- 1260
			return Trigger.KeyUp(key) -- 1262
		end -- 1262
		local buttonInput = input -- 1264
		return Trigger.ButtonUp(buttonInput.button, buttonInput.controllerId) -- 1265
	end -- 1259
	local function pressed(input) -- 1267
		local key = input.key -- 1268
		if key ~= nil then -- 1268
			return Trigger.KeyPressed(key) -- 1270
		end -- 1270
		local buttonInput = input -- 1272
		return Trigger.ButtonPressed(buttonInput.button, buttonInput.controllerId) -- 1273
	end -- 1267
	local function hold(input, holdTime) -- 1275
		local key = input.key -- 1276
		if key ~= nil then -- 1276
			if type(key) == "string" then -- 1276
				return Trigger.KeyHold(key, holdTime) -- 1279
			end -- 1279
			local triggers = {} -- 1281
			for ____, keyName in ipairs(key) do -- 1282
				triggers[#triggers + 1] = Trigger.KeyHold(keyName, holdTime) -- 1283
			end -- 1283
			return sequence(triggers) -- 1285
		end -- 1285
		local buttonInput = input -- 1287
		if type(buttonInput.button) == "string" then -- 1287
			return Trigger.ButtonHold(buttonInput.button, holdTime, buttonInput.controllerId) -- 1289
		end -- 1289
		local triggers = {} -- 1291
		for ____, buttonName in ipairs(buttonInput.button) do -- 1292
			triggers[#triggers + 1] = Trigger.ButtonHold(buttonName, holdTime, buttonInput.controllerId) -- 1293
		end -- 1293
		return sequence(triggers) -- 1295
	end -- 1275
	local function doubleDown(input, threshold) -- 1297
		local key = input.key -- 1298
		if key ~= nil then -- 1298
			if type(key) == "string" then -- 1298
				return Trigger.KeyDoubleDown(key, threshold) -- 1301
			end -- 1301
			local triggers = {} -- 1303
			for ____, keyName in ipairs(key) do -- 1304
				triggers[#triggers + 1] = Trigger.KeyDoubleDown(keyName, threshold) -- 1305
			end -- 1305
			return sequence(triggers) -- 1307
		end -- 1307
		local buttonInput = input -- 1309
		if type(buttonInput.button) == "string" then -- 1309
			return Trigger.ButtonDoubleDown(buttonInput.button, threshold, buttonInput.controllerId) -- 1311
		end -- 1311
		local triggers = {} -- 1313
		for ____, buttonName in ipairs(buttonInput.button) do -- 1314
			triggers[#triggers + 1] = Trigger.ButtonDoubleDown(buttonName, threshold, buttonInput.controllerId) -- 1315
		end -- 1315
		return sequence(triggers) -- 1317
	end -- 1297
	function Trigger.Down(input) -- 1319
		if isBindingList(input) then -- 1319
			local triggers = {} -- 1321
			for ____, binding in ipairs(input) do -- 1322
				triggers[#triggers + 1] = down(binding) -- 1323
			end -- 1323
			return select(triggers) -- 1325
		end -- 1325
		return down(input) -- 1327
	end -- 1319
	function Trigger.Up(input) -- 1329
		if isBindingList(input) then -- 1329
			local triggers = {} -- 1331
			for ____, binding in ipairs(input) do -- 1332
				triggers[#triggers + 1] = up(binding) -- 1333
			end -- 1333
			return select(triggers) -- 1335
		end -- 1335
		return up(input) -- 1337
	end -- 1329
	function Trigger.Pressed(input) -- 1339
		if isBindingList(input) then -- 1339
			local triggers = {} -- 1341
			for ____, binding in ipairs(input) do -- 1342
				triggers[#triggers + 1] = pressed(binding) -- 1343
			end -- 1343
			return select(triggers) -- 1345
		end -- 1345
		return pressed(input) -- 1347
	end -- 1339
	function Trigger.Hold(input, holdTime) -- 1349
		if isBindingList(input) then -- 1349
			local triggers = {} -- 1351
			for ____, binding in ipairs(input) do -- 1352
				triggers[#triggers + 1] = hold(binding, holdTime) -- 1353
			end -- 1353
			return select(triggers) -- 1355
		end -- 1355
		return hold(input, holdTime) -- 1357
	end -- 1349
	function Trigger.Double(input, threshold) -- 1359
		if isBindingList(input) then -- 1359
			local triggers = {} -- 1361
			for ____, binding in ipairs(input) do -- 1362
				triggers[#triggers + 1] = doubleDown(binding, threshold) -- 1363
			end -- 1363
			return select(triggers) -- 1365
		end -- 1365
		return doubleDown(input, threshold) -- 1367
	end -- 1359
	function Trigger.KeyTimed(keyName, timeWindow) -- 1390
		return __TS__New(KeyTimedTrigger, keyName, timeWindow) -- 1391
	end -- 1390
	function Trigger.AnyKeyPressed() -- 1396
		return __TS__New(AnyKeyPressedTrigger) -- 1397
	end -- 1396
	function Trigger.ButtonTimed(buttonName, timeWindow, controllerId) -- 1420
		return __TS__New(ButtonTimedTrigger, buttonName, timeWindow, controllerId or 0) -- 1421
	end -- 1420
	function Trigger.AnyButtonPressed(controllerId) -- 1426
		return __TS__New(AnyButtonPressedTrigger, controllerId or 0) -- 1427
	end -- 1426
	function Trigger.JoyStick(joyStickType, controllerId) -- 1429
		return __TS__New(JoyStickTrigger, joyStickType, controllerId or 0) -- 1430
	end -- 1429
	function Trigger.JoyStickThreshold(joyStickType, threshold, controllerId) -- 1432
		return __TS__New(JoyStickThresholdTrigger, joyStickType, threshold, controllerId or 0) -- 1433
	end -- 1432
	function Trigger.JoyStickDirectional(joyStickType, angle, tolerance, controllerId) -- 1435
		return __TS__New( -- 1436
			JoyStickDirectionalTrigger, -- 1436
			joyStickType, -- 1436
			angle, -- 1436
			tolerance, -- 1436
			controllerId or 0 -- 1436
		) -- 1436
	end -- 1435
	function Trigger.JoyStickRange(joyStickType, minRange, maxRange, controllerId) -- 1438
		return __TS__New( -- 1439
			JoyStickRangeTrigger, -- 1439
			joyStickType, -- 1439
			minRange, -- 1439
			maxRange, -- 1439
			controllerId or 0 -- 1439
		) -- 1439
	end -- 1438
	function Trigger.Sequence(triggers) -- 1441
		return __TS__New(SequenceTrigger, triggers) -- 1442
	end -- 1441
	function Trigger.Selector(triggers) -- 1444
		return __TS__New(SelectorTrigger, triggers) -- 1445
	end -- 1444
	function Trigger.Block(trigger) -- 1447
		return __TS__New(BlockTrigger, trigger) -- 1448
	end -- 1447
end -- 1447
local InputManager = __TS__Class() -- 1469
InputManager.name = "InputManager" -- 1469
function InputManager.prototype.____constructor(self, contexts) -- 1475
	self.manager = Node() -- 1476
	self.contextMap = __TS__New(Map) -- 1477
	self.actionHandlers = __TS__New(Map) -- 1478
	for contextName, actionMap in pairs(contexts) do -- 1479
		local context = contextName -- 1480
		local actions = {} -- 1481
		for actionName, trigger in pairs(actionMap) do -- 1482
			local name = actionName -- 1483
			local eventName = self:getEventName(name) -- 1484
			trigger:addListener(function() -- 1485
				local ____trigger_1 = trigger -- 1486
				local state = ____trigger_1.state -- 1486
				local progress = ____trigger_1.progress -- 1486
				local value = ____trigger_1.value -- 1486
				emit( -- 1487
					eventName, -- 1487
					state, -- 1487
					progress, -- 1487
					value, -- 1487
					name, -- 1487
					context, -- 1487
					trigger, -- 1487
					self -- 1487
				) -- 1487
			end) -- 1485
			actions[#actions + 1] = {name = name, trigger = trigger} -- 1489
		end -- 1489
		self.contextMap:set(context, actions) -- 1491
	end -- 1491
	self.contextStack = {} -- 1493
	self.manager:schedule(function(deltaTime) -- 1494
		if #self.contextStack > 0 then -- 1494
			local lastNames = self.contextStack[#self.contextStack] -- 1496
			for ____, name in ipairs(lastNames) do -- 1497
				do -- 1497
					local actions = self.contextMap:get(name) -- 1498
					if actions == nil then -- 1498
						goto __continue366 -- 1500
					end -- 1500
					for ____, action in ipairs(actions) do -- 1502
						if action.trigger.onUpdate then -- 1502
							action.trigger:onUpdate(deltaTime) -- 1504
						end -- 1504
					end -- 1504
				end -- 1504
				::__continue366:: -- 1504
			end -- 1504
		end -- 1504
		return false -- 1509
	end) -- 1494
end -- 1475
function InputManager.prototype.getNode(self) -- 1513
	return self.manager -- 1514
end -- 1513
function InputManager.prototype.getEventName(self, actionName) -- 1517
	return "Input." .. actionName -- 1518
end -- 1517
function InputManager.prototype.addActionHandler(self, actionName, handler, state) -- 1521
	local eventName = self:getEventName(actionName) -- 1522
	local function listener(stateValue, progress, value, action, context, trigger, inputManager) -- 1523
		if state ~= nil and stateValue ~= state then -- 1523
			return -- 1533
		end -- 1533
		handler({ -- 1535
			action = action or actionName, -- 1536
			context = context or "", -- 1537
			state = stateValue, -- 1538
			progress = progress, -- 1539
			value = value, -- 1540
			trigger = trigger, -- 1541
			inputManager = inputManager or self -- 1542
		}) -- 1542
	end -- 1523
	local slot = self.manager:gslot(eventName, listener) -- 1545
	local handlerMap = self.actionHandlers:get(actionName) -- 1546
	if handlerMap == nil then -- 1546
		handlerMap = __TS__New(Map) -- 1548
		self.actionHandlers:set(actionName, handlerMap) -- 1549
	end -- 1549
	local slots = handlerMap:get(handler) -- 1551
	if slots == nil then -- 1551
		slots = {} -- 1553
		handlerMap:set(handler, slots) -- 1554
	end -- 1554
	slots[#slots + 1] = slot -- 1556
end -- 1521
function InputManager.prototype.on(self, actionName, handler) -- 1559
	self:addActionHandler(actionName, handler) -- 1560
end -- 1559
function InputManager.prototype.once(self, actionName, handler) -- 1563
	local eventName = self:getEventName(actionName) -- 1564
	local slot -- 1565
	local function listener(stateValue, progress, value, action, context, trigger, inputManager) -- 1566
		if slot ~= nil then -- 1566
			slot.enabled = false -- 1576
		end -- 1576
		handler({ -- 1578
			action = action or actionName, -- 1579
			context = context or "", -- 1580
			state = stateValue, -- 1581
			progress = progress, -- 1582
			value = value, -- 1583
			trigger = trigger, -- 1584
			inputManager = inputManager or self -- 1585
		}) -- 1585
	end -- 1566
	slot = self.manager:gslot(eventName, listener) -- 1588
	local handlerMap = self.actionHandlers:get(actionName) -- 1589
	if handlerMap == nil then -- 1589
		handlerMap = __TS__New(Map) -- 1591
		self.actionHandlers:set(actionName, handlerMap) -- 1592
	end -- 1592
	local slots = handlerMap:get(handler) -- 1594
	if slots == nil then -- 1594
		slots = {} -- 1596
		handlerMap:set(handler, slots) -- 1597
	end -- 1597
	slots[#slots + 1] = slot -- 1599
end -- 1563
function InputManager.prototype.off(self, actionName, handler) -- 1602
	local handlerMap = self.actionHandlers:get(actionName) -- 1603
	if handlerMap == nil then -- 1603
		return -- 1605
	end -- 1605
	local slots = handlerMap:get(handler) -- 1607
	if slots == nil then -- 1607
		return -- 1609
	end -- 1609
	for ____, slot in ipairs(slots) do -- 1611
		slot.enabled = false -- 1612
	end -- 1612
	handlerMap:delete(handler) -- 1614
end -- 1602
function InputManager.prototype.onCompleted(self, actionName, handler) -- 1617
	self:addActionHandler(actionName, handler, "Completed") -- 1618
end -- 1617
function InputManager.prototype.pushContext(self, contextNames) -- 1621
	if type(contextNames) == "string" then -- 1621
		contextNames = {contextNames} -- 1623
	end -- 1623
	local exist = true -- 1625
	for ____, name in ipairs(contextNames) do -- 1626
		if exist then -- 1626
			exist = self.contextMap:has(name) -- 1627
		end -- 1627
	end -- 1627
	if not exist then -- 1627
		print("[Dora Error] got non-existed context name from " .. table.concat(contextNames, ", ")) -- 1630
		return false -- 1631
	else -- 1631
		if #self.contextStack > 0 then -- 1631
			local lastNames = self.contextStack[#self.contextStack] -- 1634
			for ____, name in ipairs(lastNames) do -- 1635
				do -- 1635
					local actions = self.contextMap:get(name) -- 1636
					if actions == nil then -- 1636
						goto __continue398 -- 1638
					end -- 1638
					for ____, action in ipairs(actions) do -- 1640
						action.trigger:stop(self.manager) -- 1641
					end -- 1641
				end -- 1641
				::__continue398:: -- 1641
			end -- 1641
		end -- 1641
		local ____self_contextStack_2 = self.contextStack -- 1641
		____self_contextStack_2[#____self_contextStack_2 + 1] = contextNames -- 1645
		for ____, name in ipairs(contextNames) do -- 1646
			do -- 1646
				local actions = self.contextMap:get(name) -- 1647
				if actions == nil then -- 1647
					goto __continue403 -- 1649
				end -- 1649
				for ____, action in ipairs(actions) do -- 1651
					action.trigger:start(self.manager) -- 1652
				end -- 1652
			end -- 1652
			::__continue403:: -- 1652
		end -- 1652
		return true -- 1655
	end -- 1655
end -- 1621
function InputManager.prototype.popContext(self, count) -- 1659
	if count == nil then -- 1659
		count = 1 -- 1660
	end -- 1660
	if #self.contextStack < count then -- 1660
		return false -- 1662
	end -- 1662
	for i = 1, count do -- 1662
		local lastNames = self.contextStack[#self.contextStack] -- 1665
		for ____, name in ipairs(lastNames) do -- 1666
			do -- 1666
				local actions = self.contextMap:get(name) -- 1667
				if actions == nil then -- 1667
					goto __continue411 -- 1669
				end -- 1669
				for ____, action in ipairs(actions) do -- 1671
					action.trigger:stop(self.manager) -- 1672
				end -- 1672
			end -- 1672
			::__continue411:: -- 1672
		end -- 1672
		table.remove(self.contextStack) -- 1675
		if #self.contextStack > 0 then -- 1675
			local lastNames = self.contextStack[#self.contextStack] -- 1677
			for ____, name in ipairs(lastNames) do -- 1678
				do -- 1678
					local actions = self.contextMap:get(name) -- 1679
					if actions == nil then -- 1679
						goto __continue417 -- 1681
					end -- 1681
					for ____, action in ipairs(actions) do -- 1683
						action.trigger:start(self.manager) -- 1684
					end -- 1684
				end -- 1684
				::__continue417:: -- 1684
			end -- 1684
		end -- 1684
	end -- 1684
	return true -- 1689
end -- 1659
function InputManager.prototype.emitKeyDown(self, keyName) -- 1692
	self.manager:emit("KeyDown", keyName) -- 1693
end -- 1692
function InputManager.prototype.emitKeyUp(self, keyName) -- 1696
	self.manager:emit("KeyUp", keyName) -- 1697
end -- 1696
function InputManager.prototype.emitButtonDown(self, buttonName, controllerId) -- 1700
	self.manager:emit("ButtonDown", controllerId or 0, buttonName) -- 1701
end -- 1700
function InputManager.prototype.emitButtonUp(self, buttonName, controllerId) -- 1704
	self.manager:emit("ButtonUp", controllerId or 0, buttonName) -- 1705
end -- 1704
function InputManager.prototype.emitAxis(self, axisName, value, controllerId) -- 1708
	self.manager:emit("Axis", controllerId or 0, axisName, value) -- 1709
end -- 1708
function InputManager.prototype.destroy(self) -- 1712
	self:getNode():removeFromParent() -- 1713
	self.contextStack = {} -- 1714
end -- 1712
function ____exports.CreateManager(contexts) -- 1718
	return __TS__New(InputManager, contexts) -- 1719
end -- 1718
function ____exports.DPad(props) -- 1731
	local ____props_3 = props -- 1738
	local width = ____props_3.width -- 1738
	if width == nil then -- 1738
		width = 40 -- 1733
	end -- 1733
	local height = ____props_3.height -- 1733
	if height == nil then -- 1733
		height = 40 -- 1734
	end -- 1734
	local offset = ____props_3.offset -- 1734
	if offset == nil then -- 1734
		offset = 5 -- 1735
	end -- 1735
	local color = ____props_3.color -- 1735
	if color == nil then -- 1735
		color = 4294967295 -- 1736
	end -- 1736
	local primaryOpacity = ____props_3.primaryOpacity -- 1736
	if primaryOpacity == nil then -- 1736
		primaryOpacity = 0.3 -- 1737
	end -- 1737
	local halfSize = height + width / 2 + offset -- 1739
	local dOffset = height / 2 + width / 2 + offset -- 1740
	local function DPadButton(props) -- 1742
		local hw = width / 2 -- 1743
		local drawNode = reference() -- 1744
		return React.createElement( -- 1745
			"node", -- 1745
			__TS__ObjectAssign( -- 1745
				{}, -- 1745
				props, -- 1746
				{ -- 1746
					width = width, -- 1746
					height = height, -- 1746
					onTapBegan = function() -- 1746
						if drawNode.current then -- 1746
							drawNode.current.opacity = 1 -- 1749
						end -- 1749
					end, -- 1747
					onTapEnded = function() -- 1747
						if drawNode.current then -- 1747
							drawNode.current.opacity = primaryOpacity -- 1754
						end -- 1754
					end -- 1752
				} -- 1752
			), -- 1752
			React.createElement( -- 1752
				"draw-node", -- 1752
				{ref = drawNode, y = -hw, x = hw, opacity = primaryOpacity}, -- 1752
				React.createElement( -- 1752
					"polygon-shape", -- 1752
					{ -- 1752
						verts = { -- 1752
							Vec2(-hw, hw + height), -- 1760
							Vec2(hw, hw + height), -- 1761
							Vec2(hw, hw), -- 1762
							Vec2.zero, -- 1763
							Vec2(-hw, hw) -- 1764
						}, -- 1764
						fillColor = color -- 1764
					} -- 1764
				) -- 1764
			) -- 1764
		) -- 1764
	end -- 1742
	local function onMount(buttonName) -- 1771
		return function(node) -- 1772
			node:slot( -- 1773
				"TapBegan", -- 1773
				function() return props.inputManager:emitButtonDown(buttonName) end -- 1773
			) -- 1773
			node:slot( -- 1774
				"TapEnded", -- 1774
				function() return props.inputManager:emitButtonUp(buttonName) end -- 1774
			) -- 1774
		end -- 1772
	end -- 1771
	local up = reference() -- 1778
	local down = reference() -- 1779
	local left = reference() -- 1780
	local right = reference() -- 1781
	local center = reference() -- 1782
	local current -- 1784
	local function clearButton() -- 1786
		if current then -- 1786
			current:emit("TapEnded") -- 1788
			current = nil -- 1789
		end -- 1789
	end -- 1786
	local function changeToButton(node) -- 1793
		if current ~= node then -- 1793
			clearButton() -- 1795
			current = node -- 1796
			current:emit("TapBegan") -- 1797
		end -- 1797
	end -- 1793
	local function touchForButton(touch) -- 1801
		if not up.current or not down.current or not left.current or not right.current or not center.current then -- 1801
			return -- 1802
		end -- 1802
		local menu = up.current.parent -- 1803
		if not menu then -- 1803
			return -- 1804
		end -- 1804
		local wp = menu:convertToWorldSpace(touch.location) -- 1805
		local ____temp_4 = center.current:convertToNodeSpace(wp) -- 1806
		local x = ____temp_4.x -- 1806
		local y = ____temp_4.y -- 1806
		local hw = (width + offset * 2) / 2 -- 1807
		x = x - hw -- 1808
		y = y - hw -- 1808
		local angle = math.deg(math.atan(y, x)) -- 1809
		if 45 <= angle and angle < 145 then -- 1809
			changeToButton(up.current) -- 1811
		elseif -45 <= angle and angle < 45 then -- 1811
			changeToButton(right.current) -- 1813
		elseif -145 <= angle and angle < -45 then -- 1813
			changeToButton(down.current) -- 1815
		else -- 1815
			changeToButton(left.current) -- 1817
		end -- 1817
	end -- 1801
	return React.createElement( -- 1821
		"align-node", -- 1821
		{style = {width = halfSize * 2, height = halfSize * 2}}, -- 1821
		React.createElement( -- 1821
			"menu", -- 1821
			{x = halfSize, y = halfSize, width = halfSize * 2, height = halfSize * 2}, -- 1821
			React.createElement( -- 1821
				DPadButton, -- 1824
				{ -- 1824
					ref = up, -- 1824
					x = halfSize, -- 1824
					y = dOffset + halfSize, -- 1824
					onMount = onMount("dpup") -- 1824
				} -- 1824
			), -- 1824
			React.createElement( -- 1824
				DPadButton, -- 1825
				{ -- 1825
					ref = down, -- 1825
					x = halfSize, -- 1825
					y = -dOffset + halfSize, -- 1825
					angle = 180, -- 1825
					onMount = onMount("dpdown") -- 1825
				} -- 1825
			), -- 1825
			React.createElement( -- 1825
				DPadButton, -- 1826
				{ -- 1826
					ref = right, -- 1826
					x = dOffset + halfSize, -- 1826
					y = halfSize, -- 1826
					angle = 90, -- 1826
					onMount = onMount("dpright") -- 1826
				} -- 1826
			), -- 1826
			React.createElement( -- 1826
				DPadButton, -- 1827
				{ -- 1827
					ref = left, -- 1827
					x = -dOffset + halfSize, -- 1827
					y = halfSize, -- 1827
					angle = -90, -- 1827
					onMount = onMount("dpleft") -- 1827
				} -- 1827
			), -- 1827
			React.createElement( -- 1827
				"node", -- 1827
				{ -- 1827
					ref = center, -- 1827
					x = halfSize, -- 1827
					y = halfSize, -- 1827
					width = width + offset * 2, -- 1827
					height = width + offset * 2, -- 1827
					onTapBegan = function(touch) return touchForButton(touch) end, -- 1827
					onTapMoved = function(touch) return touchForButton(touch) end, -- 1827
					onTapEnded = function() return clearButton() end -- 1827
				} -- 1827
			) -- 1827
		) -- 1827
	) -- 1827
end -- 1731
function ____exports.CreateDPad(props) -- 1838
	return toNode(React.createElement( -- 1839
		____exports.DPad, -- 1839
		__TS__ObjectAssign({}, props) -- 1839
	)) -- 1839
end -- 1838
local function Button(props) -- 1855
	local ____props_5 = props -- 1863
	local x = ____props_5.x -- 1863
	local y = ____props_5.y -- 1863
	local onMount = ____props_5.onMount -- 1863
	local text = ____props_5.text -- 1863
	local fontName = ____props_5.fontName -- 1863
	if fontName == nil then -- 1863
		fontName = "sarasa-mono-sc-regular" -- 1859
	end -- 1859
	local buttonSize = ____props_5.buttonSize -- 1859
	local color = ____props_5.color -- 1859
	if color == nil then -- 1859
		color = 4294967295 -- 1861
	end -- 1861
	local primaryOpacity = ____props_5.primaryOpacity -- 1861
	if primaryOpacity == nil then -- 1861
		primaryOpacity = 0.3 -- 1862
	end -- 1862
	local drawNode = reference() -- 1864
	return React.createElement( -- 1865
		"node", -- 1865
		{ -- 1865
			x = x, -- 1865
			y = y, -- 1865
			onMount = onMount, -- 1865
			width = buttonSize * 2, -- 1865
			height = buttonSize * 2, -- 1865
			onTapBegan = function() -- 1865
				if drawNode.current then -- 1865
					drawNode.current.opacity = 1 -- 1869
				end -- 1869
			end, -- 1867
			onTapEnded = function() -- 1867
				if drawNode.current then -- 1867
					drawNode.current.opacity = primaryOpacity -- 1874
				end -- 1874
			end -- 1872
		}, -- 1872
		React.createElement( -- 1872
			"draw-node", -- 1872
			{ref = drawNode, x = buttonSize, y = buttonSize, opacity = primaryOpacity}, -- 1872
			React.createElement("dot-shape", {radius = buttonSize, color = color}) -- 1872
		), -- 1872
		React.createElement("label", { -- 1872
			x = buttonSize, -- 1872
			y = buttonSize, -- 1872
			scaleX = 0.5, -- 1872
			scaleY = 0.5, -- 1872
			color3 = color, -- 1872
			opacity = primaryOpacity + 0.2, -- 1872
			fontName = fontName, -- 1872
			fontSize = buttonSize * 2 -- 1872
		}, text) -- 1872
	) -- 1872
end -- 1855
function ____exports.JoyStick(props) -- 1900
	local hat = reference() -- 1901
	local ____props_6 = props -- 1911
	local moveSize = ____props_6.moveSize -- 1911
	if moveSize == nil then -- 1911
		moveSize = 70 -- 1903
	end -- 1903
	local hatSize = ____props_6.hatSize -- 1903
	if hatSize == nil then -- 1903
		hatSize = 40 -- 1904
	end -- 1904
	local stickType = ____props_6.stickType -- 1904
	if stickType == nil then -- 1904
		stickType = "Left" -- 1905
	end -- 1905
	local color = ____props_6.color -- 1905
	if color == nil then -- 1905
		color = 4294967295 -- 1906
	end -- 1906
	local primaryOpacity = ____props_6.primaryOpacity -- 1906
	if primaryOpacity == nil then -- 1906
		primaryOpacity = 0.3 -- 1907
	end -- 1907
	local secondaryOpacity = ____props_6.secondaryOpacity -- 1907
	if secondaryOpacity == nil then -- 1907
		secondaryOpacity = 0.1 -- 1908
	end -- 1908
	local fontName = ____props_6.fontName -- 1908
	if fontName == nil then -- 1908
		fontName = "sarasa-mono-sc-regular" -- 1909
	end -- 1909
	local buttonSize = ____props_6.buttonSize -- 1909
	if buttonSize == nil then -- 1909
		buttonSize = 20 -- 1910
	end -- 1910
	local visualBound = math.max(moveSize - hatSize, 0) -- 1912
	local stickButton = stickType == "Left" and "leftstick" or "rightstick" -- 1913
	local function updatePosition(node, location) -- 1915
		if location.length > visualBound then -- 1915
			node.position = location:normalize():mul(visualBound) -- 1917
		else -- 1917
			node.position = location -- 1919
		end -- 1919
		repeat -- 1919
			local ____switch463 = stickType -- 1919
			local ____cond463 = ____switch463 == "Left" -- 1919
			if ____cond463 then -- 1919
				props.inputManager:emitAxis("leftx", node.x / visualBound) -- 1923
				props.inputManager:emitAxis("lefty", node.y / visualBound) -- 1924
				break -- 1925
			end -- 1925
			____cond463 = ____cond463 or ____switch463 == "Right" -- 1925
			if ____cond463 then -- 1925
				props.inputManager:emitAxis("rightx", node.x / visualBound) -- 1927
				props.inputManager:emitAxis("righty", node.y / visualBound) -- 1928
				break -- 1929
			end -- 1929
		until true -- 1929
	end -- 1915
	local ____React_createElement_11 = React.createElement -- 1915
	local ____temp_9 = {style = {width = moveSize * 2, height = moveSize * 2}} -- 1915
	local ____React_createElement_result_10 = React.createElement( -- 1915
		"node", -- 1915
		{ -- 1915
			x = moveSize, -- 1915
			y = moveSize, -- 1915
			onTapFilter = function(touch) -- 1915
				local ____touch_7 = touch -- 1937
				local location = ____touch_7.location -- 1937
				if location.length > moveSize then -- 1937
					touch.enabled = false -- 1939
				end -- 1939
			end, -- 1936
			onTapBegan = function(touch) -- 1936
				if hat.current then -- 1936
					hat.current.opacity = 1 -- 1944
					updatePosition(hat.current, touch.location) -- 1945
				end -- 1945
			end, -- 1942
			onTapMoved = function(touch) -- 1942
				if hat.current then -- 1942
					hat.current.opacity = 1 -- 1950
					updatePosition(hat.current, touch.location) -- 1951
				end -- 1951
			end, -- 1948
			onTapped = function() -- 1948
				if hat.current then -- 1948
					hat.current.opacity = primaryOpacity -- 1956
					updatePosition(hat.current, Vec2.zero) -- 1957
				end -- 1957
			end -- 1954
		}, -- 1954
		React.createElement( -- 1954
			"draw-node", -- 1954
			{opacity = secondaryOpacity}, -- 1954
			React.createElement("dot-shape", {radius = moveSize, color = color}) -- 1954
		), -- 1954
		React.createElement( -- 1954
			"draw-node", -- 1954
			{ref = hat, opacity = primaryOpacity}, -- 1954
			React.createElement("dot-shape", {radius = hatSize, color = color}) -- 1954
		) -- 1954
	) -- 1954
	local ____props_noStickButton_8 -- 1968
	if props.noStickButton then -- 1968
		____props_noStickButton_8 = nil -- 1968
	else -- 1968
		____props_noStickButton_8 = React.createElement( -- 1968
			Button, -- 1969
			{ -- 1969
				buttonSize = buttonSize, -- 1969
				x = moveSize, -- 1969
				y = moveSize * 2 + buttonSize / 2 + 20, -- 1969
				text = stickType == "Left" and "LS" or "RS", -- 1969
				fontName = fontName, -- 1969
				color = color, -- 1969
				primaryOpacity = primaryOpacity, -- 1969
				onMount = function(node) -- 1969
					node:slot( -- 1978
						"TapBegan", -- 1978
						function() return props.inputManager:emitButtonDown(stickButton) end -- 1978
					) -- 1978
					node:slot( -- 1979
						"TapEnded", -- 1979
						function() return props.inputManager:emitButtonUp(stickButton) end -- 1979
					) -- 1979
				end -- 1977
			} -- 1977
		) -- 1977
	end -- 1977
	return ____React_createElement_11("align-node", ____temp_9, ____React_createElement_result_10, ____props_noStickButton_8) -- 1933
end -- 1900
function ____exports.ButtonPad(props) -- 1996
	local ____props_12 = props -- 2003
	local buttonSize = ____props_12.buttonSize -- 2003
	if buttonSize == nil then -- 2003
		buttonSize = 30 -- 1998
	end -- 1998
	local buttonPadding = ____props_12.buttonPadding -- 1998
	if buttonPadding == nil then -- 1998
		buttonPadding = 10 -- 1999
	end -- 1999
	local fontName = ____props_12.fontName -- 1999
	if fontName == nil then -- 1999
		fontName = "sarasa-mono-sc-regular" -- 2000
	end -- 2000
	local color = ____props_12.color -- 2000
	if color == nil then -- 2000
		color = 4294967295 -- 2001
	end -- 2001
	local primaryOpacity = ____props_12.primaryOpacity -- 2001
	if primaryOpacity == nil then -- 2001
		primaryOpacity = 0.3 -- 2002
	end -- 2002
	local width = buttonSize * 5 + buttonPadding * 3 / 2 -- 2004
	local height = buttonSize * 4 + buttonPadding -- 2005
	local function onMount(buttonName) -- 2006
		return function(node) -- 2007
			node:slot( -- 2008
				"TapBegan", -- 2008
				function() return props.inputManager:emitButtonDown(buttonName) end -- 2008
			) -- 2008
			node:slot( -- 2009
				"TapEnded", -- 2009
				function() return props.inputManager:emitButtonUp(buttonName) end -- 2009
			) -- 2009
		end -- 2007
	end -- 2006
	return React.createElement( -- 2012
		"align-node", -- 2012
		{style = {width = width, height = height}}, -- 2012
		React.createElement( -- 2012
			"node", -- 2012
			{x = (buttonSize + buttonPadding / 2) / 2 + width / 2, y = buttonSize + buttonPadding / 2 + height / 2}, -- 2012
			React.createElement( -- 2012
				Button, -- 2018
				{ -- 2018
					text = "X", -- 2018
					fontName = fontName, -- 2018
					color = color, -- 2018
					primaryOpacity = primaryOpacity, -- 2018
					buttonSize = buttonSize, -- 2018
					x = -buttonSize * 2 - buttonPadding, -- 2018
					onMount = onMount("x") -- 2018
				} -- 2018
			), -- 2018
			React.createElement( -- 2018
				Button, -- 2024
				{ -- 2024
					text = "Y", -- 2024
					fontName = fontName, -- 2024
					color = color, -- 2024
					primaryOpacity = primaryOpacity, -- 2024
					buttonSize = buttonSize, -- 2024
					onMount = onMount("y") -- 2024
				} -- 2024
			), -- 2024
			React.createElement( -- 2024
				Button, -- 2028
				{ -- 2028
					text = "A", -- 2028
					fontName = fontName, -- 2028
					color = color, -- 2028
					primaryOpacity = primaryOpacity, -- 2028
					buttonSize = buttonSize, -- 2028
					x = -buttonSize - buttonPadding / 2, -- 2028
					y = -buttonSize * 2 - buttonPadding, -- 2028
					onMount = onMount("a") -- 2028
				} -- 2028
			), -- 2028
			React.createElement( -- 2028
				Button, -- 2035
				{ -- 2035
					text = "B", -- 2035
					fontName = fontName, -- 2035
					color = color, -- 2035
					primaryOpacity = primaryOpacity, -- 2035
					buttonSize = buttonSize, -- 2035
					x = buttonSize + buttonPadding / 2, -- 2035
					y = -buttonSize * 2 - buttonPadding, -- 2035
					onMount = onMount("b") -- 2035
				} -- 2035
			) -- 2035
		) -- 2035
	) -- 2035
end -- 1996
function ____exports.CreateButtonPad(props) -- 2047
	return toNode(React.createElement( -- 2048
		____exports.ButtonPad, -- 2048
		__TS__ObjectAssign({}, props) -- 2048
	)) -- 2048
end -- 2047
function ____exports.ControlPad(props) -- 2061
	local ____props_13 = props -- 2067
	local buttonSize = ____props_13.buttonSize -- 2067
	if buttonSize == nil then -- 2067
		buttonSize = 35 -- 2063
	end -- 2063
	local fontName = ____props_13.fontName -- 2063
	if fontName == nil then -- 2063
		fontName = "sarasa-mono-sc-regular" -- 2064
	end -- 2064
	local color = ____props_13.color -- 2064
	if color == nil then -- 2064
		color = 4294967295 -- 2065
	end -- 2065
	local primaryOpacity = ____props_13.primaryOpacity -- 2065
	if primaryOpacity == nil then -- 2065
		primaryOpacity = 0.3 -- 2066
	end -- 2066
	local function Button(props) -- 2068
		local drawNode = reference() -- 2069
		return React.createElement( -- 2070
			"node", -- 2070
			__TS__ObjectAssign( -- 2070
				{}, -- 2070
				props, -- 2071
				{ -- 2071
					width = buttonSize * 2, -- 2071
					height = buttonSize, -- 2071
					onTapBegan = function() -- 2071
						if drawNode.current then -- 2071
							drawNode.current.opacity = 1 -- 2074
						end -- 2074
					end, -- 2072
					onTapEnded = function() -- 2072
						if drawNode.current then -- 2072
							drawNode.current.opacity = primaryOpacity -- 2079
						end -- 2079
					end -- 2077
				} -- 2077
			), -- 2077
			React.createElement( -- 2077
				"draw-node", -- 2077
				{ref = drawNode, x = buttonSize, y = buttonSize / 2, opacity = primaryOpacity}, -- 2077
				React.createElement("rect-shape", {width = buttonSize * 2, height = buttonSize, fillColor = color}) -- 2077
			), -- 2077
			React.createElement( -- 2077
				"label", -- 2077
				{ -- 2077
					x = buttonSize, -- 2077
					y = buttonSize / 2, -- 2077
					scaleX = 0.5, -- 2077
					scaleY = 0.5, -- 2077
					fontName = fontName, -- 2077
					fontSize = math.floor(buttonSize * 1.5), -- 2077
					color3 = color, -- 2077
					opacity = primaryOpacity + 0.2 -- 2077
				}, -- 2077
				props.text -- 2088
			) -- 2088
		) -- 2088
	end -- 2068
	local function onMount(buttonName) -- 2092
		return function(node) -- 2093
			node:slot( -- 2094
				"TapBegan", -- 2094
				function() return props.inputManager:emitButtonDown(buttonName) end -- 2094
			) -- 2094
			node:slot( -- 2095
				"TapEnded", -- 2095
				function() return props.inputManager:emitButtonUp(buttonName) end -- 2095
			) -- 2095
		end -- 2093
	end -- 2092
	return React.createElement( -- 2098
		"align-node", -- 2098
		{style = {minWidth = buttonSize * 4 + 20, justifyContent = "space-between", flexDirection = "row"}}, -- 2098
		React.createElement( -- 2098
			"align-node", -- 2098
			{style = {width = buttonSize * 2, height = buttonSize}}, -- 2098
			React.createElement( -- 2098
				Button, -- 2101
				{ -- 2101
					text = "Start", -- 2101
					x = buttonSize, -- 2101
					y = buttonSize / 2, -- 2101
					onMount = onMount("start") -- 2101
				} -- 2101
			) -- 2101
		), -- 2101
		React.createElement( -- 2101
			"align-node", -- 2101
			{style = {width = buttonSize * 2, height = buttonSize}}, -- 2101
			React.createElement( -- 2101
				Button, -- 2107
				{ -- 2107
					text = "Back", -- 2107
					x = buttonSize, -- 2107
					y = buttonSize / 2, -- 2107
					onMount = onMount("back") -- 2107
				} -- 2107
			) -- 2107
		) -- 2107
	) -- 2107
end -- 2061
function ____exports.CreateControlPad(props) -- 2116
	return toNode(React.createElement( -- 2117
		____exports.ControlPad, -- 2117
		__TS__ObjectAssign({}, props) -- 2117
	)) -- 2117
end -- 2116
function ____exports.TriggerPad(props) -- 2131
	local ____props_14 = props -- 2137
	local buttonSize = ____props_14.buttonSize -- 2137
	if buttonSize == nil then -- 2137
		buttonSize = 35 -- 2133
	end -- 2133
	local fontName = ____props_14.fontName -- 2133
	if fontName == nil then -- 2133
		fontName = "sarasa-mono-sc-regular" -- 2134
	end -- 2134
	local color = ____props_14.color -- 2134
	if color == nil then -- 2134
		color = 4294967295 -- 2135
	end -- 2135
	local primaryOpacity = ____props_14.primaryOpacity -- 2135
	if primaryOpacity == nil then -- 2135
		primaryOpacity = 0.3 -- 2136
	end -- 2136
	local function Button(props) -- 2138
		local drawNode = reference() -- 2139
		return React.createElement( -- 2140
			"node", -- 2140
			__TS__ObjectAssign( -- 2140
				{}, -- 2140
				props, -- 2141
				{ -- 2141
					width = buttonSize * 2, -- 2141
					height = buttonSize, -- 2141
					onTapBegan = function() -- 2141
						if drawNode.current then -- 2141
							drawNode.current.opacity = 1 -- 2144
						end -- 2144
					end, -- 2142
					onTapEnded = function() -- 2142
						if drawNode.current then -- 2142
							drawNode.current.opacity = primaryOpacity -- 2149
						end -- 2149
					end -- 2147
				} -- 2147
			), -- 2147
			React.createElement( -- 2147
				"draw-node", -- 2147
				{ref = drawNode, x = buttonSize, y = buttonSize / 2, opacity = primaryOpacity}, -- 2147
				React.createElement("rect-shape", {width = buttonSize * 2, height = buttonSize, fillColor = color}) -- 2147
			), -- 2147
			React.createElement( -- 2147
				"label", -- 2147
				{ -- 2147
					x = buttonSize, -- 2147
					y = buttonSize / 2, -- 2147
					scaleX = 0.5, -- 2147
					scaleY = 0.5, -- 2147
					fontName = fontName, -- 2147
					fontSize = math.floor(buttonSize * 1.5), -- 2147
					color3 = color, -- 2147
					opacity = primaryOpacity + 0.2 -- 2147
				}, -- 2147
				props.text -- 2157
			) -- 2157
		) -- 2157
	end -- 2138
	local function onMountAxis(axisName) -- 2161
		return function(node) -- 2162
			node:slot( -- 2163
				"TapBegan", -- 2163
				function() return props.inputManager:emitAxis(axisName, 1, 0) end -- 2163
			) -- 2163
			node:slot( -- 2164
				"TapEnded", -- 2164
				function() return props.inputManager:emitAxis(axisName, 0, 0) end -- 2164
			) -- 2164
		end -- 2162
	end -- 2161
	local function onMountButton(buttonName) -- 2167
		return function(node) -- 2168
			node:slot( -- 2169
				"TapBegan", -- 2169
				function() return props.inputManager:emitButtonDown(buttonName, 0) end -- 2169
			) -- 2169
			node:slot( -- 2170
				"TapEnded", -- 2170
				function() return props.inputManager:emitButtonUp(buttonName, 0) end -- 2170
			) -- 2170
		end -- 2168
	end -- 2167
	local ____React_createElement_24 = React.createElement -- 2167
	local ____temp_22 = {style = {minWidth = buttonSize * 4 + 20, justifyContent = "space-between", flexDirection = "row"}} -- 2167
	local ____React_createElement_18 = React.createElement -- 2167
	local ____temp_16 = {style = {width = buttonSize * 4 + 10, height = buttonSize}} -- 2167
	local ____React_createElement_result_17 = React.createElement( -- 2167
		Button, -- 2176
		{ -- 2176
			text = "LT", -- 2176
			x = buttonSize, -- 2176
			y = buttonSize / 2, -- 2176
			onMount = onMountAxis("lefttrigger") -- 2176
		} -- 2176
	) -- 2176
	local ____props_noShoulder_15 -- 2180
	if props.noShoulder then -- 2180
		____props_noShoulder_15 = nil -- 2180
	else -- 2180
		____props_noShoulder_15 = React.createElement( -- 2180
			Button, -- 2181
			{ -- 2181
				text = "LB", -- 2181
				x = buttonSize * 3 + 10, -- 2181
				y = buttonSize / 2, -- 2181
				onMount = onMountButton("leftshoulder") -- 2181
			} -- 2181
		) -- 2181
	end -- 2181
	local ____React_createElement_18_result_23 = ____React_createElement_18("align-node", ____temp_16, ____React_createElement_result_17, ____props_noShoulder_15) -- 2181
	local ____React_createElement_21 = React.createElement -- 2181
	local ____temp_20 = {style = {width = buttonSize * 4 + 10, height = buttonSize}} -- 2181
	local ____props_noShoulder_19 -- 2188
	if props.noShoulder then -- 2188
		____props_noShoulder_19 = nil -- 2188
	else -- 2188
		____props_noShoulder_19 = React.createElement( -- 2188
			Button, -- 2189
			{ -- 2189
				text = "RB", -- 2189
				x = buttonSize, -- 2189
				y = buttonSize / 2, -- 2189
				onMount = onMountButton("rightshoulder") -- 2189
			} -- 2189
		) -- 2189
	end -- 2189
	return ____React_createElement_24( -- 2173
		"align-node", -- 2173
		____temp_22, -- 2173
		____React_createElement_18_result_23, -- 2173
		____React_createElement_21( -- 2173
			"align-node", -- 2173
			____temp_20, -- 2173
			____props_noShoulder_19, -- 2173
			React.createElement( -- 2173
				Button, -- 2194
				{ -- 2194
					text = "RT", -- 2194
					x = buttonSize * 3 + 10, -- 2194
					y = buttonSize / 2, -- 2194
					onMount = onMountAxis("righttrigger") -- 2194
				} -- 2194
			) -- 2194
		) -- 2194
	) -- 2194
end -- 2131
function ____exports.CreateTriggerPad(props) -- 2203
	return toNode(React.createElement( -- 2204
		____exports.TriggerPad, -- 2204
		__TS__ObjectAssign({}, props) -- 2204
	)) -- 2204
end -- 2203
function ____exports.GamePad(props) -- 2224
	local ____props_25 = props -- 2225
	local color = ____props_25.color -- 2225
	local primaryOpacity = ____props_25.primaryOpacity -- 2225
	local secondaryOpacity = ____props_25.secondaryOpacity -- 2225
	local inputManager = ____props_25.inputManager -- 2225
	local ____React_createElement_41 = React.createElement -- 2225
	local ____temp_39 = {style = {flexDirection = "column-reverse"}, windowRoot = true} -- 2225
	local ____React_createElement_36 = React.createElement -- 2225
	local ____temp_34 = {style = {margin = 20, justifyContent = "space-between", flexDirection = "row", alignItems = "flex-end"}} -- 2225
	local ____React_createElement_29 = React.createElement -- 2225
	local ____temp_28 = {style = {justifyContent = "space-between", flexDirection = "row", alignItems = "flex-end"}} -- 2225
	local ____props_noDPad_26 -- 2239
	if props.noDPad then -- 2239
		____props_noDPad_26 = nil -- 2239
	else -- 2239
		____props_noDPad_26 = React.createElement(____exports.DPad, {color = color, primaryOpacity = primaryOpacity, inputManager = inputManager}) -- 2239
	end -- 2239
	local ____props_noLeftStick_27 -- 2246
	if props.noLeftStick then -- 2246
		____props_noLeftStick_27 = nil -- 2246
	else -- 2246
		____props_noLeftStick_27 = React.createElement( -- 2246
			React.Fragment, -- 2246
			nil, -- 2246
			React.createElement("align-node", {style = {width = 10}}), -- 2246
			React.createElement(____exports.JoyStick, { -- 2246
				stickType = "Left", -- 2246
				color = color, -- 2246
				primaryOpacity = primaryOpacity, -- 2246
				secondaryOpacity = secondaryOpacity, -- 2246
				inputManager = inputManager, -- 2246
				noStickButton = props.noStickButton -- 2246
			}) -- 2246
		) -- 2246
	end -- 2246
	local ____React_createElement_29_result_35 = ____React_createElement_29("align-node", ____temp_28, ____props_noDPad_26, ____props_noLeftStick_27) -- 2246
	local ____React_createElement_33 = React.createElement -- 2246
	local ____temp_32 = {style = {justifyContent = "space-between", flexDirection = "row", alignItems = "flex-end"}} -- 2246
	local ____props_noRightStick_30 -- 2263
	if props.noRightStick then -- 2263
		____props_noRightStick_30 = nil -- 2263
	else -- 2263
		____props_noRightStick_30 = React.createElement( -- 2263
			React.Fragment, -- 2263
			nil, -- 2263
			React.createElement(____exports.JoyStick, { -- 2263
				stickType = "Right", -- 2263
				color = color, -- 2263
				primaryOpacity = primaryOpacity, -- 2263
				secondaryOpacity = secondaryOpacity, -- 2263
				inputManager = inputManager, -- 2263
				noStickButton = props.noStickButton -- 2263
			}), -- 2263
			React.createElement("align-node", {style = {width = 10}}) -- 2263
		) -- 2263
	end -- 2263
	local ____props_noButtonPad_31 -- 2274
	if props.noButtonPad then -- 2274
		____props_noButtonPad_31 = nil -- 2274
	else -- 2274
		____props_noButtonPad_31 = React.createElement(____exports.ButtonPad, {color = color, primaryOpacity = primaryOpacity, inputManager = inputManager}) -- 2274
	end -- 2274
	local ____React_createElement_36_result_40 = ____React_createElement_36( -- 2274
		"align-node", -- 2274
		____temp_34, -- 2274
		____React_createElement_29_result_35, -- 2274
		____React_createElement_33("align-node", ____temp_32, ____props_noRightStick_30, ____props_noButtonPad_31) -- 2274
	) -- 2274
	local ____props_noTriggerPad_37 -- 2283
	if props.noTriggerPad then -- 2283
		____props_noTriggerPad_37 = nil -- 2283
	else -- 2283
		____props_noTriggerPad_37 = React.createElement( -- 2283
			"align-node", -- 2283
			{style = {paddingLeft = 20, paddingRight = 20, paddingTop = 20}}, -- 2283
			React.createElement(____exports.TriggerPad, {color = color, noShoulder = props.noShoulder, primaryOpacity = primaryOpacity, inputManager = inputManager}) -- 2283
		) -- 2283
	end -- 2283
	local ____props_noControlPad_38 -- 2293
	if props.noControlPad then -- 2293
		____props_noControlPad_38 = nil -- 2293
	else -- 2293
		____props_noControlPad_38 = React.createElement( -- 2293
			"align-node", -- 2293
			{style = {paddingLeft = 20, paddingRight = 20}}, -- 2293
			React.createElement(____exports.ControlPad, {color = color, primaryOpacity = primaryOpacity, inputManager = inputManager}) -- 2293
		) -- 2293
	end -- 2293
	return ____React_createElement_41( -- 2226
		"align-node", -- 2226
		____temp_39, -- 2226
		____React_createElement_36_result_40, -- 2226
		____props_noTriggerPad_37, -- 2226
		____props_noControlPad_38 -- 2226
	) -- 2226
end -- 2224
function ____exports.CreateGamePad(props) -- 2306
	return toNode(React.createElement( -- 2307
		____exports.GamePad, -- 2307
		__TS__ObjectAssign({}, props) -- 2307
	)) -- 2307
end -- 2306
return ____exports -- 2306