-- [tsx]: InputManager.tsx
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ClassExtends = ____lualib.__TS__ClassExtends -- 1
local __TS__ArrayConcat = ____lualib.__TS__ArrayConcat -- 1
local __TS__New = ____lualib.__TS__New -- 1
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
	function Trigger.KeyDoubleDown(key, threshold) -- 1311
		return __TS__New(KeyDoubleDownTrigger, key, threshold or 0.3) -- 1312
	end -- 1311
	function Trigger.AnyKeyPressed() -- 1314
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
	function Trigger.ButtonDoubleDown(button, threshold, controllerId) -- 1341
		return __TS__New(ButtonDoubleDownTrigger, button, threshold or 0.3, controllerId or 0) -- 1342
	end -- 1341
	function Trigger.AnyButtonPressed(controllerId) -- 1344
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
local InputManager = __TS__Class() -- 1375
InputManager.name = "InputManager" -- 1375
function InputManager.prototype.____constructor(self, contexts) -- 1380
	self.manager = Node() -- 1381
	self.contextMap = __TS__New(Map) -- 1382
	for contextName, actionMap in pairs(contexts) do -- 1383
		local actions = {} -- 1384
		for actionName, trigger in pairs(actionMap) do -- 1385
			local name = actionName -- 1386
			local eventName = "Input." .. name -- 1387
			trigger.onChange = function() -- 1388
				local ____trigger_0 = trigger -- 1389
				local state = ____trigger_0.state -- 1389
				local progress = ____trigger_0.progress -- 1389
				local value = ____trigger_0.value -- 1389
				emit(eventName, state, progress, value) -- 1390
			end -- 1388
			actions[#actions + 1] = {name = name, trigger = trigger} -- 1392
		end -- 1392
		self.contextMap:set(contextName, actions) -- 1394
	end -- 1394
	self.contextStack = {} -- 1396
	self.manager:schedule(function(deltaTime) -- 1397
		if #self.contextStack > 0 then -- 1397
			local lastNames = self.contextStack[#self.contextStack] -- 1399
			for ____, name in ipairs(lastNames) do -- 1400
				do -- 1400
					local actions = self.contextMap:get(name) -- 1401
					if actions == nil then -- 1401
						goto __continue349 -- 1403
					end -- 1403
					for ____, action in ipairs(actions) do -- 1405
						if action.trigger.onUpdate then -- 1405
							action.trigger:onUpdate(deltaTime) -- 1407
						end -- 1407
					end -- 1407
				end -- 1407
				::__continue349:: -- 1407
			end -- 1407
		end -- 1407
		return false -- 1412
	end) -- 1397
end -- 1380
function InputManager.prototype.getNode(self) -- 1416
	return self.manager -- 1417
end -- 1416
function InputManager.prototype.pushContext(self, contextNames) -- 1420
	if type(contextNames) == "string" then -- 1420
		contextNames = {contextNames} -- 1422
	end -- 1422
	local exist = true -- 1424
	for ____, name in ipairs(contextNames) do -- 1425
		if exist then -- 1425
			exist = self.contextMap:has(name) -- 1426
		end -- 1426
	end -- 1426
	if not exist then -- 1426
		print("[Dora Error] got non-existed context name from " .. table.concat(contextNames, ", ")) -- 1429
		return false -- 1430
	else -- 1430
		if #self.contextStack > 0 then -- 1430
			local lastNames = self.contextStack[#self.contextStack] -- 1433
			for ____, name in ipairs(lastNames) do -- 1434
				do -- 1434
					local actions = self.contextMap:get(name) -- 1435
					if actions == nil then -- 1435
						goto __continue363 -- 1437
					end -- 1437
					for ____, action in ipairs(actions) do -- 1439
						action.trigger:stop(self.manager) -- 1440
					end -- 1440
				end -- 1440
				::__continue363:: -- 1440
			end -- 1440
		end -- 1440
		local ____self_contextStack_1 = self.contextStack -- 1440
		____self_contextStack_1[#____self_contextStack_1 + 1] = contextNames -- 1444
		for ____, name in ipairs(contextNames) do -- 1445
			do -- 1445
				local actions = self.contextMap:get(name) -- 1446
				if actions == nil then -- 1446
					goto __continue368 -- 1448
				end -- 1448
				for ____, action in ipairs(actions) do -- 1450
					action.trigger:start(self.manager) -- 1451
				end -- 1451
			end -- 1451
			::__continue368:: -- 1451
		end -- 1451
		return true -- 1454
	end -- 1454
end -- 1420
function InputManager.prototype.popContext(self, count) -- 1458
	if count == nil then -- 1458
		count = 1 -- 1459
	end -- 1459
	if #self.contextStack < count then -- 1459
		return false -- 1461
	end -- 1461
	for i = 1, count do -- 1461
		local lastNames = self.contextStack[#self.contextStack] -- 1464
		for ____, name in ipairs(lastNames) do -- 1465
			do -- 1465
				local actions = self.contextMap:get(name) -- 1466
				if actions == nil then -- 1466
					goto __continue376 -- 1468
				end -- 1468
				for ____, action in ipairs(actions) do -- 1470
					action.trigger:stop(self.manager) -- 1471
				end -- 1471
			end -- 1471
			::__continue376:: -- 1471
		end -- 1471
		table.remove(self.contextStack) -- 1474
		if #self.contextStack > 0 then -- 1474
			local lastNames = self.contextStack[#self.contextStack] -- 1476
			for ____, name in ipairs(lastNames) do -- 1477
				do -- 1477
					local actions = self.contextMap:get(name) -- 1478
					if actions == nil then -- 1478
						goto __continue382 -- 1480
					end -- 1480
					for ____, action in ipairs(actions) do -- 1482
						action.trigger:start(self.manager) -- 1483
					end -- 1483
				end -- 1483
				::__continue382:: -- 1483
			end -- 1483
		end -- 1483
	end -- 1483
	return true -- 1488
end -- 1458
function InputManager.prototype.emitKeyDown(self, keyName) -- 1491
	self.manager:emit("KeyDown", keyName) -- 1492
end -- 1491
function InputManager.prototype.emitKeyUp(self, keyName) -- 1495
	self.manager:emit("KeyUp", keyName) -- 1496
end -- 1495
function InputManager.prototype.emitButtonDown(self, buttonName, controllerId) -- 1499
	self.manager:emit("ButtonDown", controllerId or 0, buttonName) -- 1500
end -- 1499
function InputManager.prototype.emitButtonUp(self, buttonName, controllerId) -- 1503
	self.manager:emit("ButtonUp", controllerId or 0, buttonName) -- 1504
end -- 1503
function InputManager.prototype.emitAxis(self, axisName, value, controllerId) -- 1507
	self.manager:emit("Axis", controllerId or 0, axisName, value) -- 1508
end -- 1507
function InputManager.prototype.destroy(self) -- 1511
	self:getNode():removeFromParent() -- 1512
	self.contextStack = {} -- 1513
end -- 1511
function ____exports.CreateManager(contexts) -- 1517
	return __TS__New(InputManager, contexts) -- 1518
end -- 1517
function ____exports.DPad(props) -- 1530
	local ____props_2 = props -- 1537
	local width = ____props_2.width -- 1537
	if width == nil then -- 1537
		width = 40 -- 1532
	end -- 1532
	local height = ____props_2.height -- 1532
	if height == nil then -- 1532
		height = 40 -- 1533
	end -- 1533
	local offset = ____props_2.offset -- 1533
	if offset == nil then -- 1533
		offset = 5 -- 1534
	end -- 1534
	local color = ____props_2.color -- 1534
	if color == nil then -- 1534
		color = 4294967295 -- 1535
	end -- 1535
	local primaryOpacity = ____props_2.primaryOpacity -- 1535
	if primaryOpacity == nil then -- 1535
		primaryOpacity = 0.3 -- 1536
	end -- 1536
	local halfSize = height + width / 2 + offset -- 1538
	local dOffset = height / 2 + width / 2 + offset -- 1539
	local function DPadButton(props) -- 1541
		local hw = width / 2 -- 1542
		local drawNode = useRef() -- 1543
		return React.createElement( -- 1544
			"node", -- 1544
			__TS__ObjectAssign( -- 1544
				{}, -- 1544
				props, -- 1545
				{ -- 1545
					width = width, -- 1545
					height = height, -- 1545
					onTapBegan = function() -- 1545
						if drawNode.current then -- 1545
							drawNode.current.opacity = 1 -- 1548
						end -- 1548
					end, -- 1546
					onTapEnded = function() -- 1546
						if drawNode.current then -- 1546
							drawNode.current.opacity = primaryOpacity -- 1553
						end -- 1553
					end -- 1551
				} -- 1551
			), -- 1551
			React.createElement( -- 1551
				"draw-node", -- 1551
				{ref = drawNode, y = -hw, x = hw, opacity = primaryOpacity}, -- 1551
				React.createElement( -- 1551
					"polygon-shape", -- 1551
					{ -- 1551
						verts = { -- 1551
							Vec2(-hw, hw + height), -- 1559
							Vec2(hw, hw + height), -- 1560
							Vec2(hw, hw), -- 1561
							Vec2.zero, -- 1562
							Vec2(-hw, hw) -- 1563
						}, -- 1563
						fillColor = color -- 1563
					} -- 1563
				) -- 1563
			) -- 1563
		) -- 1563
	end -- 1541
	local function onMount(buttonName) -- 1570
		return function(node) -- 1571
			node:slot( -- 1572
				"TapBegan", -- 1572
				function() return props.inputManager:emitButtonDown(buttonName) end -- 1572
			) -- 1572
			node:slot( -- 1573
				"TapEnded", -- 1573
				function() return props.inputManager:emitButtonUp(buttonName) end -- 1573
			) -- 1573
		end -- 1571
	end -- 1570
	local up = useRef() -- 1577
	local down = useRef() -- 1578
	local left = useRef() -- 1579
	local right = useRef() -- 1580
	local center = useRef() -- 1581
	local current = nil -- 1583
	local function clearButton() -- 1585
		if current then -- 1585
			current:emit("TapEnded") -- 1587
			current = nil -- 1588
		end -- 1588
	end -- 1585
	local function changeToButton(node) -- 1592
		if current ~= node then -- 1592
			clearButton() -- 1594
			current = node -- 1595
			current:emit("TapBegan") -- 1596
		end -- 1596
	end -- 1592
	local function touchForButton(touch) -- 1600
		if not up.current or not down.current or not left.current or not right.current or not center.current then -- 1600
			return -- 1601
		end -- 1601
		local menu = up.current.parent -- 1602
		if not menu then -- 1602
			return -- 1603
		end -- 1603
		local wp = menu:convertToWorldSpace(touch.location) -- 1604
		local ____temp_3 = center.current:convertToNodeSpace(wp) -- 1605
		local x = ____temp_3.x -- 1605
		local y = ____temp_3.y -- 1605
		local hw = (width + offset * 2) / 2 -- 1606
		x = x - hw -- 1607
		y = y - hw -- 1607
		local angle = math.deg(math.atan(y, x)) -- 1608
		if 45 <= angle and angle < 145 then -- 1608
			changeToButton(up.current) -- 1610
		elseif -45 <= angle and angle < 45 then -- 1610
			changeToButton(right.current) -- 1612
		elseif -145 <= angle and angle < -45 then -- 1612
			changeToButton(down.current) -- 1614
		else -- 1614
			changeToButton(left.current) -- 1616
		end -- 1616
	end -- 1600
	return React.createElement( -- 1620
		"align-node", -- 1620
		{style = {width = halfSize * 2, height = halfSize * 2}}, -- 1620
		React.createElement( -- 1620
			"menu", -- 1620
			{x = halfSize, y = halfSize, width = halfSize * 2, height = halfSize * 2}, -- 1620
			React.createElement( -- 1620
				DPadButton, -- 1623
				{ -- 1623
					ref = up, -- 1623
					x = halfSize, -- 1623
					y = dOffset + halfSize, -- 1623
					onMount = onMount("dpup") -- 1623
				} -- 1623
			), -- 1623
			React.createElement( -- 1623
				DPadButton, -- 1624
				{ -- 1624
					ref = down, -- 1624
					x = halfSize, -- 1624
					y = -dOffset + halfSize, -- 1624
					angle = 180, -- 1624
					onMount = onMount("dpdown") -- 1624
				} -- 1624
			), -- 1624
			React.createElement( -- 1624
				DPadButton, -- 1625
				{ -- 1625
					ref = right, -- 1625
					x = dOffset + halfSize, -- 1625
					y = halfSize, -- 1625
					angle = 90, -- 1625
					onMount = onMount("dpright") -- 1625
				} -- 1625
			), -- 1625
			React.createElement( -- 1625
				DPadButton, -- 1626
				{ -- 1626
					ref = left, -- 1626
					x = -dOffset + halfSize, -- 1626
					y = halfSize, -- 1626
					angle = -90, -- 1626
					onMount = onMount("dpleft") -- 1626
				} -- 1626
			), -- 1626
			React.createElement( -- 1626
				"node", -- 1626
				{ -- 1626
					ref = center, -- 1626
					x = halfSize, -- 1626
					y = halfSize, -- 1626
					width = width + offset * 2, -- 1626
					height = width + offset * 2, -- 1626
					onTapBegan = function(touch) return touchForButton(touch) end, -- 1626
					onTapMoved = function(touch) return touchForButton(touch) end, -- 1626
					onTapEnded = function() return clearButton() end -- 1626
				} -- 1626
			) -- 1626
		) -- 1626
	) -- 1626
end -- 1530
function ____exports.CreateDPad(props) -- 1637
	return toNode(React.createElement( -- 1638
		____exports.DPad, -- 1638
		__TS__ObjectAssign({}, props) -- 1638
	)) -- 1638
end -- 1637
local function Button(props) -- 1654
	local ____props_4 = props -- 1662
	local x = ____props_4.x -- 1662
	local y = ____props_4.y -- 1662
	local onMount = ____props_4.onMount -- 1662
	local text = ____props_4.text -- 1662
	local fontName = ____props_4.fontName -- 1662
	if fontName == nil then -- 1662
		fontName = "sarasa-mono-sc-regular" -- 1658
	end -- 1658
	local buttonSize = ____props_4.buttonSize -- 1658
	local color = ____props_4.color -- 1658
	if color == nil then -- 1658
		color = 4294967295 -- 1660
	end -- 1660
	local primaryOpacity = ____props_4.primaryOpacity -- 1660
	if primaryOpacity == nil then -- 1660
		primaryOpacity = 0.3 -- 1661
	end -- 1661
	local drawNode = useRef() -- 1663
	return React.createElement( -- 1664
		"node", -- 1664
		{ -- 1664
			x = x, -- 1664
			y = y, -- 1664
			onMount = onMount, -- 1664
			width = buttonSize * 2, -- 1664
			height = buttonSize * 2, -- 1664
			onTapBegan = function() -- 1664
				if drawNode.current then -- 1664
					drawNode.current.opacity = 1 -- 1668
				end -- 1668
			end, -- 1666
			onTapEnded = function() -- 1666
				if drawNode.current then -- 1666
					drawNode.current.opacity = primaryOpacity -- 1673
				end -- 1673
			end -- 1671
		}, -- 1671
		React.createElement( -- 1671
			"draw-node", -- 1671
			{ref = drawNode, x = buttonSize, y = buttonSize, opacity = primaryOpacity}, -- 1671
			React.createElement("dot-shape", {radius = buttonSize, color = color}) -- 1671
		), -- 1671
		React.createElement("label", { -- 1671
			x = buttonSize, -- 1671
			y = buttonSize, -- 1671
			scaleX = 0.5, -- 1671
			scaleY = 0.5, -- 1671
			color3 = color, -- 1671
			opacity = primaryOpacity + 0.2, -- 1671
			fontName = fontName, -- 1671
			fontSize = buttonSize * 2 -- 1671
		}, text) -- 1671
	) -- 1671
end -- 1654
function ____exports.JoyStick(props) -- 1699
	local hat = useRef() -- 1700
	local ____props_5 = props -- 1710
	local moveSize = ____props_5.moveSize -- 1710
	if moveSize == nil then -- 1710
		moveSize = 70 -- 1702
	end -- 1702
	local hatSize = ____props_5.hatSize -- 1702
	if hatSize == nil then -- 1702
		hatSize = 40 -- 1703
	end -- 1703
	local stickType = ____props_5.stickType -- 1703
	if stickType == nil then -- 1703
		stickType = "Left" -- 1704
	end -- 1704
	local color = ____props_5.color -- 1704
	if color == nil then -- 1704
		color = 4294967295 -- 1705
	end -- 1705
	local primaryOpacity = ____props_5.primaryOpacity -- 1705
	if primaryOpacity == nil then -- 1705
		primaryOpacity = 0.3 -- 1706
	end -- 1706
	local secondaryOpacity = ____props_5.secondaryOpacity -- 1706
	if secondaryOpacity == nil then -- 1706
		secondaryOpacity = 0.1 -- 1707
	end -- 1707
	local fontName = ____props_5.fontName -- 1707
	if fontName == nil then -- 1707
		fontName = "sarasa-mono-sc-regular" -- 1708
	end -- 1708
	local buttonSize = ____props_5.buttonSize -- 1708
	if buttonSize == nil then -- 1708
		buttonSize = 20 -- 1709
	end -- 1709
	local visualBound = math.max(moveSize - hatSize, 0) -- 1711
	local stickButton = stickType == "Left" and "leftstick" or "rightstick" -- 1712
	local function updatePosition(node, location) -- 1714
		if location.length > visualBound then -- 1714
			node.position = location:normalize():mul(visualBound) -- 1716
		else -- 1716
			node.position = location -- 1718
		end -- 1718
		repeat -- 1718
			local ____switch428 = stickType -- 1718
			local ____cond428 = ____switch428 == "Left" -- 1718
			if ____cond428 then -- 1718
				props.inputManager:emitAxis("leftx", node.x / visualBound) -- 1722
				props.inputManager:emitAxis("lefty", node.y / visualBound) -- 1723
				break -- 1724
			end -- 1724
			____cond428 = ____cond428 or ____switch428 == "Right" -- 1724
			if ____cond428 then -- 1724
				props.inputManager:emitAxis("rightx", node.x / visualBound) -- 1726
				props.inputManager:emitAxis("righty", node.y / visualBound) -- 1727
				break -- 1728
			end -- 1728
		until true -- 1728
	end -- 1714
	local ____React_createElement_10 = React.createElement -- 1714
	local ____temp_8 = {style = {width = moveSize * 2, height = moveSize * 2}} -- 1714
	local ____React_createElement_result_9 = React.createElement( -- 1714
		"node", -- 1714
		{ -- 1714
			x = moveSize, -- 1714
			y = moveSize, -- 1714
			onTapFilter = function(touch) -- 1714
				local ____touch_6 = touch -- 1736
				local location = ____touch_6.location -- 1736
				if location.length > moveSize then -- 1736
					touch.enabled = false -- 1738
				end -- 1738
			end, -- 1735
			onTapBegan = function(touch) -- 1735
				if hat.current then -- 1735
					hat.current.opacity = 1 -- 1743
					updatePosition(hat.current, touch.location) -- 1744
				end -- 1744
			end, -- 1741
			onTapMoved = function(touch) -- 1741
				if hat.current then -- 1741
					hat.current.opacity = 1 -- 1749
					updatePosition(hat.current, touch.location) -- 1750
				end -- 1750
			end, -- 1747
			onTapped = function() -- 1747
				if hat.current then -- 1747
					hat.current.opacity = primaryOpacity -- 1755
					updatePosition(hat.current, Vec2.zero) -- 1756
				end -- 1756
			end -- 1753
		}, -- 1753
		React.createElement( -- 1753
			"draw-node", -- 1753
			{opacity = secondaryOpacity}, -- 1753
			React.createElement("dot-shape", {radius = moveSize, color = color}) -- 1753
		), -- 1753
		React.createElement( -- 1753
			"draw-node", -- 1753
			{ref = hat, opacity = primaryOpacity}, -- 1753
			React.createElement("dot-shape", {radius = hatSize, color = color}) -- 1753
		) -- 1753
	) -- 1753
	local ____props_noStickButton_7 -- 1767
	if props.noStickButton then -- 1767
		____props_noStickButton_7 = nil -- 1767
	else -- 1767
		____props_noStickButton_7 = React.createElement( -- 1767
			Button, -- 1768
			{ -- 1768
				buttonSize = buttonSize, -- 1768
				x = moveSize, -- 1768
				y = moveSize * 2 + buttonSize / 2 + 20, -- 1768
				text = stickType == "Left" and "LS" or "RS", -- 1768
				fontName = fontName, -- 1768
				color = color, -- 1768
				primaryOpacity = primaryOpacity, -- 1768
				onMount = function(node) -- 1768
					node:slot( -- 1777
						"TapBegan", -- 1777
						function() return props.inputManager:emitButtonDown(stickButton) end -- 1777
					) -- 1777
					node:slot( -- 1778
						"TapEnded", -- 1778
						function() return props.inputManager:emitButtonUp(stickButton) end -- 1778
					) -- 1778
				end -- 1776
			} -- 1776
		) -- 1776
	end -- 1776
	return ____React_createElement_10("align-node", ____temp_8, ____React_createElement_result_9, ____props_noStickButton_7) -- 1732
end -- 1699
function ____exports.ButtonPad(props) -- 1795
	local ____props_11 = props -- 1802
	local buttonSize = ____props_11.buttonSize -- 1802
	if buttonSize == nil then -- 1802
		buttonSize = 30 -- 1797
	end -- 1797
	local buttonPadding = ____props_11.buttonPadding -- 1797
	if buttonPadding == nil then -- 1797
		buttonPadding = 10 -- 1798
	end -- 1798
	local fontName = ____props_11.fontName -- 1798
	if fontName == nil then -- 1798
		fontName = "sarasa-mono-sc-regular" -- 1799
	end -- 1799
	local color = ____props_11.color -- 1799
	if color == nil then -- 1799
		color = 4294967295 -- 1800
	end -- 1800
	local primaryOpacity = ____props_11.primaryOpacity -- 1800
	if primaryOpacity == nil then -- 1800
		primaryOpacity = 0.3 -- 1801
	end -- 1801
	local width = buttonSize * 5 + buttonPadding * 3 / 2 -- 1803
	local height = buttonSize * 4 + buttonPadding -- 1804
	local function onMount(buttonName) -- 1805
		return function(node) -- 1806
			node:slot( -- 1807
				"TapBegan", -- 1807
				function() return props.inputManager:emitButtonDown(buttonName) end -- 1807
			) -- 1807
			node:slot( -- 1808
				"TapEnded", -- 1808
				function() return props.inputManager:emitButtonUp(buttonName) end -- 1808
			) -- 1808
		end -- 1806
	end -- 1805
	return React.createElement( -- 1811
		"align-node", -- 1811
		{style = {width = width, height = height}}, -- 1811
		React.createElement( -- 1811
			"node", -- 1811
			{x = (buttonSize + buttonPadding / 2) / 2 + width / 2, y = buttonSize + buttonPadding / 2 + height / 2}, -- 1811
			React.createElement( -- 1811
				Button, -- 1817
				{ -- 1817
					text = "X", -- 1817
					fontName = fontName, -- 1817
					color = color, -- 1817
					primaryOpacity = primaryOpacity, -- 1817
					buttonSize = buttonSize, -- 1817
					x = -buttonSize * 2 - buttonPadding, -- 1817
					onMount = onMount("x") -- 1817
				} -- 1817
			), -- 1817
			React.createElement( -- 1817
				Button, -- 1823
				{ -- 1823
					text = "Y", -- 1823
					fontName = fontName, -- 1823
					color = color, -- 1823
					primaryOpacity = primaryOpacity, -- 1823
					buttonSize = buttonSize, -- 1823
					onMount = onMount("y") -- 1823
				} -- 1823
			), -- 1823
			React.createElement( -- 1823
				Button, -- 1827
				{ -- 1827
					text = "A", -- 1827
					fontName = fontName, -- 1827
					color = color, -- 1827
					primaryOpacity = primaryOpacity, -- 1827
					buttonSize = buttonSize, -- 1827
					x = -buttonSize - buttonPadding / 2, -- 1827
					y = -buttonSize * 2 - buttonPadding, -- 1827
					onMount = onMount("a") -- 1827
				} -- 1827
			), -- 1827
			React.createElement( -- 1827
				Button, -- 1834
				{ -- 1834
					text = "B", -- 1834
					fontName = fontName, -- 1834
					color = color, -- 1834
					primaryOpacity = primaryOpacity, -- 1834
					buttonSize = buttonSize, -- 1834
					x = buttonSize + buttonPadding / 2, -- 1834
					y = -buttonSize * 2 - buttonPadding, -- 1834
					onMount = onMount("b") -- 1834
				} -- 1834
			) -- 1834
		) -- 1834
	) -- 1834
end -- 1795
function ____exports.CreateButtonPad(props) -- 1846
	return toNode(React.createElement( -- 1847
		____exports.ButtonPad, -- 1847
		__TS__ObjectAssign({}, props) -- 1847
	)) -- 1847
end -- 1846
function ____exports.ControlPad(props) -- 1860
	local ____props_12 = props -- 1866
	local buttonSize = ____props_12.buttonSize -- 1866
	if buttonSize == nil then -- 1866
		buttonSize = 35 -- 1862
	end -- 1862
	local fontName = ____props_12.fontName -- 1862
	if fontName == nil then -- 1862
		fontName = "sarasa-mono-sc-regular" -- 1863
	end -- 1863
	local color = ____props_12.color -- 1863
	if color == nil then -- 1863
		color = 4294967295 -- 1864
	end -- 1864
	local primaryOpacity = ____props_12.primaryOpacity -- 1864
	if primaryOpacity == nil then -- 1864
		primaryOpacity = 0.3 -- 1865
	end -- 1865
	local function Button(props) -- 1867
		local drawNode = useRef() -- 1868
		return React.createElement( -- 1869
			"node", -- 1869
			__TS__ObjectAssign( -- 1869
				{}, -- 1869
				props, -- 1870
				{ -- 1870
					width = buttonSize * 2, -- 1870
					height = buttonSize, -- 1870
					onTapBegan = function() -- 1870
						if drawNode.current then -- 1870
							drawNode.current.opacity = 1 -- 1873
						end -- 1873
					end, -- 1871
					onTapEnded = function() -- 1871
						if drawNode.current then -- 1871
							drawNode.current.opacity = primaryOpacity -- 1878
						end -- 1878
					end -- 1876
				} -- 1876
			), -- 1876
			React.createElement( -- 1876
				"draw-node", -- 1876
				{ref = drawNode, x = buttonSize, y = buttonSize / 2, opacity = primaryOpacity}, -- 1876
				React.createElement("rect-shape", {width = buttonSize * 2, height = buttonSize, fillColor = color}) -- 1876
			), -- 1876
			React.createElement( -- 1876
				"label", -- 1876
				{ -- 1876
					x = buttonSize, -- 1876
					y = buttonSize / 2, -- 1876
					scaleX = 0.5, -- 1876
					scaleY = 0.5, -- 1876
					fontName = fontName, -- 1876
					fontSize = math.floor(buttonSize * 1.5), -- 1876
					color3 = color, -- 1876
					opacity = primaryOpacity + 0.2 -- 1876
				}, -- 1876
				props.text -- 1887
			) -- 1887
		) -- 1887
	end -- 1867
	local function onMount(buttonName) -- 1891
		return function(node) -- 1892
			node:slot( -- 1893
				"TapBegan", -- 1893
				function() return props.inputManager:emitButtonDown(buttonName) end -- 1893
			) -- 1893
			node:slot( -- 1894
				"TapEnded", -- 1894
				function() return props.inputManager:emitButtonUp(buttonName) end -- 1894
			) -- 1894
		end -- 1892
	end -- 1891
	return React.createElement( -- 1897
		"align-node", -- 1897
		{style = {minWidth = buttonSize * 4 + 20, justifyContent = "space-between", flexDirection = "row"}}, -- 1897
		React.createElement( -- 1897
			"align-node", -- 1897
			{style = {width = buttonSize * 2, height = buttonSize}}, -- 1897
			React.createElement( -- 1897
				Button, -- 1900
				{ -- 1900
					text = "Start", -- 1900
					x = buttonSize, -- 1900
					y = buttonSize / 2, -- 1900
					onMount = onMount("start") -- 1900
				} -- 1900
			) -- 1900
		), -- 1900
		React.createElement( -- 1900
			"align-node", -- 1900
			{style = {width = buttonSize * 2, height = buttonSize}}, -- 1900
			React.createElement( -- 1900
				Button, -- 1906
				{ -- 1906
					text = "Back", -- 1906
					x = buttonSize, -- 1906
					y = buttonSize / 2, -- 1906
					onMount = onMount("back") -- 1906
				} -- 1906
			) -- 1906
		) -- 1906
	) -- 1906
end -- 1860
function ____exports.CreateControlPad(props) -- 1915
	return toNode(React.createElement( -- 1916
		____exports.ControlPad, -- 1916
		__TS__ObjectAssign({}, props) -- 1916
	)) -- 1916
end -- 1915
function ____exports.TriggerPad(props) -- 1930
	local ____props_13 = props -- 1936
	local buttonSize = ____props_13.buttonSize -- 1936
	if buttonSize == nil then -- 1936
		buttonSize = 35 -- 1932
	end -- 1932
	local fontName = ____props_13.fontName -- 1932
	if fontName == nil then -- 1932
		fontName = "sarasa-mono-sc-regular" -- 1933
	end -- 1933
	local color = ____props_13.color -- 1933
	if color == nil then -- 1933
		color = 4294967295 -- 1934
	end -- 1934
	local primaryOpacity = ____props_13.primaryOpacity -- 1934
	if primaryOpacity == nil then -- 1934
		primaryOpacity = 0.3 -- 1935
	end -- 1935
	local function Button(props) -- 1937
		local drawNode = useRef() -- 1938
		return React.createElement( -- 1939
			"node", -- 1939
			__TS__ObjectAssign( -- 1939
				{}, -- 1939
				props, -- 1940
				{ -- 1940
					width = buttonSize * 2, -- 1940
					height = buttonSize, -- 1940
					onTapBegan = function() -- 1940
						if drawNode.current then -- 1940
							drawNode.current.opacity = 1 -- 1943
						end -- 1943
					end, -- 1941
					onTapEnded = function() -- 1941
						if drawNode.current then -- 1941
							drawNode.current.opacity = primaryOpacity -- 1948
						end -- 1948
					end -- 1946
				} -- 1946
			), -- 1946
			React.createElement( -- 1946
				"draw-node", -- 1946
				{ref = drawNode, x = buttonSize, y = buttonSize / 2, opacity = primaryOpacity}, -- 1946
				React.createElement("rect-shape", {width = buttonSize * 2, height = buttonSize, fillColor = color}) -- 1946
			), -- 1946
			React.createElement( -- 1946
				"label", -- 1946
				{ -- 1946
					x = buttonSize, -- 1946
					y = buttonSize / 2, -- 1946
					scaleX = 0.5, -- 1946
					scaleY = 0.5, -- 1946
					fontName = fontName, -- 1946
					fontSize = math.floor(buttonSize * 1.5), -- 1946
					color3 = color, -- 1946
					opacity = primaryOpacity + 0.2 -- 1946
				}, -- 1946
				props.text -- 1956
			) -- 1956
		) -- 1956
	end -- 1937
	local function onMountAxis(axisName) -- 1960
		return function(node) -- 1961
			node:slot( -- 1962
				"TapBegan", -- 1962
				function() return props.inputManager:emitAxis(axisName, 1, 0) end -- 1962
			) -- 1962
			node:slot( -- 1963
				"TapEnded", -- 1963
				function() return props.inputManager:emitAxis(axisName, 0, 0) end -- 1963
			) -- 1963
		end -- 1961
	end -- 1960
	local function onMountButton(buttonName) -- 1966
		return function(node) -- 1967
			node:slot( -- 1968
				"TapBegan", -- 1968
				function() return props.inputManager:emitButtonDown(buttonName, 0) end -- 1968
			) -- 1968
			node:slot( -- 1969
				"TapEnded", -- 1969
				function() return props.inputManager:emitButtonUp(buttonName, 0) end -- 1969
			) -- 1969
		end -- 1967
	end -- 1966
	local ____React_createElement_23 = React.createElement -- 1966
	local ____temp_21 = {style = {minWidth = buttonSize * 4 + 20, justifyContent = "space-between", flexDirection = "row"}} -- 1966
	local ____React_createElement_17 = React.createElement -- 1966
	local ____temp_15 = {style = {width = buttonSize * 4 + 10, height = buttonSize}} -- 1966
	local ____React_createElement_result_16 = React.createElement( -- 1966
		Button, -- 1975
		{ -- 1975
			text = "LT", -- 1975
			x = buttonSize, -- 1975
			y = buttonSize / 2, -- 1975
			onMount = onMountAxis("lefttrigger") -- 1975
		} -- 1975
	) -- 1975
	local ____props_noShoulder_14 -- 1979
	if props.noShoulder then -- 1979
		____props_noShoulder_14 = nil -- 1979
	else -- 1979
		____props_noShoulder_14 = React.createElement( -- 1979
			Button, -- 1980
			{ -- 1980
				text = "LB", -- 1980
				x = buttonSize * 3 + 10, -- 1980
				y = buttonSize / 2, -- 1980
				onMount = onMountButton("leftshoulder") -- 1980
			} -- 1980
		) -- 1980
	end -- 1980
	local ____React_createElement_17_result_22 = ____React_createElement_17("align-node", ____temp_15, ____React_createElement_result_16, ____props_noShoulder_14) -- 1980
	local ____React_createElement_20 = React.createElement -- 1980
	local ____temp_19 = {style = {width = buttonSize * 4 + 10, height = buttonSize}} -- 1980
	local ____props_noShoulder_18 -- 1987
	if props.noShoulder then -- 1987
		____props_noShoulder_18 = nil -- 1987
	else -- 1987
		____props_noShoulder_18 = React.createElement( -- 1987
			Button, -- 1988
			{ -- 1988
				text = "RB", -- 1988
				x = buttonSize, -- 1988
				y = buttonSize / 2, -- 1988
				onMount = onMountButton("rightshoulder") -- 1988
			} -- 1988
		) -- 1988
	end -- 1988
	return ____React_createElement_23( -- 1972
		"align-node", -- 1972
		____temp_21, -- 1972
		____React_createElement_17_result_22, -- 1972
		____React_createElement_20( -- 1972
			"align-node", -- 1972
			____temp_19, -- 1972
			____props_noShoulder_18, -- 1972
			React.createElement( -- 1972
				Button, -- 1993
				{ -- 1993
					text = "RT", -- 1993
					x = buttonSize * 3 + 10, -- 1993
					y = buttonSize / 2, -- 1993
					onMount = onMountAxis("righttrigger") -- 1993
				} -- 1993
			) -- 1993
		) -- 1993
	) -- 1993
end -- 1930
function ____exports.CreateTriggerPad(props) -- 2002
	return toNode(React.createElement( -- 2003
		____exports.TriggerPad, -- 2003
		__TS__ObjectAssign({}, props) -- 2003
	)) -- 2003
end -- 2002
function ____exports.GamePad(props) -- 2023
	local ____props_24 = props -- 2024
	local color = ____props_24.color -- 2024
	local primaryOpacity = ____props_24.primaryOpacity -- 2024
	local secondaryOpacity = ____props_24.secondaryOpacity -- 2024
	local inputManager = ____props_24.inputManager -- 2024
	local ____React_createElement_40 = React.createElement -- 2024
	local ____temp_38 = {style = {flexDirection = "column-reverse"}, windowRoot = true} -- 2024
	local ____React_createElement_35 = React.createElement -- 2024
	local ____temp_33 = {style = {margin = 20, justifyContent = "space-between", flexDirection = "row", alignItems = "flex-end"}} -- 2024
	local ____React_createElement_28 = React.createElement -- 2024
	local ____temp_27 = {style = {justifyContent = "space-between", flexDirection = "row", alignItems = "flex-end"}} -- 2024
	local ____props_noDPad_25 -- 2038
	if props.noDPad then -- 2038
		____props_noDPad_25 = nil -- 2038
	else -- 2038
		____props_noDPad_25 = React.createElement(____exports.DPad, {color = color, primaryOpacity = primaryOpacity, inputManager = inputManager}) -- 2038
	end -- 2038
	local ____props_noLeftStick_26 -- 2045
	if props.noLeftStick then -- 2045
		____props_noLeftStick_26 = nil -- 2045
	else -- 2045
		____props_noLeftStick_26 = React.createElement( -- 2045
			React.Fragment, -- 2045
			nil, -- 2045
			React.createElement("align-node", {style = {width = 10}}), -- 2045
			React.createElement(____exports.JoyStick, { -- 2045
				stickType = "Left", -- 2045
				color = color, -- 2045
				primaryOpacity = primaryOpacity, -- 2045
				secondaryOpacity = secondaryOpacity, -- 2045
				inputManager = inputManager, -- 2045
				noStickButton = props.noStickButton -- 2045
			}) -- 2045
		) -- 2045
	end -- 2045
	local ____React_createElement_28_result_34 = ____React_createElement_28("align-node", ____temp_27, ____props_noDPad_25, ____props_noLeftStick_26) -- 2045
	local ____React_createElement_32 = React.createElement -- 2045
	local ____temp_31 = {style = {justifyContent = "space-between", flexDirection = "row", alignItems = "flex-end"}} -- 2045
	local ____props_noRightStick_29 -- 2062
	if props.noRightStick then -- 2062
		____props_noRightStick_29 = nil -- 2062
	else -- 2062
		____props_noRightStick_29 = React.createElement( -- 2062
			React.Fragment, -- 2062
			nil, -- 2062
			React.createElement(____exports.JoyStick, { -- 2062
				stickType = "Right", -- 2062
				color = color, -- 2062
				primaryOpacity = primaryOpacity, -- 2062
				secondaryOpacity = secondaryOpacity, -- 2062
				inputManager = inputManager, -- 2062
				noStickButton = props.noStickButton -- 2062
			}), -- 2062
			React.createElement("align-node", {style = {width = 10}}) -- 2062
		) -- 2062
	end -- 2062
	local ____props_noButtonPad_30 -- 2073
	if props.noButtonPad then -- 2073
		____props_noButtonPad_30 = nil -- 2073
	else -- 2073
		____props_noButtonPad_30 = React.createElement(____exports.ButtonPad, {color = color, primaryOpacity = primaryOpacity, inputManager = inputManager}) -- 2073
	end -- 2073
	local ____React_createElement_35_result_39 = ____React_createElement_35( -- 2073
		"align-node", -- 2073
		____temp_33, -- 2073
		____React_createElement_28_result_34, -- 2073
		____React_createElement_32("align-node", ____temp_31, ____props_noRightStick_29, ____props_noButtonPad_30) -- 2073
	) -- 2073
	local ____props_noTriggerPad_36 -- 2082
	if props.noTriggerPad then -- 2082
		____props_noTriggerPad_36 = nil -- 2082
	else -- 2082
		____props_noTriggerPad_36 = React.createElement( -- 2082
			"align-node", -- 2082
			{style = {paddingLeft = 20, paddingRight = 20, paddingTop = 20}}, -- 2082
			React.createElement(____exports.TriggerPad, {color = color, noShoulder = props.noShoulder, primaryOpacity = primaryOpacity, inputManager = inputManager}) -- 2082
		) -- 2082
	end -- 2082
	local ____props_noControlPad_37 -- 2092
	if props.noControlPad then -- 2092
		____props_noControlPad_37 = nil -- 2092
	else -- 2092
		____props_noControlPad_37 = React.createElement( -- 2092
			"align-node", -- 2092
			{style = {paddingLeft = 20, paddingRight = 20}}, -- 2092
			React.createElement(____exports.ControlPad, {color = color, primaryOpacity = primaryOpacity, inputManager = inputManager}) -- 2092
		) -- 2092
	end -- 2092
	return ____React_createElement_40( -- 2025
		"align-node", -- 2025
		____temp_38, -- 2025
		____React_createElement_35_result_39, -- 2025
		____props_noTriggerPad_36, -- 2025
		____props_noControlPad_37 -- 2025
	) -- 2025
end -- 2023
function ____exports.CreateGamePad(props) -- 2105
	return toNode(React.createElement( -- 2106
		____exports.GamePad, -- 2106
		__TS__ObjectAssign({}, props) -- 2106
	)) -- 2106
end -- 2105
return ____exports -- 2105