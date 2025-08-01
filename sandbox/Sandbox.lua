require("sandbox/SaveOs")
require("sandbox/SaveIo")

Sandbox = {}

function Sandbox.init()
    SaveOs.setup()
    SaveIo.setup()
    _G.debug = {
        traceback = CloneUtil.clone(_G.debug.traceback),
    }
    _G.loadfile = function () Log.warn("can not use loadfile in sandbox...") end
    _G.getfenv = function () Log.warn("can not use getfenv in sandbox...") end
    _G.setfenv = function () Log.warn("can not use setfenv in sandbox...") end
end
