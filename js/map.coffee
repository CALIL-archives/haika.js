map = undefined
$(document).ready ->
  validateGeoJSON = (testJson, callback) ->
    $.ajax
      type: "POST"
      url: "/validate"
      dataType: "json"
      data: testJson
      contentType: "application/json"
      success: callback
      error: (jqXHR, textStatus, errorThrown) ->

    return
  showGeoJsonSample = (geojsonType) ->
    $("#geojson-input").val JSON.stringify(window[geojsonType], null, 4)
    return
  showDroppable = ->
    $("#geojson-input").addClass "drop-it"
    return
  hideDroppable = ->
    $("#geojson-input").removeClass "drop-it"
    return
  road_layer = new L.TileLayer("http://otile{s}.mqcdn.com/tiles/1.0.0/map/{z}/{x}/{y}.png",
    maxZoom: 18
    subdomains: [
      "1"
      "2"
      "3"
      "4"
    ]
    attribution: "Tiles Courtesy of <a href=\"http://www.mapquest.com/\" target=\"_blank\">MapQuest</a>. Map data (c) <a href=\"http://www.openstreetmap.org/\" target=\"_blank\">OpenStreetMap</a> contributors, CC-BY-SA."
  )
  satellite_layer = new L.TileLayer("http://otile{s}.mqcdn.com/tiles/1.0.0/sat/{z}/{x}/{y}.png",
    maxZoom: 18
    subdomains: [
      "1"
      "2"
      "3"
      "4"
    ]
    attribution: "Tiles Courtesy of <a href=\"http://www.mapquest.com/\" target=\"_blank\">MapQuest</a>."
  )
  map = new L.Map("map-container",
    center: new L.LatLng(37.92686760148135, -96.767578125)
    zoom: 4
    layers: [road_layer]
  )
  geojsonLayer = new L.GeoJSON(null,
    onEachFeature: (feature, layer) ->
      if feature.properties
        popupString = "<div class=\"popup\">"
        for k of feature.properties
          v = feature.properties[k]
          popupString += k + ": " + v + "<br />"
        popupString += "</div>"
        layer.bindPopup popupString,
          maxHeight: 200

      return
  )
  map.addLayer geojsonLayer
  L.control.layers(
    Road: road_layer
    Satellite: satellite_layer
  ,
    GeoJSON: geojsonLayer
  ).addTo map
  geojson = JSON.parse(localStorage.getItem('geojson'))
  setTimeout(->
    $("#geojson-input").val(JSON.stringify(geojson))
    $("#submit").trigger('click')
  , 1000)
  $("#submit").on "click", ->
    return  if $("#geojson-input").val().length < 1
    testJson = $("#geojson-input").val()
    geojsonLayer.clearLayers()  if $("#clear-current").attr("checked")
    geojsonLayer.addData JSON.parse($("#geojson-input").val())
    map.fitBounds geojsonLayer.getBounds()
    return
    validateGeoJSON testJson, (data) ->
      if data.status is "ok"
        geojsonLayer.clearLayers()  if $("#clear-current").attr("checked")
        geojsonLayer.addData JSON.parse($("#geojson-input").val())
        map.fitBounds geojsonLayer.getBounds()
      else if data.status is "error"
        $("#modal-message-body").html data.message
        $("#modal-message-header").html "Invalid GeoJSON"
        $("#modal-message").modal "show"
      else
        $("#modal-message-body").html "An unknown error occured on the server. No one has been notified. You figure it out."
        $("#modal-message-header").html "Invalid GeoJSON"
        $("#modal-message").modal "show"
      return

    return

  $("#clear").on "click", ->
    $("#geojson-input").val ""
    return

  $(".modal-close").on "click", (event) ->
    event.preventDefault()
    $("#" + $(this).attr("id").split("-close")[0]).modal "hide"
    return

  $("a[data-toggle=\"tab\"]").on "shown", (event) ->
    showGeoJsonSample $(event.target).attr("data-geojson-type")
    $("#submit").trigger "click"
    return

  if window.File and window.FileReader
    $("#geojson-input").on "dragenter", (event) ->
      showDroppable()
      event.preventDefault()
      return

    $("#geojson-input").on "dragleave", (event) ->
      hideDroppable()
      event.preventDefault()
      return

    $("#geojson-input").on "dragover", (event) ->
      event.preventDefault()
      return

    $("#geojson-input").on "drop", (event) ->
      event.preventDefault()
      hideDroppable()
      dt = event.originalEvent.dataTransfer
      files = dt.files
      types = dt.types
      if files
        file = files[0]
        if file.name.indexOf(".json") isnt -1 or file.name.indexOf(".geojson") isnt -1
          reader = new FileReader()
          reader.onload = ->
            $("#geojson-input").val reader.result
            return

          reader.readAsText file
      return

  showGeoJsonSample "Point"
  return
