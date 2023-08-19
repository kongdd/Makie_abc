using GLMakie

r = LinRange(-1, 1, 200)
cube = [(x .^ 2 + y .^ 2 + z .^ 2) for x = r, y = r, z = r];

n = 200
arr = rand(n, n, 365);

begin
  fig = Figure(resolution = (1600, 800), fontsize = 12)
  ax1 = Axis3(fig[1, 1])
  ax2 = Axis3(fig[1, 2])

  # k = Observable{Int}(1) # slice of time
  # k = 1
  sl_x = Slider(fig[2, 1:2], range = 1:10, startvalue = 3)
  sl_z = Slider(fig[1, 3], range = 1:365, horizontal = false, startvalue = 6)

  k = lift(sl_z.value) do val
    ceil(Int, val)
  end

  mat = @lift arr_Tmax[:, :, $k]
  # mat = @lift($arr[:, :, k])

  contour!(ax1, arr, alpha = 0.5, z = (1, 366))
  contour!(ax2, mat, alpha = 0.5) # , transformation = (:xy, 10)
  # xmin, ymin, zmin = minimum(ax1.finallimits[])
  # xmax, ymax, zmax = maximum(ax1.finallimits[])
  fig
end

arr_Tmax = load("temp.jld2", "arr_Tmax")
arr = arr_Tmax;

# size(cube)

# using nctools
# f = "G:/Researches/CMIP6/CMIP6_ChinaHW_anomaly/HItasmax/historical/anomaly_HItasmax_movTRS_ACCESS-CM2.nc"
# nc_open(f)
# nc_info(f)

# using AbstractPlotting
# using AbstractPlotting.MakieLayout
# scene, layout = layoutscene(resolution = (1200, 900))

using JLD2

begin
  using nctools
  using nctools.Ipaper

  f = "/mnt/n/DATA/3h metrology data/Data_forcing_01dy_010deg/nc/merged/ITPCAS_CMFD_050deg/Tmax_ITPCAS-CMFD_V0106_B-01_01dy_050deg_1979-2018.nc"

  f = "n:/DATA/3h metrology data/Data_forcing_01dy_010deg/nc/merged/ITPCAS_CMFD_050deg/Tmax_ITPCAS-CMFD_V0106_B-01_01dy_050deg_1979-2018.nc"
  nc = nc_open(f)
  dates = nc_date(f)

  inds = @pipe Ipaper.year.(dates) |> findall(_ .== 2016)
  arr_Tmax = nc["temp"][:, :, inds]

  jldsave("temp.jld2"; arr_Tmax)
end
