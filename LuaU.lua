local Decompile = 
{
    LoadFunction = function(self, script)
        if (typeof(script) ~= "Instance" or not script:IsA("LuaSourceContainer")) then return nil end
        local env = getsenv(script)
        for _, v in pairs(getgc(true)) do
            if (type(v) == "function" and not isexecutorclosure(v)) then
                local fenv = getfenv(v)
                if (fenv and rawget(fenv, "script") == script) then
                    return v
                end
            end
        end
        return nil
    end,

    ParseBytecode = function(self, func)
        if (not islclosure(func)) then return nil end
        local bytecode = dumpstring(func)
        local instructions = {}
        for i = 1, #bytecode do
            table.insert(instructions, bytecode:byte(i))
        end
        return instructions
    end,

    ResolveConstants = function(self, func)
        local gc = getgc(true)
        for _, v in ipairs(gc) do
            if (type(v) == "table" and rawget(v, "__func") == func) then
                return rawget(v, "constants")
            end
        end
        return {}
    end,

    BuildAST = function(self, instructions, constants)
        local ast = {}
        for i, op in ipairs(instructions) do
            table.insert(ast, {
                type = "op",
                value = op,
                constant = constants[i]
            })
        end
        return ast
    end,

    Sanitize = function(self, ast)
        local source = ""
        for _, node in ipairs(ast) do
            if (node.constant ~= nil) then
                source = source .. tostring(node.constant) .. "\n"
            else
                source = source .. "OP_" .. tostring(node.value) .. "\n"
            end
        end
        return source
    end,

    Decompile = function(self, script)
        local func = self:LoadFunction(script)
        if (not func) then return "[FAILED]" end
        local instructions = self:ParseBytecode(func)
        local constants = self:ResolveConstants(func)
        local ast = self:BuildAST(instructions, constants)
        local output = self:Sanitize(ast)
        return output
    end,
}

return Decompile
