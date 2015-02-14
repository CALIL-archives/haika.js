log = (obj) ->
  try
    console.log obj


merge = (paths) ->
  cpr = new ClipperLib.Clipper()
  ClipperLib.JS.ScaleUpPaths subj_paths, scale
  ClipperLib.JS.ScaleUpPaths clip_paths, scale
  ClipperLib.JS.ScaleUpPaths new_paths, scale
  for path in paths
    cpr.AddPaths path, ClipperLib.PolyType.ptSubject, true # true means closed path
  solution_paths = new ClipperLib.Paths()
  succeeded = cpr.Execute(ClipperLib.ClipType.ctUnion, solution_paths, ClipperLib.PolyFillType.pftNonZero, ClipperLib.PolyFillType.pftNonZero)
  solution_paths

# Scale down coordinates and draw ...

# Converts Paths to SVG path string
# and scales down the coordinates
paths2string = (paths, scale) ->
  svgpath = ""
  i = undefined
  j = undefined
  scale = 1  unless scale
  i = 0
  while i < paths.length
    j = 0
    while j < paths[i].length
      unless j
        svgpath += "M"
      else
        svgpath += "L"
      svgpath += (paths[i][j].X / scale) + ", " + (paths[i][j].Y / scale)
      j++
    svgpath += "Z"
    i++
  svgpath = "M0,0"  if svgpath is ""
  svgpath
subj_paths = [[
  {
    X: 10
    Y: 10
  }
  {
    X: 110
    Y: 10
  }
  {
    X: 110
    Y: 110
  }
  {
    X: 10
    Y: 110
  }
]]
clip_paths = [[
  {
    X: 50
    Y: 50
  }
  {
    X: 150
    Y: 50
  }
  {
    X: 150
    Y: 150
  }
  {
    X: 50
    Y: 150
  }
]]
new_paths = [[
  {
    X: 0
    Y: 150
  }
  {
    X: 150
    Y: 150
  }
  {
    X: 150
    Y: 250
  }
  {
    X: 0
    Y: 250
  }
]]
scale = 100

geojson = JSON.parse(localStorage.getItem('geojson'))
log geojson
paths = []
if geojson and geojson.features.length>0
  for object in geojson.features
    if object.properties.type=='floor'
      path = []
      log object.geometry.coordinates[0]
      for geometry in object.geometry.coordinates[0]
        p = {
          X: geometry[0]*1000+4500
          Y: geometry[1]*1000+4500
        }
        path.push(p)
      paths.push([path])

log paths
log subj_paths
#solution_paths = merge([subj_paths, clip_paths, new_paths])
solution_paths = merge(paths)
console.log JSON.stringify(solution_paths)

coordinates = []
for path in solution_paths[0]
  coordinates.push [path.X, path.Y]
log coordinates

svg = "<svg style=\"background-color:#dddddd\" width=\"1600\" height=\"1600\">"
svg += "<path stroke=\"black\" fill=\"yellow\" stroke-width=\"2\" d=\"" + paths2string(solution_paths, scale) + "\"/>"
svg += "</svg>"
document.getElementById("svgcontainer").innerHTML = svg
paths = [[
  {
    X: 10
    Y: 10
  }
  {
    X: 110
    Y: 10
  }
  {
    X: 110
    Y: 110
  }
  {
    X: 10
    Y: 110
  }
]]
console.log JSON.stringify(paths)
ClipperLib.Clipper.ReversePaths paths
console.log JSON.stringify(paths)