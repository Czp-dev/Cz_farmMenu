function RageUI.Info(Title, RightText, LeftText)
    local maxLineCount = math.max(#RightText, #LeftText)
    local titleHeight = Title ~= nil and 24 or 0
    local initialYOffset = 82 + titleHeight
    local LineCount = #RightText >= #LeftText and #RightText or #LeftText

    -- rectangle size
    local rectangleWidth = 450
    local rectangleHeight = Title ~= nil and 50 + (LineCount * 20) or ((LineCount + 1) * 20)
    
    -- rectangle position
    local rectX = 485
    local rectY = 70

    if Title ~= nil then
        RenderText("~h~" .. Title .. "~h~", rectX + 20, 82, 0, 0.36, 255, 255, 255, 255, 0)
    end
    if RightText ~= nil then
        RenderText(table.concat(RightText, "\n"), rectX + 20, initialYOffset, 0, 0.315, 255, 255, 255, 255, 0)
    end
    if LeftText ~= nil then
        RenderText(table.concat(LeftText, "\n"), rectX + rectangleWidth - 20, initialYOffset, 0, 0.315, 255, 255, 255, 255, 2)
    end

    RenderRectangle(rectX, rectY, rectangleWidth, rectangleHeight, 0, 0, 0, 125)
end

function RageUI.INFOVEHICLE(Title, RightText, LeftText)
    local maxLineCount = math.max(#RightText, #LeftText)
    local titleHeight = Title ~= nil and 24 or 0
    local initialYOffset = 82 + titleHeight
    local LineCount = #RightText >= #LeftText and #RightText or #LeftText
    if Title ~= nil then
        RenderText("~h~" .. Title .. "~h~", 490, 82, 1, 0.36, 255, 255, 255, 255, 0)
    end

    if RightText ~= nil then
        RenderText(table.concat(RightText, "\n"), 490, initialYOffset, 10, 0.28, 255, 255, 255, 255, 0)
    end

    if LeftText ~= nil then
        RenderText(table.concat(LeftText, "\n"), 690, initialYOffset, 10, 0.28, 255, 255, 255, 255, 2)
    end

    RenderRectangle(385 + 100, 70, 430, Title ~= nil and 50 + (LineCount * 20) or ((LineCount + 1) * 20), 0, 0, 0, 125)
end

function RageUI.Test(value)
    if value == 'NON' then
        RenderRectangle(432 + 10 + 100, 115, 432, 5, 255, 0, 0, 160)
    else
        RenderRectangle(432 + 10 + 100, 115, 432, 5, 0, 255, 0, 160)
    end
end

function RageUI.InfoReport(Title, RightText, LeftText)
    local maxLineCount = math.max(#RightText, #LeftText)
    local titleHeight = Title ~= nil and 24 or 0
    local initialYOffset = 82 + titleHeight
    local LineCount = #RightText >= #LeftText and #RightText or #LeftText
    if Title ~= nil then
        RenderText("~h~" .. Title .. "~h~", 490, 82, 1, 0.36, 255, 255, 255, 255, 0)
    end

    if RightText ~= nil then
        RenderText(table.concat(RightText, "\n"), 490, initialYOffset, 10, 0.28, 255, 255, 255, 255, 0)
    end

    if LeftText ~= nil then
        RenderText(table.concat(LeftText, "\n"), 690, initialYOffset, 10, 0.28, 255, 255, 255, 255, 2)
    end

    RenderRectangle(385 + 100, 70, 430, Title ~= nil and 50 + (LineCount * 20) or ((LineCount + 1) * 20), 0, 0, 0, 125)
end