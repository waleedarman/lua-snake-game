local Events = {listeners = {}}
function Events:subscribe(event, callback)
    self.listeners[event] = self.listeners[event] or {}
    table.insert(self.listeners[event], callback)
end
function Events:emit(event, data)
    for _, callback in ipairs(self.listeners[event] or {}) do
        callback(data)
    end
end
return Events
