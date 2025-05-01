local me=LocalPlayer()
local lv={}
lv.cfg = {Dist=3500}
local tar = GetRenderTarget("1" .. os.time(), ScrW(), ScrH())
local function v0(vOrigin, vAngle, vFOV)
local view = {
x=0,
y=0,
w=ScrW(),
h=ScrH(),
dopostprocess=true,
origin=vOrigin,
angles=vAngle,
fov=vFOV,
drawhud=true,
drawmonitors=true,
drawviewmodel=true
}
render.RenderView(view)
render.CopyTexture(nil, tar)
cam.Start2D()
hook.Run("AltHUDPaint")
cam.End2D()
render.SetRenderTarget(tar)
end

hook.Add("RenderScene","RenderScene",function(vOrigin, vAngle, vFOV)
    v0(vOrigin, vAngle, vFOV)
end)

hook.Add("ShutDown","ShutDown",function()
    render.SetRenderTarget()
end)

local function v1(ply)
    local zteam=ply:Team()
    if rp and rp.GetJobWithoutDisguise then
        local index=rp.GetJobWithoutDisguise(ply:EntIndex())
        local tbl=rp.jobs.List[index]
        return index,tbl.Name,tbl.Color
    else
        return zteam,team.GetName(zteam),team.GetColor(zteam)
    end
end

lv.frame = vgui.CreateX("EditablePanel")

local function Slider(x,y,key,min,max,step)
    step=step or 1
    lv.cfg[key]=math.Clamp(lv.cfg[key]or min,min,max)
    local slider=vgui.Create("DPanel",lv.frame)
    slider:SetPos(x,y)
    local w,h=70,11
    slider:SetSize(w,h)
    function slider:Paint(w,h)
        draw.RoundedBox(6,0,h/3,w,h/3,color_black)
        local frac=(lv.cfg[key]-min)/(max-min)
        local fillw=math.Clamp(frac*w,0,w)
        local fillh=h*0.4
        local fillY=(h-fillh)/2
        draw.RoundedBox(6,0,fillY,fillw,fillh,Color(99,99,99))
    end
    function slider:OnMousePressed()
        self.Dragging=true
        self:MouseCapture(true)
    end
    function slider:OnMouseReleased()
        self.Dragging=false
        self:MouseCapture(false)
    end
    function slider:Think()
        if self.Dragging then
            local mx,_=gui.MousePos()
            local lx=mx-self:LocalToScreen(0,0)
            local frac=math.Clamp(lx/w,0,1)
            local rawval=min+frac*(max-min)
            local stepval=math.Round(rawval/step)*step
            lv.cfg[key]=math.Clamp(stepval,min,max)
        end
    end
end

local function Checkbox(key,y)
    local chk=vgui.Create("DCheckBox",lv.frame)
    chk:SetPos(10,y)
    chk:SetValue(lv.cfg[key])
    function chk:OnChange(val)
        lv.cfg[key]=val
    end
    function chk:Paint(w,h)
        surface.SetDrawColor(12,12,12)
        surface.DrawOutlinedRect(0,0,w,h,1)
        surface.SetDrawColor(21,21,21)
        surface.DrawRect(0,0,w,h)
        if self:GetChecked()then
            surface.SetDrawColor(99,99,99)
            surface.DrawRect(3,3,w-6,h-6)
        end
    end
    local lbl=vgui.Create("DLabel",lv.frame)
    lbl:SetPos(30,y-2)
    lbl:SetText(key)
    lbl:SizeToContents()
    return chk
end

do
    F=lv.frame
    F:SetFocusTopLevel(true)
    F:SetSize(230,230)
    F:SetPos(100,100)
    F:SetPaintBackgroundEnabled(false)
    F:SetPaintBorderEnabled(false)
    F:DockPadding(5,60,5,5)
    F:MakePopup()
    function F:Paint(w,h)
        surface.SetDrawColor(30,30,30)
        surface.DrawRect(0,0,w,h)
        surface.SetDrawColor(99,99,99)
        surface.DrawRect(0,30,w,2)
        surface.SetDrawColor(22,22,22)
        surface.DrawOutlinedRect(0,0,w,h,5)
        surface.SetTextColor(color_white)
        surface.SetTextPos(10,10)
        surface.SetFont("DermaDefault")
        surface.DrawText("lv render")
    end
    function F:Think()
        local x,y=input.GetCursorPos()
        local mx,my=math.Clamp(x,1,ScrW()-1),math.Clamp(y,1,ScrH()-1)
        if F.Dragging then
            F:SetPos(mx-F.Dragging[1],my-F.Dragging[2])
        end
    end
    function F:OnMousePressed()
        local x,y=input.GetCursorPos()
        local scrx,scry=self:LocalToScreen(0,0)
        local w,h=self:GetSize()
        if x>scrx+w-20 and y>scry+h-20 then
            self.Resizing=true
            self:MouseCapture(true)
        elseif y<scry+850 then
            self.Dragging={x-self.x,y-self.y}
            self:MouseCapture(true)
        end
    end
    function F:OnMouseReleased()
        self.Dragging,self.Resizing=nil,nil
        self:MouseCapture(false)
    end
    function F:PerformLayout(w,h)
        local padL,padT,padR,padB=self:GetDockPadding()
        local pw,ph=w-padL-padR,h-padT-padB
    end
    Checkbox("ESP",45)
    Checkbox("Box",65)
    Checkbox("Name",85)
    Checkbox("HP",105)
    Checkbox("Wep",125)
    Checkbox("Role",145)
    Checkbox("Rank",165)
    Slider(10,185,"Dist",500,10000,1)
end

local function v2()
    if input.IsKeyDown(74) and not kd then
        if IsValid(lv.frame) then
            lv.frame:SetVisible(not lv.frame:IsVisible())
        end
    end
    kd = input.IsKeyDown(74)
    if input.IsKeyDown(73) and not del then
        if IsValid(lv.frame) then
            lv.frame:Remove()
        end
        hook.Remove("DrawOverlay","Simple")
        hook.Remove("Think","DecorProps")
    end
    del = input.IsKeyDown(73)
end
hook.Add("Think","DecorProps",v2)

local function v3()
    local plys=player.GetAll()
    for i=1,#plys do
        local a=plys[i]
        if not lv.cfg.ESP or a==me or not a:Alive() or me:GetPos():DistToSqr(a:GetPos())>lv.cfg.Dist^2 then continue end
        surface.SetAlphaMultiplier(a:IsDormant() and 0.4 or 1)
        local cw = color_white
        local pos=a:GetPos()
        local min,max=a:OBBMins(),a:OBBMaxs()
        local pos2=(pos+Vector(min.x,0,max.z)):ToScreen()
        pos=pos:ToScreen()
        local h,w=pos.y-pos2.y,(pos.y-pos2.y)/2
        if lv.cfg.Name then
            draw.SimpleTextOutlined(a:Nick(),"default",pos.x,pos2.y-2,cw,TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM,1,color_black)
        end
        if lv.cfg.Rank then
            draw.SimpleTextOutlined(a:GetUserGroup(),"default",pos.x,pos2.y-10,cw,TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM,1,color_black)
        end
        if lv.cfg.Wep then
            local z=a:GetActiveWeapon()
            if IsValid(z) then
                draw.SimpleTextOutlined(z:GetPrintName():lower(),"default",pos.x,pos.y+5,cw,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER,1,color_black)
            end
        end
        if lv.cfg.Role then
            local role,clr=select(2,v1(a)),select(3,v1(a))
            draw.SimpleTextOutlined(role,"default",pos.x,pos.y+(lv.cfg.Wep and 16 or 5),clr,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER,1,color_black)
        end
        if lv.cfg.HP then
            local hp=math.Clamp(a:Health(),0,100)
            local hh=h/100*hp
            local clr=HSVToColor(hp/100*120,1,1)
            local x=pos.x-w/2-5
            surface.SetDrawColor(20,20,20)
            surface.DrawRect(x,pos2.y-1,w/w+2,h+2)
            surface.SetDrawColor(clr)
            surface.DrawRect(x+1,pos.y-(a:Health()>100 and h or hh),w/w,(a:Health()>100 and h or hh))
        end
        if lv.cfg.Box then
            local clr=select(3,v1(a))
            surface.SetDrawColor(clr)
            surface.DrawOutlinedRect(pos.x-w/2,pos2.y,w,h)
            surface.SetDrawColor(0,0,0)
            surface.DrawOutlinedRect(pos.x-w/2-1,pos2.y-1,w+2,h+2)
            surface.DrawOutlinedRect(pos.x-w/2+1,pos2.y+1,w-2,h-2)
        end
    end
end
hook.Add("DrawOverlay","Simple",v3)
