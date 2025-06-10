local function getShapeBackground(color, radius, strokeWidth, strokeColor)
    local drawable = luajava.new(GradientDrawable)
    drawable.setShape(GradientDrawable.RECTANGLE)
    drawable.setColor(color)
    drawable.setCornerRadii({radius, radius, radius, radius, radius, radius, radius, radius})
    if strokeWidth and strokeColor then
        drawable.setStroke(strokeWidth, strokeColor)
    end
    return drawable
end


function CreateMenu(arr, func, menuType, menuItems)
    if type(arr) ~= 'table' then
        return error('The parameter must be of table type')
    end

    local function createCustomText(index, customText)
        return string.format(customText or 'List function example%d', index)
    end

    local function enableMarquee(textView, text)
        local textLengthThreshold = 10
        if #text > textLengthThreshold then
            textView.setSelected(true)
        end
    end

    local function createTextView(id, text, textColor, marginStart, marginEnd, layoutWeight)
        return {
            TextView;
            id = id;
            text = Html.fromHtml(text);
            textSize = "10sp";
            textColor = textColor or text_color or "#ffffffff";
            layout_marginStart = marginStart or "2.5dp";
            layout_marginEnd = marginEnd or "2.5dp";
            layout_width = layoutWeight and "0dp" or "wrap_content";
            layout_weight = layoutWeight or nil;
            layout_gravity = "center_vertical";
            ellipsize = "marquee";
            singleLine = "true";
            focusable = "true";
            focusableInTouchMode = "true";
        }
    end

    local function createSwitch(id, isChecked, onChangeListener)
        local trackDrawable, thumbDrawable = iOSwitch(isChecked)
        return {
            Switch;
            id = id;
            layout_width = "wrap_content";
            layout_height = "wrap_content";
            layout_marginStart = "2.5dp";
            layout_marginEnd = "2.5dp";
            checked = isChecked;
            scaleX = .8,
            scaleY = .8,
            trackDrawable = trackDrawable;
            thumbDrawable = thumbDrawable;
            onCheckedChangeListener = onChangeListener;
        }
    end

    local function applyCheckboxStyling(checkboxView, isChecked)
        if checkboxView and checkboxView.ButtonDrawable then
            if isChecked then
                checkboxView.ButtonDrawable.setColorFilter(PorterDuffColorFilter(checkbox_color_on or 0xFF00FF00, PorterDuff.Mode.SRC_ATOP))
            else
                checkboxView.ButtonDrawable.setColorFilter(PorterDuffColorFilter(checkbox_color_off or 0xFFFF0000, PorterDuff.Mode.SRC_ATOP))
            end
        end
    end

    local function createCheckbox(id, isChecked, onChangeListener)
        return {
            CheckBox;
            id = id;
            layout_width = "wrap_content";
            layout_height = "wrap_content";
            layout_marginStart = "2.5dp";
            layout_marginEnd = "2.5dp";
            scaleX = .8,
            scaleY = .8,
            checked = isChecked;
            onCheckedChangeListener = function(view, checked)
                applyCheckboxStyling(view, checked)
                if onChangeListener then
                    onChangeListener(view, checked)
                end
            end;
        }
    end

    local function createButton(id, text, onClickListener)
        return {
            Button;
            id = id;
            text = text;
            layout_width = "match_parent";
            layout_height = "34dp";
            layout_marginStart = "2.5dp";
            layout_marginEnd = "2.5dp";
            textSize = "10sp";
            onClick = onClickListener;
        }
    end

    local function createToggleButton(id, text, textOn, textOff, isChecked, onChangeListener)
        return {
            ToggleButton;
            id = id;
            text = text,
            textOn = textOn or "ON";
            textOff = textOff or "OFF";
            layout_width = "match_parent";
            layout_height = "34dp";
            layout_marginStart = "2.5dp";
            layout_marginEnd = "2.5dp";
            checked = isChecked;
            textSize = "10sp";
            onCheckedChangeListener = onChangeListener;
        }
    end

    local function createSeekBar(id, min, max, progress, onChangeListener)
        return {
            SeekBar;
            id = id;
            layout_width = "match_parent";
            layout_height = "wrap_content";
            layout_marginStart = "2.5dp";
            layout_marginEnd = "2.5dp";
            layout_marginTop = "5dp";
            min = min or 0;
            max = max or 100;
            progress = progress or 0;
            onSeekBarChangeListener = onChangeListener;
        }
    end

    local function createRadioButton(id, text, isChecked, onChangeListener)
        return {
            RadioButton;
            id = id;
            text = text;
            layout_width = "match_parent";
            layout_height = "wrap_content";
            layout_marginStart = "8dp";
            layout_marginEnd = "2.5dp";
            layout_marginTop = "2dp";
            layout_marginBottom = "2dp";
            textSize = "9sp";
            textColor = text_color or "#ffffffff";
            checked = isChecked;
            enabled = false; -- disabled by default
            onCheckedChangeListener = onChangeListener;
        }
    end

    -- Tambahkan fungsi untuk format label kittyseekbar
    local function getKittyLabel(item, progress)
    local labelKey = "e" .. tostring(progress)
    if item[labelKey] then
        return tostring(item[labelKey])
    else
        return tostring(progress)
    end
end

    -- Perbaikan: makeTextClickable sekarang bisa toggle checkbox/switch pada tab 2
    local function makeTextClickable(textView, controlId, controlType)
        textView.setOnClickListener({
            onClick = function(view)
                local control = _G[controlId]
                if control then
                    if controlType == "switch" or controlType == "checkbox" then
                        local currentState = control.isChecked()
                        control.setChecked(not currentState)
                    end
                end
            end
        })
    end

    local function createLayout(menuItems, customAction)
        for i, item in ipairs(menuItems) do
            if type(item) == "table" and #item > 1 and item[1] and item[1].type and
                (item[1].type == "checkbox" or item[1].type == "switch") then
                local rowLayout = {
                    LinearLayout;
                    orientation = "horizontal";
                    layout_width = "match_parent";
                    layout_height = "wrap_content";
                    padding = "4.1dp";
                }

                for j, subItem in ipairs(item) do
                    local subItemName = subItem.name or ("Unknown Option " .. j)
                    local subItemType = subItem.type or "switch"
                    local subItemAction = subItem.action
                    local isChecked = false

                    local componentId = "component_" .. menuType .. "_" .. i .. "_" .. j
                    local textId = "TabText" .. menuType .. "_" .. i .. "_" .. j

                    local textLayout = {
                        LinearLayout;
                        orientation = "vertical";
                        layout_width = "0dp";
                        layout_weight = 1;
                        layout_height = "wrap_content";
                        layout_marginStart = "2.5dp";
                        layout_marginEnd = "1dp";
                        layout_gravity = "center_vertical";
                    }

                    table.insert(textLayout, {
                        TextView;
                        id = textId;
                        text = Html.fromHtml(subItemName);
                        textSize = "10sp";
                        textColor = subItem.textColor or text_color or "#ffffffff";
                        layout_width = "wrap_content";
                        layout_height = "wrap_content";
                        ellipsize = "marquee";
                        singleLine = "true";
                        focusable = "true";
                        focusableInTouchMode = "true";
                    })

                    if subItem.sub_text then
                        table.insert(textLayout, {
                            TextView;
                            id = textId .. "_sub";
                            text = Html.fromHtml(subItem.sub_text);
                            textSize = "8sp";
                            textColor = sub_text_color or "#FFAAAAAA";
                            layout_width = "wrap_content";
                            layout_height = "wrap_content";
                            ellipsize = "marquee";
                            singleLine = "true";
                            focusable = "true";
                            focusableInTouchMode = "true";
                        })
                    end

                    local onChangeListener = function(view, isChecked)
                        local runnable = {
                            run = function()
                                pcall(subItemAction, {text = subItemName}, isChecked, i, j)
                                if customAction then
                                    pcall(customAction, {text = subItemName}, isChecked, i, j)
                                end
                            end,
                        }
                        if subItemType == "switch" then
                            updateiOSwitch(view, isChecked)
                        end
                        rx.b(runnable)
                    end

                    if subItemType == "switch" then
                        table.insert(rowLayout, textLayout)
                        table.insert(rowLayout, createSwitch(componentId, isChecked, onChangeListener))
                    elseif subItemType == "checkbox" then
                        table.insert(rowLayout, createCheckbox(componentId, isChecked, onChangeListener))
                        table.insert(rowLayout, textLayout)
                    end
                end

                local layoutView = loadlayout(rowLayout)
                func.addView(layoutView)

                for j, subItem in ipairs(item) do
                    local componentId = "component_" .. menuType .. "_" .. i .. "_" .. j
                    local textView = _G["TabText" .. menuType .. "_" .. i .. "_" .. j]
                    local subTextView = _G["TabText" .. menuType .. "_" .. i .. "_" .. j .. "_sub"]

                    if textView then
                        enableMarquee(textView, subItem.name or "")
                        -- Perbaikan: Pastikan makeTextClickable dipanggil di sini, agar text bisa toggle checkbox/switch
                        makeTextClickable(textView, componentId, subItem.type)
                    end
                    if subTextView then
                        enableMarquee(subTextView, subItem.sub_text or "")
                        makeTextClickable(subTextView, componentId, subItem.type)
                    end

                    if subItem.type == "checkbox" then
                        local checkboxView = _G[componentId]
                        if checkboxView then
                            applyCheckboxStyling(checkboxView, false)
                        end
                    end
                end

            else
                local actualItem = type(item) == "table" and #item == 1 and item[1] or item
                local itemName = actualItem.name or "Unknown Option"
                local itemType = actualItem.type or "switch"
                local itemAction = actualItem.action
                local isChecked = false

                local componentId = "component_" .. menuType .. "_" .. i
                local textId = "TabText" .. menuType .. i

                local mainLayout = {
                    LinearLayout;
                    orientation = "vertical";
                    layout_width = "match_parent";
                    layout_height = "wrap_content";
                    padding = "4.1dp";
                }

                if itemType == "text" then
                    -- Text-only layout
                    local textLayout = {
                        LinearLayout;
                        orientation = "vertical";
                        layout_width = "match_parent";
                        layout_height = "wrap_content";
                        layout_marginStart = "2.5dp";
                        layout_marginEnd = "2.5dp";
                        padding = "4dp";
                    }

                    table.insert(textLayout, {
                        TextView;
                        id = textId;
                        text = Html.fromHtml(itemName);
                        textSize = "10sp";
                        textColor = actualItem.textColor or text_color or "#ffffffff";
                        layout_width = "match_parent";
                        layout_height = "wrap_content";
                        ellipsize = "marquee";
                        singleLine = "true";
                        focusable = "true";
                        focusableInTouchMode = "true";
                    })

                    if actualItem.sub_text then
                        table.insert(textLayout, {
                            TextView;
                            id = textId .. "_sub";
                            text = Html.fromHtml(actualItem.sub_text);
                            textSize = "8sp";
                            textColor = sub_text_color or "#FFAAAAAA";
                            layout_width = "match_parent";
                            layout_height = "wrap_content";
                            ellipsize = "marquee";
                            singleLine = "true";
                            focusable = "true";
                            focusableInTouchMode = "true";
                            layout_marginTop = "2dp";
                        })
                    end

                    table.insert(mainLayout, textLayout)

                elseif itemType == "radio" then
                    local controlLayout = {
                        LinearLayout;
                        orientation = "horizontal";
                        layout_width = "match_parent";
                        layout_height = "wrap_content";
                    }

                    local textLayout = {
                        LinearLayout;
                        orientation = "vertical";
                        layout_width = "0dp";
                        layout_weight = 1;
                        layout_height = "wrap_content";
                        layout_marginStart = "2.5dp";
                        layout_marginEnd = "2.5dp";
                        layout_gravity = "center_vertical";
                    }

                    local checkboxId = componentId .. "_checkbox"
                    local radioGroupId = componentId .. "_radiogroup"

                    table.insert(textLayout, {
                        TextView;
                        id = textId;
                        text = Html.fromHtml(itemName);
                        textSize = "10sp";
                        textColor = actualItem.textColor or text_color or "#ffffffff";
                        layout_width = "wrap_content";
                        layout_height = "wrap_content";
                        ellipsize = "marquee";
                        singleLine = "true";
                        focusable = "true";
                        focusableInTouchMode = "true";
                    })

                    if actualItem.sub_text then
                        table.insert(textLayout, {
                            TextView;
                            id = textId .. "_sub";
                            text = Html.fromHtml(actualItem.sub_text);
                            textSize = "8sp";
                            textColor = sub_text_color or "#FFAAAAAA";
                            layout_width = "wrap_content";
                            layout_height = "wrap_content";
                            ellipsize = "marquee";
                            singleLine = "true";
                            focusable = "true";
                            focusableInTouchMode = "true";
                        })
                    end

                    local onCheckboxChange = function(view, isChecked)
                        -- Enable/disable radio buttons
                        local radioItems = actualItem.items or {}
                        for j, radioItem in ipairs(radioItems) do
                            local radioId = componentId .. "_radio_" .. j
                            local radioView = _G[radioId]
                            if radioView then
                                radioView.setEnabled(isChecked)
                                if not isChecked then
                                    radioView.setChecked(false)
                                end
                            end
                        end

                        local runnable = {
                            run = function()
                                -- Get selected radio button index
                                local selectedIndex = 0
                                if isChecked then
                                    for j, radioItem in ipairs(radioItems) do
                                        local radioId = componentId .. "_radio_" .. j
                                        local radioView = _G[radioId]
                                        if radioView and radioView.isChecked() then
                                            selectedIndex = j
                                            break
                                        end
                                    end
                                end
                                pcall(itemAction, {text = itemName}, isChecked, selectedIndex, i)
                                if customAction then
                                    pcall(customAction, {text = itemName}, isChecked, selectedIndex, i)
                                end
                            end,
                        }
                        rx.b(runnable)
                    end

                    table.insert(controlLayout, createCheckbox(checkboxId, false, onCheckboxChange))
                    table.insert(controlLayout, textLayout)
                    table.insert(mainLayout, controlLayout)

                    -- Create RadioGroup for radio buttons
                    local radioGroupLayout = {
                        RadioGroup;
                        id = radioGroupId;
                        orientation = "vertical";
                        layout_width = "match_parent";
                        layout_height = "wrap_content";
                        layout_marginStart = "20dp";
                        layout_marginEnd = "2.5dp";
                        layout_marginTop = "5dp";
                        onCheckedChangeListener = function(group, checkedId)
                            local checkboxView = _G[checkboxId]
                            if checkboxView and checkboxView.isChecked() then
                                -- Find which radio button was selected
                                local selectedIndex = 0
                                local radioItems = actualItem.items or {}
                                for j, radioItem in ipairs(radioItems) do
                                    local radioId = componentId .. "_radio_" .. j
                                    local radioView = _G[radioId]
                                    if radioView and radioView.getId() == checkedId then
                                        selectedIndex = j
                                        break
                                    end
                                end
                                
                                local runnable = {
                                    run = function()
                                        pcall(itemAction, {text = itemName}, true, selectedIndex, i)
                                        if customAction then
                                            pcall(customAction, {text = itemName}, true, selectedIndex, i)
                                        end
                                    end,
                                }
                                rx.b(runnable)
                            end
                        end
                    }

                    -- Add radio buttons to the group
                    local radioItems = actualItem.items or {}
                    for j, radioItem in ipairs(radioItems) do
                        local radioId = componentId .. "_radio_" .. j
                        table.insert(radioGroupLayout, createRadioButton(radioId, radioItem, false, nil))
                    end

                    table.insert(mainLayout, radioGroupLayout)

                elseif itemType == "switch" or itemType == "checkbox" then
                    local rowLayout = {
                        LinearLayout;
                        orientation = "horizontal";
                        layout_width = "match_parent";
                        layout_height = "wrap_content";
                    }

                    local textLayout = {
                        LinearLayout;
                        orientation = "vertical";
                        layout_width = "0dp";
                        layout_weight = 1;
                        layout_height = "wrap_content";
                        layout_marginStart = "2.5dp";
                        layout_marginEnd = "2.5dp";
                        layout_gravity = "center_vertical";
                    }

                    table.insert(textLayout, {
                        TextView;
                        id = textId;
                        text = Html.fromHtml(itemName);
                        textSize = "10sp";
                        textColor = actualItem.textColor or text_color or "#ffffffff";
                        layout_width = "wrap_content";
                        layout_height = "wrap_content";
                        ellipsize = "marquee";
                        singleLine = "true";
                        focusable = "true";
                        focusableInTouchMode = "true";
                    })

                    if actualItem.sub_text then
                        table.insert(textLayout, {
                            TextView;
                            id = textId .. "_sub";
                            text = Html.fromHtml(actualItem.sub_text);
                            textSize = "8sp";
                            textColor = sub_text_color or "#FFAAAAAA";
                            layout_width = "wrap_content";
                            layout_height = "wrap_content";
                            ellipsize = "marquee";
                            singleLine = "true";
                            focusable = "true";
                            focusableInTouchMode = "true";
                        })
                    end

                    if itemType == "switch" then
                        local onChangeListener = function(view, isChecked)
                            local runnable = {
                                run = function()
                                    pcall(itemAction, {text = itemName}, isChecked, i)
                                    if customAction then
                                        pcall(customAction, {text = itemName}, isChecked, i)
                                    end
                                end,
                            }
                            updateiOSwitch(view, isChecked)
                            rx.b(runnable)
                        end
                        table.insert(rowLayout, textLayout)
                        table.insert(rowLayout, createSwitch(componentId, isChecked, onChangeListener))
                    elseif itemType == "checkbox" then
                        local onChangeListener = function(view, isChecked)
                            local runnable = {
                                run = function()
                                    pcall(itemAction, {text = itemName}, isChecked, i)
                                    if customAction then
                                        pcall(customAction, {text = itemName}, isChecked, i)
                                    end
                                end,
                            }
                            rx.b(runnable)
                        end
                        table.insert(rowLayout, createCheckbox(componentId, isChecked, onChangeListener))
                        table.insert(rowLayout, textLayout)
                    end

                    table.insert(mainLayout, rowLayout)

                elseif itemType == "button" then
                    local onClickListener = function(view)
                        local runnable = {
                            run = function()
                                pcall(itemAction, {text = itemName}, false, i)
                                if customAction then
                                    pcall(customAction, {text = itemName}, false, i)
                                end
                            end,
                        }
                        rx.b(runnable)
                    end
                    table.insert(mainLayout, createButton(componentId, itemName, onClickListener))

                elseif itemType == "togglebutton" then
                    local onChangeListener = function(view, isChecked)
                        if isChecked then
                            view.setBackground(getShapeBackground(button_color_on, 16, 1.5, button_stroke_color_on))
                        else
                            view.setBackground(getShapeBackground(button_color_off, 16, 1.5, button_stroke_color_off))
                        end
                        local runnable = {
                            run = function()
                                pcall(itemAction, {text = itemName}, isChecked, i)
                                if customAction then
                                    pcall(customAction, {text = itemName}, isChecked, i)
                                end
                            end,
                        }
                        rx.b(runnable)
                    end
                    table.insert(mainLayout, createToggleButton(
                        componentId,
                        actualItem.name,
                        actualItem.textOn,
                        actualItem.textOff,
                        isChecked,
                        onChangeListener
                    ))

                elseif itemType == "seekbar" or itemType == "kittyseekbar" then
                    local controlLayout = {
                        LinearLayout;
                        orientation = "horizontal";
                        layout_width = "match_parent";
                        layout_height = "wrap_content";
                    }

                    local textLayout = {
                        LinearLayout;
                        orientation = "vertical";
                        layout_width = "0dp";
                        layout_weight = 1;
                        layout_height = "wrap_content";
                        layout_marginStart = "2.5dp";
                        layout_marginEnd = "2.5dp";
                        layout_gravity = "center_vertical";
                    }

                    local checkboxId = componentId .. "_checkbox"
                    local seekbarId = componentId .. "_seekbar"
                    local progressTextId = componentId .. "_progress"

                    local onCheckboxChange = function(view, isChecked)
                        local seekbar = _G[seekbarId]
                        if seekbar then
                            seekbar.setEnabled(isChecked)
                        end
                        local runnable = {
                            run = function()
                                local currentProgress = seekbar and seekbar.getProgress() or (actualItem.progress or 0)
                                -- Perbaikan: Pastikan nilai progress yang benar dikirim ke action
                                pcall(itemAction, {text = itemName, value = currentProgress}, isChecked, currentProgress)
                                if customAction then
                                    pcall(customAction, {text = itemName, value = currentProgress}, isChecked, currentProgress)
                                end
                            end,
                        }
                        rx.b(runnable)
                    end

                    local mainTextLayout = {
                        LinearLayout;
                        orientation = "horizontal";
                        layout_width = "wrap_content";
                        layout_height = "wrap_content";
                        layout_gravity = "center_vertical";
                    }

                    table.insert(mainTextLayout, {
                        TextView;
                        id = textId;
                        text = Html.fromHtml(itemName .. ": ");
                        textSize = "10sp";
                        textColor = actualItem.textColor or text_color or "#ffffffff";
                        layout_width = "wrap_content";
                        layout_height = "wrap_content";
                        ellipsize = "marquee";
                        singleLine = "true";
                        focusable = "true";
                        focusableInTouchMode = "true";
                    })

                    -- Perbaikan: Gunakan progress yang benar untuk label awal
                    local initialProgress = actualItem.progress or 1
                    local progressLabel = (itemType == "kittyseekbar") and getKittyLabel(actualItem, initialProgress) or tostring(initialProgress)
    
                    table.insert(mainTextLayout, {
                        TextView;
                        id = progressTextId;
                        text = progressLabel;
                        textSize = "10sp";
                        textColor = color_accent1 or text_color or "#FFFFFF00";
                        layout_width = "wrap_content";
                        layout_height = "wrap_content";
                    })

                    table.insert(textLayout, mainTextLayout)

                    if actualItem.sub_text then
                        table.insert(textLayout, {
                            TextView;
                            id = textId .. "_sub";
                            text = Html.fromHtml(actualItem.sub_text);
                            textSize = "8sp";
                            textColor = sub_text_color or "#FFAAAAAA";
                            layout_width = "wrap_content";
                            layout_height = "wrap_content";
                            ellipsize = "marquee";
                            singleLine = "true";
                            focusable = "true";
                            focusableInTouchMode = "true";
                        })
                    end

                    table.insert(controlLayout, createCheckbox(checkboxId, false, onCheckboxChange))
                    table.insert(controlLayout, textLayout)

                    table.insert(mainLayout, controlLayout)

                    -- Perbaikan: OnSeekBarChange listener yang benar
                    local onSeekBarChange = {
                        onStartTrackingTouch = function() end,
                        onStopTrackingTouch = function(seekbar)
                            local progress = seekbar.getProgress()
                            local progressText = progressTextId and _G[progressTextId] or nil
            
                            -- Update tampilan label
                            if progressText then
                                if itemType == "kittyseekbar" then
                                    progressText.setText(getKittyLabel(actualItem, progress))
                                else
                                    progressText.setText(tostring(progress))
                                end
                            end
            
                            seekbar.getProgressDrawable().setColorFilter(checkbox_color_on, android.graphics.PorterDuff.Mode.SRC_IN);
                            seekbar.getThumb().setColorFilter(checkbox_color_on, android.graphics.PorterDuff.Mode.SRC_IN);
            
                            local runnable = {
                                run = function()
                                    -- Perbaikan: Kirim progress sebagai parameter ketiga (p)
                                    pcall(itemAction, {text = itemName, value = progress}, true, progress)
                                    if customAction then
                                        pcall(customAction, {text = itemName, value = progress}, true, progress)
                                    end
                                end,
                            }
                            rx.b(runnable)
                        end,
                        onProgressChanged = function(seekbar, progress, fromUser)
                            local progressText = progressTextId and _G[progressTextId] or nil
                            if progressText and fromUser then
                                if itemType == "kittyseekbar" then
                                    progressText.setText(getKittyLabel(actualItem, progress))
                                else
                                    progressText.setText(tostring(progress))
                                end
                            end
                        end
                    }

                    table.insert(mainLayout, createSeekBar(
                        seekbarId,
                        actualItem.min,
                        actualItem.max,
                        actualItem.progress,
                        onSeekBarChange
                    ))
                end

                local layoutView = loadlayout(mainLayout)
                func.addView(layoutView)

                -- Post-processing for different item types
                if itemType == "text" then
                    local textView = textId and _G[textId] or nil
                    local subTextView = textId and _G[textId .. "_sub"] or nil
                    if textView then
                        enableMarquee(textView, itemName)
                    end
                    if subTextView then
                        enableMarquee(subTextView, actualItem.sub_text)
                    end
                end

                if itemType == "radio" then
                    local textView = textId and _G[textId] or nil
                    local subTextView = textId and _G[textId .. "_sub"] or nil
                    local checkboxId = componentId .. "_checkbox"
                    
                    if textView then
                        enableMarquee(textView, itemName)
                        makeTextClickable(textView, checkboxId, "checkbox")
                    end
                    if subTextView then
                        enableMarquee(subTextView, actualItem.sub_text)
                        makeTextClickable(subTextView, checkboxId, "checkbox")
                    end

                    local checkboxView = _G[checkboxId]
                    if checkboxView then
                        applyCheckboxStyling(checkboxView, false)
                    end

                    -- Apply styling to radio buttons
                    local radioItems = actualItem.items or {}
                    for j, radioItem in ipairs(radioItems) do
                        local radioId = componentId .. "_radio_" .. j
                        local radioView = _G[radioId]
                        if radioView then
                            radioView.setEnabled(false) -- disabled by default
                            if radioView.ButtonDrawable then
                                radioView.ButtonDrawable.setColorFilter(PorterDuffColorFilter(checkbox_color_off or 0xFFFF0000, PorterDuff.Mode.SRC_ATOP))
                            end
                        end
                    end
                end

                if itemType == "seekbar" or itemType == "kittyseekbar" then
                    local seekbar = _G[componentId .. "_seekbar"]
                    if seekbar then
                        seekbar.setEnabled(false)
                        seekbar.getProgressDrawable().setColorFilter(checkbox_color_on, android.graphics.PorterDuff.Mode.SRC_IN);
                        seekbar.getThumb().setColorFilter(checkbox_color_on, android.graphics.PorterDuff.Mode.SRC_IN);
        
                        -- Perbaikan: Set progress yang benar
                        local initialProgress = actualItem.progress or 1
                        seekbar.setProgress(initialProgress)
        
                        local progressText = progressTextId and _G[progressTextId] or nil
                        if progressText then
                            if itemType == "kittyseekbar" then
                                progressText.setText(getKittyLabel(actualItem, initialProgress))
                            else
                                progressText.setText(tostring(initialProgress))
                            end
                        end
                    end

                    local checkboxView = _G[componentId .. "_checkbox"]
                    if checkboxView then
                        applyCheckboxStyling(checkboxView, false)
                    end

                    local textView = textId and _G[textId] or nil
                    local subTextView = textId and _G[textId .. "_sub"] or nil
                    local checkboxId = componentId .. "_checkbox"
                    if textView then
                        enableMarquee(textView, itemName)
                        makeTextClickable(textView, checkboxId, "checkbox")
                    end
                    if subTextView then
                        enableMarquee(subTextView, actualItem.sub_text)
                        makeTextClickable(subTextView, checkboxId, "checkbox")
                    end
                end

                if itemType == "spinner" then
                    local textView = textId and _G[textId] or nil
                    local subTextView = textId and _G[textId .. "_sub"] or nil
                    local checkboxId = componentId .. "_checkbox"
                    if textView then
                        enableMarquee(textView, itemName)
                        makeTextClickable(textView, checkboxId, "checkbox")
                    end
                    if subTextView then
                        enableMarquee(subTextView, actualItem.sub_text)
                        makeTextClickable(subTextView, checkboxId, "checkbox")
                    end
                end

                if itemType == "button" then
                    local view = componentId and _G[componentId] or nil
                    if view then
                        view.setAllCaps(false)
                        view.setBackground(getShapeBackground(button_color, 16, 1.5, button_stroke_color))
                    end
                end

                if itemType == "togglebutton" then
                    local view = componentId and _G[componentId] or nil
                    if view then
                        view.setAllCaps(false)
                        view.setBackground(getShapeBackground(button_color, 16, 1.5, button_stroke_color))
                    end
                end

                if itemType == "switch" or itemType == "checkbox" then
                    local textView = textId and _G[textId] or nil
                    local subTextView = textId and _G[textId .. "_sub"] or nil
                    if textView then
                        enableMarquee(textView, itemName)
                        makeTextClickable(textView, componentId, itemType)
                    end
                    if subTextView then
                        enableMarquee(subTextView, actualItem.sub_text)
                        makeTextClickable(subTextView, componentId, itemType)
                    end
                    if itemType == "checkbox" then
                        local checkboxView = _G[componentId]
                        if checkboxView then
                            applyCheckboxStyling(checkboxView, false)
                        end
                    end
                end
            end
        end
    end

    createLayout(menuItems, nil)
end
