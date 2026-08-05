local Classes = {ClassesList = {},Instances = {}}

local function DeepClone(t)
    assert(type(t) == "table","t should be a table")
    local ClonedTable = {}
    for i,v in pairs(t) do
        if i == "New" then
            continue
        end
        if type(v) == "table" then
            ClonedTable[i] = {}
            for h,w in pairs(v) do
                if type(w) =="table" then
                return warn("Should be only 1(one) layer of tables") end
                ClonedTable[i][h] = w
            end
        else
            ClonedTable[i] = v
        end
    end
    return ClonedTable
end

function Classes:CreateClass(properties: {})
    if not properties["Name"] then
    return end
    if self.ClassesList["Name"] then
        return error(("Class '%s' already exists"):format(properties.Name))
    end
    self.ClassesList[properties["Name"]] = properties
    local Name = properties["Name"]
    local Class = self.ClassesList[properties["Name"]]

    Class["New"] = function()
        if not Class then
        return warn("Class not Found use CreateClass first!") end

        if not Classes.Instances[Name] then
            Classes.Instances[Name] = {}
        end

        table.insert(Classes.Instances[Name],DeepClone(Classes.ClassesList[Name]))
        local instance = Classes.Instances[Name][#Classes.Instances[Name]]

        return instance
    end
    return Class
end
return Classes