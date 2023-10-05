include("main_pkgs.jl")
using DimensionalData

zs = getRegionalMean(vol)

dims = (X(lon), Y(lat), Ti(time))
ds = DimArray(vol, dims)

cellx = lon[2] - lon[1]
celly = lat[2] - lat[1]

## 01. 设置theme ---------------------------------------------------------------
font_size = 24
kw_axes = (xticklabelsize=font_size, yticklabelsize=font_size,
  xlabelsize=font_size, ylabelsize=font_size,
  xlabelfont=:bold, ylabelfont=:bold)
mytheme = Theme(fontsize=30, Axis=kw_axes)
set_theme!(mytheme)

## 02. 绘图 --------------------------------------------------------------------
fig = Figure(resolution=(1600, 1200), outer_padding=2) # figure_padding = 10

slon = Observable(100.0)
slat = Observable(30.0)

sg = SliderGrid(fig[1, 2], (label="time", range=time, startvalue=middle(time)))
stime = sg.sliders[1].value
ticks_time = 0:50:350
# stime = Observable(1)

ax_xz = Axis(fig[2, 1], title=@lift(@sprintf("XZ剖面图: lat = %.2f", $slat));
  ylabel="Longitude", xlabel="Doy", xticks=ticks_time)

ax_yz = Axis(fig[2, 2], title=@lift(@sprintf("YZ剖面图: lon = %.2f", $slon)),
  ylabel="Latitude", xlabel="Doy", xticks=ticks_time)

## 时间序列图
ax5 = Axis(fig[3, 1], title=@lift(@sprintf("XY剖面图: time = %d", $stime)), 
  xlabel="DOY", xticks=ticks_time)

plot_main = fig[3, 2]
ax_xy = Axis(plot_main, title=@lift(@sprintf("XY剖面图: time = %d", $stime)),
  yticks = 15:10:55,
  xlabel="Latitude", ylabel="Longitude")

mat_yz = @lift ds[X=Near($slon)].data
mat_xz = @lift ds[Y=Near($slat)].data
mat_z = @lift ds[Ti=Near($stime)].data

i = @lift findnear(lon, $slon)[2]
j = @lift findnear(lat, $slat)[2]
k = @lift findnear(time, $stime)[2]

str_pos = @lift @sprintf("Position: i=%d, j=%d", $i, $j)
label_pos = Label(fig[1, 1], str_pos, fontsize=30, tellwidth=false)

z = @lift ds[X=Near($slon), Y=Near($slat)].data
heatmap!(ax_xz, time, lon, mat_xz)

## yz图
heatmap!(ax_yz, time, lat, mat_yz)

## 正常的空间图
handle_hm = heatmap!(ax_xy, lon, lat, mat_z)
Colorbar(fig[:, 0], handle_hm, height=Relative(0.5))
vlines!(ax_xy, slon)
hlines!(ax_xy, slat)

# 时间序列图
plot!(ax5, time, zs, label="China")
lines!(ax5, time, z, label="Pixel", color=:blue)
vlines!(ax5, k) # , zs[$k]

colgap!(fig.layout, 0)
rowgap!(fig.layout, 0)

## events添加到这里
map_on_mouse(fig, handle_hm, slon, slat)
map_on_keyboard(fig, slon, slat, stime, cellx, celly)

fig
