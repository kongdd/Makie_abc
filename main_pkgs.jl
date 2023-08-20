using GLMakie
using JLD2
using Statistics
using Printf
using NaNStatistics


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
