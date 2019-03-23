//
//  GeofenceHardcodedData.swift
//  SlateGeoFencingExample
//
//  Created by BrandonWong on 22/03/2019.
//  Copyright © 2019 Silverlake Mobility Ecosystem Sdn Bhd. All rights reserved.
//

import Foundation

let geofenceJSONString = """
{
"locPointListBean": [{
"latitude": 3.16891,
"locDesc": "New Polygon",
"locName": "New Polygon",
"locPointID": 14,
"longitude": 101.647275,
"locationWifiInfo": {
"ssid": "PolygonSSID2"
},
"polygonLocPoint": [{
"latitude": 3.16891,
"longitude": 101.647275
},
{
"latitude": 3.162861,
"longitude": 101.636359
},
{
"latitude": 3.159328,
"longitude": 101.646375
},
{
"latitude": 3.167413,
"longitude": 101.652373
},
{
"latitude": 3.172263,
"longitude": 101.641037
}
],
"radius": 0,
"shapeFlagString": "P",
"startTime": "08:00"
},
{
"latitude": 3.143027,
"locDesc": "New Polygon 2",
"locName": "New Polygon 2",
"locPointID": 17,
"longitude": 101.649323,
"locationWifiInfo": {
"ssid": "PolygonSSID2"
},
"polygonLocPoint": [{
"latitude": 3.143027,
"longitude": 101.649323
},
{
"latitude": 3.142183,
"longitude": 101.652203
},
{
"latitude": 3.139119,
"longitude": 101.651704
},
{
"latitude": 3.139658,
"longitude": 101.648353
},
{
"latitude": 3.142337,
"longitude": 101.648839
}
],
"radius": 0,
"shapeFlagString": "P",
"startTime": "08:00"
},
{
"latitude": 3.145816,
"locDesc": "New Radius 3",
"locName": "New Radius 3",
"locPointID": 19,
"longitude": 101.64111,
"locationWifiInfo": {
"ssid": "PolygonSSID2"
},
"radius": 240,
"shapeFlagString": "R",
"startTime": "08:00"
}
]
}
"""
