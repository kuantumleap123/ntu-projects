breed [monomers mono]
breed [polymers poly]
breed [drugs1 drug1]
breed [drugs2 drug2]
breed [drugs3 drug3]

globals [ drugs ]

polymers-own [poly-size drug2-attached]

to setup
  print "Setting up model"
  clear-all
  setup-polymers
  setup-monomers
  setup-drugs

  reset-ticks

end

to setup-monomers
  create-monomers initial-monomer
  [
    setxy random-xcor random-ycor
    set shape "circle"
    set color blue
    set size 0.5
  ]

end

to setup-polymers
  create-polymers initial-polymer
  [
    setxy random-xcor random-ycor
    set shape "circle"
    set color red
    set poly-size poly-threshold-size
    set drug2-attached 0
    set label poly-size
  ]

end

to setup-drugs
  create-drugs1 drug1-dose
  [
    setxy random-xcor random-ycor
    set shape "circle"
    set color yellow
    set size 0.5

  ]

  create-drugs2 drug2-dose
  [
    setxy random-xcor random-ycor
    set shape "circle"
    set color cyan
    set size 0.5

  ]

  create-drugs3 drug3-dose
  [
    setxy random-xcor random-ycor
    set shape "circle"
    set color green
    set size 0.5

  ]

end


to go
  set-default-shape monomers "circle"
  set-default-shape polymers "circle"
  set drugs turtles with [ ( breed = drugs1 ) or ( breed = drugs2 ) or ( breed = drugs3 ) ]

  ask monomers
  [
    bounce
    mono-wander

    let r random-float 1          ;;roll die for mono death
    if r < mono-death-rate
    [ die ]

    mono-aggregate                ;;mono + mono/poly aggregation
  ]

  ask polymers
  [
    set label poly-size

    bounce
    poly-wander

    let r random-float 1            ;;roll die for poly death
    if r < poly-death-rate
    [ die ]

    poly-collide-bounce             ;;poly + poly collision bounce apart
    poly-try-split

    poly-drug-collide

  ]

  ask drugs
  [
    bounce
    mono-wander
    drug-collide-bounce

    ;let r random-float 1          ;;roll die for mono death
    ;if r < mono-death-rate
    ;[ die ]

  ]



  spawn-monomer                     ;;produce more mono

  if drug1-interval != 0
  [
    if ticks mod drug1-interval = 0
    [
      create-drugs1 drug1-dose
      [
        setxy random-xcor random-ycor
        set shape "circle"
        set color yellow
        set size 0.5

      ]
    ]
  ]

  if drug2-interval != 0
  [
    if ticks mod drug2-interval = 0
    [
      create-drugs2 drug2-dose
      [
        setxy random-xcor random-ycor
        set shape "circle"
        set color cyan
        set size 0.5

      ]
    ]
  ]

  if drug3-interval != 0
  [
    if ticks mod drug3-interval = 0
    [
      create-drugs3 drug3-dose
      [
        setxy random-xcor random-ycor
        set shape "circle"
        set color green
        set size 0.5

      ]
    ]
  ]

  tick

  if ticks = 100000
  [ stop ]
end

to bounce
  if abs pxcor = max-pxcor      ;;bounce off vertical wall
    [
      set heading (- heading)
    ]

    if abs pycor = max-pycor      ;;bounce off horizontal wall
    [
      set heading (180 - heading)
    ]
end

to mono-wander   ;; turtle procedure
  ;; the WIGGLE-ANGLE slider makes our path straight or wiggly
  rt random-float wiggle-angle - random-float wiggle-angle

  ;; move
  fd 1
end

to poly-wander   ;; turtle procedure
  ;; the WIGGLE-ANGLE slider makes our path straight or wiggly
  rt random-float wiggle-angle - random-float wiggle-angle

  ;; move

  let step-size 1 / sqrt(poly-size)
  fd step-size
end

to spawn-monomer
  let r random-float 1
  if r < spawn-rate
  [
    create-monomers 1
    [
      setxy random-xcor random-ycor
      set shape "circle"
      set color blue
      set size 0.5
    ]
  ]
end

to mono-aggregate                   ;;mono + mono
  let has-aggregate? false
  let mono-id who

  if any? drugs1 in-radius (size / 2)           ;;mono + drug1
  [
    ask one-of drugs1 in-radius (size / 2) [ die ]
    die
  ]

  if any? drugs2 in-radius (size / 2)
  [
    ask drugs2 in-radius (size / 2) [ set heading (180 + heading) ]
    set heading (180 + heading)
  ]

  if any? drugs3 in-radius (size / 2)
  [
    ask drugs3 in-radius (size / 2) [ set heading (180 + heading) ]
    set heading (180 + heading)
  ]

  if any? other monomers in-radius (size / 2)           ;;mono + mono
  [
    let r random-float 1
    ifelse r < slow-aggregate-rate
    [
      ask one-of other monomers in-radius (size / 2)
      [
        die
        ask other monomers in-radius (size / 2)
        [
          set heading (180 + heading)
        ]
      ]
      set breed polymers
      set color red
      set size 1
      set poly-size 2

    ]
    [
      set heading (180 + heading)
      ask other monomers in-radius (size / 2)
      [
        set heading (180 + heading)
      ]
    ]

    set has-aggregate? true
  ]


  if not has-aggregate? and any? other polymers in-radius (size / 2)       ;;mono + poly
  [
    let r random-float 1
    ask one-of other polymers in-radius (size / 2)
    [
      ifelse poly-size < poly-threshold-size
      [
        ifelse r < slow-aggregate-rate
        [
          ask turtle mono-id
          [ die ]
          set poly-size (poly-size + 1)

        ]
        [
          ask turtle mono-id
          [ set heading (180 + heading)]
        ]
      ]
      [
        ifelse r < fast-aggregate-rate
        [
          ask turtle mono-id
          [ die ]
          set poly-size (poly-size + 1)
        ]
        [
          ask turtle mono-id
          [ set heading (180 + heading)]
        ]
      ]
    ]
  ]
end

to poly-collide-bounce
  if any? other polymers in-radius (size / 2)
  [
    set heading (180 + heading)
    ask other polymers in-radius (size / 2)
    [ set heading (180 + heading) ]
  ]
end

to poly-drug-collide
  if breed = monomers [ stop ]
  if any? other drugs2 in-radius (size / 2)
  [
    if drug2-attached < drug2-cap
    [
      set drug2-attached ( drug2-attached + 1 )
      ask one-of drugs2 in-radius (size / 2) [ die ]
    ]
    ask drugs2 in-radius (size / 2) [ set heading (180 + heading) ]
  ]

  if any? other drugs3 in-radius (size / 2)
  [
    ask one-of drugs3 in-radius (size / 2) [ die ]
    do-split
    ask drugs3 in-radius (size / 2) [ set heading (180 + heading) ]
  ]
end

to drug-collide-bounce
  if any? other drugs in-radius (size / 2)
  [
    set heading (180 + heading)
    ask other drugs in-radius (size / 2)
    [ set heading (180 + heading) ]
  ]
end

to poly-try-split
  let r random-float 1
  ifelse poly-size < poly-threshold-size
  [
    if r < fast-split-rate
    [
      do-split

    ]

  ]
  [
    if r < slow-split-rate
    [
      do-split
    ]
  ]

end

to do-split
  let p random (poly-size - 1)
  set p (p + 1)
  ifelse p = 1 or p = poly-size - 1
  [
    hatch-monomers 1
    [
      set shape "circle"
      set color blue
      set size 0.5
      set label ""
      rt random 360
      jump 1
    ]
    ifelse poly-size = 2
    [
      set breed monomers
      set color blue
      set size 0.5
      set label ""
      rt random 360
      jump 1
    ]
    [
      set poly-size (poly-size - 1)
      set label poly-size
      let coin-toss random 2
      if drug2-attached = 2 [ set drug2-attached 1 ]
      if drug2-attached = 1 and coin-toss = 1 [ set drug2-attached 1 ]
    ]
  ]
  [
    let is-both-blocked? false
    let new-is-blocked? false

    if drug2-attached = 2
    [
      set drug2-attached 1
      set is-both-blocked? true
    ]

    let coin-toss random 2
    ifelse drug2-attached = 1 and coin-toss = 1
    [
      set drug2-attached 1
    ]
    [
      set drug2-attached 0
      set new-is-blocked? true
    ]

    hatch-polymers 1
    [
      set shape "circle"
      set color red
      set size 1
      set poly-size p
      set label poly-size
      ifelse is-both-blocked? or new-is-blocked?
      [ set drug2-attached 1 ]
      [ set drug2-attached 0 ]

      rt random 360
      jump 1.5

    ]

    set poly-size (poly-size - p)
    set label poly-size
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
401
10
835
445
-1
-1
12.93
1
10
1
1
1
0
0
0
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
21
15
121
48
Setup Model
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

SLIDER
20
55
192
88
initial-monomer
initial-monomer
0
100
5.0
1
1
NIL
HORIZONTAL

BUTTON
126
16
219
49
Run Model
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

SLIDER
196
55
368
88
initial-polymer
initial-polymer
0
100
3.0
1
1
NIL
HORIZONTAL

SLIDER
909
32
1081
65
wiggle-angle
wiggle-angle
0.0
360.0
50.0
1.0
1
degrees
HORIZONTAL

SLIDER
20
95
192
128
spawn-rate
spawn-rate
0.0
1.0
0.4777
0.0001
1
NIL
HORIZONTAL

SLIDER
197
95
369
128
mono-death-rate
mono-death-rate
0.0
1.0
1.0E-4
0.0001
1
NIL
HORIZONTAL

SLIDER
197
130
369
163
poly-death-rate
poly-death-rate
0.0
1.0
0.0
0.0001
1
NIL
HORIZONTAL

MONITOR
923
115
1041
160
Number of monomers
count monomers
0
1
11

MONITOR
1044
115
1156
160
Number of polymers
count polymers
0
1
11

PLOT
924
166
1124
316
Number of monomers
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count monomers"

PLOT
1127
165
1327
315
Number of polymers
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count polymers"

PLOT
925
319
1125
469
Polymer size distribution
size
NIL
0.0
50.0
0.0
100.0
false
false
"let y-max count polymers\nset y-max ceiling (1.5 * y-max)\n;;set-plot-y-range 0 max (list y-max 5)\nset-plot-pen-mode 1" "let y-max count polymers\nset y-max ceiling (1.5 * y-max)\n;;set-plot-y-range 0 max (list y-max 5)\nset-plot-y-range 0 300"
PENS
"default" 1.0 1 -16777216 true "" "histogram [ poly-size ] of polymers"

SLIDER
105
171
277
204
poly-threshold-size
poly-threshold-size
2
25
6.0
1
1
NIL
HORIZONTAL

SLIDER
20
209
192
242
slow-aggregate-rate
slow-aggregate-rate
0.0
1.0
0.2611
0.0001
1
NIL
HORIZONTAL

SLIDER
199
209
371
242
fast-aggregate-rate
fast-aggregate-rate
0.0
1.0
0.949
0.0001
1
NIL
HORIZONTAL

SLIDER
19
248
191
281
fast-split-rate
fast-split-rate
0.0
1.0
0.3822
0.0001
1
NIL
HORIZONTAL

SLIDER
199
250
371
283
slow-split-rate
slow-split-rate
0.0
1.0
0.0637
0.0001
1
NIL
HORIZONTAL

MONITOR
1157
116
1300
161
No. of infectious polymers
count polymers with [ poly-size >= poly-threshold-size ]
17
1
11

PLOT
1129
319
1329
469
No. of infectious polymers
NIL
NIL
0.0
10.0
0.0
1000.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count polymers with [ poly-size >= poly-threshold-size ]"

SLIDER
226
579
398
612
drug1-dose
drug1-dose
0
100
0.0
1
1
NIL
HORIZONTAL

SLIDER
226
620
398
653
drug2-dose
drug2-dose
0
100
0.0
1
1
NIL
HORIZONTAL

SLIDER
226
660
398
693
drug3-dose
drug3-dose
0
100
0.0
1
1
NIL
HORIZONTAL

SLIDER
404
580
576
613
drug1-interval
drug1-interval
0
1000
500.0
1
1
NIL
HORIZONTAL

SLIDER
404
621
576
654
drug2-interval
drug2-interval
0
1000
500.0
1
1
NIL
HORIZONTAL

SLIDER
404
662
576
695
drug3-interval
drug3-interval
0
1000
500.0
1
1
NIL
HORIZONTAL

BUTTON
597
583
701
616
Add drug 1
create-drugs1 drug1-dose\n  [\n    setxy random-xcor random-ycor\n    set shape \"circle\"\n    set color yellow\n    set size 0.5\n    \n  ]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
595
625
699
658
Add drug 2
create-drugs2 drug2-dose\n  [\n    setxy random-xcor random-ycor\n    set shape \"circle\"\n    set color cyan\n    set size 0.5\n    \n  ]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
593
665
697
698
Add drug 3
create-drugs3 drug3-dose\n  [\n    setxy random-xcor random-ycor\n    set shape \"circle\"\n    set color green\n    set size 0.5\n    \n  ]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
410
551
593
569
Add drugs every ___ ticks:
13
0.0
1

TEXTBOX
606
561
756
579
Add drug now:
13
0.0
1

SLIDER
737
626
909
659
drug2-cap
drug2-cap
1
2
1.0
1
1
NIL
HORIZONTAL

TEXTBOX
746
581
896
613
Drug 2 can cap only one end or both ends?
13
0.0
1

TEXTBOX
405
456
555
474
Yellow Drug 1
13
0.0
1

TEXTBOX
402
475
552
493
Cyan Drug 2
13
0.0
1

TEXTBOX
402
496
552
514
Green Drug 3\n
13
0.0
1

TEXTBOX
406
714
581
746
If zero, don't add drug at all.
13
0.0
1

@#$#@#$#@
## WHAT IS IT?

Nucleated Polymerisation Model (NPM) of prion replication

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

Masel J, Jansen VAA, Nowak MA. Quantifying the kinetic parameters of prion replication, Biophys Chem. 1999 Mar 29;77(2-3):139-52.

Sindi SS. Mathematical Modeling of Prion Disease, Prion – An Overview Ch. 10
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
NetLogo 6.0.4
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="No drugs" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>let timestamp date-and-time
set timestamp replace-item 2 timestamp "-"
set timestamp replace-item 5 timestamp "-"
export-plot "Polymer size distribution" (word "size-" timestamp ".csv")</final>
    <exitCondition>ticks = 50000</exitCondition>
    <metric>count monomers</metric>
    <metric>count polymers</metric>
    <metric>count polymers with [ poly-size &gt;= poly-threshold-size ]</metric>
    <enumeratedValueSet variable="drug2-cap">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spawn-rate">
      <value value="0.4777"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-monomer">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="drug3-dose">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="drug2-interval">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="drug2-dose">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="poly-death-rate">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="drug1-dose">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-polymer">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="wiggle-angle">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mono-death-rate">
      <value value="1.0E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="slow-aggregate-rate">
      <value value="0.2611"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fast-aggregate-rate">
      <value value="0.949"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="drug3-interval">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="drug1-interval">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="poly-threshold-size">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fast-split-rate">
      <value value="0.3822"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="slow-split-rate">
      <value value="0.0637"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Drug 1 only" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>let timestamp date-and-time
set timestamp replace-item 2 timestamp "-"
set timestamp replace-item 5 timestamp "-"
export-plot "Polymer size distribution" (word "size-" timestamp ".csv")</final>
    <exitCondition>ticks = 50000</exitCondition>
    <metric>count monomers</metric>
    <metric>count polymers</metric>
    <metric>count polymers with [ poly-size &gt;= poly-threshold-size ]</metric>
    <enumeratedValueSet variable="drug2-cap">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spawn-rate">
      <value value="0.4777"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-monomer">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="drug3-dose">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="drug2-interval">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="drug2-dose">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="poly-death-rate">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="drug1-dose">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-polymer">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="wiggle-angle">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mono-death-rate">
      <value value="1.0E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="slow-aggregate-rate">
      <value value="0.2611"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fast-aggregate-rate">
      <value value="0.949"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="drug3-interval">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="drug1-interval">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="poly-threshold-size">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fast-split-rate">
      <value value="0.3822"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="slow-split-rate">
      <value value="0.0637"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Drug 2 only, cap 1" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>let timestamp date-and-time
set timestamp replace-item 2 timestamp "-"
set timestamp replace-item 5 timestamp "-"
export-plot "Polymer size distribution" (word "size-" timestamp ".csv")</final>
    <exitCondition>ticks = 50000</exitCondition>
    <metric>count monomers</metric>
    <metric>count polymers</metric>
    <metric>count polymers with [ poly-size &gt;= poly-threshold-size ]</metric>
    <enumeratedValueSet variable="drug2-cap">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spawn-rate">
      <value value="0.4777"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-monomer">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="drug3-dose">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="drug2-interval">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="drug2-dose">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="poly-death-rate">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="drug1-dose">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-polymer">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="wiggle-angle">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mono-death-rate">
      <value value="1.0E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="slow-aggregate-rate">
      <value value="0.2611"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fast-aggregate-rate">
      <value value="0.949"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="drug3-interval">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="drug1-interval">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="poly-threshold-size">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fast-split-rate">
      <value value="0.3822"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="slow-split-rate">
      <value value="0.0637"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Drug 3 only" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>let timestamp date-and-time
set timestamp replace-item 2 timestamp "-"
set timestamp replace-item 5 timestamp "-"
export-plot "Polymer size distribution" (word "size-" timestamp ".csv")</final>
    <exitCondition>ticks = 50000</exitCondition>
    <metric>count monomers</metric>
    <metric>count polymers</metric>
    <metric>count polymers with [ poly-size &gt;= poly-threshold-size ]</metric>
    <enumeratedValueSet variable="drug2-cap">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spawn-rate">
      <value value="0.4777"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-monomer">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="drug3-dose">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="drug2-interval">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="drug2-dose">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="poly-death-rate">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="drug1-dose">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-polymer">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="wiggle-angle">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mono-death-rate">
      <value value="1.0E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="slow-aggregate-rate">
      <value value="0.2611"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fast-aggregate-rate">
      <value value="0.949"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="drug3-interval">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="drug1-interval">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="poly-threshold-size">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fast-split-rate">
      <value value="0.3822"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="slow-split-rate">
      <value value="0.0637"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Drug 2 only, cap 2" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>let timestamp date-and-time
set timestamp replace-item 2 timestamp "-"
set timestamp replace-item 5 timestamp "-"
export-plot "Polymer size distribution" (word "size-" timestamp ".csv")</final>
    <exitCondition>ticks = 50000</exitCondition>
    <metric>count monomers</metric>
    <metric>count polymers</metric>
    <metric>count polymers with [ poly-size &gt;= poly-threshold-size ]</metric>
    <enumeratedValueSet variable="drug2-cap">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spawn-rate">
      <value value="0.4777"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-monomer">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="drug3-dose">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="drug2-interval">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="drug2-dose">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="poly-death-rate">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="drug1-dose">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-polymer">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="wiggle-angle">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mono-death-rate">
      <value value="1.0E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="slow-aggregate-rate">
      <value value="0.2611"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fast-aggregate-rate">
      <value value="0.949"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="drug3-interval">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="drug1-interval">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="poly-threshold-size">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fast-split-rate">
      <value value="0.3822"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="slow-split-rate">
      <value value="0.0637"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
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
