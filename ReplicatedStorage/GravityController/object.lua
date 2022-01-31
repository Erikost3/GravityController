-- Default constructor to initialize a _class_
local function __construct__(_class_, _instance_)
    assert(rawget(_class_, "__call"), "Failed to initiate an instance; no __call method")

    setmetatable(_instance_, _class_)
    _instance_:init()

    return _instance_
end

-- Subclass _subclass_ of _class_
local function __subclass__(_class_, _subclass_)
    _subclass_.__index = _subclass_
    _subclass_.__call = __construct__

    return setmetatable(_subclass_, _class_)    
end

-- Make first _class_
local Object = __subclass__(
    {
        --__index = function (table, key)
            --error("No such member '"..tostring(key).."'")
        --end,
        __call = __construct__
    },
    {}
)

Object.init = function () end
Object.subclass = __subclass__

-- Returns a constructor for this _class_
function Object:constructor()
    
    local constructor = rawget(self, "__constructor__")

    if not constructor then
        assert(rawget(self, "__call"), "Instances can't have constructors")

        local init = self.init

        if init == Object.init then
            init = nil
        end

        constructor = function (_instance_)
            setmetatable(_instance_, self)

            if init then
                init(_instance_)
            end

            return _instance_
        end

        self.__constructor__ = constructor
    end

    return constructor
end

-- Return this object when it is an instance of the given class
function Object:is_class(class)
    local meta = getmetatable(self)

    if type(class) == "table" then
        while meta do
            if meta == class then
                return self
            end
            meta = getmetatable(meta)
        end
    elseif type(class) == "function" then
        -- Assuming constructor function so can't be subclass
        if rawget(meta, "__constructor__") == class then
            return self
        end
    end

    return nil
end

return Object