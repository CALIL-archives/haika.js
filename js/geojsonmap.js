// Generated by CoffeeScript 1.7.1
var center, geojson, image, map, styleFunction, styles, vectorLayer, vectorSource;

image = new ol.style.Circle({
  radius: 5,
  fill: null,
  stroke: new ol.style.Stroke({
    color: "blue",
    width: 1
  })
});

styles = {
  Point: [
    new ol.style.Style({
      image: image
    })
  ],
  LineString: [
    new ol.style.Style({
      stroke: new ol.style.Stroke({
        color: "green",
        width: 1
      })
    })
  ],
  MultiLineString: [
    new ol.style.Style({
      stroke: new ol.style.Stroke({
        color: "green",
        width: 1
      })
    })
  ],
  MultiPoint: [
    new ol.style.Style({
      image: image
    })
  ],
  MultiPolygon: [
    new ol.style.Style({
      stroke: new ol.style.Stroke({
        color: "yellow",
        width: 1
      }),
      fill: new ol.style.Fill({
        color: "rgba(255, 255, 0, 0.1)"
      })
    })
  ],
  Polygon: [
    new ol.style.Style({
      stroke: new ol.style.Stroke({
        color: "red",
        lineDash: [4],
        width: 3
      }),
      fill: new ol.style.Fill({
        color: "rgba(255, 0, 0, 0.1)"
      })
    })
  ],
  GeometryCollection: [
    new ol.style.Style({
      stroke: new ol.style.Stroke({
        color: "magenta",
        width: 2
      }),
      fill: new ol.style.Fill({
        color: "magenta"
      }),
      image: new ol.style.Circle({
        radius: 10,
        fill: null,
        stroke: new ol.style.Stroke({
          color: "magenta"
        })
      })
    })
  ],
  Circle: [
    new ol.style.Style({
      stroke: new ol.style.Stroke({
        color: "red",
        width: 2
      }),
      fill: new ol.style.Fill({
        color: "rgba(255,0,0,0.2)"
      })
    })
  ]
};

styleFunction = function(feature, resolution) {
  return styles[feature.getGeometry().getType()];
};


/*
@type {olx.source.GeoJSONOptions}
 */

geojson = JSON.parse(localStorage.getItem('geojson'));

console.log(geojson);

console.log(localStorage.getItem('geojson'))

vectorSource = new ol.source.GeoJSON({
  object:geojson
});

var features = vectorSource.getFeatures();
console.log(features);

vectorLayer = new ol.layer.Vector({
  source: vectorSource,
  style: styleFunction
});

center = ol.proj.transform([136.963791, 35.155080], "EPSG:4326", "EPSG:3857");

map = new ol.Map({
  layers: [
    new ol.layer.Tile({
      source: new ol.source.OSM()
    }), vectorLayer
  ],
  target: "map",
  view: new ol.View2D({
    center: center,
    zoom: 2,
    projection: 'EPSG:4326'
  })
});

//# sourceMappingURL=geojsonmap.map
