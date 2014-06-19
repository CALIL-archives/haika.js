center = ol.proj.transform([ 136.9637921, 35.1550234 ], "EPSG:4326", "EPSG:3857")
map = new ol.Map(
  target: "map"
  ol3Logo: false
  layers: [new ol.layer.Tile(source: new ol.source.OSM())]
  view: new ol.View2D(
    center: center
    zoom: 2
    maxZoom: 5
    maxResolution: 1
  )
)
featureOverlay = new ol.FeatureOverlay({
  style: new ol.style.Style({
    fill: new ol.style.Fill({
      color: 'rgba(255, 255, 255, 0.2)'
    }),
    stroke: new ol.style.Stroke({
      color: '#ffcc33',
      width: 2
    }),
    image: new ol.style.Circle({
      radius: 7,
      stroke: new ol.style.Stroke({
        color: '#ffffff',
        width: 2
      }),
      fill: new ol.style.Fill({
        color: '#0077FF'
      })
    })
  })
})
featureOverlay.addFeature(new ol.Feature(new ol.geom.Point(center)))

featureOverlay.setMap(map);
draw = new ol.interaction.Draw({features: featureOverlay.getFeatures(), type: "Point"})
modify = new ol.interaction.Modify({
  features: featureOverlay.getFeatures(),
  deleteCondition: (event) =>
    return ol.events.condition.shiftKeyOnly(event) &&
      ol.events.condition.singleClick(event);
})
map.addInteraction(modify);
map.addInteraction(new ol.interaction.DragRotateAndZoom())
map.addInteraction(draw);
map.addControl(new ol.control.ZoomSlider())
map.addControl(new ol.control.ScaleLine())