local _, ns = ...
if ns.disabled then return end

-- One slash command for the lot; each file registers the word it answers to.
SLASH_MIDVENTURES1 = '/midv'
SlashCmdList.MIDVENTURES = function(argument)
    local word, rest = argument:match('^%s*(%S*)%s*(.-)%s*$')
    local handler = ns.commands[word:lower()]
    if handler then return handler(rest) end

    local words = {}
    for name in pairs(ns.commands) do words[#words + 1] = name end
    table.sort(words)
    ns.Print('try /midv ' .. table.concat(words, ', '))
end
