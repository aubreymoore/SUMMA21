breed[beetles beetle]
breed[spruces spruce]
breed[d-trees d-tree]


beetles-own[age]
d-trees-own [age-d-tree]
spruces-own [age-tree ]
patches-own[hit]
globals [all-spruces]


;================================
to setup
  ca

  setup-patches

  ask patches
  [let tree-1 count spruces-here                                           ;find number of spruce trees
    let tree-2 count d-trees-here                                          ;find number of other trees
     if tree-1 = 0 and tree-2 = 0
      [ifelse random 100 < (100 - %-of-non-spruce-trees)
        [sprout-spruces 1                                                  ;find number of spruce trees
          [set shape "2spruce"
            set size 2.25 - random-float 2.25                                                  ;spruce tree size
            set color rgb 0 110 0

            set age-tree random 100
            setxy pxcor + random-float 0.5 pycor + random-float 0.5        ;sightly randomize spruce tree positions
            ]]
         [sprout-d-trees 1
          [set shape "tree2"
            set size 1.5
            set color rgb 0 90 0
            set age-d-tree random 100
            setxy pxcor + random-float 0.5 pycor + random-float 0.5
            ]]
         ]]
  set all-spruces count spruces

  create-beetles 150
  [setup-beetles]

  reset-ticks
end
;================================

to setup-d-trees-seedling
            set shape "tree2"
            set size 0.25
            set color rgb 0 85 0
            set age-d-tree 0
            setxy pxcor + random-float 0.5 pycor + random-float 0.5
end

to setup-spruces-seedling
   set shape "2spruce"
            set size 0.25
            set age-tree 0
            set color rgb 0 110 0

            setxy pxcor + random-float 0.5 pycor + random-float 0.5 ;slightly randomize the tree position. This makes the forest look more natural but increase the max number of trees in a the simuation as each patch can have more than one trees.
end

to setup-beetles                         ; set up initial beetle features, in which all beetles are at the age of 0
    set color 1
    set shape "bark-beetle"
    set size 0.3
    setxy (random-float 3)(random-float 3)
    set age 0
end

to setup-patches                                           ;set patches to certain drought level
  ask patches [
    set pcolor 36 + random-float (0.5 + (0.5 * Severity-of-Drought))
    ]
end

;=================================


to go
  tick

  tree-grow
  tree-death
  infest
  patch-count
  set-tree-color
  beetle-migrate
  temperature-control
  beetle-death
  seedling


  if count beetles = 0 [user-message ("There are no bark beetles in this forest.") stop]
end


;==================================

to tree-grow                                  ; Spruces grow until size 2.25
  ask spruces
  [if size < 2.25 [set size size + 0.05 set age-tree age-tree + 1]]
  ask d-trees
  [if size < 1.5 [set size size + 0.025 set age-d-tree age-d-tree + 1]]
end

to tree-death                               ;natural motality of trees
  ask d-trees
  [ if random 800 < 10 [die]]
  ask spruces
  [ if random 1000 < 10 [die]
  ]
end

to patch-count                                ;count how many beetles on a patch, use the number of beetles to indicate severity of infestation
  ask patches
  [set hit 0
    let num-bug count beetles-here
    set hit (num-bug * (10 + (Severity-of-Drought * 5)))]
end


to set-tree-color                            ;determine severity of infestation. The number of beetles are associated to the tree color
  ask spruces
  [let redness [hit] of patch-here
    ifelse redness > 200
    [die ask beetles-here [setxy (xcor + random-float 1) (ycor + random-float 1)]]
    [ set color rgb redness 110 0]
  ]
end

to seedling                                  ;seed new green trees at 2 percentage
  ask patches
  [let tree-1 count spruces-here
    let tree-2 count d-trees-here
     if tree-1 = 0 and tree-2 = 0
     [if random 1000 < 30
     [let tree-ratio count spruces / (count spruces + count d-trees + 1)
     ifelse tree-ratio * 100 < (100 - %-of-non-spruce-trees)
        [sprout-spruces 1
          [setup-spruces-seedling]]
        [sprout-d-trees 1
          [setup-d-trees-seedling]]
      ]]]

  if (100 - %-of-non-spruce-trees) = 100 [ask d-trees [die]]        ;clear other tree when diversity is low
end


to infest                                      ;Beetles detect trees avaiable in radius of 3. then migrate to one of the available spruces.
  ask beetles
     [let target-tree one-of spruces with [size > 0.5] in-radius 3     ;infest tree larger than 0.5
  ifelse target-tree != nobody
    [face target-tree
      move-to target-tree
       hatch 2 [set age 0]                  ;If a beetle infests a mature tree, hatches 2 offspring and then dies.
          if random 100 < Temperature-increase * 2 [hatch 1 [set age 0]] ;If temperature increases, hatch one more beetle at the defined rate.
          die
        ]
    [ set age age + 1]                      ;If a beetle does not infests a mature tree, age increases 1
  ]
end

to beetle-death
  ask beetles with [age >= 2] [die]           ;If beetles with age of 2 or older die.
end



to temperature-control                             ;Percentages of beetles die every year, related to the temperature increase.
  ask beetles
  [if random 100 > ((Temperature-increase * 2) + 50)
    [die]]
end


to beetle-migrate
  ask beetles
  [
    setxy (xcor + random-float random 2) (ycor + random-float random 2)
    ]
end

; developed by Lin Xiang at Weber State University

;lxiang75@gmail.com ; linxiang@weber.edu
@#$#@#$#@
GRAPHICS-WINDOW
398
10
855
468
-1
-1
21.428571428571427
1
10
1
1
1
0
1
1
1
-10
10
-10
10
0
0
1
Years
5.0

BUTTON
145
304
265
353
Run Forever/Pause
Go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

MONITOR
185
429
282
474
# of Beetles
count beetles
0
1
11

PLOT
21
475
499
678
Changes in Bark Beetles and Spruce Trees over Time
Years
# of Beetles and Trees
0.0
10.0
0.0
3500.0
true
true
"" ""
PENS
"Bark Beetles" 1.0 0 -5298144 true "plot count beetles" "plot count beetles"
"Spruces" 1.0 0 -14439633 true "plot count spruces" "plot count spruces"

MONITOR
75
429
184
474
# of Spruce trees
count spruces
0
1
11

SLIDER
194
40
383
73
Temperature-increase
Temperature-increase
0
2
0.0
0.5
1
C
HORIZONTAL

SLIDER
194
80
383
113
Severity-of-Drought
Severity-of-Drought
0
3
0.0
1
1
NIL
HORIZONTAL

TEXTBOX
12
10
280
28
Step 1: Choose a small or large forest to start. 
11
15.0
1

TEXTBOX
17
176
339
205
-------------------------------------------\nStep 2: Choose how long to run the simulation.
11
15.0
1

TEXTBOX
20
372
377
421
---------------------------------------------\nStep 3: Observe the changes in the numbers of bark beetles and spruces over time.
11
15.0
1

BUTTON
276
218
331
251
200
go\nif ticks >= 200 [stop]
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
216
218
271
251
150
go\nif ticks >= 150 [stop]
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
96
218
151
251
50
go\nif ticks >= 50 [stop]
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
156
218
211
251
100
go\nif ticks >= 100 [stop]
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
157
257
212
290
500
go\nif ticks >= 500 [stop]
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
96
257
151
290
250
go\nif ticks >= 250 [stop]
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
194
119
383
152
%-of-non-spruce-trees
%-of-non-spruce-trees
0
100
0.0
10
1
%
HORIZONTAL

BUTTON
28
230
85
275
1 year
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

MONITOR
21
429
74
474
Years
ticks
17
1
11

BUTTON
30
78
164
114
Set/Reset Forest
resize-world (-1 * Forest-size) Forest-size (-1 * Forest-size) Forest-size\nset-patch-size 450 / (2 * Forest-size + 1)\n\n\nsetup
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
30
40
164
73
Forest-size
Forest-size
5
15
10.0
1
1
NIL
HORIZONTAL

BUTTON
216
257
271
290
750
go\nif ticks >= 750 [stop]
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
276
258
331
291
1000
go\nif ticks >= 1000 [stop]
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

@#$#@#$#@
## DESIGN NOTES

1. Starting # of beetles = 150
2. Students can investigate a smaller or larger forest.
3. Beetles can move up to 3 patches randomly in the forest every tick.
4. Beetles only attack trees whose size is larger than 0.5
5. The color of trees indicates the number of beetles infesting the tree.

## Module rules

1. The lifespan of a bark beetle is two hypothetical years (ticks). If it finds a proper host spruce tree, it produces two offspring and dies. If no host spruce trees are available, it dies at the age of 2. 

2. Bark beetles only attack spruce trees whose size is larger than 0.5.

3. When temperature increases, fewer bark beetles die in winter (at the end of a tick).

4. As temperature increases, more bark beetles may produce one more offspring. 

5. When drought becomes severer, it takes fewer beetles to kill a host spruce tree.

6. No relationships are defined between temperature and severity of drought (even it is likely in reality).

7. The ratio of spruce and other trees in a forest is set and maintained by the Tree-Diversity slider.

## Things to notice

* It is important to examine the spruce tree population when defining an outbreak.

* The y-axis upper bound automatically adjust to fit in the data. Make sure to check the y-axis bounds when interpreting data.

* The year buttons "250", "500", "750", and "1000" can be used to set a successive investigation on a certain variable with the precise time interval of 250 years.


* Bark beetle population may crash due to no available host trees in a reachable distance. It is not a programming error but a normal emergent event of the model. It will happen more or less depending on the settings you use. 

## CREDITS AND REFERENCES

This module is made by Dr. Lin Xiang at Weber State University. If you mention this model in a publication, we ask that you include the citations below.

Xiang, L. (2017). Bark Beetle Epidemic. Zoology Department, Weber State University, Ogden, UT.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

2spruce
false
0
Polygon -6459832 true false 135 180 135 270 105 285 150 284 165 300 165 285 195 285 166 265 165 180
Polygon -7500403 true true 150 0 120 30 135 30 105 45 120 45 90 75 105 75 75 105 90 105 60 150 75 150 45 195 120 180 180 180 255 195 225 150 240 150 210 105 225 105 195 75 210 75 180 45 195 45 165 30 180 30
Polygon -14835848 false false 150 0 120 30 135 30 105 45 120 45 90 75 105 75 75 105 90 105 60 150 75 150 45 195 120 180 180 180 255 195 225 150 240 150 210 105 225 105 195 75 210 75 180 45 195 45 165 30 180 30

3forest
false
0
Rectangle -6459832 true false 262 62 277 107
Polygon -7500403 true true 105 15 75 45 90 45 60 60 75 60 45 90 60 90 30 120 45 120 15 165 30 165 0 210 75 195 135 195 210 210 180 165 195 165 165 120 180 120 150 90 165 90 135 60 150 60 120 45 135 45
Polygon -14835848 false false 105 15 75 45 90 45 60 60 75 60 45 90 60 90 30 120 45 120 15 165 30 165 0 210 75 195 135 195 210 210 180 165 195 165 165 120 180 120 150 90 165 90 135 60 150 60 120 45 135 45
Polygon -7500403 true true 150 0 120 30 135 30 105 45 120 45 90 75 105 75 75 105 90 105 60 150 75 150 45 195 120 180 180 180 255 195 225 150 240 150 210 105 225 105 195 75 210 75 180 45 195 45 165 30 180 30
Polygon -14835848 false false 150 0 120 30 135 30 105 45 120 45 90 75 105 75 75 105 90 105 60 150 75 150 45 195 120 180 180 180 255 195 225 150 240 150 210 105 225 105 195 75 210 75 180 45 195 45 165 30 180 30
Polygon -6459832 true false 135 180 135 270 105 285 150 284 165 300 165 285 195 285 166 265 165 180
Polygon -6459832 true false 90 195 90 270 75 285 105 285 120 300 120 285 135 285 120 270 120 195
Polygon -7500403 true true 270 0 255 15 270 15 240 45 255 45 240 75 300 75 285 45 300 45 270 15 285 15
Polygon -14835848 false false 270 0 255 15 270 15 240 45 255 45 240 75 300 75 285 45 300 45 270 15 285 15

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

bark-beetle
true
0
Polygon -7500403 true true 152 17 135 17 122 27 115 38 110 54 102 63 95 80 90 105 116 114 132 111 152 111
Polygon -7500403 true true 148 17 165 17 178 27 185 38 190 54 198 63 205 80 210 105 182 114 168 111 148 111
Polygon -7500403 true true 151 109 124 109 106 117 97 119 91 126 92 167 90 203 90 243 100 262 117 280 133 290 148 292 152 292
Polygon -7500403 true true 149 109 176 109 194 117 203 119 209 126 208 167 210 203 210 243 200 262 183 280 167 290 152 292 148 292
Polygon -7500403 true true 128 27 114 21 111 23 109 26 108 30 99 30 93 23 87 20 85 29 93 37 109 33 115 27
Polygon -7500403 true true 172 27 186 21 189 23 191 26 192 30 201 30 207 23 213 20 215 29 207 37 191 33 185 27
Polygon -7500403 true true 95 92 84 85 80 85 77 81 68 65 63 63 55 51 46 49 45 50 51 52 48 60 51 56 54 58 63 69 62 71 78 89 78 93 93 103
Polygon -7500403 true true 205 92 216 85 220 85 223 81 232 65 237 63 245 51 254 49 255 50 249 52 252 60 249 56 246 58 237 69 238 71 222 89 222 93 207 103
Polygon -7500403 true true 94 127 84 122 44 141 39 139 41 142 35 142 42 145 24 166 14 172 18 181 17 173 25 168 27 171 29 164 43 148 46 149 77 130 93 148
Polygon -7500403 true true 206 127 216 122 256 141 261 139 259 142 265 142 258 145 276 166 286 172 282 181 283 173 275 168 273 171 271 164 257 148 254 149 223 130 207 148
Polygon -7500403 true true 94 183 76 194 62 224 58 227 65 223 62 239 55 252 59 249 63 254 62 243 67 247 69 224 76 205 95 200
Polygon -7500403 true true 206 183 224 194 238 224 242 227 235 223 238 239 245 252 241 249 237 254 238 243 233 247 231 224 224 205 205 200

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

spruce
false
0
Polygon -7500403 true true 150 0 135 30 105 60 120 60 105 90 75 120 90 120 75 150 45 180 60 180 45 210 15 240 105 270 195 270 285 240 255 210 240 180 255 180 225 150 210 120 225 120 195 90 180 60 195 60 165 30 150 0
Rectangle -6459832 true false 120 270 180 300
Polygon -14835848 false false 150 0 135 30 105 60 120 60 105 90 75 120 90 120 75 150 45 180 60 180 45 210 15 240 105 270 195 270 285 240 255 210 240 180 255 180 225 150 210 120 225 120 195 90 180 60 195 60 165 30

spruce1
false
0
Polygon -7500403 true true 150 0 135 30 105 60 120 60 105 90 75 120 90 120 75 150 45 180 60 180 45 210 15 240 105 270 195 270 285 240 255 210 240 180 255 180 225 150 210 120 225 120 195 90 180 60 195 60 165 30 150 0
Polygon -14835848 false false 150 0 135 30 105 60 120 60 105 90 75 120 90 120 75 150 45 180 60 180 45 210 15 240 105 270 195 270 285 240 255 210 240 180 255 180 225 150 210 120 225 120 195 90 180 60 195 60 165 30

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

tree2
false
0
Polygon -7500403 true true 59 170 74 169 88 173 115 168 136 176 156 176 188 173 222 157 261 151 287 138 286 111 266 94 248 83 246 73 225 60 205 56 186 50 175 42 155 42 134 41 119 37 92 46 70 60 53 83 35 98 24 115 11 142 21 160 34 166 46 167
Polygon -6459832 true false 99 157 110 165 102 152 106 151 117 170 127 179 122 162 114 147 118 145 128 166 127 150 131 150 134 172 134 188 139 206 140 175 138 151 131 136 135 130 144 156 142 140 146 132 151 132 148 150 148 172 145 190 157 166 157 153 162 150 162 162 170 148 174 149 161 171 155 183 169 173 181 155 185 151 178 168 189 160 197 159 180 173 156 192 150 221 153 249 158 267 159 287 161 298 128 298 133 272 137 247 135 224 128 206 124 193 114 176 97 160

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
