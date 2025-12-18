local GreatPainter = GameMain:GetMod("GreatPainter");--先注册一个新的MOD模块
--GreatPainter.AutoStart = true;
GreatPainter.Power = 12;
local GlobleDataMgr = CS.XiaWorld.GlobleDataMgr.Instance;
GreatPainter_MainUI = GreatPainter_MainUI or GameMain:GetMod("Windows"):CreateWindow("GreatPainter_MainUI");

local function AddTranslation()
	if CS.TFMgr.Instance.Language == "cn" then
		return;
	end
	xlua.private_accessible(CS.TFMgr);
	CS.TFMgr.Instance:AddKv("超级符师", "GreatPainter");
	CS.TFMgr.Instance:AddKv("倍画符", "Times Power");
	CS.TFMgr.Instance:AddKv("快速画符+", "Instant Draw Plus");
	CS.TFMgr.Instance:AddKv("假符模板", "Mirror Pattern");
	CS.TFMgr.Instance:AddKv("出错啦！\n超级符师修改失败！\n请及时反馈bug", "Error!\nFail to edit!");
	CS.TFMgr.Instance:AddKv("超级符师修改成功", "Changes applied to ");
	CS.TFMgr.Instance:AddKv("暂无", "None");
	CS.TFMgr.Instance:AddKv("幽粹成功率设置为：\n100%", "Specter Refinement Success Rate Change to:\n100%");
	CS.TFMgr.Instance:AddKv("幽粹成功率设置为：\n游戏默认值", "Specter Refinement Success Rate Change to:\nDefault Value");
	CS.TFMgr.Instance:AddKv("灵粹成功率设置为：\n100%", "Spiritual Refinement Success Rate Change to:\n100%");
	CS.TFMgr.Instance:AddKv("灵粹成功率设置为：\n游戏默认值", "Spiritual Refinement Success Rate Change to:\nDefault Value");
	CS.TFMgr.Instance:AddKv("快速画符品质：", "Instant Draw V:");
	CS.TFMgr.Instance:AddKv("快速画符设置", "Instant Draw Setting");
	CS.TFMgr.Instance:AddKv("预测品质:%s", "Predict Quality:%s");
	CS.TFMgr.Instance:AddKv("未知", "N/A");
	
end
function GreatPainter:OnInit()
	print("GreatPainter init");	
	--接管需要用的管理类
	AddTranslation();
	GreatPainter:LoadSetting();
	GreatPainter.WorldLuaHelper = CS.WorldLuaHelper();
	GreatPainter_MainUI:Init();
	GreatPainter.LocalLoad = true;
end

local function QuickPaintPlus(power)
	local _GreatPainter = GameMain:GetMod("GreatPainter");
	_GreatPainter.Window.BrokenCallBack(_GreatPainter.Window.SelectName, 1, power, true);
	_GreatPainter.Window.BrokenCallBack = nil;
	if not _GreatPainter.Window.waithide then
		_GreatPainter.Window:Hide();
	else
		_GreatPainter.Window.willhide = true;
		CS.MapRender.Instance.MousePainter.enabled = false;
	end
end

local function UpdateButton(EventContext)
	if EventContext.sender.selectedIndex == 2 then
		GreatPainter.Button.visible = true;
	else
		GreatPainter.Button.visible = false;
	end
end

local function CallWindow()
	local Window = CS.Wnd_Message.ShowSlider(XT("超级符师"), 2, function(f) if f > -1 then QuickPaintPlus(f+1) end; end, true, nil, nil, GreatPainter.Power -1, true);
	--Window.UIInfo.m_n45.value = 0;
	Window.UIInfo.m_slidertxt.text = string.format("------------------------%02d".."倍画符".."------------------------", Window.UIInfo.m_n45.value+1) .. "\n[color=#ff0000]超级符师MOD功能！请谨慎选择倍率以免破坏游戏体验！[/color]";
	Window.UIInfo.m_n45.onChanged:Add(function(e) Window.UIInfo.m_slidertxt.text = string.format("------------------------%02d倍画符------------------------", e.sender.value+1) .."\n[color=#ff0000]超级符师MOD功能！请谨慎选择倍率以免破坏游戏体验！[/color]"; end);
end

local function AddButton()
	--符修快速画符按钮
	local obj = UIPackage.CreateObjectFromURL("ui://0xrxw6g7hdhl18");
	local Button = GreatPainter.Window.contentPane:AddChild(obj);
	Button:SetXY(GreatPainter.Window.contentPane.m_n51.x - 10, GreatPainter.Window.contentPane.m_n51.y - 35);
	Button.width = 75;
	Button.title = XT("快速画符+");
	Button.name = "QuickPaintPlus";
	Button.onClick:Add(function() CallWindow(); end);
	Button.visible = false;
	
	--伪符水印选项
	local obj2 = CS.XiaWorld.UI.InGame.UI_WindowPainter.CreateInstance();
	--GList
	local obj3 = obj2.m_n25;
	--背景图片
	local obj4 = obj2.m_n61;
	--标题
	local obj5 = obj2.m_n47;
	local BG = GreatPainter.Window.contentPane:AddChild(obj4);
	BG.x = GreatPainter.Window.contentPane.width;
	--BG.visible = false;
	local title = GreatPainter.Window.contentPane:AddChild(obj5);
	title.title = XT("假符模板");
	title.x = 27 + GreatPainter.Window.contentPane.width;
	--title.visible = false;
	local List = GreatPainter.Window.contentPane:AddChild(obj3);
	List.x = 27 + GreatPainter.Window.contentPane.width;
	local bt1 = List:AddItemFromPool().asButton;
	bt1.title = XT("空白");
	bt1.data = nil;
	bt1.name = "0";
	bt1.tooltips = XT("似乎随便画画就可以得到神奇的结果。");
	local AllFu = PracticeMgr.m_mapSpellDefs;
	local num = 1;
	for k,v in pairs(AllFu) do
		if v.Name ~= "Spell_SYSLOST" then
			local b = List:AddItemFromPool().asButton;
			b.title = v.DisplayName;
			b.data = k;
			b.name = num;
			num = num + 1;
			b.tooltips = v.Desc;
			b.enabled = true;
		end
	end
	--是否显示水印ui
	local function WaterMark(EventContext)
		local item = EventContext.data;
		if item.data == nil then
			BG.visible = true;
			title.visible = true;
			List.visible = true;
		else
			BG.visible = false;
			title.visible = false;
			List.visible = false;
		end
	end
	
	--Button2:SetXY(GreatPainter.Window.contentPane.width, GreatPainter.Window.contentPane.m_n25.y);
	--Button2.width = 75;
	--Button2.title = "水印选择";
	--Button2.name = "WaterMark";
	--Button2.onClick:Add(function() print(123); end);
	--Button2.visible = false;
	GreatPainter.Button = Button;
	GreatPainter.List = List;
	GreatPainter.Window.contentPane.m_Mode.onChanged:Add(function(EventContext) UpdateButton(EventContext) end);

	--显示预测品质
	local Label = UIPackage.CreateObjectFromURL("ui://0xrxw6g7nd594l");
	Label:SetSize(150,20,false)
	Label.m_title.textFormat.color = CS.UnityEngine.Color.red;
	Label.name = "predict";
	Label.title = string.format(XT("预测品质:%s"),XT("未知"));
	GreatPainter.Window.contentPane:AddChild(Label);
	Label.x = 20;
	Label.y = 22;
	GreatPainter.Label = Label;
	local function UpdateLabel()
		local paintMainTexture = CS.MapRender.Instance.PaintPanel:GetPaintMainTexture("Painter");
		local simple = CS.XiaWorld.CompareTexture.GetSimple(paintMainTexture, 32);
		local num = 0;
		if CS.Wnd_FuPatinter.Instance.SelectName then
			num = CS.XiaWorld.CompareTexture.Compare(simple, CS.XiaWorld.PracticeMgr.Instance:GetSpellSimple(CS.Wnd_FuPatinter.Instance.SelectName));
			num = string.format("%.f",num*100)
		else
			num = XT("未知");
		end
		Label.title = string.format(XT("预测品质:%s"),num);
	end
	local a = CS.Wnd_FuPatinter.Instance.UIInfo.m_n54;
	a.onTouchEnd:Clear()
	a.onTouchEnd:Add(function(e) UpdateLabel() end)
	local function ClearLabel()
		Label.title = string.format(XT("预测品质:%s"),XT("未知"));
	end
	GreatPainter.Window.contentPane.m_n51.onClick:Add(function() ClearLabel(); end)
	GreatPainter.Window.contentPane.m_n25.onClickItem:Add(function() ClearLabel(); end)
	GreatPainter.Window.contentPane.m_n62.onClick:Add(function() ClearLabel(); end)
	GreatPainter.Window.contentPane.m_n56.onClick:Add(function() ClearLabel(); end)
	GreatPainter.Window.contentPane.m_n65.onClickItem:Add(function() ClearLabel(); end)
	
	
	--选择水印符文回调
	local function SelectWaterMark(EventContext)
		local item = EventContext.data;
		local name = item.data;
		if name == nil then
			CS.MapRender.Instance.PainRender.sharedMaterial:SetTexture("_Temp", nil);
		else
			local spellDef = PracticeMgr:GetSpellDef(name);
			CS.MapRender.Instance.PainRender.sharedMaterial:SetTexture("_Temp", CS.UnityEngine.Resources.Load(spellDef.Template));
		end
		GreatPainter.Window.SelectName = name;
		GreatPainter.Window.UIInfo.m_n62.grayed = true;
		GreatPainter.Window.UIInfo.m_n63.text = nil;
		UpdateLabel();
	end
	List.onClickItem:Add(function(EventContext) SelectWaterMark(EventContext); end);
	GreatPainter.Window.onPositionChanged:Clear();
end


function GreatPainter:OnEnter()
	print("GreatPainter enter");
	xlua.private_accessible(CS.Wnd_FuPatinter);
	--初始化UI内容
	--if GreatPainter.LocalLoad == true then
	--	GreatPainter:LoadSetting()
	--else
	--	GreatPainter:SaveSetting()
	--end
	GreatPainter_MainUI:Show();
	if GreatPainter.AutoStart == false then
		GreatPainter_MainUI:Hide();
	end
	if GreatPainter.YouCui then
		CS.XiaWorld.GameDefine.SOULCRYSTALYOU_BASE = 1;
	end
	if GreatPainter.LingCui then
		CS.XiaWorld.GameDefine.SOULCRYSTALLING_BASE = 1;
	end
	GreatPainter.Window = CS.Wnd_FuPatinter.Instance;
	GreatPainter.Window.onPositionChanged:Add(function() AddButton() end);
end

function GreatPainter:OnStep(dt)--请谨慎处理step的逻辑，可能会影响游戏效率
	--print("GreatPainter Step"..dt);
end

function GreatPainter:OnRender(dt)--渲染帧 刷新
	--print("GreatPainter Render"..dt);
end

function GreatPainter:ToStringEx(value)
    if type(value)=='table' then
        return GreatPainter:TableToStr(value)
    elseif type(value)=='string' then
        return "\'"..value.."\'"
    else
        return tostring(value)
    end
end

function GreatPainter:TableToStr(t)
    if t == nil then return "" end
    local retstr= "{"

    local i = 1
    for key,value in pairs(t) do
        local signal = ","
        if i==1 then
            signal = ""
        end

        if key == i then
            retstr = retstr..signal..GreatPainter:ToStringEx(value)
        else
            if type(key)=='number' or type(key) == 'string' then
                retstr = retstr..signal..'['..GreatPainter:ToStringEx(key).."]="..GreatPainter:ToStringEx(value)
            else
                if type(key)=='userdata' then
                    retstr = retstr..signal.."*s"..GreatPainter:TableToStr(getmetatable(key)).."*e".."="..GreatPainter:ToStringEx(value)
                else
                    retstr = retstr..signal..key.."="..GreatPainter:ToStringEx(value)
                end
            end
        end

        i = i+1
    end

    retstr = retstr.."}"
    return retstr
end

function GreatPainter:LoadSetting()
	local file = io.open(".\\saves\\GreatPainter.cfg", "r")
	if file == nil then
		print("没有配置文件，创建新的配置文件。");
		
		if GreatPainter.AutoStart == nil then
			GreatPainter.AutoStart = true;
		end
		if GreatPainter.YouCui == nil then
			GreatPainter.YouCui = false;
		end
		if GreatPainter.LingCui == nil then
			GreatPainter.LingCui = false;
		end
		GreatPainter:SaveSetting();
		return;
	end
	local t = file:read("*all")
	print("超级符师读取设置："..t)
	local data = load("return "..t)();
	
	GreatPainter.AutoStart = data.AutoStart;
	GreatPainter.YouCui = data.YouCui;
	GreatPainter.LingCui = data.LingCui;
	file:close();
	return;
end

function GreatPainter:SaveSetting()
	local file = io.open(".\\saves\\GreatPainter.cfg", "w")
	if GreatPainter.AutoStart == nil then
		GreatPainter.AutoStart = true;
	end
	if GreatPainter.YouCui == nil then
		GreatPainter.YouCui = false;
	end
	if GreatPainter.LingCui == nil then
		GreatPainter.LingCui = false;
	end
	local data = {
		AutoStart = GreatPainter.AutoStart;
		YouCui = GreatPainter.YouCui;
		LingCui = GreatPainter.LingCui
		};
	print("超级符师保存设置："..GreatPainter:ToStringEx(data))
	file:write(GreatPainter:ToStringEx(data));
	file:close()
end

function GreatPainter:OnSave()--系统会将返回的table存档 table应该是纯粹的KV
	print("GreatPainter OnSave");
end

function GreatPainter:OnLoad(tbLoad)--读档时会将存档的table回调到这里
	print("GreatPainter OnLoad");
end

function GreatPainter:OnLeave()
	GreatPainter:SaveSetting();
	print("GreatPainter Leave");
end

function GreatPainter:OnSetHotKey()  --更新了热键方法
	local HotKey = { {ID = "GreatPainter" , Name = XT("超级符师") , Type = "Mod", InitialKey1 = "F8" } };
	return HotKey;
end

function GreatPainter:OnHotKey(ID,state)
	if ID == "GreatPainter" and state == "down" then
		if GreatPainter_MainUI.isShowing then
			GreatPainter_MainUI:Hide();
		else
			GreatPainter_MainUI:Show();
		end
	end
end

function GreatPainter:SetAutoStart(bool)
	GreatPainter.AutoStart = bool;
end

function GreatPainter:SetAll(value)

	local data = PracticeMgr.m_mapSpellDefs;
	local count = 0;
	local realvalue = value/100;
	local newvalue = realvalue/0.95;
	if realvalue == nil then
		GreatPainter.WorldLuaHelper:ShowMsgBox(XT("出错啦！\n超级符师修改失败！\n请及时反馈bug"),XT("超级符师"));
		return;
	end
	for k, v in pairs(data) do
		local s , cv = GlobleDataMgr.FuSaves:TryGetValue(k)
		if s and cv > newvalue then
			GlobleDataMgr.FuSaves:Remove(k)
		end
		GlobleDataMgr:SaveFuValue(k,newvalue);
	
		local spelldef = PracticeMgr:GetSpellDef(k)
		local spellname = spelldef.DisplayName;
		print(spellname , " 快速画符品质已修改为：" , newvalue);
		count = count + 1;
	end
	print("所有符文都已修改完毕2");
	GreatPainter_MainUI:FuListUpdate(); --更新符文列表
	--弹出窗口显示Log
	GreatPainter.WorldLuaHelper:ShowMsgBox(XT("超级符师修改成功")..count..XT("个符文"),"超级符师");
end



function GreatPainter:SetOne(name,value)
	local data = PracticeMgr.m_mapSpellDefs;
	local realvalue = value/100;
	local newvalue = realvalue/0.95;
	if realvalue == nil then
		GreatPainter.WorldLuaHelper:ShowMsgBox("出错啦！\n超级符师修改失败！\n请及时反馈bug","超级符师");
		return;
	end
	local s , cv = GlobleDataMgr.FuSaves:TryGetValue(name)
	if s and cv > newvalue then
		GlobleDataMgr.FuSaves:Remove(name)
	end
	GlobleDataMgr:SaveFuValue(name,newvalue);
	local spelldef = PracticeMgr:GetSpellDef(name)
	local spellname = spelldef.DisplayName;
	print(spellname , " 快速画符品质已修改为：" , newvalue);
	print("单个符文都已修改完毕");
	GreatPainter_MainUI:FuListUpdate();
	--弹出窗口显示Log
	GreatPainter.WorldLuaHelper:ShowMsgBox("超级符师修改成功\n符文：".. spellname .. "\n快速画符品质已修改为：" .. value,"超级符师");
end

function GreatPainter:OnLeave()
	GreatPainter:SaveSetting();
end