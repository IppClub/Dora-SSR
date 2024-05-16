-- [tsx]: Platformer-x.tsx
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local ____exports = {} -- 1
local Warn, visitBTree -- 1
local ____dora_2Djsx = require("DoraX") -- 1
local React = ____dora_2Djsx.React -- 1
local P = require("Platformer") -- 2
function Warn(msg) -- 179
    print("[Dora Warning] " .. msg) -- 180
end -- 180
function visitBTree(treeStack, node) -- 285
    if type(node) ~= "table" then -- 285
        return false -- 287
    end -- 287
    repeat -- 287
        local ____switch57 = node.name -- 287
        local ____cond57 = ____switch57 == "BTSelector" -- 287
        if ____cond57 then -- 287
            do -- 287
                local props = node.data -- 291
                local children = props.children -- 292
                if children and #children > 0 then -- 292
                    local stack = {} -- 294
                    do -- 294
                        local i = 0 -- 295
                        while i < #children do -- 295
                            if not visitBTree(stack, children[i + 1].props) then -- 295
                                Warn("unsupported BehaviorTree node with name " .. tostring(children[i + 1].props.name)) -- 297
                            end -- 297
                            i = i + 1 -- 295
                        end -- 295
                    end -- 295
                    if #stack > 0 then -- 295
                        treeStack[#treeStack + 1] = P.Behavior.Sel(stack) -- 301
                    end -- 301
                end -- 301
                break -- 304
            end -- 304
        end -- 304
        ____cond57 = ____cond57 or ____switch57 == "BTSequence" -- 304
        if ____cond57 then -- 304
            do -- 304
                local props = node.data -- 307
                local children = props.children -- 308
                if children and #children > 0 then -- 308
                    local stack = {} -- 310
                    do -- 310
                        local i = 0 -- 311
                        while i < #children do -- 311
                            if not visitBTree(stack, children[i + 1].props) then -- 311
                                Warn("unsupported BehaviorTree node with name " .. tostring(children[i + 1].props.name)) -- 313
                            end -- 313
                            i = i + 1 -- 311
                        end -- 311
                    end -- 311
                    if #stack > 0 then -- 311
                        treeStack[#treeStack + 1] = P.Behavior.Seq(stack) -- 317
                    end -- 317
                end -- 317
                break -- 320
            end -- 320
        end -- 320
        ____cond57 = ____cond57 or ____switch57 == "BTCondition" -- 320
        if ____cond57 then -- 320
            do -- 320
                local props = node.data -- 323
                treeStack[#treeStack + 1] = P.Behavior.Con(props.desc, props.onCheck) -- 324
                break -- 325
            end -- 325
        end -- 325
        ____cond57 = ____cond57 or ____switch57 == "BTMatch" -- 325
        if ____cond57 then -- 325
            do -- 325
                local props = node.data -- 328
                local children = props.children -- 329
                if children and #children > 0 then -- 329
                    local stack = {} -- 331
                    do -- 331
                        local i = 0 -- 332
                        while i < #children do -- 332
                            if not visitBTree(stack, children[i + 1].props) then -- 332
                                Warn("unsupported BehaviorTree node with name " .. tostring(children[i + 1].props.name)) -- 334
                            end -- 334
                            i = i + 1 -- 332
                        end -- 332
                    end -- 332
                    if #stack > 0 then -- 332
                        treeStack[#treeStack + 1] = P.Behavior.Seq({ -- 338
                            P.Behavior.Con(props.desc, props.onCheck), -- 340
                            table.unpack(stack) -- 340
                        }) -- 340
                        break -- 343
                    end -- 343
                end -- 343
                treeStack[#treeStack + 1] = P.Behavior.Con(props.desc, props.onCheck) -- 346
                break -- 347
            end -- 347
        end -- 347
        ____cond57 = ____cond57 or ____switch57 == "BTAction" -- 347
        if ____cond57 then -- 347
            do -- 347
                local props = node.data -- 350
                treeStack[#treeStack + 1] = P.Behavior.Act(props.name) -- 351
                break -- 352
            end -- 352
        end -- 352
        ____cond57 = ____cond57 or ____switch57 == "BTCommand" -- 352
        if ____cond57 then -- 352
            do -- 352
                local props = node.data -- 355
                treeStack[#treeStack + 1] = P.Behavior.Command(props.name) -- 356
                break -- 357
            end -- 357
        end -- 357
        ____cond57 = ____cond57 or ____switch57 == "BTWait" -- 357
        if ____cond57 then -- 357
            do -- 357
                local props = node.data -- 360
                treeStack[#treeStack + 1] = P.Behavior.Wait(props.time) -- 361
                break -- 362
            end -- 362
        end -- 362
        ____cond57 = ____cond57 or ____switch57 == "BTCountdown" -- 362
        if ____cond57 then -- 362
            do -- 362
                local props = node.data -- 365
                local children = props.children -- 366
                if children and #children >= 1 then -- 366
                    local stack = {} -- 368
                    if visitBTree(stack, children[1].props) then -- 368
                        treeStack[#treeStack + 1] = P.Behavior.Countdown(props.time, stack[1]) -- 370
                    else -- 370
                        Warn("expects only one BehaviorTree child for BehaviorTree.Countdown") -- 372
                    end -- 372
                else -- 372
                    Warn("expects only one BehaviorTree child for BehaviorTree.Countdown") -- 375
                end -- 375
                break -- 377
            end -- 377
        end -- 377
        ____cond57 = ____cond57 or ____switch57 == "BTTimeout" -- 377
        if ____cond57 then -- 377
            do -- 377
                local props = node.data -- 380
                local children = props.children -- 381
                if children and #children >= 1 then -- 381
                    local stack = {} -- 383
                    if visitBTree(stack, children[1].props) then -- 383
                        treeStack[#treeStack + 1] = P.Behavior.Timeout(props.time, stack[1]) -- 385
                    else -- 385
                        Warn("expects only one BehaviorTree child for BehaviorTree.Timeout") -- 387
                    end -- 387
                else -- 387
                    Warn("expects only one BehaviorTree child for BehaviorTree.Timeout") -- 390
                end -- 390
                break -- 392
            end -- 392
        end -- 392
        ____cond57 = ____cond57 or ____switch57 == "BTRepeat" -- 392
        if ____cond57 then -- 392
            do -- 392
                local props = node.data -- 395
                local children = props.children -- 396
                if children and #children >= 1 then -- 396
                    local stack = {} -- 398
                    if visitBTree(stack, children[1].props) then -- 398
                        if props.times ~= nil then -- 398
                            treeStack[#treeStack + 1] = P.Behavior.Repeat(props.times, stack[1]) -- 401
                        else -- 401
                            treeStack[#treeStack + 1] = P.Behavior.Repeat(stack[1]) -- 403
                        end -- 403
                    else -- 403
                        Warn("expects only one BehaviorTree child for BehaviorTree.Repeat") -- 406
                    end -- 406
                else -- 406
                    Warn("expects only one BehaviorTree child for BehaviorTree.Repeat") -- 409
                end -- 409
                break -- 411
            end -- 411
        end -- 411
        ____cond57 = ____cond57 or ____switch57 == "BTRetry" -- 411
        if ____cond57 then -- 411
            do -- 411
                local props = node.data -- 414
                local children = props.children -- 415
                if children and #children >= 1 then -- 415
                    local stack = {} -- 417
                    if visitBTree(stack, children[1].props) then -- 417
                        if props.times ~= nil then -- 417
                            treeStack[#treeStack + 1] = P.Behavior.Retry(props.times, stack[1]) -- 420
                        else -- 420
                            treeStack[#treeStack + 1] = P.Behavior.Retry(stack[1]) -- 422
                        end -- 422
                    else -- 422
                        Warn("expects only one BehaviorTree child for BehaviorTree.Retry") -- 425
                    end -- 425
                else -- 425
                    Warn("expects only one BehaviorTree child for BehaviorTree.Retry") -- 428
                end -- 428
                break -- 430
            end -- 430
        end -- 430
        do -- 430
            return false -- 433
        end -- 433
    until true -- 433
    return true -- 435
end -- 435
____exports.BehaviorTree = {} -- 435
local BehaviorTree = ____exports.BehaviorTree -- 435
do -- 435
    BehaviorTree.Leaf = __TS__Class() -- 4
    local Leaf = BehaviorTree.Leaf -- 4
    Leaf.name = "Leaf" -- 19
    function Leaf.prototype.____constructor(self) -- 20
    end -- 20
    function BehaviorTree.Selector(self, props) -- 30
        return React:createElement("custom-element", {name = "BTSelector", data = props}) -- 31
    end -- 30
    function BehaviorTree.Sequence(self, props) -- 34
        return React:createElement("custom-element", {name = "BTSequence", data = props}) -- 35
    end -- 34
    function BehaviorTree.Condition(self, props) -- 43
        return React:createElement("custom-element", {name = "BTCondition", data = props}) -- 44
    end -- 43
    function BehaviorTree.Match(self, props) -- 53
        return React:createElement("custom-element", {name = "BTMatch", data = props}) -- 54
    end -- 53
    function BehaviorTree.Action(self, props) -- 61
        return React:createElement("custom-element", {name = "BTAction", data = props}) -- 62
    end -- 61
    function BehaviorTree.Command(self, props) -- 65
        return React:createElement("custom-element", {name = "BTCommand", data = props}) -- 66
    end -- 65
    function BehaviorTree.Wait(self, props) -- 73
        return React:createElement("custom-element", {name = "BTWait", data = props}) -- 74
    end -- 73
    function BehaviorTree.Countdown(self, props) -- 82
        return React:createElement("custom-element", {name = "BTCountdown", data = props}) -- 83
    end -- 82
    function BehaviorTree.Timeout(self, props) -- 86
        return React:createElement("custom-element", {name = "BTTimeout", data = props}) -- 87
    end -- 86
    function BehaviorTree.Repeat(self, props) -- 95
        return React:createElement("custom-element", {name = "BTRepeat", data = props}) -- 96
    end -- 95
    function BehaviorTree.Retry(self, props) -- 99
        return React:createElement("custom-element", {name = "BTRetry", data = props}) -- 100
    end -- 99
end -- 99
____exports.DecisionTree = {} -- 99
local DecisionTree = ____exports.DecisionTree -- 99
do -- 99
    DecisionTree.Leaf = __TS__Class() -- 104
    local Leaf = DecisionTree.Leaf -- 104
    Leaf.name = "Leaf" -- 116
    function Leaf.prototype.____constructor(self) -- 117
    end -- 117
    function DecisionTree.Selector(self, props) -- 127
        return React:createElement("custom-element", {name = "DTSelector", data = props}) -- 128
    end -- 127
    function DecisionTree.Sequence(self, props) -- 131
        return React:createElement("custom-element", {name = "DTSequence", data = props}) -- 132
    end -- 131
    function DecisionTree.Condition(self, props) -- 140
        return React:createElement("custom-element", {name = "DTCondition", data = props}) -- 141
    end -- 140
    function DecisionTree.Match(self, props) -- 150
        return React:createElement("custom-element", {name = "DTMatch", data = props}) -- 151
    end -- 150
    function DecisionTree.Action(self, props) -- 158
        return React:createElement("custom-element", {name = "DTAction", data = props}) -- 159
    end -- 158
    function DecisionTree.Accept(self) -- 162
        return React:createElement("custom-element", {name = "DTAccept", data = nil}) -- 163
    end -- 162
    function DecisionTree.Reject(self) -- 166
        return React:createElement("custom-element", {name = "DTReject", data = nil}) -- 167
    end -- 166
    function DecisionTree.Behavior(self, props) -- 174
        return React:createElement("custom-element", {name = "DTBehavior", data = props}) -- 175
    end -- 174
end -- 174
local function visitDTree(treeStack, node) -- 183
    if type(node) ~= "table" then -- 183
        return false -- 185
    end -- 185
    repeat -- 185
        local ____switch28 = node.name -- 185
        local ____cond28 = ____switch28 == "DTSelector" -- 185
        if ____cond28 then -- 185
            do -- 185
                local props = node.data -- 189
                local children = props.children -- 190
                if children and #children > 0 then -- 190
                    local stack = {} -- 192
                    do -- 192
                        local i = 0 -- 193
                        while i < #children do -- 193
                            if not visitDTree(stack, children[i + 1].props) then -- 193
                                Warn("unsupported DecisionTree node with name " .. tostring(children[i + 1].props.name)) -- 195
                            end -- 195
                            i = i + 1 -- 193
                        end -- 193
                    end -- 193
                    if #stack > 0 then -- 193
                        treeStack[#treeStack + 1] = P.Decision.Sel(stack) -- 199
                    end -- 199
                end -- 199
                break -- 202
            end -- 202
        end -- 202
        ____cond28 = ____cond28 or ____switch28 == "DTSequence" -- 202
        if ____cond28 then -- 202
            do -- 202
                local props = node.data -- 205
                local children = props.children -- 206
                if children and #children > 0 then -- 206
                    local stack = {} -- 208
                    do -- 208
                        local i = 0 -- 209
                        while i < #children do -- 209
                            if not visitDTree(stack, children[i + 1].props) then -- 209
                                Warn("unsupported DecisionTree node with name " .. tostring(children[i + 1].props.name)) -- 211
                            end -- 211
                            i = i + 1 -- 209
                        end -- 209
                    end -- 209
                    if #stack > 0 then -- 209
                        treeStack[#treeStack + 1] = P.Decision.Seq(stack) -- 215
                    end -- 215
                end -- 215
                break -- 218
            end -- 218
        end -- 218
        ____cond28 = ____cond28 or ____switch28 == "DTCondition" -- 218
        if ____cond28 then -- 218
            do -- 218
                local props = node.data -- 221
                treeStack[#treeStack + 1] = P.Decision.Con(props.desc, props.onCheck) -- 222
                break -- 223
            end -- 223
        end -- 223
        ____cond28 = ____cond28 or ____switch28 == "DTMatch" -- 223
        if ____cond28 then -- 223
            do -- 223
                local props = node.data -- 226
                local children = props.children -- 227
                if children and #children > 0 then -- 227
                    local stack = {} -- 229
                    do -- 229
                        local i = 0 -- 230
                        while i < #children do -- 230
                            if not visitDTree(stack, children[i + 1].props) then -- 230
                                Warn("unsupported DecisionTree node with name " .. tostring(children[i + 1].props.name)) -- 232
                            end -- 232
                            i = i + 1 -- 230
                        end -- 230
                    end -- 230
                    if #stack > 0 then -- 230
                        treeStack[#treeStack + 1] = P.Decision.Seq({ -- 236
                            P.Decision.Con(props.desc, props.onCheck), -- 238
                            table.unpack(stack) -- 238
                        }) -- 238
                        break -- 241
                    end -- 241
                end -- 241
                treeStack[#treeStack + 1] = P.Decision.Con(props.desc, props.onCheck) -- 244
                break -- 245
            end -- 245
        end -- 245
        ____cond28 = ____cond28 or ____switch28 == "DTAction" -- 245
        if ____cond28 then -- 245
            do -- 245
                local props = node.data -- 248
                if type(props.name) == "string" then -- 248
                    treeStack[#treeStack + 1] = P.Decision.Act(props.name) -- 250
                else -- 250
                    treeStack[#treeStack + 1] = P.Decision.Act(props.name) -- 252
                end -- 252
                break -- 254
            end -- 254
        end -- 254
        ____cond28 = ____cond28 or ____switch28 == "DTAccept" -- 254
        if ____cond28 then -- 254
            do -- 254
                treeStack[#treeStack + 1] = P.Decision.Accept() -- 257
                break -- 258
            end -- 258
        end -- 258
        ____cond28 = ____cond28 or ____switch28 == "DTReject" -- 258
        if ____cond28 then -- 258
            do -- 258
                treeStack[#treeStack + 1] = P.Decision.Reject() -- 261
                break -- 262
            end -- 262
        end -- 262
        ____cond28 = ____cond28 or ____switch28 == "DTBehavior" -- 262
        if ____cond28 then -- 262
            do -- 262
                local props = node.data -- 265
                local children = props.children -- 266
                if children and #children >= 1 then -- 266
                    local stack = {} -- 268
                    if visitBTree(stack, children[1].props) then -- 268
                        treeStack[#treeStack + 1] = P.Decision.Behave(props.name, stack[1]) -- 270
                    else -- 270
                        Warn("expects only one BehaviorTree child for DecisionTree.Behavior") -- 272
                    end -- 272
                else -- 272
                    Warn("expects only one BehaviorTree child for DecisionTree.Behavior") -- 275
                end -- 275
                break -- 277
            end -- 277
        end -- 277
        do -- 277
            return false -- 280
        end -- 280
    until true -- 280
    return true -- 282
end -- 183
function ____exports.toAI(node) -- 438
    if type(node) ~= "table" then -- 438
        return nil -- 440
    end -- 440
    local treeStack = {} -- 442
    if visitDTree(treeStack, node.props) and #treeStack > 0 then -- 442
        return treeStack[1] -- 444
    end -- 444
    return nil -- 446
end -- 438
return ____exports -- 438
