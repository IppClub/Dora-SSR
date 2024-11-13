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
	return React.createElement( -- 1577
		"align-node", -- 1577
		{style = {width = halfSize * 2, height = halfSize * 2}}, -- 1577
		React.createElement( -- 1577
			"menu", -- 1577
			{x = halfSize, y = halfSize, width = halfSize * 2, height = halfSize * 2}, -- 1577
			React.createElement( -- 1577
				DPadButton, -- 1580
				{ -- 1580
					x = halfSize, -- 1580
					y = dOffset + halfSize, -- 1580
					onMount = onMount("dpup") -- 1580
				} -- 1580
			), -- 1580
			React.createElement( -- 1580
				DPadButton, -- 1581
				{ -- 1581
					x = halfSize, -- 1581
					y = -dOffset + halfSize, -- 1581
					angle = 180, -- 1581
					onMount = onMount("dpdown") -- 1581
				} -- 1581
			), -- 1581
			React.createElement( -- 1581
				DPadButton, -- 1582
				{ -- 1582
					x = dOffset + halfSize, -- 1582
					y = halfSize, -- 1582
					angle = 90, -- 1582
					onMount = onMount("dpright") -- 1582
				} -- 1582
			), -- 1582
			React.createElement( -- 1582
				DPadButton, -- 1583
				{ -- 1583
					x = -dOffset + halfSize, -- 1583
					y = halfSize, -- 1583
					angle = -90, -- 1583
					onMount = onMount("dpleft") -- 1583
				} -- 1583
			) -- 1583
		) -- 1583
	) -- 1583
end -- 1530
function ____exports.CreateDPad(props) -- 1589
	return toNode(React.createElement( -- 1590
		____exports.DPad, -- 1590
		__TS__ObjectAssign({}, props) -- 1590
	)) -- 1590
end -- 1589
local function Button(props) -- 1606
	local ____props_3 = props -- 1614
	local x = ____props_3.x -- 1614
	local y = ____props_3.y -- 1614
	local onMount = ____props_3.onMount -- 1614
	local text = ____props_3.text -- 1614
	local fontName = ____props_3.fontName -- 1614
	if fontName == nil then -- 1614
		fontName = "sarasa-mono-sc-regular" -- 1610
	end -- 1610
	local buttonSize = ____props_3.buttonSize -- 1610
	local color = ____props_3.color -- 1610
	if color == nil then -- 1610
		color = 4294967295 -- 1612
	end -- 1612
	local primaryOpacity = ____props_3.primaryOpacity -- 1612
	if primaryOpacity == nil then -- 1612
		primaryOpacity = 0.3 -- 1613
	end -- 1613
	local drawNode = useRef() -- 1615
	return React.createElement( -- 1616
		"node", -- 1616
		{ -- 1616
			x = x, -- 1616
			y = y, -- 1616
			onMount = onMount, -- 1616
			width = buttonSize * 2, -- 1616
			height = buttonSize * 2, -- 1616
			onTapBegan = function() -- 1616
				if drawNode.current then -- 1616
					drawNode.current.opacity = 1 -- 1620
				end -- 1620
			end, -- 1618
			onTapEnded = function() -- 1618
				if drawNode.current then -- 1618
					drawNode.current.opacity = primaryOpacity -- 1625
				end -- 1625
			end -- 1623
		}, -- 1623
		React.createElement( -- 1623
			"draw-node", -- 1623
			{ref = drawNode, x = buttonSize, y = buttonSize, opacity = primaryOpacity}, -- 1623
			React.createElement("dot-shape", {radius = buttonSize, color = color}) -- 1623
		), -- 1623
		React.createElement("label", { -- 1623
			x = buttonSize, -- 1623
			y = buttonSize, -- 1623
			scaleX = 0.5, -- 1623
			scaleY = 0.5, -- 1623
			color3 = color, -- 1623
			opacity = primaryOpacity + 0.2, -- 1623
			fontName = fontName, -- 1623
			fontSize = buttonSize * 2 -- 1623
		}, text) -- 1623
	) -- 1623
end -- 1606
function ____exports.JoyStick(props) -- 1651
	local hat = useRef() -- 1652
	local ____props_4 = props -- 1662
	local moveSize = ____props_4.moveSize -- 1662
	if moveSize == nil then -- 1662
		moveSize = 70 -- 1654
	end -- 1654
	local hatSize = ____props_4.hatSize -- 1654
	if hatSize == nil then -- 1654
		hatSize = 40 -- 1655
	end -- 1655
	local stickType = ____props_4.stickType -- 1655
	if stickType == nil then -- 1655
		stickType = "Left" -- 1656
	end -- 1656
	local color = ____props_4.color -- 1656
	if color == nil then -- 1656
		color = 4294967295 -- 1657
	end -- 1657
	local primaryOpacity = ____props_4.primaryOpacity -- 1657
	if primaryOpacity == nil then -- 1657
		primaryOpacity = 0.3 -- 1658
	end -- 1658
	local secondaryOpacity = ____props_4.secondaryOpacity -- 1658
	if secondaryOpacity == nil then -- 1658
		secondaryOpacity = 0.1 -- 1659
	end -- 1659
	local fontName = ____props_4.fontName -- 1659
	if fontName == nil then -- 1659
		fontName = "sarasa-mono-sc-regular" -- 1660
	end -- 1660
	local buttonSize = ____props_4.buttonSize -- 1660
	if buttonSize == nil then -- 1660
		buttonSize = 20 -- 1661
	end -- 1661
	local visualBound = math.max(moveSize - hatSize, 0) -- 1663
	local stickButton = stickType == "Left" and "leftstick" or "rightstick" -- 1664
	local function updatePosition(node, location) -- 1666
		if location.length > visualBound then -- 1666
			node.position = location:normalize():mul(visualBound) -- 1668
		else -- 1668
			node.position = location -- 1670
		end -- 1670
		repeat -- 1670
			local ____switch414 = stickType -- 1670
			local ____cond414 = ____switch414 == "Left" -- 1670
			if ____cond414 then -- 1670
				props.inputManager:emitAxis("leftx", node.x / visualBound) -- 1674
				props.inputManager:emitAxis("lefty", node.y / visualBound) -- 1675
				break -- 1676
			end -- 1676
			____cond414 = ____cond414 or ____switch414 == "Right" -- 1676
			if ____cond414 then -- 1676
				props.inputManager:emitAxis("rightx", node.x / visualBound) -- 1678
				props.inputManager:emitAxis("righty", node.y / visualBound) -- 1679
				break -- 1680
			end -- 1680
		until true -- 1680
	end -- 1666
	local ____React_createElement_9 = React.createElement -- 1666
	local ____temp_7 = {style = {width = moveSize * 2, height = moveSize * 2}} -- 1666
	local ____React_createElement_result_8 = React.createElement( -- 1666
		"node", -- 1666
		{ -- 1666
			x = moveSize, -- 1666
			y = moveSize, -- 1666
			onTapFilter = function(touch) -- 1666
				local ____touch_5 = touch -- 1688
				local location = ____touch_5.location -- 1688
				if location.length > moveSize then -- 1688
					touch.enabled = false -- 1690
				end -- 1690
			end, -- 1687
			onTapBegan = function(touch) -- 1687
				if hat.current then -- 1687
					hat.current.opacity = 1 -- 1695
					updatePosition(hat.current, touch.location) -- 1696
				end -- 1696
			end, -- 1693
			onTapMoved = function(touch) -- 1693
				if hat.current then -- 1693
					hat.current.opacity = 1 -- 1701
					updatePosition(hat.current, touch.location) -- 1702
				end -- 1702
			end, -- 1699
			onTapped = function() -- 1699
				if hat.current then -- 1699
					hat.current.opacity = primaryOpacity -- 1707
					updatePosition(hat.current, Vec2.zero) -- 1708
				end -- 1708
			end -- 1705
		}, -- 1705
		React.createElement( -- 1705
			"draw-node", -- 1705
			{opacity = secondaryOpacity}, -- 1705
			React.createElement("dot-shape", {radius = moveSize, color = color}) -- 1705
		), -- 1705
		React.createElement( -- 1705
			"draw-node", -- 1705
			{ref = hat, opacity = primaryOpacity}, -- 1705
			React.createElement("dot-shape", {radius = hatSize, color = color}) -- 1705
		) -- 1705
	) -- 1705
	local ____props_noStickButton_6 -- 1719
	if props.noStickButton then -- 1719
		____props_noStickButton_6 = nil -- 1719
	else -- 1719
		____props_noStickButton_6 = React.createElement( -- 1719
			Button, -- 1720
			{ -- 1720
				buttonSize = buttonSize, -- 1720
				x = moveSize, -- 1720
				y = moveSize * 2 + buttonSize / 2 + 20, -- 1720
				text = stickType == "Left" and "LS" or "RS", -- 1720
				fontName = fontName, -- 1720
				color = color, -- 1720
				primaryOpacity = primaryOpacity, -- 1720
				onMount = function(node) -- 1720
					node:slot( -- 1729
						"TapBegan", -- 1729
						function() return props.inputManager:emitButtonDown(stickButton) end -- 1729
					) -- 1729
					node:slot( -- 1730
						"TapEnded", -- 1730
						function() return props.inputManager:emitButtonUp(stickButton) end -- 1730
					) -- 1730
				end -- 1728
			} -- 1728
		) -- 1728
	end -- 1728
	return ____React_createElement_9("align-node", ____temp_7, ____React_createElement_result_8, ____props_noStickButton_6) -- 1684
end -- 1651
function ____exports.ButtonPad(props) -- 1747
	local ____props_10 = props -- 1754
	local buttonSize = ____props_10.buttonSize -- 1754
	if buttonSize == nil then -- 1754
		buttonSize = 30 -- 1749
	end -- 1749
	local buttonPadding = ____props_10.buttonPadding -- 1749
	if buttonPadding == nil then -- 1749
		buttonPadding = 10 -- 1750
	end -- 1750
	local fontName = ____props_10.fontName -- 1750
	if fontName == nil then -- 1750
		fontName = "sarasa-mono-sc-regular" -- 1751
	end -- 1751
	local color = ____props_10.color -- 1751
	if color == nil then -- 1751
		color = 4294967295 -- 1752
	end -- 1752
	local primaryOpacity = ____props_10.primaryOpacity -- 1752
	if primaryOpacity == nil then -- 1752
		primaryOpacity = 0.3 -- 1753
	end -- 1753
	local width = buttonSize * 5 + buttonPadding * 3 / 2 -- 1755
	local height = buttonSize * 4 + buttonPadding -- 1756
	local function onMount(buttonName) -- 1757
		return function(node) -- 1758
			node:slot( -- 1759
				"TapBegan", -- 1759
				function() return props.inputManager:emitButtonDown(buttonName) end -- 1759
			) -- 1759
			node:slot( -- 1760
				"TapEnded", -- 1760
				function() return props.inputManager:emitButtonUp(buttonName) end -- 1760
			) -- 1760
		end -- 1758
	end -- 1757
	return React.createElement( -- 1763
		"align-node", -- 1763
		{style = {width = width, height = height}}, -- 1763
		React.createElement( -- 1763
			"node", -- 1763
			{x = (buttonSize + buttonPadding / 2) / 2 + width / 2, y = buttonSize + buttonPadding / 2 + height / 2}, -- 1763
			React.createElement( -- 1763
				Button, -- 1769
				{ -- 1769
					text = "X", -- 1769
					fontName = fontName, -- 1769
					color = color, -- 1769
					primaryOpacity = primaryOpacity, -- 1769
					buttonSize = buttonSize, -- 1769
					x = -buttonSize * 2 - buttonPadding, -- 1769
					onMount = onMount("x") -- 1769
				} -- 1769
			), -- 1769
			React.createElement( -- 1769
				Button, -- 1775
				{ -- 1775
					text = "Y", -- 1775
					fontName = fontName, -- 1775
					color = color, -- 1775
					primaryOpacity = primaryOpacity, -- 1775
					buttonSize = buttonSize, -- 1775
					onMount = onMount("y") -- 1775
				} -- 1775
			), -- 1775
			React.createElement( -- 1775
				Button, -- 1779
				{ -- 1779
					text = "A", -- 1779
					fontName = fontName, -- 1779
					color = color, -- 1779
					primaryOpacity = primaryOpacity, -- 1779
					buttonSize = buttonSize, -- 1779
					x = -buttonSize - buttonPadding / 2, -- 1779
					y = -buttonSize * 2 - buttonPadding, -- 1779
					onMount = onMount("a") -- 1779
				} -- 1779
			), -- 1779
			React.createElement( -- 1779
				Button, -- 1786
				{ -- 1786
					text = "B", -- 1786
					fontName = fontName, -- 1786
					color = color, -- 1786
					primaryOpacity = primaryOpacity, -- 1786
					buttonSize = buttonSize, -- 1786
					x = buttonSize + buttonPadding / 2, -- 1786
					y = -buttonSize * 2 - buttonPadding, -- 1786
					onMount = onMount("b") -- 1786
				} -- 1786
			) -- 1786
		) -- 1786
	) -- 1786
end -- 1747
function ____exports.CreateButtonPad(props) -- 1798
	return toNode(React.createElement( -- 1799
		____exports.ButtonPad, -- 1799
		__TS__ObjectAssign({}, props) -- 1799
	)) -- 1799
end -- 1798
function ____exports.ControlPad(props) -- 1812
	local ____props_11 = props -- 1818
	local buttonSize = ____props_11.buttonSize -- 1818
	if buttonSize == nil then -- 1818
		buttonSize = 35 -- 1814
	end -- 1814
	local fontName = ____props_11.fontName -- 1814
	if fontName == nil then -- 1814
		fontName = "sarasa-mono-sc-regular" -- 1815
	end -- 1815
	local color = ____props_11.color -- 1815
	if color == nil then -- 1815
		color = 4294967295 -- 1816
	end -- 1816
	local primaryOpacity = ____props_11.primaryOpacity -- 1816
	if primaryOpacity == nil then -- 1816
		primaryOpacity = 0.3 -- 1817
	end -- 1817
	local function Button(props) -- 1819
		local drawNode = useRef() -- 1820
		return React.createElement( -- 1821
			"node", -- 1821
			__TS__ObjectAssign( -- 1821
				{}, -- 1821
				props, -- 1822
				{ -- 1822
					width = buttonSize * 2, -- 1822
					height = buttonSize, -- 1822
					onTapBegan = function() -- 1822
						if drawNode.current then -- 1822
							drawNode.current.opacity = 1 -- 1825
						end -- 1825
					end, -- 1823
					onTapEnded = function() -- 1823
						if drawNode.current then -- 1823
							drawNode.current.opacity = primaryOpacity -- 1830
						end -- 1830
					end -- 1828
				} -- 1828
			), -- 1828
			React.createElement( -- 1828
				"draw-node", -- 1828
				{ref = drawNode, x = buttonSize, y = buttonSize / 2, opacity = primaryOpacity}, -- 1828
				React.createElement("rect-shape", {width = buttonSize * 2, height = buttonSize, fillColor = color}) -- 1828
			), -- 1828
			React.createElement( -- 1828
				"label", -- 1828
				{ -- 1828
					x = buttonSize, -- 1828
					y = buttonSize / 2, -- 1828
					scaleX = 0.5, -- 1828
					scaleY = 0.5, -- 1828
					fontName = fontName, -- 1828
					fontSize = math.floor(buttonSize * 1.5), -- 1828
					color3 = color, -- 1828
					opacity = primaryOpacity + 0.2 -- 1828
				}, -- 1828
				props.text -- 1839
			) -- 1839
		) -- 1839
	end -- 1819
	local function onMount(buttonName) -- 1843
		return function(node) -- 1844
			node:slot( -- 1845
				"TapBegan", -- 1845
				function() return props.inputManager:emitButtonDown(buttonName) end -- 1845
			) -- 1845
			node:slot( -- 1846
				"TapEnded", -- 1846
				function() return props.inputManager:emitButtonUp(buttonName) end -- 1846
			) -- 1846
		end -- 1844
	end -- 1843
	return React.createElement( -- 1849
		"align-node", -- 1849
		{style = {minWidth = buttonSize * 4 + 20, justifyContent = "space-between", flexDirection = "row"}}, -- 1849
		React.createElement( -- 1849
			"align-node", -- 1849
			{style = {width = buttonSize * 2, height = buttonSize}}, -- 1849
			React.createElement( -- 1849
				Button, -- 1852
				{ -- 1852
					text = "Start", -- 1852
					x = buttonSize, -- 1852
					y = buttonSize / 2, -- 1852
					onMount = onMount("start") -- 1852
				} -- 1852
			) -- 1852
		), -- 1852
		React.createElement( -- 1852
			"align-node", -- 1852
			{style = {width = buttonSize * 2, height = buttonSize}}, -- 1852
			React.createElement( -- 1852
				Button, -- 1858
				{ -- 1858
					text = "Back", -- 1858
					x = buttonSize, -- 1858
					y = buttonSize / 2, -- 1858
					onMount = onMount("back") -- 1858
				} -- 1858
			) -- 1858
		) -- 1858
	) -- 1858
end -- 1812
function ____exports.CreateControlPad(props) -- 1867
	return toNode(React.createElement( -- 1868
		____exports.ControlPad, -- 1868
		__TS__ObjectAssign({}, props) -- 1868
	)) -- 1868
end -- 1867
function ____exports.TriggerPad(props) -- 1882
	local ____props_12 = props -- 1888
	local buttonSize = ____props_12.buttonSize -- 1888
	if buttonSize == nil then -- 1888
		buttonSize = 35 -- 1884
	end -- 1884
	local fontName = ____props_12.fontName -- 1884
	if fontName == nil then -- 1884
		fontName = "sarasa-mono-sc-regular" -- 1885
	end -- 1885
	local color = ____props_12.color -- 1885
	if color == nil then -- 1885
		color = 4294967295 -- 1886
	end -- 1886
	local primaryOpacity = ____props_12.primaryOpacity -- 1886
	if primaryOpacity == nil then -- 1886
		primaryOpacity = 0.3 -- 1887
	end -- 1887
	local function Button(props) -- 1889
		local drawNode = useRef() -- 1890
		return React.createElement( -- 1891
			"node", -- 1891
			__TS__ObjectAssign( -- 1891
				{}, -- 1891
				props, -- 1892
				{ -- 1892
					width = buttonSize * 2, -- 1892
					height = buttonSize, -- 1892
					onTapBegan = function() -- 1892
						if drawNode.current then -- 1892
							drawNode.current.opacity = 1 -- 1895
						end -- 1895
					end, -- 1893
					onTapEnded = function() -- 1893
						if drawNode.current then -- 1893
							drawNode.current.opacity = primaryOpacity -- 1900
						end -- 1900
					end -- 1898
				} -- 1898
			), -- 1898
			React.createElement( -- 1898
				"draw-node", -- 1898
				{ref = drawNode, x = buttonSize, y = buttonSize / 2, opacity = primaryOpacity}, -- 1898
				React.createElement("rect-shape", {width = buttonSize * 2, height = buttonSize, fillColor = color}) -- 1898
			), -- 1898
			React.createElement( -- 1898
				"label", -- 1898
				{ -- 1898
					x = buttonSize, -- 1898
					y = buttonSize / 2, -- 1898
					scaleX = 0.5, -- 1898
					scaleY = 0.5, -- 1898
					fontName = fontName, -- 1898
					fontSize = math.floor(buttonSize * 1.5), -- 1898
					color3 = color, -- 1898
					opacity = primaryOpacity + 0.2 -- 1898
				}, -- 1898
				props.text -- 1908
			) -- 1908
		) -- 1908
	end -- 1889
	local function onMountAxis(axisName) -- 1912
		return function(node) -- 1913
			node:slot( -- 1914
				"TapBegan", -- 1914
				function() return props.inputManager:emitAxis(axisName, 1, 0) end -- 1914
			) -- 1914
			node:slot( -- 1915
				"TapEnded", -- 1915
				function() return props.inputManager:emitAxis(axisName, 0, 0) end -- 1915
			) -- 1915
		end -- 1913
	end -- 1912
	local function onMountButton(buttonName) -- 1918
		return function(node) -- 1919
			node:slot( -- 1920
				"TapBegan", -- 1920
				function() return props.inputManager:emitButtonDown(buttonName, 0) end -- 1920
			) -- 1920
			node:slot( -- 1921
				"TapEnded", -- 1921
				function() return props.inputManager:emitButtonUp(buttonName, 0) end -- 1921
			) -- 1921
		end -- 1919
	end -- 1918
	local ____React_createElement_22 = React.createElement -- 1918
	local ____temp_20 = {style = {minWidth = buttonSize * 4 + 20, justifyContent = "space-between", flexDirection = "row"}} -- 1918
	local ____React_createElement_16 = React.createElement -- 1918
	local ____temp_14 = {style = {width = buttonSize * 4 + 10, height = buttonSize}} -- 1918
	local ____React_createElement_result_15 = React.createElement( -- 1918
		Button, -- 1927
		{ -- 1927
			text = "LT", -- 1927
			x = buttonSize, -- 1927
			y = buttonSize / 2, -- 1927
			onMount = onMountAxis("lefttrigger") -- 1927
		} -- 1927
	) -- 1927
	local ____props_noShoulder_13 -- 1931
	if props.noShoulder then -- 1931
		____props_noShoulder_13 = nil -- 1931
	else -- 1931
		____props_noShoulder_13 = React.createElement( -- 1931
			Button, -- 1932
			{ -- 1932
				text = "LB", -- 1932
				x = buttonSize * 3 + 10, -- 1932
				y = buttonSize / 2, -- 1932
				onMount = onMountButton("leftshoulder") -- 1932
			} -- 1932
		) -- 1932
	end -- 1932
	local ____React_createElement_16_result_21 = ____React_createElement_16("align-node", ____temp_14, ____React_createElement_result_15, ____props_noShoulder_13) -- 1932
	local ____React_createElement_19 = React.createElement -- 1932
	local ____temp_18 = {style = {width = buttonSize * 4 + 10, height = buttonSize}} -- 1932
	local ____props_noShoulder_17 -- 1939
	if props.noShoulder then -- 1939
		____props_noShoulder_17 = nil -- 1939
	else -- 1939
		____props_noShoulder_17 = React.createElement( -- 1939
			Button, -- 1940
			{ -- 1940
				text = "RB", -- 1940
				x = buttonSize, -- 1940
				y = buttonSize / 2, -- 1940
				onMount = onMountButton("rightshoulder") -- 1940
			} -- 1940
		) -- 1940
	end -- 1940
	return ____React_createElement_22( -- 1924
		"align-node", -- 1924
		____temp_20, -- 1924
		____React_createElement_16_result_21, -- 1924
		____React_createElement_19( -- 1924
			"align-node", -- 1924
			____temp_18, -- 1924
			____props_noShoulder_17, -- 1924
			React.createElement( -- 1924
				Button, -- 1945
				{ -- 1945
					text = "RT", -- 1945
					x = buttonSize * 3 + 10, -- 1945
					y = buttonSize / 2, -- 1945
					onMount = onMountAxis("righttrigger") -- 1945
				} -- 1945
			) -- 1945
		) -- 1945
	) -- 1945
end -- 1882
function ____exports.CreateTriggerPad(props) -- 1954
	return toNode(React.createElement( -- 1955
		____exports.TriggerPad, -- 1955
		__TS__ObjectAssign({}, props) -- 1955
	)) -- 1955
end -- 1954
function ____exports.GamePad(props) -- 1975
	local ____props_23 = props -- 1976
	local color = ____props_23.color -- 1976
	local primaryOpacity = ____props_23.primaryOpacity -- 1976
	local secondaryOpacity = ____props_23.secondaryOpacity -- 1976
	local inputManager = ____props_23.inputManager -- 1976
	local ____React_createElement_39 = React.createElement -- 1976
	local ____temp_37 = {style = {flexDirection = "column-reverse"}, windowRoot = true} -- 1976
	local ____React_createElement_34 = React.createElement -- 1976
	local ____temp_32 = {style = {margin = 20, justifyContent = "space-between", flexDirection = "row", alignItems = "flex-end"}} -- 1976
	local ____React_createElement_27 = React.createElement -- 1976
	local ____temp_26 = {style = {justifyContent = "space-between", flexDirection = "row", alignItems = "flex-end"}} -- 1976
	local ____props_noDPad_24 -- 1990
	if props.noDPad then -- 1990
		____props_noDPad_24 = nil -- 1990
	else -- 1990
		____props_noDPad_24 = React.createElement(____exports.DPad, {color = color, primaryOpacity = primaryOpacity, inputManager = inputManager}) -- 1990
	end -- 1990
	local ____props_noLeftStick_25 -- 1997
	if props.noLeftStick then -- 1997
		____props_noLeftStick_25 = nil -- 1997
	else -- 1997
		____props_noLeftStick_25 = React.createElement( -- 1997
			React.Fragment, -- 1997
			nil, -- 1997
			React.createElement("align-node", {style = {width = 10}}), -- 1997
			React.createElement(____exports.JoyStick, { -- 1997
				stickType = "Left", -- 1997
				color = color, -- 1997
				primaryOpacity = primaryOpacity, -- 1997
				secondaryOpacity = secondaryOpacity, -- 1997
				inputManager = inputManager, -- 1997
				noStickButton = props.noStickButton -- 1997
			}) -- 1997
		) -- 1997
	end -- 1997
	local ____React_createElement_27_result_33 = ____React_createElement_27("align-node", ____temp_26, ____props_noDPad_24, ____props_noLeftStick_25) -- 1997
	local ____React_createElement_31 = React.createElement -- 1997
	local ____temp_30 = {style = {justifyContent = "space-between", flexDirection = "row", alignItems = "flex-end"}} -- 1997
	local ____props_noRightStick_28 -- 2014
	if props.noRightStick then -- 2014
		____props_noRightStick_28 = nil -- 2014
	else -- 2014
		____props_noRightStick_28 = React.createElement( -- 2014
			React.Fragment, -- 2014
			nil, -- 2014
			React.createElement(____exports.JoyStick, { -- 2014
				stickType = "Right", -- 2014
				color = color, -- 2014
				primaryOpacity = primaryOpacity, -- 2014
				secondaryOpacity = secondaryOpacity, -- 2014
				inputManager = inputManager, -- 2014
				noStickButton = props.noStickButton -- 2014
			}), -- 2014
			React.createElement("align-node", {style = {width = 10}}) -- 2014
		) -- 2014
	end -- 2014
	local ____props_noButtonPad_29 -- 2025
	if props.noButtonPad then -- 2025
		____props_noButtonPad_29 = nil -- 2025
	else -- 2025
		____props_noButtonPad_29 = React.createElement(____exports.ButtonPad, {color = color, primaryOpacity = primaryOpacity, inputManager = inputManager}) -- 2025
	end -- 2025
	local ____React_createElement_34_result_38 = ____React_createElement_34( -- 2025
		"align-node", -- 2025
		____temp_32, -- 2025
		____React_createElement_27_result_33, -- 2025
		____React_createElement_31("align-node", ____temp_30, ____props_noRightStick_28, ____props_noButtonPad_29) -- 2025
	) -- 2025
	local ____props_noTriggerPad_35 -- 2034
	if props.noTriggerPad then -- 2034
		____props_noTriggerPad_35 = nil -- 2034
	else -- 2034
		____props_noTriggerPad_35 = React.createElement( -- 2034
			"align-node", -- 2034
			{style = {paddingLeft = 20, paddingRight = 20, paddingTop = 20}}, -- 2034
			React.createElement(____exports.TriggerPad, {color = color, noShoulder = props.noShoulder, primaryOpacity = primaryOpacity, inputManager = inputManager}) -- 2034
		) -- 2034
	end -- 2034
	local ____props_noControlPad_36 -- 2044
	if props.noControlPad then -- 2044
		____props_noControlPad_36 = nil -- 2044
	else -- 2044
		____props_noControlPad_36 = React.createElement( -- 2044
			"align-node", -- 2044
			{style = {paddingLeft = 20, paddingRight = 20}}, -- 2044
			React.createElement(____exports.ControlPad, {color = color, primaryOpacity = primaryOpacity, inputManager = inputManager}) -- 2044
		) -- 2044
	end -- 2044
	return ____React_createElement_39( -- 1977
		"align-node", -- 1977
		____temp_37, -- 1977
		____React_createElement_34_result_38, -- 1977
		____props_noTriggerPad_35, -- 1977
		____props_noControlPad_36 -- 1977
	) -- 1977
end -- 1975
function ____exports.CreateGamePad(props) -- 2057
	return toNode(React.createElement( -- 2058
		____exports.GamePad, -- 2058
		__TS__ObjectAssign({}, props) -- 2058
	)) -- 2058
end -- 2057
return ____exports -- 2057