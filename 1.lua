local x=LocalPlayer()
local cw=color_white
local cb=color_black
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
hook.Run("HUDPaintZ")
cam.End2D()
render.SetRenderTarget(tar)
end

hook.Add("RenderScene","RenderScene",function(vOrigin, vAngle, vFOV)
    v0(vOrigin, vAngle, vFOV)
end)

hook.Add("ShutDown","ShutDown",function()
    render.SetRenderTarget()
end)

lv.frame = vgui.CreateX("EditablePanel")

local function Slider(x,y,key,min,max,step)
    step=step or 1
    lv.cfg[key]=math.Clamp(lv.cfg[key]or min,min,max)
    local slider=vgui.Create("DPanel",lv.frame)
    slider:SetPos(x,y)
    local w,h=70,11
    slider:SetSize(w,h)
    function slider:Paint(w,h)
        draw.RoundedBox(6,0,h/3,w,h/3,cb)
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

local function Chkbox(key,y)
    local chk=vgui.Create("DCheckBoxLabel",lv.frame)
    chk:SetPos(10,y)
    chk:SetText(key)
    chk:SetValue(lv.cfg[key])
    chk:SizeToContents()
    function chk:OnChange(val)
        lv.cfg[key]=val
    end
    function chk.Button:Paint(w,h)
        surface.SetDrawColor(12,12,12)
        surface.DrawOutlinedRect(0,0,w,h,1)
        surface.SetDrawColor(21,21,21)
        surface.DrawRect(0,0,w,h)
        if self:GetChecked()then
            surface.SetDrawColor(99,99,99)
            surface.DrawRect(3,3,w-6,h-6)
        end
    end
    return chk
end

do
    F=lv.frame
    F:SetFocusTopLevel(true)
    F:SetSize(200,200)
    F:SetPos(100,100)
    F:MakePopup()
    function F:Paint(w,h)
        surface.SetDrawColor(30,30,30)
        surface.DrawRect(0,0,w,h)
    end
    Chkbox("Box",15)
    Chkbox("Name",35)
    Chkbox("HP",55)
    Chkbox("Wep",75)
    Chkbox("Role",95)
    Chkbox("Rank",115)
    Slider(10,135,"Dist",500,10000,0.1)
end
local function v1()
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
        hook.Remove("DrawOverlay","a")
        hook.Remove("Think","b")
    end
    del = input.IsKeyDown(73)
end
hook.Add("Think","b",v1)
local function v2()
    local plys=player.GetAll()
    for i=1,#plys do
        local a=plys[i]
        if a==x or not a:Alive() or x:GetPos():DistToSqr(a:GetPos())>lv.cfg.Dist^2 then continue end
        surface.SetAlphaMultiplier(a:IsDormant() and 0.4 or 1)
        local pos=a:GetPos()
        local min,max=a:OBBMins(),a:OBBMaxs()
        local pos2=(pos+Vector(min.x,0,max.z)):ToScreen()
        pos=pos:ToScreen()
        local h,w=pos.y-pos2.y,(pos.y-pos2.y)/2
        if lv.cfg.Name then
            draw.SimpleTextOutlined(a:Nick(),"default",pos.x,pos2.y-2,cw,TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM,1,cb)
        end
        if lv.cfg.Rank then
            draw.SimpleTextOutlined(a:GetUserGroup(),"default",pos.x,pos2.y-10,cw,TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM,1,cb)
        end
        if lv.cfg.Wep then
            local z=a:GetActiveWeapon()
            if IsValid(z) then
                draw.SimpleTextOutlined(z:GetPrintName(),"default",pos.x,pos.y+5,cw,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER,1,cb)
            end
        end
        if lv.cfg.Role then
            draw.SimpleTextOutlined(team.GetName(a:Team()),"default",pos.x,pos.y+(lv.cfg.Wep and 16 or 5),cw,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER,1,cb)
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
            surface.SetDrawColor(team.GetColor(a:Team()))
            surface.DrawOutlinedRect(pos.x-w/2,pos2.y,w,h)
            surface.SetDrawColor(0,0,0)
            surface.DrawOutlinedRect(pos.x-w/2-1,pos2.y-1,w+2,h+2)
            surface.DrawOutlinedRect(pos.x-w/2+1,pos2.y+1,w-2,h-2)
        end
    end
end
hook.Add("DrawOverlay","a",v2)
