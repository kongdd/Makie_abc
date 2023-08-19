using GLMakie
using JLD2
using Statistics

arr = load("temp.jld2", "arr_Tmax");
nlon, nlat, ntime = size(arr)
vol = replace(arr, missing => Inf) .- 273.15;
# vol = arr

cellsize = 0.5
lon = 70+cellsize/2:cellsize:140
lat = 15+cellsize/2:cellsize:55
time = 1:366

size(vol)

begin
  fig = Figure()
  ax = LScene(fig[1, 1], scenekw = (show_axis = false,))
  # ax.aspect = DataAspect()
  x = LinRange(0, π, length(lon))
  y = LinRange(0, 2π, length(lat))
  z = LinRange(0, 3π, length(time))
  x = 1:nlon
  y = 1:nlat
  z = 1:ntime
  # vol = [cos(X) * sin(Y) * sin(Z) for X ∈ x, Y ∈ y, Z ∈ z]
  # plt = volume!(ax, lon, lat, time, vol) #  

  lsgrid = labelslidergrid!(
    fig,
    ["yz plane - x axis", "xz plane - y axis", "xy plane - z axis"],
    [1:length(x), 1:length(y), 1:length(z)]
  )
  fig[1, 2] = lsgrid.layout

  ## Figure 1.1
  # connect sliders to `volumeslices` update methods
  sl_yz, sl_xz, sl_xy = lsgrid.sliders

  plt = volumeslices!(ax, x, y, z, vol,) #  
  set_close_to!(sl_yz, 0.5length(x))
  set_close_to!(sl_xz, 0.5length(y))
  set_close_to!(sl_xy, 0.5length(z))

  # plt = volumeslices!(ax, lon, lat, time, vol) #  
  # set_close_to!(sl_yz, 0.5mean(lon))
  # set_close_to!(sl_xz, 0.5mean(lat))
  # set_close_to!(sl_xy, 0.5mean(time))

  # This step is necessary,
  # update_slice(plt, sl_yz, sl_xz, sl_xy)
  on(sl_yz.value) do v
    plt[:update_yz][](v)
  end
  on(sl_xz.value) do v
    plt[:update_xz][](v)
  end
  on(sl_xy.value) do v
    plt[:update_xy][](v)
  end

  i = sl_yz.value
  j = sl_xz.value
  k = sl_xy.value

  colgap!(fig.layout, 0)
  rowgap!(fig.layout, 0)
  fig
end

begin
  mat_z = @lift vol[:, :, $k]
  ## Figure 1.2 
  # ax1 = Axis3(fig[1, 2])
  # lab = "yz: i = 25"
  ax_yz = Axis(fig[1, 2], title = @lift("yz刨面图: lon = $(lon[$i])"),
    xlabel = "Latitude", ylabel = "Doy")
  ax_xz = Axis(fig[2, 1], title = @lift("xz刨面图: lat = $(lat[$j])"),
    xlabel = "Longitude", ylabel = "Doy")
  ax_xy = Axis(fig[2, 2], title = @lift("xz刨面图: lat = $(time[$k])"),
    xlabel = "Latitude", ylabel = "Longitude")


  mat_yz = @lift vol[$i, :, :]
  mat_xz = @lift vol[:, $j, :]
  mat_xy = @lift vol[:, :, $k]

  # k = @lift($sl_yz.value)
  heatmap!(ax_yz, lat, time, mat_yz)
  heatmap!(ax_xz, lon, time, mat_xz)
  hm = heatmap!(ax_xy, lon, lat, mat_xy)

  Colorbar(fig[:, 0], hm, height = Relative(0.5))
  # cam3d!(ax.scene, projectiontype=Makie.Orthographic)
  fig
end

# i@lift "yz: i = $(i.value)"
function update_slice(plt, sl_yz::Slider, sl_xz::Slider, sl_xy::Slider)
  on(sl_yz.value) do v
    plt[:update_yz][](v)
  end

  on(sl_xz.value) do v
    plt[:update_xz][](v)
  end

  on(sl_xy.value) do v
    plt[:update_xy][](v)
  end
end
