using GLMakie
using JLD2
using Statistics
using Printf
using NaNStatistics


function findnear(values, x)
  _, i = findmin(abs.(values .- x))
  values[i], i
end

function make_slider_3d(subfig, lon, lat, time)
  sg = SliderGrid(subfig,
    (label="lon", range=lon, start=middle(lon)),
    (label="lat", range=lat, start=middle(lat)),
    (label="time", range=time, start=middle(time))
  )
  sl_yz, sl_xz, sl_xy = sg.sliders
  # set_close_to!(sl_yz, middle(lon))
  
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


function map_on_mouse(fig, handle_plot, slon, slat)
  on(events(fig).mousebutton, priority=2) do event
    if event.button == Mouse.left && event.action == Mouse.press
      plt, i = pick(fig)
      if plt == handle_plot
        pos = mouseposition(ax_xy)
        slon[] = pos[1]
        slat[] = pos[2]
      end
    end
    return Consume(false)
  end
end

function map_on_keyboard(fig, slon, slat, stime, cellx, celly)
  on(events(fig).keyboardbutton) do event
    if event.action == Keyboard.press || event.action == Keyboard.repeat
      if event.key == Keyboard.up
        slat[] += celly
      elseif event.key == Keyboard.down
        slat[] -= celly
      elseif event.key == Keyboard.right
        slon[] += cellx
      elseif event.key == Keyboard.left
        slon[] -= cellx
      elseif event.key == Keyboard.page_up
        stime[] += 1
      elseif event.key == Keyboard.page_down
        stime[] -= 1
      end
    end
    return Consume(false)
  end
end

function getRegionalMean(vol)
  map(k -> nanmean(vol[:, :, k]), axes(vol, 3))
end


## load data -------------------------------------------------------------------

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
