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

surface.CreateFont("lv",{font="Calibri",size=14,weight=250,extended=true})

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

local function Slider(name,x,y,varName,min,max,default,parent,step)
    step=step or 1
    lv.cfg[varName]=math.Clamp(lv.cfg[varName]or default,min,max)
    local slider=vgui.Create("DPanel",parent)
    slider:SetPos(x,y)
    local w,h=70,11
    slider:SetSize(w,h)
    local lbl=vgui.Create("DLabel",parent)
    lbl:SetPos(x,y-15)
    lbl:SetText("")
    lbl:SizeToContents()
    function slider:Paint(w,h)
        draw.RoundedBox(6,0,h/3,w,h/3,color_black)
        local frac=(lv.cfg[varName]-min)/(max-min)
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
            lv.cfg[varName]=math.Clamp(stepval,min,max)
        end
    end
end

local function Checkbox(parent,name,key,x,y)
    local pan=vgui.Create("Panel",parent)
    pan:SetPos(x,y)
    pan:SetSize(12,12)
    local lbl=vgui.Create("DPanel",parent)
    lbl:SetPos(x+18,y)
    function lbl:Paint(w,h)
        surface.SetTextColor(color_white)
        surface.SetFont("lv")
        local textw,texth=surface.GetTextSize(name)
        self:SetSize(textw,texth)
        surface.SetTextPos(0,h/2-texth/1.6)
        surface.DrawText(name)
    end
    function pan:Paint(w,h)
        local v=lv.cfg[key]
        surface.SetDrawColor(12,12,12)
        surface.DrawOutlinedRect(0,0,w,h,1)
        surface.SetDrawColor(21,21,21)
        surface.DrawRect(0,0,w,h)
        if v then
            surface.SetDrawColor(99,99,99)
            surface.DrawRect(0,0,w,h)
        end
    end
    function pan:OnMousePressed()
        lv.cfg[key]=not lv.cfg[key]
    end
    return pan
end

do
    F=lv.frame
    F:SetFocusTopLevel(true)
    F:SetSize(ScrW()/8,ScrH()/4)
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
        surface.SetFont("lv")
        surface.SetTextColor(color_white)
        surface.SetTextPos(10,10)
        surface.DrawText("lv render")
    end
    function F:Think()
        local x,y=input.GetCursorPos()
        local mouseX,mouseY=math.Clamp(x,1,ScrW()-1),math.Clamp(y,1,ScrH()-1)
        if F.Dragging then
            F:SetPos(mouseX-F.Dragging[1],mouseY-F.Dragging[2])
        end
    end
    function F:OnMousePressed()
        local x,y=input.GetCursorPos()
        local screenX,screenY=self:LocalToScreen(0,0)
        local w,h=self:GetSize()
        if x>screenX+w-20 and y>screenY+h-20 then
            self.Resizing=true
            self:MouseCapture(true)
        elseif y<screenY+850 then
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
    Checkbox(lv.frame,"ESP","ESP",10,45)
    Checkbox(lv.frame,"Box","Box",10,65)
    Checkbox(lv.frame,"Name","Name",10,85)
    Checkbox(lv.frame,"Health","HP",10,105)
    Checkbox(lv.frame,"Weapon","Wep",10,125)
    Checkbox(lv.frame,"Role","Role",10,145)
    Checkbox(lv.frame,"Rank","Rank",10,165)
    Slider("",10,185,"Dist",500,10000,50,lv.frame)
end

local function v2()
    if input.IsKeyDown(74) and not kd then
        if IsValid(lv.frame) then
            lv.frame:SetVisible(not lv.frame:IsVisible())
        end
    end
    kd = input.IsKeyDown(74)
    if input.IsKeyDown(73) and not kd_del then
        if IsValid(lv.frame) then
            lv.frame:Remove()
        end
        hook.Remove("DrawOverlay","Simple")
        hook.Remove("Think","DecorProps")
    end
    kd_del = input.IsKeyDown(73)
end
hook.Add("Think","DecorProps",v2)

local function v3()
    local plys = player.GetAll()
    for i=1,#plys do
        local a=plys[i]
        if lv.cfg.ESP then
            if a==me or not a:Alive() or me:GetPos():DistToSqr(a:GetPos())>lv.cfg.Dist^2 then continue end
            surface.SetAlphaMultiplier(a:IsDormant() and 0.4 or 1)
            local pos=a:GetPos()
            local min,max=a:OBBMins(),a:OBBMaxs()
            local pos2=pos+Vector(min.x,0,max.z)
            pos=pos:ToScreen()
            pos2=pos2:ToScreen()
            local h=pos.y-pos2.y
            local w=h/2
            if lv.cfg.Name then
                draw.SimpleTextOutlined(a:Nick(),"lv",pos.x,pos2.y-2,color_white,TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM,1,Color(0,0,0))
            end
            if lv.cfg.Rank then
                draw.SimpleTextOutlined(a:GetUserGroup(),"lv",pos.x,pos2.y-10,color_white,TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM,1,Color(0,0,0))
            end
            if lv.cfg.Wep then
                local z=a:GetActiveWeapon()
                if IsValid(z) then
                    local gun=z:GetPrintName():lower()
                    draw.SimpleTextOutlined(gun,"lv",pos.x,pos.y+5,color_white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER,1,Color(0,0,0))
                end
            end
            if lv.cfg.Role then
                draw.SimpleTextOutlined((select(2,v1(a))),"lv",pos.x,pos.y+(lv.cfg.Wep and 16 or 5),select(3,v1(a)),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER,1,Color(0,0,0))
            end
            if lv.cfg.HP then
                local hp=math.Clamp(a:Health(),0,100)
                local clr=HSVToColor(hp/100*120,1,1)
                if a:Health()<=100 then
                    surface.SetDrawColor(Color(20,20,20))
                    surface.DrawRect(pos.x-w/2-5,pos2.y-1,w/w+2,h+2)
                    surface.SetDrawColor(clr)
                    surface.DrawRect(pos.x-w/2-4,pos.y-h/100*a:Health(),w/w,h/100*a:Health())
                else
                    surface.SetDrawColor(Color(20,20,20))
                    surface.DrawRect(pos.x-w/2-5,pos2.y-1,w/w+2,h+2)
                    surface.SetDrawColor(clr)
                    surface.DrawRect(pos.x-w/2-4,pos.y-h,w/w,h)
                end
            end
            if lv.cfg.Box then
                surface.SetDrawColor(select(3,v1(a)))
                surface.DrawOutlinedRect(pos.x-w/2,pos2.y,w,h)
                surface.SetDrawColor(0,0,0)
                surface.DrawOutlinedRect(pos.x-w/2-1,pos2.y-1,w+2,h+2,1)
                surface.DrawOutlinedRect(pos.x-w/2+1,pos2.y+1,w-2,h-2,1)
            end
        end
    end
end
hook.Add("DrawOverlay","Simple",v3)
