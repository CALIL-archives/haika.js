onmessage = (e) ->

  convert = (data)->
      colors = []
      w = data.w
      h = data.h
      y = 0
      while y < h - 1
        x = 0
        while x < w - 1
          n = x * 4 + y * w * 4
          # RGB
          r = data.image[n]
          g = data.image[n + 1]
          b = data.image[n + 2]
          a = data.image[n + 3]
          if a!=0
            color = hex_color(r,g,b)
            colors.push
              color : color
              x     : x
              y     : y
          x++
        y++
        result = 
          status: "working"
          count: y
        postMessage(result)
      return colors
  hex_color = (r, g, b)->
    return '#' + [r,g,b].map((a)->
      return ("0" + parseInt(a).toString(16)).slice(-2)
    ).join('')

  #メイン処理	
  result =
    status: "end"
    result: convert(e.data)

  postMessage result
