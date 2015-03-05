function print_r_table ( t )
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        print(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        print(indent..string.rep(" ",string.len(pos)+6).."}")
                    elseif (type(val)=="string") then
                        print(indent.."["..pos..'] => "'..val..'"')
                    else
                        print(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                print(indent..tostring(t))
            end
        end
    end
    if (type(t)=="table") then
        print(tostring(t).." {")
        sub_print_r(t,"  ")
        print("}")
    else
        sub_print_r(t,"  ")
    end
    print()
end

function show_table ( t )
    local print_r_cache={}
    local show = ''
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            show = show .. (indent.."*"..tostring(t)) .. "\n"
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        show = show .. (indent.."["..pos.."] => "..tostring(t).." {") .. "\n"
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        show = show .. (indent..string.rep(" ",string.len(pos)+6).."}") .. "\n\r"
                    elseif (type(val)=="string") then
                        show = show .. "\n" .. (indent.."["..pos..'] => "'..val..'"')
                    else
                        show = show .. (indent.."["..pos.."] => "..tostring(val)) .. "\n"
                    end
                end
            else
                show = show .. (indent..tostring(t)) .. "\n"
            end
        end
    end
    if (type(t)=="table") then
        show = show .. (tostring(t).." {") .. "\n"
        sub_print_r(t,"  ")
        show = show .. ("}")
    else
        sub_print_r(t,"  ")
    end
    return show
end

