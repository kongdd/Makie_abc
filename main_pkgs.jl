using GLMakie
using JLD2
using Statistics
using Printf
using NaNStatistics


function make_slider_3d(subfig, lon, lat, time)
  sg = SliderGrid(subfig,
    (label="lon", range=lon),
    (label="lat", range=lat),
    (label="time", range=time)
  )

  sl_yz, sl_xz, sl_xy = sg.sliders
  set_close_to!(sl_yz, middle(lon))
  set_close_to!(sl_xz, middle(lat))
  set_close_to!(sl_xy, middle(time))

  slon = sl_yz.value
  slat = sl_xz.value
  stime = sl_xy.value

  i = @lift findall(lon .== $slon)[1]
  j = @lift findall(lat .== $slat)[1]
  k = @lift findall(time .== $stime)[1]
  slon, slat, stime, i, j, k
end

## 另外一种方式




function update_slice(plt, sl_yz::Slider, sl_xz::Slider, sl_xy::Slider)
  on(sl_yz.value) do v
    # 这里需要一个判断下标的操作
    plt[:update_yz][](v)
  end
  on(sl_xz.value) do v
    plt[:update_xz][](v)
  end
  on(sl_xy.value) do v
    plt[:update_xy][](v)
  end
end



arr = load("temp.jld2", "arr_Tmax");
nlon, nlat, ntime = size(arr)
vol = replace(arr, missing => NaN32) .- 273.15;
size(vol)

x = 1:nlon
y = 1:nlat
z = 1:ntime

cellsize = 0.5
lon = 70+cellsize/2:cellsize:140
lat = 15+cellsize/2:cellsize:55
time = 1:366
