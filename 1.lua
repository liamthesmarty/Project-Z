local x=LocalPlayer()
local b={}
b.cfg={d=3500}
local s=false
local u=vgui.GetWorldPanel
local function r()
if s then return end
s=true
render.Clear(0,0,0,255,true,true)
render.RenderView({
origin=x:EyePos(),
angles=x:EyeAngles(),
x=0,
y=0;
w=ScrW(),
h=ScrH(),
dopostprocess=true;
drawhud=true;
drawmonitors=true;
drawviewmodel=true
})
local m=u()
if IsValid(m) then m:SetPaintedManually(true) end
timer.Simple(5, function()
u():SetPaintedManually(false)
s=false
end)
end
render.Capture = function(m)
r()
local S=render.Capture(m)
return S
end
b.frame=vgui.CreateX("EditablePanel")
local gh={"box","name","hp","wep","role","rank"}
do
local F=b.frame
F:SetSize(150,150)
F:SetPos(100,100)
F:MakePopup()
function F:Paint(w,h)surface.SetDrawColor(30,30,30)surface.DrawRect(0,0,w,h)end
for i,key in ipairs(gh)do
local chk=vgui.Create("DCheckBoxLabel",F)
chk:SetPos(10,10+(i-1)*20)
chk:SetText(key)
chk:SetValue(b.cfg[key])
chk:SizeToContents()
function chk:OnChange(val)b.cfg[key]=val end
function chk.Button:Paint(w,h)
surface.SetDrawColor(12,12,12)
surface.DrawOutlinedRect(0,0,w,h,1)
surface.SetDrawColor(21,21,21)
surface.DrawRect(0,0,w,h)
if self:GetChecked()then surface.SetDrawColor(99,99,99)surface.DrawRect(3,3,w-6,h-6)end
end
end
end
local function k()
if input.IsKeyDown(74)and not kd then
if IsValid(b.frame)then b.frame:SetVisible(not b.frame:IsVisible())end
end
kd=input.IsKeyDown(74)
if input.IsKeyDown(73)and not del then
if IsValid(b.frame)then b.frame:Remove()end
hook.Remove("HUDPaint","DrawRecordingIcon")
hook.Remove("Think","DecorProps")
end
del=input.IsKeyDown(73)
end
hook.Add("Think","DecorProps",k)
local function u()
local ply=player.GetAll()
for i=1,#ply do
local a=ply[i]
if a==x or not a:Alive()or x:GetPos():DistToSqr(a:GetPos())>b.cfg.d^2 then continue end
surface.SetAlphaMultiplier(a:IsDormant()and 0.4 or 1)
local pos=a:GetPos()
local min,max=a:OBBMins(),a:OBBMaxs()
local pos2=(pos+Vector(min.x,0,max.z)):ToScreen()
pos=pos:ToScreen()
local h,w=pos.y-pos2.y,(pos.y-pos2.y)/2
if b.cfg.name then draw.SimpleTextOutlined(a:Nick(),"default",pos.x,pos2.y-2,color_white,TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM,1,color_black)end
if b.cfg.rank then draw.SimpleTextOutlined(a:GetUserGroup(),"default",pos.x,pos2.y-10,color_white,TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM,1,color_black)end
if b.cfg.wep then
local z=a:GetActiveWeapon()
if IsValid(z)then draw.SimpleTextOutlined(z:GetPrintName(),"default",pos.x,pos.y+5,color_white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER,1,color_black)end
end
if b.cfg.role then draw.SimpleTextOutlined(team.GetName(a:Team()),"default",pos.x,pos.y+(b.cfg.wep and 16 or 5),color_white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER,1,color_black)end
if b.cfg.hp then
local hp=math.Clamp(a:Health(),0,100)
local hh=h/100*hp
local x=pos.x-w/2-5
surface.SetDrawColor(20,20,20)
surface.DrawRect(x,pos2.y-1,w/w+2,h+2)
surface.SetDrawColor(HSVToColor(hp/100*120,1,1))
surface.DrawRect(x+1,pos.y-(a:Health()>100 and h or hh),w/w,(a:Health()>100 and h or hh))
end
if b.cfg.box then
surface.SetDrawColor(team.GetColor(a:Team()))
surface.DrawOutlinedRect(pos.x-w/2,pos2.y,w,h)
surface.SetDrawColor(0,0,0)
surface.DrawOutlinedRect(pos.x-w/2-1,pos2.y-1,w+2,h+2)
surface.DrawOutlinedRect(pos.x-w/2+1,pos2.y+1,w-2,h-2)
end
end
end
hook.Add("HUDPaint","DrawRecordingIcon",u)
