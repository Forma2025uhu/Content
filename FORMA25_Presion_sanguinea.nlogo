globals [spawn-P spawn-GR spawn-GB numChoques cateter int-cateter margenSuperior margenInferior ultimoTick presionTotal ensanchadoTotal danioTotal activoCateter auxCateter auxintCateter]
turtles-own[ velocidad]
breed [globBlancos globBlanco]
breed [globRojos globRojo]
breed [plaquetas plaqueta]
breed [medicamentos medicamento]

to setup
  ca
  set numChoques 0
  set ultimoTick 0
  set danioTotal 0
colorear-carriles 2 24 4
  set activoCateter true
      set auxCateter cateter
    set auxintCateter int-cateter
  reset-ticks
end


to go

  ask spawn-P [
      if random-float 100 < (0.2 * VelocidadCaudalSanguineo / 100)[
    sprout 1 [
          set breed plaquetas
          set shape "circle"
          set color yellow
          set size 0.6 + random-float (0.8 - 0.6)
          set velocidad 0.02 * (1 / size)
  set heading 90
  ]
      ]
    ]
      ask spawn-GR [
      if random-float 100 < (0.2 * VelocidadCaudalSanguineo / 100) [
    sprout 1 [

          set breed globRojos
          set shape "circle"
          set color red
          set size 1.2 + random-float (1.2 - 1.6)
        set velocidad 0.02 * (1 / size)
  set heading 90
  ]
      ]
    ]
      ask spawn-GB [
      if random-float 100 < (0.2 * VelocidadCaudalSanguineo / 100) [
    sprout 1 [
          set breed globBlancos
          set color white
          set shape "circle"
          set size 2.4 + random-float (2.4 - 3.4)
        set velocidad 0.02 * (1 / size)
  set heading 90
  ]
      ]
]


  ask turtles [wiggle]
  actualizar-patches
  tick
end

to wiggle
  if not can-move? 1
  [ die ]

  let yo self
  if-else size >= 2.4
  [
    if any? turtles in-radius 1
    [
      ask min-one-of turtles in-radius 1 [distance myself] [choque yo]
    ]
  ]
  [
  (if-else any? turtles-on patch-here
  [
        ask min-one-of turtles-on patch-here [distance myself] [choque yo]
  ]
   (any? turtles with [size >= 2.4] in-radius 1)
      [
        ask min-one-of turtles with [size >= 2.4] in-radius 1 [distance myself] [choque yo]
      ]
    )
  ]


  let y ycor
  (if-else(any? neighbors with [(pycor > y or pycor < y) and pcolor = red - 1])
  [
    set numChoques numChoques + 1
     if-else pycor > 0
        [set heading 150]
      [set heading 60]
    fd velocidad * VelocidadCaudalSanguineo / 100
  ]( patch-ahead 1 != nobody and cateter != nobody and member? patch-ahead 1 cateter )
    [
      (if-else pycor > 2
        [set heading 360]
      (pycor < -2)
      [set heading 180]
      [
          if-else random 100 < 50
          [set heading 360]
          [set heading 180]

        ]
        )
      fd velocidad * VelocidadCaudalSanguineo / 100
    ]

  [
    fd velocidad * VelocidadCaudalSanguineo / 100
  ])
  ;ajuste caudal
  if heading > 0 and heading < 90 [ set heading heading + 0.2 * (1 / size)  * VelocidadCaudalSanguineo / 100]
  if heading > 90 and heading < 180 [ set heading heading - 0.2 * (1 / size)  * VelocidadCaudalSanguineo / 100]
  ;if heading > 180 and heading < 360 [ set heading heading + 0.25  * VelocidadCaudalSanguineo / 100]

end

to choque [ Otro ]
  let angulo ((random-float 10 * (1 / size) * [size] of Otro) + 0.1)
  if [ycor] of Otro < ycor [set angulo (- angulo)]
  if [ycor] of Otro = ycor [
    if random 100 < 50
    [set angulo (- angulo)]

  ]

  set heading max list 45 (min list 135 (heading + angulo))

end


to-report calcular-presion [px]
  let presionActual (count turtles with [floor (xcor) = px])
  let presionLateral (count turtles with [floor (xcor) = (px - 1) or floor (xcor) = (px + 1)])
  let presionExterior (count turtles with [floor (xcor) = (px - 2) or floor (xcor) = (px + 2)])
  report (presionActual + (0.5 * presionLateral) + (0.1 * presionExterior))
end

to-report incrementoDanio [niv]
  report (2 * (niv + 1))
end

to-report reduccionDanio [niv]
  ifelse (niv - 4 < 0)
  [
   report ((0))
  ]
  [
    report ((niv - 4))
  ]
end

to actualizar-patches

  if(ticks > (ultimoTick + 200))
    [
      let pTotal 0
      let eTotal 0
      set ultimoTick ticks
      ask patches with [pcolor = (red - 1) and pycor >= margenSuperior]
      [

       let presion (calcular-presion pxcor)
       let nivel (obtenernivel pxcor pycor)
       set pTotal pTotal + presion
       set eTotal eTotal + nivel

       (if-else (presion > (valorIntervaloNivel pycor nivel))
       [
            if((nivel + 1) >= 3)
            [
              set danioTotal (danioTotal + incrementoDanio nivel)
            ]
            if(pycor < (max-pycor))
            [
              mover pxcor pycor "UP"
              mover pxcor (pycor * -1) "DW"
            ]

        ]
        (presion < (valorIntervaloNivel pycor nivel))
        [

           ifelse(pycor > margenSuperior)
           [
             reset-mover pxcor pycor "UP"
             reset-mover pxcor (pycor * -1) "DW"
             if(danioTotal > reduccionDanio nivel)
             [
                set danioTotal (danioTotal - reduccionDanio nivel)
             ]
           ]
            [
              if(nivel = 0)

            [
              if((danioTotal - ((reduccionDanio 4.01))) > 0)
              [
                 set danioTotal danioTotal - ((reduccionDanio 4.01))
              ]
            ]
            ]

        ]
        [
            ifelse(nivel > 0)
            [
              set danioTotal (danioTotal + incrementoDanio nivel)
            ]
            [
              if((danioTotal - ((reduccionDanio 7))) > 0)
              [
                 set danioTotal danioTotal - ((reduccionDanio 7))
              ]
            ]
        ])
      ]
      set presionTotal pTotal / (max-pxcor * 2 + 1)
      set ensanchadoTotal ((eTotal / (max-pxcor * 2 + 1)) * 2) * 0.05263 * 1000
  ]


end

to mover [objx objy dir]
  ask patch objx objy
  [

    let cuenta 1
    if (dir = "DW") [
      set cuenta cuenta * -1
    ]
    ask patch objx objy
    [
      set pcolor black
    ]
    ask patch objx (objy + cuenta)
    [
      set pcolor (red - 1)
    ]

    ask (neighbors with[pcolor = (red - 1) and (abs((objy + cuenta) - pycor) > 1 )])
    [
      mover pxcor pycor dir
    ]
  ]
end

to reset-mover [objx objy dir]

  ask patch objx objy
  [
    let cuenta -1
    if (dir = "DW") [
      set cuenta cuenta * -1
    ]

    if (not any? neighbors with [cond pycor objy dir and pcolor = (red - 1)])
    [
      ask patch objx objy
      [
        set pcolor black
      ]
      ask patch objx (objy + cuenta)
      [
        set pcolor (red - 1)
      ]

      ask (neighbors with[pcolor = (red - 1) and (pycor > margenSuperior or pycor < margenInferior) and pycor != objy and ((calcular-presion pxcor) < (valorIntervaloNivel pycor (obtenernivel pxcor pycor)))])
      [
        reset-mover pxcor pycor dir
     ]
  ]
  ]
end

to-report obtenerNivel [objx objy]

    ifelse(objy >= margenSuperior)
    [
      report ((max-pycor - margenSuperior) - (max-pycor - objy))
    ]
    [
      report((margenInferior - min-pycor) - (objy - min-pycor))
    ]

end

to-report valorIntervaloNivel [coordy niv]
  let presionMaxima 25
  let presionMinima 17

  ifelse(coordy >= margenSuperior)
  [
    let incremento ((presionMaxima - presionMinima) / (max-pycor - margenSuperior))
    report (presionMinima + (incremento * niv))

  ]
  [
    let incremento ((presionMaxima - presionMinima) / (margenInferior - min-pycor))
    report (presionMinima + (incremento * niv))

  ]
end

to-report cond [acty objy dir]
  ifelse(dir = "UP")
  [
   report (acty > objy)
  ]
  [
    report (acty < objy)
  ]
end

to colorear-carriles [pequeno mediano grande]
  clear-all
  let y-pos 0
  let total-altura (2 * pequeno + 2 * mediano + grande)
  let y-inicial floor (total-altura / 2) ; Punto de inicio en la parte superior
  set margenSuperior y-inicial + 1
  ask patches with [pycor = y-inicial + 1] [set pcolor red - 1]

  ; Carril pequeño superior
  let pequeno-s patches with [pycor > y-inicial - pequeno and pycor <= y-inicial]
  set y-inicial y-inicial - pequeno

  ; Carril mediano superior
  let mediano-s patches with [pycor > y-inicial - mediano and pycor <= y-inicial]
  set y-inicial y-inicial - mediano

  ; Carril grande (central)
  let grande-c patches with [pycor > y-inicial - grande and pycor <= y-inicial]

  ; Dibujar la semicircunferencia rellena con el lado curvo apuntando al lado contrario
  let radio 10
  let centro-x -34
  let centro-y y-inicial - (grande / 2)

  ask patches with [ (pxcor - centro-x) ^ 2 + (pycor - centro-y) ^ 2 <= radio ^ 2 and pxcor < centro-x ] [
    set pcolor gray
  ]
  set radio 9
  set int-cateter  patches with [ (pxcor - centro-x) ^ 2 + (pycor - centro-y) ^ 2 <= radio ^ 2 and pxcor < centro-x ]
  ask int-cateter[set pcolor black]
  set int-cateter int-cateter with [ pxcor != -43 or pycor != 0]

  ask patch -43 0 [set pcolor gray]
  ask patch -43 5 [set pcolor gray]
  ask patch -43 -5 [set pcolor gray]
  ask patch -44 0 [set pcolor black]
  ask patch -39 9 [set pcolor gray]
  ask patch -39 -9 [set pcolor gray]


  set cateter patches with [pcolor = gray]

  set y-inicial y-inicial - grande

  ; Carril mediano inferior
  let mediano-i patches with [pycor > y-inicial - mediano and pycor <= y-inicial]
  set y-inicial y-inicial - mediano

  ; Carril pequeño inferior
  let pequeno-i patches with [pycor > y-inicial - pequeno and pycor <= y-inicial]
  set y-inicial y-inicial - pequeno - 1
  ask patches with [pycor = y-inicial ] [set pcolor red - 1]
  set margenInferior y-inicial

  set spawn-P (patch-set pequeno-s with [pxcor = -100] pequeno-i with [pxcor = -100])
  set spawn-GR (patch-set mediano-s with [pxcor = -100] mediano-i with [pxcor = -100])
  set spawn-GB (grande-c with [pxcor = -100])
  ask spawn-P [set pcolor yellow]
  ask spawn-GB [set pcolor white]
  ask spawn-GR [set pcolor red]
  ask patch -100 0 [set pcolor red]
  ask patch -100 1 [set pcolor red]
  ask patch -100 -2 [set pcolor white]
  ask patch -100 3 [set pcolor white]
  set spawn-GB patches with [pcolor = white]
  set spawn-GR patches with [pcolor = red]
    ask spawn-P [set pcolor black]
  ask spawn-GB [set pcolor black]
  ask spawn-GR [set pcolor black]

end

to Inyectar
  if activoCateter [
  ask int-cateter [
    if random-float 100 < (0.01 * densidadMedicamento)[
    sprout 1 [
          set breed medicamentos
          set shape "circle"
          set color blue
          set size tamMedicamento
          set velocidad velocidadMedicamento / 100 * (1 / size)
  set heading 90
  ]
  ]
  ]
  ]

end

to Mod-Cateter
  if-else activoCateter
  [
     ask cateter [set pcolor black]
    set cateter nobody
    set int-cateter nobody
    set activoCateter false
  ]
  [
     ask auxCateter [set pcolor gray]
    set cateter auxCateter
    set int-cateter auxIntCateter
    set activoCateter true
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
258
87
1409
556
-1
-1
5.69
1
10
1
1
1
0
0
0
1
-100
100
-40
40
0
0
1
ticks
144.0

BUTTON
262
33
325
66
setup
setup
NIL
1
T
OBSERVER
NIL
S
NIL
NIL
1

BUTTON
329
33
392
66
go
go
T
1
T
OBSERVER
NIL
G
NIL
NIL
1

SLIDER
557
10
747
43
VelocidadCaudalSanguineo
VelocidadCaudalSanguineo
1
1500
1012.0
1
1
NIL
HORIZONTAL

BUTTON
401
10
550
43
Inyectar medicamento
Inyectar
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
756
10
947
43
tamMedicamento
tamMedicamento
0.5
4
4.0
0.5
1
NIL
HORIZONTAL

SLIDER
757
44
947
77
densidadMedicamento
densidadMedicamento
1
25
23.0
1
1
NIL
HORIZONTAL

PLOT
15
85
215
235
Presión Media Total
Tiempo
Nº de moléculas
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot presionTotal"

SLIDER
557
43
746
76
velocidadMedicamento
velocidadMedicamento
1
10
3.0
1
1
NIL
HORIZONTAL

PLOT
15
238
215
388
Ensanchado Promedio Total
T
µm
0.0
0.1
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot ensanchadoTotal"

PLOT
14
391
214
541
Daño Acumulado
Tiempo
Daño
0.0
10.0
0.0
1000.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot danioTotal\nset-plot-x-range (plot-x-min + 0.5) plot-x-max"

BUTTON
402
44
549
77
Quitar/Poner Cateter
Mod-Cateter
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

@#$#@#$#@
## WHAT IS IT?

Se trata de un modelo de simulación del torrente sanguíneo en una vena. Concretamente el modelo simula las interacciones celulares del torrente a la hora de insertar un catéter con fármacos.

## HOW IT WORKS

Las celulas interactúan entre si cuando se encuentran en proximidad de otras células, un medicamento o la pared de la vena o del catéter. Al entrar en contacto, "chocan" entre sí o con el obstáculo, recalculando su ángulo y velocidad de dirección en función de la velocidad del torrente, su tamaño y (en caso de ser otra célula o fármaco) el tamaño del componente con el que colisiona. A su vez, la vena se ensancha conforme aumenta la presión.

## HOW TO USE IT

Disponemos de 3 gráficas que miden el daño a la vena acumulado, el ensanchamiento en tiempo real de la vena y la presión en promedio total.

También disponemos de un botón que permite insertar o retirar el catéter y otro que inyecta el medicamento en la sangre.

Las propiedades del medicamento dependen de 3 sliders:

Uno para el tamaño del medicamento (tamMedicamento), que influye en el tamaño de la molecula farmacológica en sí.

Uno para la densidad del medicamento (densidadMedicamento), que influye en el numero de partículas por ml que contiene la disolución.

Uno para la velocidad de inyección del medicamento (velocidadMedicamento), que afecta a la velocidad inicial que toma el medicamento al salir del catéter.

Por último, disponemos de un slider para aumentar o disminuir la velocidad del torrente sanguíneo.

## THINGS TO NOTICE

La disposición de la sangre es de carácter laminar, lo que significa que las células de mayor tamaño tienden a disponerse en el centro del torrente. A su vez, introducir un medicamento con cierta densidad o tamaño puede disrumpir el orden laminar y generar turbulencias. 

## THINGS TO TRY

Intente ajustar los sliders para experimentar que es más dañino para el paciente: tamaño alto y velocidad baja, tamaño pequeño y alta densidad... etc.

## EXTENDING THE MODEL

Podría implementarse que la pared de la vena no solo se dilate hacia el exterior, sino que hacia el interior también.

## NETLOGO FEATURES

Cabe destacar que hemos utilizado una función recursiva para recalcular la posición de los patches correspondientes a la pared de la vena. Tmabién hemos usado in-radius para establecer la zona de choque entre agentes en función de su tamaño, independientemente de su raza.

## RELATED MODELS



## CREDITS AND REFERENCES
Jornadas : Forma 25 Universidad de Huelva , 7, 13 y 14 Marzo 2025
https://github.com/Forma2025uhu/Content
.Investigador : José Miguel Robles-Romero
https://orcid.org/0000-0001-8343-6421
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
Circle -16777216 false false -2 -2 304

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
Circle -16777216 false false 89 89 122

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
NetLogo 6.3.0
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
