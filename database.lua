Database = {}

function Database:new(storage)
    local instance = {
        connection = dbConnect("sqlite", storage)
    }
    
    if not instance.connection then
        error("[DB]: Connection not created.", 2)
    end

    setmetatable(instance, {
        __index = self
    })

    return instance
end

function Database:set(structures)
    local connection = self:getConnection()

    for tableName, structure in pairs(structures) do
        local columns = {}
        local primaryKey

        for columnName, attributes in pairs(structure) do
            local preparedString = columnName.." "..attributes.type

            if attributes.autoIncrement then
                preparedString = preparedString.." AUTO_INCREMENT"
            end

            if not attributes.null then
                preparedString = preparedString.." NOT NULL"
            end

            if attributes.default then
                preparedString = preparedString.." DEFAULT "..attributes.default
            end
    
            if attributes.primaryKey then
                preparedString = preparedString.." PRIMARY KEY"
                table.insert(columns, 1, preparedString)
            else
                columns[#columns + 1] = preparedString
            end
        end

        local query = "CREATE TABLE IF NOT EXISTS `"..tableName.."` ("..table.concat(columns, ", ")..")"
        if not dbExec(connection, query) then
            error("[DB]: database not defined.")
        end
    end
end

function Database:insert(tableName, data, callback)
    local connection = self:getConnection()

    local columns = {}
    local values = {}
    local placeholders = {}

    for index, value in pairs(data) do
        columns[#columns + 1] = index
        values[#values + 1] = value
        placeholders[#placeholders + 1] = "?"
    end

    local query = "INSERT INTO `"..tableName.."` ("..table.concat(columns, ", ")..") VALUES ("..table.concat(placeholders, ", ")..")"
    local preparedString = dbPrepareString(connection, query, unpack(values))

    return self:addQueryToQueue(preparedString, callback)
end

function Database:update(tableName, data, where, _type, callback)
    local connection = self:getConnection()

    local columns = {}
    local conditions = {}
    local values = {}

    for index, value in pairs(data) do
        columns[#columns + 1] = index.." = ?"
        values[#values + 1] = value
    end

    if where then
        for index, value in pairs(where) do
            conditions[#conditions + 1] = index.." = ?"
            values[#values + 1] = value
        end
    end

    local query = "UPDATE `"..tableName.."` SET "..table.concat(columns, ", ")..(#conditions > 0 and " WHERE "..table.concat(conditions, " "..(_type or "AND").." " or ""))
    local preparedString = dbPrepareString(connection, query, unpack(values))

    return self:addQueryToQueue(preparedString, callback)
end

function Database:delete(tableName, where, _type, callback)
    local connection = self:getConnection()

    local conditions = {}
    local values = {}

    if where then
        for index, value in pairs(where) do
            conditions[#conditions + 1] = index.." = ?"
            values[#values + 1] = value
        end
    end

    local query = "DELETE FROM `"..tableName.."`"..(#conditions > 0 and " WHERE "..table.concat(conditions, " "..(_type or "AND").." " or ""))
    local preparedString = dbPrepareString(connection, query, unpack(values))

    return self:addQueryToQueue(preparedString, callback)
end

function Database:find(tableName, columns, where, _type, callback)
    local connection = self:getConnection()

    local colum = type(columns) == "table" and table.concat(columns, ", ") or columns
    local conditions = {}
    local values = {}

    if where then
        for index, value in pairs(where) do
            conditions[#conditions + 1] = index.." = ?"
            values[#values + 1] = value
        end
    end

    local query = "SELECT "..colum.." FROM `"..tableName.."`"..(#conditions > 0 and " WHERE "..table.concat(conditions, " "..(_type or "AND").." " or ""))
    local preparedString = dbPrepareString(connection, query, unpack(values))
    local result, affectRows, lastInsert = dbPoll(dbQuery(connection, preparedString), -1)
    
    if callback then
        callback(result, affectRows, lastInsert)
        return
    end

    return result, affectRows, lastInsert
end

function Database:exists(tableName, where, _type, callback)
    local connection = self:getConnection()

    local conditions = {}
    local values = {}

    if where then
        for index, value in pairs(where) do
            conditions[#conditions + 1] = index.." = ?"
            values[#values + 1] = value
        end
    end

    local query = "SELECT COUNT(*) AS amount FROM `" .. tableName .. "`" .. (#conditions > 0 and " WHERE " .. table.concat(conditions, " " .. (_type or "AND") .. " ") or "")
    local preparedString = dbPrepareString(connection, query, unpack(values))
    local result = dbPoll(dbQuery(connection, preparedString), -1)
    local existsAmount = (result and result[1]) and result[1].amount or 0

    if callback then
        callback(existsAmount > 0, existsAmount)
        return
    end

    return existsAmount > 0, existsAmount
end


-- System functions
function Database:addQueryToQueue(preparedString, callback)
    if not self.queues then
        self.queues = {} 
    end

    self.queues[#self.queues + 1] = {
        preparedString = preparedString,
        callback = callback
    }

    if #self.queues > 0 then
        self:queryQueue()
    end
end

function Database:queryQueue()
    if not isTimer(self.queueTimer) then
        self.queueTimer = setTimer(function()
            local data = table.remove(self.queues, 1)
            if data then
                local connection = self:getConnection()
                local result = dbExec(connection, data.preparedString)
                
                if data.callback then
                    data.callback(result)
                end
            end

            if #self.queues < 1 then
                return killTimer(self.queueTimer)
            end
        end, self.queueDelay or 100, 0) 
    end
end

-- User functions
function Database:getConnection()
    return self.connection
end

function Database:setProperties(properties)
    local validProperties = {
        queueDelay = true
    }
    
    for index, value in pairs(properties) do
        if validProperties[index] then
            self[index] = value
        end
    end
end
