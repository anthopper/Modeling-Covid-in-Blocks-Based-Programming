globals [time day]
breed [RiverVolumes RiverVolume]                        ;; ceate a breed to represent river volumes
breed [WaterVolumes WaterVolume]              ;; ceate a breed to represent irrigation volumes
breed [StorageVolumes StorageVolume]                    ;; ceate a breed to represent storage volumes
breed [Crops Crop]
patches-own[CurrentStorage QgateMaxR QgateMaxR1 QgateMaxL QgateMaxL1]

to setup
  clear-all
  reset-ticks
end

to go
  set time ticks mod 24                                                                  ;; there are 24 ticks per day, one tick is equal to 1 hour
  set day (floor (ticks / 24)) mod 7 + 1                                                 ;; day range from 1 to 7, means Monday to Sunday
  tick

 if day > 0 and day < 30 and time > 1
  [
    FirstIrrigation
    DeathOfFirstWaterVolumes
    OutFlow-1
  ]

  if day >= 31 and day < 60 and time > 1
  [
    SecondIrrigation
    DeathOfSecondWaterVolumes
    OutFlow-2
  ]
end

to FirstIrrigation                                                                             ;; means flow the water to canals
  ifelse [CurrentStorage] of patch 35 15 < FirstStorage
  [
    move-to-right-canal1-1
    RGateCapacity-1
    RGateFlow1-1
    RFieldStorage-1                                                                        ;; the storage of the field means the irrigation volume in the field
    RFieldStorageOverFlow-1                                                                ;; the storage over flow means the water in the field is more than the irrigation demand
  ]
  [
    ifelse [CurrentStorage] of patch 1 15 < FirstStorage
    [
      move-to-left-canal1-1
      LGateCapacity-1
      LGateFlow1-1
      LFieldStorage-1
      LFieldStorageOverFlow-1
    ]
    [
      ifelse [CurrentStorage] of patch 35 13 < FirstStorage
      [
        move-to-right-canal2-1
        RGateCapacity-1
        RGateFlow2-1
        RFieldStorage-1
        RFieldStorageOverFlow-1
     ]
     [
        ifelse [CurrentStorage] of patch 1 13 < FirstStorage
        [
          move-to-left-canal2-1
          LGateCapacity-1
          LGateFlow2-1
          LFieldStorage-1
          LFieldStorageOverFlow-1
        ]
        [
          ask patches with [pycor = 0]
          [
            if any? RiverVolumes-here
            [
               ask RiverVolumes [die]
            ]

           ]
         ]
       ]
     ]
   ]
end

to move-to-right-canal1-1
  ask patches with [pcolor = 95.1]
  [
    if pxcor = 18 and pycor = 14
    [
      ask n-of QgateMaxFixed1 RiverVolumes-here
      [
        lt 90
        fd 1
      ]
    ]
  ]
end

to RGateCapacity-1
  ask patches with [pcolor = 48.8]                                                      ;; gates at the right side of the river
  [
    ifelse pxcor = 19
    [
      set QgateMaxR1 QgateMaxFixed1                                                     ;; set the capacity of the first right gate is QgateMaxFixed1
    ]
    [
      set QgateMaxR QgateMaxFixed
    ]
  ]
end

to RGateFlow1-1
  ask patches with [pcolor = 48.8 and pycor = 14]                               ;; gates at the right side of the river
  [
    ifelse pxcor = 19
    [
      ask n-of QgateMaxFixed1 RiverVolumes-here [fd 1]
    ]
    [
      ifelse CurrentStorage < FirstStorage
      [
        ifelse (count RiverVolumes-here - QgateMaxR) > 0
        [
          ask n-of QgateMaxFixed RiverVolumes-here [lt 90]
        ]
        [
          ask n-of (count RiverVolumes-here) RiverVolumes-here [lt 90]
        ]
      ]
      [
      ]
    ]
  ]
end

to RFieldStorage-1
  ask patches with [pcolor = 64.2]                                     ;; ask the fields at the right side of the river
  [
    set CurrentStorage (CurrentStorage + count RiverVolumes-here)
    sprout-WaterVolumes (count RiverVolumes-here)
    ask WaterVolumes-here
    [
      set color 97
      set size 0.8
      set heading 0
    ]
    ask RiverVolumes-here [die]
  ]
end

to RFieldStorageOverFlow-1
  ask patches with [pcolor = 64.2]                                   ;; ask the one of the fields which used to store the irrigation water
  [
    if CurrentStorage > FirstStorage                                                       ;; if the current storage exceeds the maximum storage
    [
      ask n-of (CurrentStorage - FirstStorage) WaterVolumes-here [die]                ;; ask the extra storage volumes to die (so they go out the system)
      set CurrentStorage FirstStorage                                                      ;; set current storage to the FirsIrrigationDemand
    ]
  ]
end

to move-to-left-canal1-1
  ask patches with [pcolor = 95.1]
  [
    if pxcor = 18 and pycor = 14
    [
        ask n-of QgateMaxFixed1 RiverVolumes-here
        [
          rt 90
          fd 1
        ]
    ]
  ]
end

to LGateCapacity-1
  ask patches with [ pcolor = 47.4]                                                     ;; gates at the left side of the river
  [
    ifelse pxcor = 17
    [
      set QgateMaxL1 QgateMaxFixed1                                                     ;; set the capacity of the first right gate is QgateMaxFixed1
    ]
    [
      set QgateMaxL QgateMaxFixed
    ]
  ]
end

to LGateFlow1-1
  ask patches with [pcolor = 47.4 and pycor = 14]                               ;; gates at the left side of the river
  [
    ifelse pxcor = 17
    [
      ask n-of QgateMaxFixed1 RiverVolumes-here [fd 1]
    ]
    [
      ifelse CurrentStorage < FirstStorage
      [
        ifelse (count RiverVolumes-here - QgateMaxL) > 0
        [
          ask n-of QgateMaxFixed RiverVolumes-here [rt 90]
        ]
        [
          ask n-of (count RiverVolumes-here) RiverVolumes-here [rt 90]
        ]
      ]
      [
      ]
    ]
  ]
end

to LFieldStorage-1
  ask patches with [pcolor = 64.2]                                     ;; ask the fields at the right side of the river
  [
    set CurrentStorage (CurrentStorage + count RiverVolumes-here)
    sprout-WaterVolumes (count RiverVolumes-here)
    ask WaterVolumes-here
    [
      set color 97
      set size 0.8
      set heading 0
    ]
    ask RiverVolumes-here [die]
  ]
end

to LFieldStorageOverFlow-1
  ask patches with [pcolor = 64.2]                                   ;; ask the one of the fields which used to store the irrigation water
  [
    if CurrentStorage > FirstStorage                                                       ;; if the current storage exceeds the maximum storage
    [
      ask n-of (CurrentStorage - FirstStorage) WaterVolumes-here [die]                ;; ask the extra storage volumes to die (so they go out the system)
      set CurrentStorage FirstStorage                                                      ;; set current storage to the FirsIrrigationDemand
    ]
  ]
end

to move-to-right-canal2-1
  ask patches with [pcolor = 95.1]
  [
    if pxcor = 18 and pycor = 12
    [
      ask n-of QgateMaxFixed1 RiverVolumes-here
      [
        lt 90
        fd 1
      ]
    ]
  ]
end

to RGateFlow2-1
  ask patches with [pcolor = 48.8 and pycor = 12]                               ;; gates at the right side of the river
  [
    ifelse pxcor = 19
    [
      ask n-of QgateMaxFixed1 RiverVolumes-here [fd 1]
    ]
    [
      ifelse CurrentStorage < FirstStorage
      [
        ifelse (count RiverVolumes-here - QgateMaxR) > 0
        [
          ask n-of QgateMaxFixed RiverVolumes-here [lt 90]
        ]
        [
          ask n-of (count RiverVolumes-here) RiverVolumes-here [lt 90]
        ]
      ]
      [
      ]
    ]
  ]
end

to move-to-left-canal2-1
  ask patches with [pcolor = 95.1]
  [
    if pxcor = 18 and pycor = 12
    [
        ask n-of QgateMaxFixed1 RiverVolumes-here
        [
          rt 90
          fd 1
        ]
    ]
  ]
end

to LGateFlow2-1
  ask patches with [pcolor = 47.4 and pycor = 12]                               ;; gates at the left side of the river
  [
    ifelse pxcor = 17
    [
      ask n-of QgateMaxFixed1 RiverVolumes-here [fd 1]
    ]
    [
      ifelse CurrentStorage < FirstStorage
      [
        ifelse (count RiverVolumes-here - QgateMaxL) > 0
        [
          ask n-of QgateMaxFixed RiverVolumes-here [rt 90]
        ]
        [
          ask n-of (count RiverVolumes-here) RiverVolumes-here [rt 90]
        ]
      ]
      [
      ]
    ]
  ]
end

to RCropGrowth-1
  ask patches with [pcolor = 22.6]
  [
    if pxcor > 20 and ([CurrentStorage] of patch (pxcor - 1) pycor) = FirstStorage
    [
      sprout-Crops 1
      [
        set shape "plant"
        set size 0.1
        set color green
      ]
    ]
  ]
end

to LCropGrowth-1
  ask patches with [pcolor = 22.6]
  [
    if pxcor < 16 and ([CurrentStorage] of patch (pxcor + 1) pycor) = FirstStorage
    [
      sprout-Crops 1
      [
        set shape "plant"
        set size 0.1
        set color green
      ]
    ]
  ]
end

to DeathOfFirstWaterVolumes
  ask patches with [pcolor = 64.2 and pxcor > 20 and pycor = 15]
  [
    if any? Crops-on patch 36 15
    [
      ask WaterVolumes-here [die]
    ]
  ]

  ask patches with [pcolor = 64.2 and pxcor < 16  and pycor = 15]
  [
    if any? Crops-on patch 0 15
    [
      ask WaterVolumes-here [die]
    ]
  ]

  ask patches with [pcolor = 64.2 and pxcor > 20 and pycor = 13]
  [
    if any? Crops-on patch 36 13
    [
      ask WaterVolumes-here [die]
    ]
  ]

  ask patches with [pcolor = 64.2 and pxcor < 16  and pycor = 13]
  [
    if any? Crops-on patch 0 13
    [
      ask WaterVolumes-here [die]
    ]
  ]
end

to OutFlow-1
  ask patches with [pxcor = 0 and pxcor = 36 and pycor = 0]
  [
    if [CurrentStorage] of patch 1 1 = FirstStorage
    [
      ask RiverVolumes-here [die]
    ]
  ]
end

to SecondIrrigation                                                                             ;; means flow the water to canals
  ifelse [CurrentStorage] of patch 35 15 < SecondStorage
  [
    move-to-right-canal1-2
    RGateCapacity-2
    RGateFlow1-2
    RFieldStorage-2                                                                        ;; the storage of the field means the irrigation volume in the field
    RFieldStorageOverFlow-2                                                                ;; the storage over flow means the water in the field is more than the irrigation demand
  ]
  [
    ifelse [CurrentStorage] of patch 1 15 < SecondStorage
    [
      move-to-left-canal1-2
      LGateCapacity-2
      LGateFlow1-2
      LFieldStorage-2
      LFieldStorageOverFlow-2
    ]
    [
      ifelse [CurrentStorage] of patch 35 13 < SecondStorage
      [
        move-to-right-canal2-2
        RGateCapacity-2
        RGateFlow2-2
        RFieldStorage-2
        RFieldStorageOverFlow-2
     ]
     [
        ifelse [CurrentStorage] of patch 1 13 < SecondStorage
        [
          move-to-left-canal2-2
          LGateCapacity-2
          LGateFlow2-2
          LFieldStorage-2
          LFieldStorageOverFlow-2
        ]
        [
          ask patches with [pycor = 0]
          [
            if any? RiverVolumes-here
            [
              ask RiverVolumes [die]
            ]
          ]
        ]
      ]
    ]
  ]
end

to move-to-right-canal1-2
  ask patches with [pcolor = 95.1]
  [
    if pxcor = 18 and pycor = 14
    [
      ask n-of QgateMaxFixed1 RiverVolumes-here
      [
        lt 90
        fd 1
      ]
    ]
  ]
end

to RGateCapacity-2
  ask patches with [pcolor = 48.8]                                                      ;; gates at the right side of the river
  [
    ifelse pxcor = 19
    [
      set QgateMaxR1 QgateMaxFixed1                                                     ;; set the capacity of the first right gate is QgateMaxFixed1
    ]
    [
      set QgateMaxR QgateMaxFixed
    ]
  ]
end

to RGateFlow1-2
  ask patches with [pcolor = 48.8 and pycor = 14]                               ;; gates at the right side of the river
  [
    ifelse pxcor = 19
    [
      ask n-of QgateMaxFixed1 RiverVolumes-here [fd 1]
    ]
    [
      ifelse CurrentStorage < SecondStorage
      [
        ifelse (count RiverVolumes-here - QgateMaxR) > 0
        [
          ask n-of QgateMaxFixed RiverVolumes-here [lt 90]
        ]
        [
          ask n-of (count RiverVolumes-here) RiverVolumes-here [lt 90]
        ]
      ]
      [
      ]
    ]
  ]
end

to RFieldStorage-2
  ask patches with [pcolor = 64.2]                                     ;; ask the fields at the right side of the river
  [
    set CurrentStorage (CurrentStorage + count RiverVolumes-here)
    sprout-WaterVolumes (count RiverVolumes-here)
    ask WaterVolumes-here
    [
      set color 97
      set size 0.8
      set heading 0
    ]
    ask RiverVolumes-here [die]
  ]
end

to RFieldStorageOverFlow-2
  ask patches with [pcolor = 64.2]                                   ;; ask the one of the fields which used to store the irrigation water
  [
    if CurrentStorage > SecondStorage                                                       ;; if the current storage exceeds the maximum storage
    [
      ask n-of (CurrentStorage - SecondStorage) WaterVolumes-here [die]                ;; ask the extra storage volumes to die (so they go out the system)
      set CurrentStorage SecondStorage                                                      ;; set current storage to the FirsIrrigationDemand
    ]
  ]
end

to move-to-left-canal1-2
  ask patches with [pcolor = 95.1]
  [
    if pxcor = 18 and pycor = 14
    [
        ask n-of QgateMaxFixed1 RiverVolumes-here
        [
          rt 90
          fd 1
        ]
    ]
  ]
end

to LGateCapacity-2
  ask patches with [ pcolor = 47.4]                                                     ;; gates at the left side of the river
  [
    ifelse pxcor = 17
    [
      set QgateMaxL1 QgateMaxFixed1                                                     ;; set the capacity of the first right gate is QgateMaxFixed1
    ]
    [
      set QgateMaxL QgateMaxFixed
    ]
  ]
end

to LGateFlow1-2
  ask patches with [pcolor = 47.4 and pycor = 14]                               ;; gates at the left side of the river
  [
    ifelse pxcor = 17
    [
      ask n-of QgateMaxFixed1 RiverVolumes-here [fd 1]
    ]
    [
      ifelse CurrentStorage < SecondStorage
      [
        ifelse (count RiverVolumes-here - QgateMaxL) > 0
        [
          ask n-of QgateMaxFixed RiverVolumes-here [rt 90]
        ]
        [
          ask n-of (count RiverVolumes-here) RiverVolumes-here [rt 90]
        ]
      ]
      [
      ]
    ]
  ]
end

to LFieldStorage-2
  ask patches with [pcolor = 64.2]                                     ;; ask the fields at the right side of the river
  [
    set CurrentStorage (CurrentStorage + count RiverVolumes-here)
    sprout-WaterVolumes (count RiverVolumes-here)
    ask WaterVolumes-here
    [
      set color 97
      set size 0.8
      set heading 0
    ]
    ask RiverVolumes-here [die]
  ]
end

to LFieldStorageOverFlow-2
  ask patches with [pcolor = 64.2]                                   ;; ask the one of the fields which used to store the irrigation water
  [
    if CurrentStorage > SecondStorage                                                       ;; if the current storage exceeds the maximum storage
    [
      ask n-of (CurrentStorage - SecondStorage) WaterVolumes-here [die]                ;; ask the extra storage volumes to die (so they go out the system)
      set CurrentStorage SecondStorage                                                      ;; set current storage to the FirsIrrigationDemand
    ]
  ]
end

to move-to-right-canal2-2
  ask patches with [pcolor = 95.1]
  [
    if pxcor = 18 and pycor = 12
    [
      ask n-of QgateMaxFixed1 RiverVolumes-here
      [
        lt 90
        fd 1
      ]
    ]
  ]
end

to RGateFlow2-2
  ask patches with [pcolor = 48.8 and pycor = 12]                               ;; gates at the right side of the river
  [
    ifelse pxcor = 19
    [
      ask n-of QgateMaxFixed1 RiverVolumes-here [fd 1]
    ]
    [
      ifelse CurrentStorage < SecondStorage
      [
        ifelse (count RiverVolumes-here - QgateMaxR) > 0
        [
          ask n-of QgateMaxFixed RiverVolumes-here [lt 90]
        ]
        [
          ask n-of (count RiverVolumes-here) RiverVolumes-here [lt 90]
        ]
      ]
      [
      ]
    ]
  ]
end

to move-to-left-canal2-2
  ask patches with [pcolor = 95.1]
  [
    if pxcor = 18 and pycor = 12
    [
        ask n-of QgateMaxFixed1 RiverVolumes-here
        [
          rt 90
          fd 1
        ]
    ]
  ]
end

to LGateFlow2-2
  ask patches with [pcolor = 47.4 and pycor = 12]                               ;; gates at the left side of the river
  [
    ifelse pxcor = 17
    [
      ask n-of QgateMaxFixed1 RiverVolumes-here [fd 1]
    ]
    [
      ifelse CurrentStorage < SecondStorage
      [
        ifelse (count RiverVolumes-here - QgateMaxL) > 0
        [
          ask n-of QgateMaxFixed RiverVolumes-here [rt 90]
        ]
        [
          ask n-of (count RiverVolumes-here) RiverVolumes-here [rt 90]
        ]
      ]
      [
      ]
    ]
  ]
end

to RCropGrowth-2
  ask patches with [pcolor = 22.6]
  [
    if pxcor > 20 and ([CurrentStorage] of patch (pxcor - 1) pycor) = FirstStorage
    [
      sprout-Crops 1
      [
        set shape "plant"
        set size 0.2
        set color green
      ]
    ]
  ]
end

to LCropGrowth-2
  ask patches with [pcolor = 22.6]
  [
    if pxcor < 16 and ([CurrentStorage] of patch (pxcor + 1) pycor) = FirstStorage
    [
      sprout-Crops 1
      [
        set shape "plant"
        set size 0.2
        set color green
      ]
    ]
  ]
end

to DeathOfSecondWaterVolumes
  ask patches with [pcolor = 64.2 and pxcor > 20 and pycor = 15]
  [
    if any? Crops-on patch 36 15
    [
      ask WaterVolumes-here [die]
    ]
  ]

  ask patches with [pcolor = 64.2 and pxcor < 16  and pycor = 15]
  [
    if any? Crops-on patch 0 15
    [
      ask WaterVolumes-here [die]
    ]
  ]

  ask patches with [pcolor = 64.2 and pxcor > 20 and pycor = 13]
  [
    if any? Crops-on patch 36 13
    [
      ask WaterVolumes-here [die]
    ]
  ]

  ask patches with [pcolor = 64.2 and pxcor < 16  and pycor = 13]
  [
    if any? Crops-on patch 0 13
    [
      ask WaterVolumes-here [die]
    ]
  ]
end

to OutFlow-2
  ask patches with [pxcor = 0 and pxcor = 36 and pycor = 0]
  [
    if [CurrentStorage] of patch 1 1 = SecondStorage
    [
      ask RiverVolumes-here [die]
    ]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
405
10
1523
499
-1
-1
30.0
1
10
1
1
1
0
0
0
1
0
36
0
15
0
0
1
ticks
30.0

BUTTON
15
88
78
121
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

INPUTBOX
5
11
160
71
SimulationDays
365.0
1
0
Number

SLIDER
2
204
174
237
Qin_average
Qin_average
10
1000
1000.0
10
1
NIL
HORIZONTAL

SLIDER
3
240
175
273
Qin_randomizer
Qin_randomizer
0
30
1.0
1
1
NIL
HORIZONTAL

BUTTON
15
128
78
161
NIL
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
2
279
174
312
QgateMaxFixed
QgateMaxFixed
0
10
10.0
1
1
NIL
HORIZONTAL

SLIDER
1
317
173
350
MaximumStorage
MaximumStorage
0
640
50.0
10
1
NIL
HORIZONTAL

INPUTBOX
173
12
392
72
DaysFromHarvestToNextSowing
0.0
1
0
Number

INPUTBOX
208
77
365
137
RandomSeed
18579.0
1
0
Number

SWITCH
230
142
333
175
Seed?
Seed?
0
1
-1000

PLOT
1933
10
2133
160
Barley of Farmer
Ticks
Amount
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"F1" 1.0 0 -16777216 true "" "plot [Barley] of patch 22 14"
"F2" 1.0 0 -7500403 true "" "plot [Barley] of patch 24 14"
"F3" 1.0 0 -2674135 true "" "plot [Barley] of patch 26 14"
"F4" 1.0 0 -955883 true "" "plot [Barley] of patch 28 14"
"F5" 1.0 0 -6459832 true "" "plot [Barley] of patch 30 14"
"F6" 1.0 0 -1184463 true "" "plot [Barley] of patch 32 14"
"F7" 1.0 0 -10899396 true "" "plot [Barley] of patch 34 14"
"F8" 1.0 0 -13840069 true "" "plot [Barley] of patch 36 14"

PLOT
1932
163
2132
313
Total Barley
Ticks
Amount
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot totalBarley"

PLOT
1932
319
2132
469
River Discharge
Ticks
Q(Units/tick)
0.0
10.0
0.0
200.0
true
false
"set-plot-y-range 0 ((ceiling ((Qin_average + Qin_randomizer) / 10 )) * 10 + 10)" ""
PENS
"default" 1.0 0 -2674135 true "" "plot [count turtles-here] of patch 18 14"
"pen-1" 1.0 0 -14070903 true "" "plot [count turtles-here] of patch 36 14"

BUTTON
93
87
156
120
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
91
138
148
183
day
floor (ticks / 24) + 1
17
1
11

MONITOR
152
138
209
183
time
ticks mod 24
17
1
11

SLIDER
197
215
369
248
FirstStorage
FirstStorage
0
100
60.0
10
1
NIL
HORIZONTAL

SLIDER
196
252
382
285
SecondStorage
SecondStorage
0
100
60.0
10
1
NIL
HORIZONTAL

SLIDER
0
361
172
394
QgateMaxFixed1
QgateMaxFixed1
0
100
80.0
10
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

drop
false
0
Circle -7500403 true true 73 133 152
Polygon -7500403 true true 219 181 205 152 185 120 174 95 163 64 156 37 149 7 147 166
Polygon -7500403 true true 79 182 95 152 115 120 126 95 137 64 144 37 150 6 154 165

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

person farmer
false
0
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -1 true false 60 195 90 210 114 154 120 195 180 195 187 157 210 210 240 195 195 90 165 90 150 105 150 150 135 90 105 90
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 79 172 94
Polygon -13345367 true false 120 90 120 180 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 180 90 172 89 165 135 135 135 127 90
Polygon -6459832 true false 116 4 113 21 71 33 71 40 109 48 117 34 144 27 180 26 188 36 224 23 222 14 178 16 167 0
Line -16777216 false 225 90 270 90
Line -16777216 false 225 15 225 90
Line -16777216 false 270 15 270 90
Line -16777216 false 247 15 247 90
Rectangle -6459832 true false 240 90 255 300

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
