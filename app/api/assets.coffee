folders =
  js: '/public/js'
  css: '/public/css'

GetEnvPath = (type, pathBase)->
  getEnvPath = ->
    path = "#{folders[type]}/#{pathBase}"
    if window.env isnt 'dev' then path += '.min'
    return "#{path}.#{type}"

quaggaBaseName = 'quagga-0.10.2'
cropperBaseName = 'cropper-2.3.0'
leafletBaseName = 'leaflet-bundle-1.0.2'

module.exports =
  scripts:
    moment: (lang)-> "#{folders.js}/moment/#{lang}.js?DIGEST"
    # keep versions in sync with scripts/install_external_js_modules
    quagga: GetEnvPath 'js', quaggaBaseName
    cropper: GetEnvPath 'js', cropperBaseName
    leaflet: GetEnvPath 'js', leafletBaseName
  stylesheets:
    cropper: GetEnvPath 'css', cropperBaseName
    leaflet: GetEnvPath 'css', leafletBaseName
