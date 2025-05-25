local a=LocalPlayer()
local s=GetRenderTarget("g" .. os.time(),ScrW(),ScrH())
local function l(vOrigin,vAngle,vFOV)
local h={
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
drawhmodel=true
}
render.RenderView(h)
render.CopyTexture(nil, s)
cam.Start2D()
hook.Run("HUDPaintZ")
cam.End2D()
render.SetRenderTarget(s)
end
hook.Add("RenderScene","b", function(vOrigin,vAngle,vFOV)
l(vOrigin,vAngle,vFOV)
end)
hook.Add("ShutDown","n", function()
render.SetRenderTarget()
end)
local b={}
b.c={d=3000}
b.m=vgui.CreateX("EditablePanel")
local k={"box","nick","hp","wep","role"}
do
local l=b.m
l:SetSize(80,110)
l:SetPos(100,100)
function l:Paint(n,m)surface.SetDrawColor(30,30,30)surface.DrawRect(0,0,n,m)end
for p,r in ipairs(k)do
local t=vgui.Create("DCheckBoxLabel",l)
t:SetPos(10,10+(p-1)*20)
t:SetText(r)
t:SetValue(b.c[r])
t:SizeToContents()
function t:OnChange(u)b.c[r]=u end
function t.Button:Paint(n,m)
surface.SetDrawColor(12,12,12)
surface.DrawOutlinedRect(0,0,n,m,1)
surface.SetDrawColor(21,21,21)
surface.DrawRect(0,0,n,m)
if self:GetChecked()then surface.SetDrawColor(99,99,99)surface.DrawRect(3,3,n-6,m-6)end
end
end
end
local function v()
if input.IsKeyDown(4)and not w then
if IsValid(b.m)then b.m:SetVisible(not b.m:IsVisible())end
end
w=input.IsKeyDown(4)
if input.IsKeyDown(73)and not x then
if IsValid(b.m)then b.m:Remove()end
hook.Remove("DrawOverlay","b")
hook.Remove("Think","a")
hook.Remove("ShutDown","n")
hook.Remove("RenderScene","b")
end
x=input.IsKeyDown(73)
end
hook.Add("Think","a",v)
local function y()
local z=player.GetAll()
for i=1,#z do
local j=z[i]
if j==a or not j:Alive()or a:GetPos():DistToSqr(j:GetPos())>b.c.d^2 then continue end
surface.SetAlphaMultiplier(j:IsDormant()and 0.4 or 1)
local w=j:GetPos()
local u,v=j:OBBMins(),j:OBBMaxs()
local y=(w+Vector(u.x,0,v.z)):ToScreen()
w=w:ToScreen()
local h,n=w.y-y.y,(w.y-y.y)/1.8
if b.c.nick then draw.SimpleTextOutlined(j:Name(),"DefaultSmall",w.x,y.y-2,color_white,TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM,1,color_black)end
if b.c.wep then
local z=j:GetActiveWeapon()
if IsValid(z)then draw.SimpleTextOutlined(z:GetPrintName(),"DefaultSmall",w.x,w.y+5,color_white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER,1,color_black)end
end
if b.c.role then draw.SimpleTextOutlined(team.GetName(j:Team()),"DefaultSmall",w.x,w.y+(b.c.wep and 16 or 5),color_white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER,1,color_black)end
if b.c.hp then
local hp=math.Clamp(j:Health(),0,100)
local hh=h/100*hp
local x=w.x-n/2-4
surface.SetDrawColor(20,20,20)
surface.DrawRect(x,y.y-1,n/n+2,h+2)
surface.SetDrawColor(0,255,0)
surface.DrawRect(x+1,w.y-(j:Health()>100 and h or hh),n/n,(j:Health()>100 and h or hh))
end
if b.c.box then
surface.SetDrawColor(team.GetColor(j:Team()))
surface.DrawOutlinedRect(w.x-n/2,y.y,n,h)
surface.SetDrawColor(0,0,0)
surface.DrawOutlinedRect(w.x-n/2-1,y.y-1,n+2,h+2)
surface.DrawOutlinedRect(w.x-n/2+1,y.y+1,n-2,h-2)
end
end
end
hook.Add("DrawOverlay","b",y)
