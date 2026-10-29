-- Deliberate failure with queued work: test final browser-runtime teardown.
local Dora = require("Dora")
print("DORA_PENDING_BOOTSTRAP_TASK")
error("DORA_EXPECTED_BOOTSTRAP_FAILURE")
