# SlateGeoFencingExample (installation)

1. In order to debug and run the application an AppID with Access WiFi Information capability is required, create a provisioning profile for it or just tick automatically codesign it.
2. Run 'pod install' in project directory using Terminal. 
3. Enable Always GPS location in order to fully utilize Consumer module.

# How To Use?

1. First, proceed as Consumer to proof that user are not in any geofenced area.
2. Proceed as Admin and add a radius outside your location (preferably while connected to a WiFi)
3. Proceed as Consumer to check whether you are covered within geofenced area via WiFi. (result : only connected via WiFi)
4. Turn off WiFi, and you will be out of the geofenced area.
5. Proceed as Admin and add a radius inside your location (preferably while connected to a WiFi).
6. Proceed as Consumer to check whether you are covered within geofenced area via WiFi. (result : connected via both)
7. Turn off WiFi, and you will be in the geofenced area via Geofencing only.

# Optional Steps

1. To convert image-config-source into iOS Assets follow : https://github.com/swiftcafex/ios-image-maker
   • brew install node
   • brew install imagemagick
   • npm install -g ios-image-maker
   • brew install GraphicsMagick
   • ios-image
