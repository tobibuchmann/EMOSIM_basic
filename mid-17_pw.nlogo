;; ####################################### DEFINITION EXTENSIONS, BREEDS & VARIABLEN ###################################################

;; =================== Extensions ======================---------------------------------------

extensions
[
  gis nw csv
]

;; ====================== Breeds ===================---------------------------------------

breed
[
  hh hhs
] ; Haushalte sind vom Typ innovator, early adopter....haben sich zum letzten Mal vor x Jahren für ein Fahrzeug entschieden und Haben eine Anzahl von "Freunden", die ein E-Fahrzueg (social_i_e) oder ein herkömmliches Fahrzeug (social_i_h) besitzen

breed
[
  kfz kfzs
]

;; ===================== Variablen ====================---------------------------------------

hh-own
[
  typ
  schwelle
  letzte_entscheidung_1  ;fuer FZG 1 in Jahren
  letzte_entscheidung_2  ;fuer FZG 2 in Jahren
  letzte_entscheidung_3  ;fuer FZG 3 in Jahren
  letzte_entscheidung_4  ;fuer FZG 4 in Jahren

  hh-lage

  mundprop_e
  mundprop_h
  mundprop_p

  mundprop_nw_e ; Nutzwert
  mundprop_nw_h ; Nutzwert
  mundprop_nw_p ; Nutzwert

  fz1 ;
  fz2 ;
  fz3 ;
  fz4 ;

  brennstoff_nw_e
  brennstoff_nw_h
  brennstoff_nw_p

  Einkommen

  nfzg
  nfzgkrs
  hheink1
  fahrlj_h1

  bula1
  verstaedterung1

  ;Faktor_Plugin

 ]

kfz-own
[
  antrieb     ;h: herkömmlich oder e: elektrisch k: kein Fahrzeug
  reichweite  ;in km
  preis-list  ;Preisentwicklung E-Fahrzeug im Verhältnis zu herkömmlichem Fahrzeug (aus Horvath Studie + eigene Fortschreibung)
  mundprop_e
  mundprop_h
  mundprop_p
  test_001
 ]

patches-own
[
  bula population area verstaedterung lage country-name population-density agent-country-name fzgbest fzg-density fzganzahl_patches hheink fahrlj_h
]

globals
[
  number-of-nodes
  nr_patches

  max_reich
  min_preis

  year
  preis_e
  number_e

  zuwachs_reichweite

  countries-dataset de-Laender de-Kreise de-Gemeinden

  time

  reichweite_01
  reichweite_02

  preis-fahrzeug_nw_e

  COGSn_Lernkuve

  SPn
  SPn_plugin

  Anzahl_P
  Anzahl_E
  Anzahl_H
  Gesamt_EPH
  anzahl_fzg_bayern

  market_doubling

  Preis_EFahrzeug
  Preis_plugin_1

  Fahrleistung

  Gesamtemissionen

  Startwert

  Steigung

  Variable

  Reichweite_nw_h
  Reichweite_nw_e
  Reichweite_nw_p

  Preis_nw_e
  Preis_nw_h
  Preis_nw_p

  brennstoff_h
  brennstoff_e
  brennstoff_p

  wartungskosten_nw_h
  wartungskosten_nw_e
  wartungskosten_nw_p

  CO2-Emission_H
  CO2-Emission_E
  CO2-Emission_P
  C02-Emissionen

  Gesamtemissionen_hochgerechnet

  Variable_Inno
  Variable_EA

  indx

  range_schwelle
  schwelle_inno_range
  schwelle_earlya_range
  schwelle_eralyma_range
  schwelle_latema_range
  schwelle_laggard

  NW_E_Gesamt

  Range_Wert
  variable_range
  Ende_Range
  Faktor_Preis

  csv
  subset-area1

  Gesamtemission_Jahr
  Gesamtfahrleistung

  Durchschnittseink
  Durchschnittsfahrstrecke

  CO2-Emission_H_100
  strompreis_var
  kraftstoffpreis_konv_var

]

;; ################################### LADEN GIS und KARTENDATEN ############################################

;; =========================================---------------------------------------
;; Lade GIS-Daten und Grenzlinien
;; =========================================---------------------------------------

to setup-de

  clear-all
  ask patches [set pcolor white]

  set de-Laender gis:load-dataset "data/VG1000_LAN.shp"
  set de-Kreise gis:load-dataset "data/VG1000_KRS.shp"
  set de-Gemeinden gis:load-dataset "data/VG250_GEM.shp"

  ifelse (Grenzen-Berechnung = "Kreise")
    [ set countries-dataset de-Kreise] ;gis:load-dataset "data/VG1000_KRS.shp" ]
    [ set countries-dataset de-Gemeinden];gis:load-dataset "data/VG1000_LAN.shp" ]

  gis:set-drawing-color black

  ifelse (Grenzen-Anzeige = "Laender")
    [ gis:draw de-Laender 1 ]
    [ ifelse (Grenzen-Anzeige = "Kreise")
      [gis:draw de-Kreise 1 ]
      [gis:draw de-Gemeinden 1]]

end


;; =========================================---------------------------------------
;; Lade Daten für Karte
;; =========================================---------------------------------------

to Kartendaten

  show "Loading patches..."

  gis:apply-coverage countries-dataset "EWZ" population
  gis:apply-coverage countries-dataset "KFL" area
  gis:apply-coverage countries-dataset "GEN" country-name
  gis:apply-coverage countries-dataset "STRUKTUR" verstaedterung ;Ausprägungen sind "laendlich", "tw_staedtisch", "staedtisch"
 ;gis:apply-coverage countries-dataset "LAGE" lage ; Ausprägungen sind "sehr peripher", "peripher", "zentral", "seht zentral"
  gis:apply-coverage countries-dataset "FZGB_GES" fzgbest
  gis:apply-coverage countries-dataset "BULA" bula

  ;ask patches with [area > 0 and population > 0] [set population-density (population / area)]
  ;ask patches with [area = 0] [set population-density 0]

  ask patches with [area > 0 and fzgbest > 0] [set fzg-density ((fzgbest / 1.5) / area)]
  ask patches with [area = 0] [set fzg-density 0]

end

;; ##########################################################################################
;; ##########################################################################################
;; =========================================---------------------------------------
;; SETUP
;; =========================================---------------------------------------
;; ##########################################################################################
;; ##########################################################################################

;; =========================================---------------------------------------
;; Erstellen und Darstellen der Haushalte
;; =========================================---------------------------------------

to setup-hh

  ask hh [ die ]

  set nr_patches count patches with [fzgbest > 0]

  set csv csv:from-file "mid8.csv"

  ask patches [

    if (fzgbest > 0) [
      let num-people ((fzg-density * ((Anzahl-Fahrzeughalter) / 46455203)) * round(357376 / nr_patches));
      sprout-hh (num-people) [ agent-setup country-name ]

      let fractional-part (num-people - (floor num-people))
      if (fractional-part > random-float 1) [ sprout-hh 1 [ agent-setup country-name] ]
    ]
  ]

  ask patches [set fzganzahl_patches count turtles-here]

  ask hh [set bula1 bula]
  ask hh [set verstaedterung1 verstaedterung]
  ask hh [set nfzg 0]
  ask hh [set hheink1 0]
  ask hh [set fahrlj_h1 0]

  let blaender (list "Bayern" "Hessen" "Saarland" "Brandenburg" "Berlin" "Hamburg" "Nordrhein-Westfalen" "Mecklenburg-Vorpommern"
    "Sachsen" "Schleswig-Holstein" "Niedersachsen" "Bremen" "Rheinland-Pfalz" "Baden-Wuerttemberg" "Sachsen-Anhalt" "Thueringen")

  let verstadterung2 (list "staedtisch" "tw_staedtisch" "laendlich")

  ;ask hh with [bula1 = "Thüringen"] [set bula1 "Thueringen"]

; ------------------------------------------------------------------------------------------------------------------

  foreach blaender [
    [y] -> let b y
    foreach verstadterung2 [
      [z] -> let c z

      set subset-area1 []

      foreach csv [
        [x] -> let a x
        if (item 2 a = b and item 3 a = c) [set subset-area1 lput a subset-area1]
        ;print(length subset-area1)
      ]
      if length subset-area1 != 0 [ask hh with [bula1 = b and verstaedterung1 = c] [set nfzg (item (random length subset-area1) subset-area1)]
      ask hh with [bula1 = b and verstaedterung1 = c] [set hheink1 (item 5 nfzg)]
      ask hh with [bula1 = b and verstaedterung1 = c] [set fahrlj_h1 (item 6 nfzg)]
      ask hh with [bula1 = b and verstaedterung1 = c] [set nfzg (item 4 nfzg)]]
    ]
    ]

 ;ask hh [if (nfzg = 0) [set nfzg 1 set fahrlj_h1 5000 set hheink1 1]] ; Einzelne hh werden keinerlei Informationen zugeteilt aufgrund der CSV-Datei. Bsp: Sachsen laendlich existiert nicht. Muss in MID Daten angepasst werden.

  ask hh with [nfzg = 1] [set fz1 "h" set fz2 "x" set fz3 "x" set fz4 "x"] ;übertagung Fahrzeuganzahl an Agenten
  ask hh with [nfzg = 2] [set fz1 "h" set fz2 "h" set fz3 "x" set fz4 "x"]
  ask hh with [nfzg = 3] [set fz1 "h" set fz2 "h" set fz3 "h" set fz4 "x"]
  ask hh with [nfzg > 4] [set nfzg 4]
  ask hh with [nfzg = 4] [set fz1 "h" set fz2 "h" set fz3 "h" set fz4 "h"]

  show (word "Randomly created " (count hh) " people")

  ask n-of (count hh * 0.025) hh [set typ "innovators" set color green]
  ask n-of (count hh * 0.135) hh with [typ = 0] [set typ "early-adopters" set color yellow]
  ask n-of (count hh * 0.34) hh with [typ = 0]  [set typ "early-majority" set color orange]
  ask n-of (count hh * 0.34) hh with [typ = 0]  [set typ "late-majority" set color red]
  ask hh with [typ = 0] [set typ "laggards" set color grey]

end

to agent-setup [ ctry ]  ;set up agent parameters, including the country of the agent

  set shape "dot"
  set size 1.7
  set agent-country-name ctry

end

;; =========================================---------------------------------------
;; Setup
;; =========================================---------------------------------------

to setup


  import-drawing "data/germany.png"

  if (indx != 1) [setup-de Kartendaten] ;Netzwerk wird nach jedem Setup neu geladen

  setup-hh
  setup-netzwerk-2

  set indx 1

  ask kfz [ die ]
  setup-kfz

  ask hh [set shape "dot" set size 2]

  ask hh with [typ = "innovators"]   [set schwelle schwelle_inno set letzte_entscheidung_1 (random Haltedauer) set letzte_entscheidung_2 (random Haltedauer) set letzte_entscheidung_3 (random Haltedauer) set letzte_entscheidung_4 (random Haltedauer)] ;set infos 10]
  ask hh with [typ = "early-adopters"] [set schwelle schwelle_earlya set letzte_entscheidung_1 (random Haltedauer) set letzte_entscheidung_2 (random Haltedauer) set letzte_entscheidung_3 (random Haltedauer) set letzte_entscheidung_4 (random Haltedauer)]
  ask hh with [typ = "early-majority"] [set schwelle schwelle_earlyma set letzte_entscheidung_1 (random Haltedauer) set letzte_entscheidung_2 (random Haltedauer) set letzte_entscheidung_3 (random Haltedauer) set letzte_entscheidung_4 (random Haltedauer)]
  ask hh with [typ = "late-majority"] [set schwelle schwelle_latema set letzte_entscheidung_1 (random Haltedauer) set letzte_entscheidung_2 (random Haltedauer) set letzte_entscheidung_3 (random Haltedauer) set letzte_entscheidung_4 (random Haltedauer)]
  ask hh with [typ = "laggards"] [set schwelle schwelle_laggards set letzte_entscheidung_1 (random Haltedauer) set letzte_entscheidung_2 (random Haltedauer) set letzte_entscheidung_3 (random Haltedauer) set letzte_entscheidung_4 (random Haltedauer)]

  ;ask hh with [typ = "innovators"]   [set color green set schwelle schwelle_inno set letzte_entscheidung_1 (random Haltedauer) set letzte_entscheidung_2 (random Haltedauer) set letzte_entscheidung_3 (random Haltedauer) set letzte_entscheidung_4 (random Haltedauer)] ;set infos 10]
  ;ask hh with [typ = "early-adopters"] [set color yellow set schwelle schwelle_earlya set letzte_entscheidung_1 (random Haltedauer) set letzte_entscheidung_2 (random Haltedauer) set letzte_entscheidung_3 (random Haltedauer) set letzte_entscheidung_4 (random Haltedauer)]
  ;ask hh with [typ = "early-majority"] [set color orange set schwelle schwelle_earlyma set letzte_entscheidung_1 (random Haltedauer) set letzte_entscheidung_2 (random Haltedauer) set letzte_entscheidung_3 (random Haltedauer) set letzte_entscheidung_4 (random Haltedauer)]
  ;ask hh with [typ = "late-majority"] [set color red set schwelle schwelle_latema set letzte_entscheidung_1 (random Haltedauer) set letzte_entscheidung_2 (random Haltedauer) set letzte_entscheidung_3 (random Haltedauer) set letzte_entscheidung_4 (random Haltedauer)]
  ;ask hh with [typ = "laggards"] [set color grey set schwelle schwelle_laggards set letzte_entscheidung_1 (random Haltedauer) set letzte_entscheidung_2 (random Haltedauer) set letzte_entscheidung_3 (random Haltedauer) set letzte_entscheidung_4 (random Haltedauer)]

  ;ask hh [set bemw_hh hheink]

  ;--------------------------------------------------------------------------------
  ;Einkommensverteilung der Personen
  ;--------------------------------------------------------------------------------

  ask hh with [hheink1 = 1] [set Einkommen  500]
  ask hh with [hheink1 = 2] [set Einkommen  900]
  ask hh with [hheink1 = 3] [set Einkommen  1500]
  ask hh with [hheink1 = 4] [set Einkommen  2000]
  ask hh with [hheink1 = 5] [set Einkommen  2600]
  ask hh with [hheink1 = 6] [set Einkommen  3000]
  ask hh with [hheink1 = 7] [set Einkommen  3600]
  ask hh with [hheink1 = 8] [set Einkommen  4000]
  ask hh with [hheink1 = 9] [set Einkommen  4600]
  ask hh with [hheink1 = 10] [set Einkommen  5000]
  ask hh with [hheink1 = 11] [set Einkommen  5600]
  ask hh with [hheink1 = 12] [set Einkommen  6000]
  ask hh with [hheink1 = 13] [set Einkommen  6600]
  ask hh with [hheink1 = 14] [set Einkommen  7000]
  ask hh with [hheink1 = 15] [set Einkommen  7500]

  set Durchschnittseink mean [Einkommen] of hh
  set Durchschnittsfahrstrecke mean [fahrlj_h1] of hh


  set number_e 0
  set year 0
  reset-ticks

  ; globalen Variablen werden zu Beginn wieder auf 0 gesetzt

  set preis_nw_e 0
  set max_reich 0
  set preis_e 0
  set zuwachs_reichweite 0
  set preis_nw_h 0
  set market_doubling 0
  set Reichweite_nw_e 0
  set Reichweite_nw_h 0
  set Preis_nw_h 0
  set Preis_nw_e 0
  set Faktor_Preis 0
  set Ende_Range 0
  set Umweltbonus 0
  set Gesamtemissionen 0
  set Gesamtemissionen_hochgerechnet 0
  set Gesamtemission_Jahr 0
  set CO2-Emission_H 0
  set CO2-Emission_P 0
  set CO2-Emission_E 0
  set Gesamtfahrleistung 0

  ask hh [set mundprop_nw_h 0]
  ask hh [set mundprop_nw_e 0]
  ask hh [set mundprop_nw_p 0]

  plot-pen-up
  plotxy 0 0
  plot-pen-down

  ;ask hh with [typ = "innovators"] [set Faktor_Plugin 1]
  ;ask hh with [typ = "early-adopters"] [set Faktor_Plugin 1.2]
  ;ask hh with [typ = "early-majority"] [set Faktor_Plugin 1.2]
  ;ask hh with [typ = "late-majority"] [set Faktor_Plugin 1.1]
  ;ask hh with [typ = "laggards"] [set Faktor_Plugin 1]

end

;; =========================================---------------------------------------
;; Setup Fahrzeuge
;; =========================================---------------------------------------

to setup-kfz

  create-kfz 1 [set antrieb "h" set reichweite 600 hide-turtle]

  create-kfz 1 [set antrieb "e" set reichweite 200 hide-turtle]

  create-kfz 1 [set antrieb "p" set reichweite 600 hide-turtle]

end

;; =========================================---------------------------------------
;; Erstellen des Netzwerks
;; =========================================---------------------------------------


to setup-netzwerk-2

  ask hh with [verstaedterung = "laendlich" and count my-links < Nachbarn_laendlich] [carefully [create-links-with (min-n-of Nachbarn_laendlich (other hh in-radius 8 with [not link-neighbor? myself]) [distance myself])] [carefully [create-links-with (min-n-of Nachbarn_laendlich (other hh in-radius 10 with [not link-neighbor? myself]) [distance myself])] []]]

  ask hh with [verstaedterung = "tw_staedtisch" and count my-links < tw_staedtisch] [carefully [create-links-with (min-n-of tw_staedtisch (other hh in-radius 6 with [not link-neighbor? myself]) [distance myself])] [carefully [create-links-with (min-n-of tw_staedtisch (other hh in-radius 10 with [not link-neighbor? myself]) [distance myself])] []]]

  ask hh with [verstaedterung = "staedtisch" and count my-links < staedtisch] [carefully [create-links-with (min-n-of staedtisch (other hh in-radius 4 with [not link-neighbor? myself]) [distance myself])] [carefully [create-links-with (min-n-of staedtisch (other hh in-radius 10 with [not link-neighbor? myself]) [distance myself])] []]]

end


to setup-netzwerk-3

  ;;-------------------------------------------------
  ;; Aufteilung auf Lage und Typen hh plus Verteilung
  ;;-------------------------------------------------


  ;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  ;;innovators
  ;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  ask hh with [verstaedterung = "laendlich" and typ = "innovators"] [create-links-with (min-n-of Nachbarn_laendlich (other hh with [typ = "innovators" and not link-neighbor? myself]) [distance myself])]

  ask hh with [verstaedterung = "laendlich" and typ = "innovators"] [create-links-with (min-n-of Nachbarn_laendlich (other hh with [not link-neighbor? myself]) [distance myself])]


  ask hh with [verstaedterung = "tw_staedtisch" and typ = "innovators"] [create-links-with (min-n-of tw_staedtisch (other hh with [typ = "innovators" and not link-neighbor? myself]) [distance myself])]

  ask hh with [verstaedterung = "tw_staedtisch" and typ = "innovators"] [create-links-with (min-n-of tw_staedtisch (other hh with [not link-neighbor? myself]) [distance myself])]


  ask hh with [verstaedterung = "staedtisch" and typ = "innovators"] [create-links-with (min-n-of staedtisch (other hh with [typ = "innovators" and not link-neighbor? myself]) [distance myself])]

  ask hh with [verstaedterung = "staedtisch" and typ = "innovators"] [create-links-with (min-n-of staedtisch (other hh with [not link-neighbor? myself]) [distance myself])]

  ; --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  ;;early-adopter
  ;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  ask hh with [verstaedterung = "laendlich" and typ = "early-adopters"] [create-links-with (min-n-of Nachbarn_laendlich (other hh with [typ = "early-adopters" and not link-neighbor? myself]) [distance myself])]

  ask hh with [verstaedterung = "laendlich" and typ = "early-adopters"] [create-links-with (min-n-of Nachbarn_laendlich (other hh with [not link-neighbor? myself]) [distance myself])]


  ask hh with [verstaedterung = "tw_staedtisch" and typ = "early-adopters"] [create-links-with (min-n-of tw_staedtisch (other hh with [typ = "early-adopters" and not link-neighbor? myself]) [distance myself])]

  ask hh with [verstaedterung = "tw_staedtisch" and typ = "early-adopters"] [create-links-with (min-n-of tw_staedtisch (other hh with [not link-neighbor? myself]) [distance myself])]


  ask hh with [verstaedterung = "staedtisch" and typ = "early-adopters"] [create-links-with (min-n-of staedtisch (other hh with [typ = "early-adopters" and not link-neighbor? myself]) [distance myself])]

  ask hh with [verstaedterung = "staedtisch" and typ = "early-adopters"] [create-links-with (min-n-of staedtisch (other hh with [not link-neighbor? myself]) [distance myself])]


  ;-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  ;;early-majority
  ;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  ask hh with [verstaedterung = "laendlich" and typ = "early-majority"] [create-links-with (min-n-of Nachbarn_laendlich (other hh with [typ = "early-majority" and not link-neighbor? myself]) [distance myself])]

  ask hh with [verstaedterung = "laendlich" and typ = "early-majority"] [create-links-with (min-n-of Nachbarn_laendlich (other hh with [not link-neighbor? myself]) [distance myself])]


  ask hh with [verstaedterung = "tw_staedtisch" and typ = "early-majority"] [create-links-with (min-n-of tw_staedtisch (other hh with [typ = "early-majority" and not link-neighbor? myself]) [distance myself])]

  ask hh with [verstaedterung = "tw_staedtisch" and typ = "early-majority"] [create-links-with (min-n-of tw_staedtisch (other hh with [not link-neighbor? myself]) [distance myself])]


  ask hh with [verstaedterung = "staedtisch" and typ = "early-majority"] [create-links-with (min-n-of staedtisch (other hh with [typ = "early-majority" and not link-neighbor? myself]) [distance myself])]

  ask hh with [verstaedterung = "staedtisch" and typ = "early-majority"] [create-links-with (min-n-of staedtisch (other hh with [not link-neighbor? myself]) [distance myself])]

  ;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  ;;late-majority
  ;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  ask hh with [verstaedterung = "laendlich" and typ = "late-majority"] [create-links-with (min-n-of Nachbarn_laendlich (other hh with [typ = "late-majority" and not link-neighbor? myself]) [distance myself])]

  ask hh with [verstaedterung = "laendlich" and typ = "late-majority"] [create-links-with (min-n-of Nachbarn_laendlich (other hh with [not link-neighbor? myself]) [distance myself])]


  ask hh with [verstaedterung = "tw_staedtisch" and typ = "late-majority"] [create-links-with (min-n-of tw_staedtisch (other hh with [typ = "late-majority" and not link-neighbor? myself]) [distance myself])]

  ask hh with [verstaedterung = "tw_staedtisch" and typ = "late-majority"] [create-links-with (min-n-of tw_staedtisch (other hh with [not link-neighbor? myself]) [distance myself])]


  ask hh with [verstaedterung = "staedtisch" and typ = "late-majority"] [create-links-with (min-n-of staedtisch (other hh with [typ = "late-majority" and not link-neighbor? myself]) [distance myself])]

  ask hh with [verstaedterung = "staedtisch" and typ = "late-majority"] [create-links-with (min-n-of staedtisch (other hh with [not link-neighbor? myself]) [distance myself])]

  ; --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  ;;laggards
  ;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


  ask hh with [verstaedterung = "laendlich" and typ = "laggards"] [create-links-with (min-n-of Nachbarn_laendlich (other hh with [typ = "laggards" and not link-neighbor? myself]) [distance myself])]

  ask hh with [verstaedterung = "laendlich" and typ = "laggards"] [create-links-with (min-n-of Nachbarn_laendlich (other hh with [not link-neighbor? myself]) [distance myself])]


  ask hh with [verstaedterung = "tw_staedtisch" and typ = "laggards"] [create-links-with (min-n-of tw_staedtisch (other hh with [typ = "laggards" and not link-neighbor? myself]) [distance myself])]

  ask hh with [verstaedterung = "tw_staedtisch" and typ = "laggards"] [create-links-with (min-n-of tw_staedtisch (other hh with [not link-neighbor? myself]) [distance myself])]


  ask hh with [verstaedterung = "staedtisch" and typ = "laggards"] [create-links-with (min-n-of staedtisch (other hh with [typ = "laggards" and not link-neighbor? myself]) [distance myself])]

  ask hh with [verstaedterung = "staedtisch" and typ = "laggards"] [create-links-with (min-n-of staedtisch (other hh with [not link-neighbor? myself]) [distance myself])]


  ; ask turtles [ create-links-with (min-n-of links-per-node (other turtles with [not link-neighbor? myself]) [distance myself])]

end


;; ##########################################################################################
;; ##########################################################################################
;; =========================================---------------------------------------
;; GO
;; =========================================---------------------------------------
;; ##########################################################################################
;; ##########################################################################################

to go

   ;if year = 30
   if year = Jahr
  [
    file-close
    stop
  ]

  if year >= 5 and year <= 10 [set umweltbonus 4000] ;Feste Einstellung des Umweltbonus ab Jahr 5 für die Simulation im BehaviourSpace
  ;if year > 10 [set umweltbonus 0]

;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Batteriekosten COGSn = (D1)^n * MCo + (D2)^n * OHo + (D3)^n + Lo    D1 = 0,765 discount factor for (material cost), D2 = 0757 discount factor for (overhead and profit), D3 = 0,574 discount factor for (learning curves)
; n = 0 for inital conditions in 2015
; n = n + 1 for each market doubling
; SPn = COGSn * 1,15 * 1,35
; Market doubling startet bei 0,05 von der Gesamtanzahl an Fahrzeugen (lineare Interpolation)   y = y2 + (y2 - y1 / x2 - x1) * (x - x1)  y = steht für marketdoubling und x für den Anteil an Fahrzeugen
;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  set Anzahl_E count hh with [fz1 = "e"] + count hh with [fz2 = "e"] + count hh with [fz3 = "e"] + count hh with [fz4 = "e"]

  set Anzahl_P count hh with [fz1 = "p"] + count hh with [fz2 = "p"] + count hh with [fz3 = "p"] + count hh with [fz4 = "p"]

  set Anzahl_H count hh with [fz1 = "h"] + count hh with [fz2 = "h"] + count hh with [fz3 = "h"] + count hh with [fz4 = "h"]

  set Gesamt_EPH count hh with [fz1 != "x"] + count hh with [fz2 != "x"] + count hh with [fz3 != "x"] +  count hh with [fz4 != "x"]


  if ((Anzahl_E + Anzahl_P * 0.5) < 0.01 * Gesamt_EPH) and ((Anzahl_E + Anzahl_P * 0.5) >= 0)  [set market_doubling 1]

  if ((Anzahl_E + Anzahl_P * 0.5) < 0.02 * Gesamt_EPH) and ((Anzahl_E + Anzahl_P * 0.5) > 0.01 * Gesamt_EPH) [set market_doubling (1 + ((2 - 1) / (0.02 - 0.001)) * ((Anzahl_E / Gesamt_EPH) - 0.01))]

  if ((Anzahl_E + Anzahl_P * 0.5) < 0.04 * Gesamt_EPH) and ((Anzahl_E + Anzahl_P * 0.5) > 0.02 * Gesamt_EPH) [set market_doubling (2 + ((3 - 2) / (0.04 - 0.02)) * ((Anzahl_E / Gesamt_EPH) - 0.02))]

  if ((Anzahl_E + Anzahl_P * 0.5) < 0.08 * Gesamt_EPH) and ((Anzahl_E + Anzahl_P * 0.5) > 0.04 * Gesamt_EPH) [set market_doubling (3 + ((4 - 3) / (0.08 - 0.04)) * ((Anzahl_E / Gesamt_EPH) - 0.04))]

  if ((Anzahl_E + Anzahl_P * 0.5) < 0.16 * Gesamt_EPH) and ((Anzahl_E + Anzahl_P * 0.5) > 0.08 * Gesamt_EPH) [set market_doubling (4 + ((5 - 4) / (0.16 - 0.08)) * ((Anzahl_E / Gesamt_EPH) - 0.08))]

  if ((Anzahl_E + Anzahl_P * 0.5) < 1 * Gesamt_EPH) and (Anzahl_E > 0.16 * Gesamt_EPH) [set market_doubling 5]

  set SPn 1.15 * 1.35 * ((0.765) ^ (market_doubling)) * Materialkosten + ((0.757) ^ market_doubling) * (0.08 * Materialkosten) + ((0.574) ^ market_doubling) * (0.15 * Materialkosten)

  set Preis_EFahrzeug (Preis_Eauto + SPn - Umweltbonus)

  set SPn_plugin 1.15 * 1.35 * ((0.765) ^ (market_doubling)) * Materialkosten_plugin + ((0.757) ^ market_doubling) * (0.08 * Materialkosten_plugin) + ((0.574) ^ market_doubling) * (0.15 * Materialkosten_plugin)

  set Preis_plugin_1 (Preis_plugin + SPn_plugin - (0.75 * Umweltbonus)) ;Der Umweltbonus ist für Plug-In Hybride geringer als für reine Elektrofahrzeuge


;; -------------------------------------------------------------------------------------------------------------------------
;; Forschungsförderung Zeitlich abhängige Funktion wurde hizugefügt. Dadurch die Bedeutsamkeit der Forschungsforderung.
;; -------------------------------------------------------------------------------------------------------------------------

  set zuwachs_reichweite 25 * exp(Forschungsfoerderung / 250)

;; ---------------------------------------------------------------------------------------------------------------------
;; Begrenzung der Reichweite auf einen maximalen Wert von 600 km sowohl für E-Fahrzeuge als auch herkömmliche Fahrzeuge
;; ---------------------------------------------------------------------------------------------------------------------

  ask kfz with [antrieb = "e"] [ifelse (reichweite + zuwachs_reichweite < 600)[set reichweite reichweite + zuwachs_reichweite] [set reichweite 600]]

;;---------------------------------------------------------------------------------
;; Brennstoffvergleich E-Auto und herkömmliches Fahrzeug (Linear)
;;---------------------------------------------------------------------------------

  set kraftstoffpreis_konv_var 0.0033 * year + (Ökosteuer * Preis_konventionell_Liter)

  set strompreis_var 0.0081 * year + preis_strom_kWh ; Der variable Strompreis wird mit den Werten ab 2012 ermittelt und fortlaufend berechnet

  set brennstoff_h (kraftstoffpreis_konv_var * Verbrauch_konventionell) / 100 ; Der Krafstoffpreis steigt an

  set brennstoff_e (strompreis_var * Verbrauch_E-Auto) / 100

  set brennstoff_p (((0.1 * (strompreis_var * Verbrauch_E-Auto) / 100)) + (0.9 * (Preis_konventionell_Liter * Verbrauch_konventionell) / 100))

;; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;; Brennstoffpreise werden bestimmt und mit Nutzwerten versehen
;; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  ask hh [if brennstoff_h > brennstoff_e and brennstoff_p > brennstoff_e  [set brennstoff_nw_e 100 set brennstoff_nw_h (100 - (((brennstoff_h * fahrlj_h1) / 100) - ((brennstoff_e * fahrlj_h1) / 100) / 100)) set brennstoff_nw_p ((100 - ((brennstoff_h * fahrlj_h1) / 100)) - ((0.1 * (brennstoff_e) / 100) + (0.9 * (brennstoff_h) / 100)) / 100)]]

;;---------------------------------------------------------------------------------
;; C02-Emissionen -> muss noch angepasst werden
;;---------------------------------------------------------------------------------

  if year = 0 [set Gesamtemissionen 0]

  set Gesamtfahrleistung sum [fahrlj_h1] of hh

  set CO2-Emission_H ((Anzahl_H * 100 / Gesamt_EPH) * Gesamtfahrleistung * (0.002 * (Verbrauch_konventionell / 100)))
  set CO2-Emission_E ((Anzahl_E * 100 / Gesamt_EPH) * Gesamtfahrleistung * (0.000489 * (Verbrauch_E-Auto / 100))) ;Deutscher Strommix = 0,000489 tCO2/kWh
  set CO2-Emission_P (Anzahl_P * 100 / Gesamt_EPH) * Gesamtfahrleistung * ((0.9 *  0.002 * (Verbrauch_konventionell / 100) + (0.000489 * 0.1 * (Verbrauch_E-Auto / 100))))
  set CO2-Emission_H_100 ((Gesamt_EPH * 100 / Gesamt_EPH) * Gesamtfahrleistung * (0.002 * (Verbrauch_konventionell / 100)))
  set Gesamtemission_Jahr 100 * (CO2-Emission_H + CO2-Emission_E + CO2-Emission_P) / CO2-Emission_H_100

;;-------------------------------------------------------------------------------------
;; Bestimmung des Nutzwertes für die Reichweite anhand einer S-Kurve
;;-------------------------------------------------------------------------------------

   set Startwert 100

   set Steigung 0.0165

   set Variable 200 ; 100

   set Reichweite_nw_e Startwert / (1 + (Variable) * exp (- Steigung * ([reichweite] of one-of kfz with [antrieb = "e"])))

   set Reichweite_nw_h Startwert / (1 + (Variable) * exp (- Steigung * ([reichweite] of one-of kfz with [antrieb = "h"])))

   set Reichweite_nw_p Startwert / (1 + (Variable) * exp (- Steigung * ([reichweite] of one-of kfz with [antrieb = "p"])))

;;-------------------------------------------------------------------------------------
;; Bestimmung des Nutzwertes für den Preis anhand einer S-Kurve
;;-------------------------------------------------------------------------------------

   set Startwert 100

   set Steigung 0.0001

   set Variable 200    ;100, 150

   set Preis_nw_e 100 - (Startwert / (1 + (Variable) * exp (- Steigung * (Preis_EFahrzeug))))

   set Preis_nw_h 100 - (Startwert / (1 + (Variable) * exp (- Steigung * (Preis_konventionell))))

   set Preis_nw_p 100 - (Startwert / (1 + (Variable) * exp (- Steigung * (Preis_plugin_1))))

;;-----------------------------------------
;; Kaufentscheidung abhängig vom Einkommen
;;-----------------------------------------

 ; Durchschnittswert aller Einkommen bestimmt, diesen anschließend mit 2 multipliziert um eine Range zu erstellen. Der Faktor wird also zwischen 0-2 festgelegt und anschließend mit dem Nutzwert des Preises multipliziert.
 ; Die Berechnungsgrundlage ist: Range (0 2); Ende_Range = (bemw * (2/bemw * 2); Faktor_Preis = (bemw * Ende_Range)

  set Ende_Range (1 / Durchschnittseink)

  ask hh [if (Einkommen > 7000) [set Faktor_Preis 0]]

  ask hh [if (Einkommen > Durchschnittseink and Einkommen <= 7000) [set Faktor_Preis (1 - (Ende_Range * Einkommen) + 1)]]

  ask hh [if (Einkommen = Durchschnittseink) [set Faktor_Preis 1]]

  ask hh [if (Einkommen < Durchschnittseink) [set Faktor_Preis (1 - (Ende_Range * Einkommen) + 1)]]

;; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;; Mundpropaganda
;; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    ;mundprop_e -> innovators

   ask hh [set mundprop_e 0]
   ask hh [set mundprop_h 0]

   ;Mundpropaganda Startwert

   ask hh with [typ = "innovators"] [set mundprop_e 100]

   ask hh with [typ = "early-adopters"] [set mundprop_e 50]

   ask hh with [typ ="early-majority"] [set mundprop_e 0]

   ask hh with [typ = "late-majority"] [set mundprop_h 50]

   ask hh with [typ = "laggards"] [set mundprop_h 100]

   ;Mundpropaganda_E_Wert von hh mit E-Auto

   ask hh with [typ = "innovators" and shape = "car"] [ask link-neighbors [set mundprop_e (mundprop_e + 50)]]
   ask hh with [typ = "early-adopters" and shape = "car"] [ask link-neighbors [set mundprop_e (mundprop_e + 40)]]
   ask hh with [typ = "early-majority" and shape = "car"] [ask link-neighbors [set mundprop_e (mundprop_e + 30)]]
   ask hh with [typ = "late-majority" and shape = "car"] [ask link-neighbors [set mundprop_e (mundprop_e + 20)]]
   ask hh with [typ = "laggards" and shape = "car"] [ask link-neighbors [set mundprop_e (mundprop_e + 10)]]

   ;Mundpropaganda_H_Wert von hh mit E-Auto

   ask hh with [typ = "innovators" and shape = "car"] [ask link-neighbors [set mundprop_h (mundprop_h + 5)]]
   ask hh with [typ = "early-adopters" and shape = "car"] [ask link-neighbors [set mundprop_h (mundprop_h + 10)]]
   ask hh with [typ = "early-majority" and shape = "car"] [ask link-neighbors [set mundprop_h (mundprop_h + 15)]]
   ask hh with [typ = "late-majority" and shape = "car"] [ask link-neighbors [set mundprop_h (mundprop_h + 20)]]
   ask hh with [typ = "laggards" and shape = "car"] [ask link-neighbors [set mundprop_h (mundprop_h + 25)]]

   ;Mundpropaganda_E_Wert von hh ohne E-Auto

   ask n-of (count hh with [typ = "innovators" and shape = "dot"]) hh with [typ = "innovators" and shape = "dot"] [ask link-neighbors [set mundprop_e (mundprop_e + 25)]]
   ask n-of (count hh with [typ = "innovators" and shape = "dot"] * (Anz_inno)) hh with [typ = "innovators" and shape = "dot"] [ask self [set mundprop_e ((Kampagnen) * (mundprop_e + 25))] ask link-neighbors [set mundprop_e ((Kampagnen) * (mundprop_e + 25))]]

   ask n-of (count hh with [typ = "early-adopters" and shape = "dot"]) hh with [typ = "early-adopters" and shape = "dot"] [ask link-neighbors [set mundprop_e (mundprop_e + 20)]]
   ask n-of (count hh with [typ = "early-adopters" and shape = "dot"] * (Anz_earlya)) hh with [typ = "early-adopters" and shape = "dot"] [ask self [set mundprop_e ((Kampagnen) * (mundprop_e + 20))] ask link-neighbors [set mundprop_e ((Kampagnen) * (mundprop_e + 20))]]

   ask n-of (count hh with [typ = "early-majority" and shape = "dot"]) hh with [typ = "early-majority" and shape = "dot"] [ask link-neighbors [set mundprop_e (mundprop_e + 15)]]
   ask n-of (count hh with [typ = "early-majority" and shape = "dot"] * (Anz_earlyma)) hh with [typ = "early-majority" and shape = "dot"] [ask self [set mundprop_e ((Kampagnen) * (mundprop_e + 15))] ask link-neighbors [set mundprop_e ((Kampagnen) * (mundprop_e + 15))]]

   ask n-of (count hh with [typ = "late-majority" and shape = "dot"]) hh with [typ = "late-majority" and shape = "dot"] [ask link-neighbors [set mundprop_e (mundprop_e + 10)]]
   ask n-of (count hh with [typ = "late-majority" and shape = "dot"] * (Anz_latema)) hh with [typ = "late-majority" and shape = "dot"] [ask self [set mundprop_e ((Kampagnen) * (mundprop_e + 10))] ask link-neighbors [set mundprop_e ((Kampagnen) * (mundprop_e + 10))]]

   ask n-of (count hh with [typ = "laggards" and shape = "dot"]) hh with [typ = "laggards" and shape = "dot"] [ask link-neighbors [set mundprop_e (mundprop_e + 5)]]
   ask n-of (count hh with [typ = "laggards" and shape = "dot"] * (Anz_laggards)) hh with [typ = "laggards" and shape = "dot"] [ask self [set mundprop_e ((Kampagnen) * (mundprop_e + 5))] ask link-neighbors [set mundprop_e ((Kampagnen) * (mundprop_e + 5))]]

   ;Mundpropaganda_H_Wert von hh ohne E-Auto

   ask hh with [typ = "innovators" and shape = "dot"] [ask link-neighbors [set mundprop_h (mundprop_h + 10)]]
   ask hh with [typ = "early-adopters" and shape = "dot"] [ask link-neighbors [set mundprop_h (mundprop_h + 20)]]
   ask hh with [typ = "early-majority" and shape = "dot"] [ask link-neighbors [set mundprop_h (mundprop_h + 30)]]
   ask hh with [typ = "late-majority" and shape = "dot"] [ask link-neighbors [set mundprop_h (mundprop_h + 40)]]
   ask hh with [typ = "laggards" and shape = "dot"] [ask link-neighbors [set mundprop_h (mundprop_h + 50)]]

  ;Mundpropaganda_E_Wert von hh mit PlugIn-Auto

  ask hh with [typ = "innovators" and shape = "car" and color = "green"] [ask link-neighbors [set mundprop_e (mundprop_e + 25)]]
  ask hh with [typ = "early-adopters" and shape = "car" and color = "green"] [ask link-neighbors [set mundprop_e (mundprop_e + 20)]]
  ask hh with [typ = "early-majority" and shape = "car" and color = "green"] [ask link-neighbors [set mundprop_e (mundprop_e + 15)]]
  ask hh with [typ = "late-majority" and shape = "car" and color = "green"] [ask link-neighbors [set mundprop_e (mundprop_e + 10)]]
  ask hh with [typ = "laggards" and shape = "car" and color = "green"] [ask link-neighbors [set mundprop_e (mundprop_e + 5)]]

  ;Mundpropaganda_H_Wert von hh mit PlugIn-Auto

  ask hh with [typ = "innovators" and shape = "car" and color = "green"] [ask link-neighbors [set mundprop_h (mundprop_h + 5)]]
  ask hh with [typ = "early-adopters" and shape = "car" and color = "green"] [ask link-neighbors [set mundprop_h (mundprop_h + 10)]]
  ask hh with [typ = "early-majority" and shape = "car" and color = "green"] [ask link-neighbors [set mundprop_h (mundprop_h + 15)]]
  ask hh with [typ = "late-majority" and shape = "car" and color = "green"] [ask link-neighbors [set mundprop_h (mundprop_h + 20)]]
  ask hh with [typ = "laggards" and shape = "car" and color = "green"] [ask link-neighbors [set mundprop_h (mundprop_h + 25)]]


;; --------------------------------------------------------------------------------
;; Erstellen Nutzwert von mundprop_nw_e und mundprop_nw_h ---- Der jeweils beste Wert einer Kategorie wird in 100 Nutzenpunkte übersetzt, der andere Werte jeweils anteilsmäßig
;; --------------------------------------------------------------------------------

   ask hh [if mundprop_e > mundprop_h [set mundprop_nw_e 100 set mundprop_nw_h 100 * mundprop_h / mundprop_e]]

   ask hh [if mundprop_h > mundprop_e [set mundprop_nw_h 100 set mundprop_nw_e 100 * mundprop_e /  mundprop_h]]

   ask hh [if mundprop_h = mundprop_e [set mundprop_nw_h 50  set mundprop_nw_e 50]]


;; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;; Bestimmung des Nutzwertes für die Mundpropaganda anhand einer S-Kurve
;; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  ; set Startwert 100

  ; set Steigung 0.03

  ; set Variable 100

  ; ask hh [set mundprop_nw_e Startwert / (1 + (Variable) * exp (- Steigung * (mundprop_e)))]

  ; ask hh [set mundprop_nw_h Startwert / (1 + (Variable) * exp (- Steigung * (mundprop_h)))]


;;-------------------------------------------------------------------------------
;; Einzelnen Schwellenwerte mit Range
;;-------------------------------------------------------------------------------

  set schwelle_inno_range (schwelle_earlya - schwelle_inno); möglicherweis die /2 rausnehmen nachschauen!
  set schwelle_earlya_range (schwelle_earlyma - schwelle_earlya)
  set schwelle_eralyma_range (schwelle_latema - schwelle_earlyma)
  set schwelle_latema_range (schwelle_laggards - schwelle_latema)
  set schwelle_laggard (0.25)

  ask hh with [typ = "innovators"] [set range_schwelle schwelle_inno_range]
  ask hh with [typ = "early-adopters"] [set range_schwelle schwelle_earlya_range]
  ask hh with [typ = "early-majority"] [set range_schwelle schwelle_eralyma_range]
  ask hh with [typ = "late-majority"] [set range_schwelle schwelle_latema_range]
  ask hh with [typ = "laggards"] [set range_schwelle schwelle_laggard]

;; --------------------------------------------------------------------------------
;; Erstellen Nutzwert von Wartungskosten für E und H  ---- Der jeweils beste Wert einer Kategorie wird in 100 Nutzenpunkte übersetzt, der andere Werte jeweils anteilsmäßig
;; --------------------------------------------------------------------------------

  ask hh [if wartungskosten_h > wartungskosten_e and wartungskosten_p > wartungskosten_e [set wartungskosten_nw_e 100 set wartungskosten_nw_h 100 * wartungskosten_e / wartungskosten_h set wartungskosten_nw_p 100 * wartungskosten_e / wartungskosten_p]]
  ask hh [if wartungskosten_e > wartungskosten_h and wartungskosten_p > wartungskosten_h [set wartungskosten_nw_h 100 set wartungskosten_nw_e 100 * wartungskosten_h / wartungskosten_e set wartungskosten_nw_p 100 * wartungskosten_h / wartungskosten_p]]
  ask hh [if wartungskosten_h > wartungskosten_p and wartungskosten_e > wartungskosten_p [set wartungskosten_nw_p 100 set wartungskosten_nw_h 100 * wartungskosten_p / wartungskosten_h set wartungskosten_nw_e 100 * wartungskosten_p / wartungskosten_e]]
  ask hh [if wartungskosten_h = wartungskosten_e and wartungskosten_e = wartungskosten_p [set wartungskosten_nw_e 50 set wartungskosten_nw_p 50 set wartungskosten_nw_h 50]]

;; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;; Entscheidung der Haushalte
;; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  ask hh with [(letzte_entscheidung_1 = Haltedauer) and (fz1 != "x")][entscheidung_1 (set letzte_entscheidung_1 0)]
  ask hh with [(letzte_entscheidung_2 = Haltedauer) and (fz2 != "x")][entscheidung_2 (set letzte_entscheidung_2 0)]
  ask hh with [(letzte_entscheidung_3 = Haltedauer) and (fz3 != "x")][entscheidung_3 (set letzte_entscheidung_3 0)]
  ask hh with [(letzte_entscheidung_4 = Haltedauer) and (fz4 != "x")][entscheidung_4 (set letzte_entscheidung_4 0)]

;; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;; Alle hh werden mit der Variable "x" versehen damit es nicht zu überschneidungen mit der Haltedauer kommt
;; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  ask hh with [letzte_entscheidung_1 != "x"] [set letzte_entscheidung_1 letzte_entscheidung_1 + 1]
  ask hh with [letzte_entscheidung_2 != "x"] [set letzte_entscheidung_2 letzte_entscheidung_2 + 1]
  ask hh with [letzte_entscheidung_3 != "x"] [set letzte_entscheidung_3 letzte_entscheidung_3 + 1]
  ask hh with [letzte_entscheidung_4 != "x"] [set letzte_entscheidung_4 letzte_entscheidung_4 + 1]

  tick
  set year year + 1

 ;spread-info
end

;; ##########################################################################################
;; =========================================---------------------------------------
;; Unterfunktionen zu GO
;; =========================================---------------------------------------
;; ##########################################################################################

;; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;; Entscheidungsfunktion fuer Fahrzeug 1
;; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

to entscheidung_1

;; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;  Betrachet werden HH mit einem Fahrzeug daher fz2 = "x". Die Schwelle wird mit verschiedenen Werten multipliziert, um eine geschmeidigeren Verlauf zu erzielen.
;; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

 if (Faktor_Reichweite * Reichweite_nw_e + Preis_nw_e * Faktor_Preis + (mundprop_nw_e * Faktor_mundprop_e) + brennstoff_nw_e * Faktor_brennstoff + wartungskosten_nw_e * Faktor_Wartungskosten + one-of (list 0 1) * ceiling Random-Float Random_E)  >=
    (Faktor_Reichweite * Reichweite_nw_h + Preis_nw_h * Faktor_Preis + (mundprop_nw_h * Faktor_mundprop_e) + wartungskosten_nw_h * Faktor_Wartungskosten + brennstoff_nw_h * Faktor_brennstoff) * (Random-Float range_Schwelle + schwelle) + one-of (list 0 1) * ceiling Random-Float Random_H and
    (Faktor_Reichweite * Reichweite_nw_e + Preis_nw_e * Faktor_Preis + (mundprop_nw_e * Faktor_mundprop_e) + brennstoff_nw_e * Faktor_brennstoff + wartungskosten_nw_e * Faktor_Wartungskosten + one-of (list 0 1) * ceiling Random-Float Random_E) >=
    Faktor_Plugin * ((Faktor_Reichweite * Reichweite_nw_p + Preis_nw_p * Faktor_Preis + (mundprop_nw_e * Faktor_mundprop_e) + brennstoff_nw_p * Faktor_brennstoff + wartungskosten_nw_p * Faktor_Wartungskosten + one-of (list 0 1) * ceiling Random-Float Random_E)) [

     set fz1 "e"
     set color blue
     set shape "car"
     set size size - 0.2
  ]

 if Faktor_Plugin * ((Faktor_Reichweite * Reichweite_nw_p + Preis_nw_p * Faktor_Preis + (mundprop_nw_e * Faktor_mundprop_e) + brennstoff_nw_p * Faktor_brennstoff + wartungskosten_nw_p * Faktor_Wartungskosten + one-of (list 0 1) * ceiling Random-Float Random_E)) >=
    (Faktor_Reichweite * Reichweite_nw_h + Preis_nw_h * Faktor_Preis + (mundprop_nw_h * Faktor_mundprop_e) + wartungskosten_nw_h * Faktor_Wartungskosten + brennstoff_nw_h * Faktor_brennstoff) * (Random-Float range_Schwelle + schwelle) + one-of (list 0 1) * ceiling Random-Float Random_H and
    Faktor_Plugin * ((Faktor_Reichweite * Reichweite_nw_p + Preis_nw_p * Faktor_Preis + (mundprop_nw_e * Faktor_mundprop_e) + brennstoff_nw_p * Faktor_brennstoff + wartungskosten_nw_p * Faktor_Wartungskosten + one-of (list 0 1) * ceiling Random-Float Random_E)) >=
    (Faktor_Reichweite * Reichweite_nw_e + Preis_nw_e * Faktor_Preis + (mundprop_nw_e * Faktor_mundprop_e) + brennstoff_nw_e * Faktor_brennstoff + wartungskosten_nw_e * Faktor_Wartungskosten + one-of (list 0 1) * ceiling Random-Float Random_E)  [

     set fz1 "p"
     set color green
     set shape "car"
     set size size - 0.2
  ]

 if (fz1 = "p" and (Faktor_Reichweite * Reichweite_nw_e  + Preis_nw_e * Faktor_Preis + (mundprop_nw_e * Faktor_mundprop_e) + brennstoff_nw_e * Faktor_brennstoff + wartungskosten_nw_e * Faktor_Wartungskosten + one-of (list 0 1) * ceiling Random-Float Random_E) * Faktor_EP  >=
     Faktor_Plugin * ((Faktor_Reichweite * Reichweite_nw_p  + Preis_nw_p * Faktor_Preis + (mundprop_nw_e * Faktor_mundprop_e) + brennstoff_nw_p * Faktor_brennstoff + wartungskosten_nw_p * Faktor_Wartungskosten + one-of (list 0 1) * ceiling Random-Float Random_E)))[

    set fz1 "e"
    set color blue
    set shape "car"
    set size size - 0.2
 ]


end


to entscheidung_2

;; --------------------------------------------------------------------------------------------------------------------------------------------------------------
;  Betrachet werden HH mit zwei herkömmlichen Fahrzeugen fz1 = "h" und fz2 = "h". Hierbei wird das Reichweitenkriterium bei der Berechnung nicht berücksichtigt.
;; ---------------------------------------------------------------------------------------------------------------------------------------------------------------

 if (Preis_nw_e * Faktor_Preis + (mundprop_nw_e * Faktor_mundprop_e) + brennstoff_nw_e * Faktor_brennstoff + wartungskosten_nw_e * Faktor_Wartungskosten + one-of (list 0 1) * ceiling Random-Float Random_E)  >=
    (Preis_nw_h * Faktor_Preis + (mundprop_nw_h * Faktor_mundprop_e) + wartungskosten_nw_h * Faktor_Wartungskosten + brennstoff_nw_h * Faktor_brennstoff) * (Random-Float range_Schwelle + schwelle) + one-of (list 0 1) * ceiling Random-Float Random_H and
    (Preis_nw_e * Faktor_Preis + (mundprop_nw_e * Faktor_mundprop_e) + brennstoff_nw_e * Faktor_brennstoff + wartungskosten_nw_e * Faktor_Wartungskosten + one-of (list 0 1) * ceiling Random-Float Random_E) >=
    Faktor_Plugin * (Preis_nw_p * Faktor_Preis + (mundprop_nw_e * Faktor_mundprop_e) + brennstoff_nw_p * Faktor_brennstoff + wartungskosten_nw_p * Faktor_Wartungskosten + one-of (list 0 1) * ceiling Random-Float Random_E)  [

     set fz2 "e"
     set color blue
     set shape "car"
     set size size - 0.2
  ]

 if Faktor_Plugin * (Preis_nw_p * Faktor_Preis + (mundprop_nw_e * Faktor_mundprop_e) + brennstoff_nw_p * Faktor_brennstoff + wartungskosten_nw_p * Faktor_Wartungskosten + one-of (list 0 1) * ceiling Random-Float Random_E)  >=
    (Preis_nw_h * Faktor_Preis + (mundprop_nw_h * Faktor_mundprop_e) + wartungskosten_nw_h * Faktor_Wartungskosten + brennstoff_nw_h * Faktor_brennstoff) * (Random-Float range_Schwelle + schwelle) + one-of (list 0 1) * ceiling Random-Float Random_H and
    Faktor_Plugin * (Preis_nw_p * Faktor_Preis + (mundprop_nw_e * Faktor_mundprop_e) + brennstoff_nw_p * Faktor_brennstoff + wartungskosten_nw_p * Faktor_Wartungskosten + one-of (list 0 1) * ceiling Random-Float Random_E) >=
    (Preis_nw_e * Faktor_Preis + (mundprop_nw_e * Faktor_mundprop_e) + brennstoff_nw_e * Faktor_brennstoff + wartungskosten_nw_e * Faktor_Wartungskosten + one-of (list 0 1) * ceiling Random-Float Random_E)  [

     set fz2 "p"
     set color green
     set shape "car"
     set size size - 0.2
  ]

 if (fz2 = "p" and (Preis_nw_e * Faktor_Preis + (mundprop_nw_e * Faktor_mundprop_e) + brennstoff_nw_e * Faktor_brennstoff + wartungskosten_nw_e * Faktor_Wartungskosten + one-of (list 0 1) * ceiling Random-Float Random_E) * Faktor_EP  >=
     Faktor_Plugin * (Preis_nw_p * Faktor_Preis + (mundprop_nw_e * Faktor_mundprop_e) + brennstoff_nw_p * Faktor_brennstoff + wartungskosten_nw_p * Faktor_Wartungskosten + one-of (list 0 1) * ceiling Random-Float Random_E))[

    set fz2 "e"
    set color blue
    set shape "car"
    set size size - 0.2
 ]


end


to entscheidung_3

;; --------------------------------------------------------------------------------------------------------------------------------------------------------------
;  Betrachet werden HH mit zwei herkömmlichen Fahrzeugen fz1 = "h" und fz2 = "h". Hierbei wird das Reichweitenkriterium bei der Berechnung nicht berücksichtigt.
;; ---------------------------------------------------------------------------------------------------------------------------------------------------------------
 if (Preis_nw_e * Faktor_Preis + (mundprop_nw_e * Faktor_mundprop_e) + brennstoff_nw_e * Faktor_brennstoff + wartungskosten_nw_e * Faktor_Wartungskosten + one-of (list 0 1) * ceiling Random-Float Random_E)  >=
    (Preis_nw_h * Faktor_Preis + (mundprop_nw_h * Faktor_mundprop_e) + wartungskosten_nw_h * Faktor_Wartungskosten + brennstoff_nw_h * Faktor_brennstoff) * (Random-Float range_Schwelle + schwelle) + one-of (list 0 1) * ceiling Random-Float Random_H and
    (Preis_nw_e * Faktor_Preis + (mundprop_nw_e * Faktor_mundprop_e) + brennstoff_nw_e * Faktor_brennstoff + wartungskosten_nw_e * Faktor_Wartungskosten + one-of (list 0 1) * ceiling Random-Float Random_E) >=
    Faktor_Plugin * (Preis_nw_p * Faktor_Preis + (mundprop_nw_e * Faktor_mundprop_e) + brennstoff_nw_p * Faktor_brennstoff + wartungskosten_nw_p * Faktor_Wartungskosten + one-of (list 0 1) * ceiling Random-Float Random_E)  [

     set fz3 "e"
     set color blue
     set shape "car"
     set size size - 0.2
  ]

 if Faktor_Plugin * (Preis_nw_p * Faktor_Preis + (mundprop_nw_e * Faktor_mundprop_e) + brennstoff_nw_p * Faktor_brennstoff + wartungskosten_nw_p * Faktor_Wartungskosten + one-of (list 0 1) * ceiling Random-Float Random_E)  >=
    (Preis_nw_h * Faktor_Preis + (mundprop_nw_h * Faktor_mundprop_e) + wartungskosten_nw_h * Faktor_Wartungskosten + brennstoff_nw_h * Faktor_brennstoff) * (Random-Float range_Schwelle + schwelle) + one-of (list 0 1) * ceiling Random-Float Random_H and
    Faktor_Plugin * (Preis_nw_p * Faktor_Preis + (mundprop_nw_e * Faktor_mundprop_e) + brennstoff_nw_p * Faktor_brennstoff + wartungskosten_nw_p * Faktor_Wartungskosten + one-of (list 0 1) * ceiling Random-Float Random_E) >=
    (Preis_nw_e * Faktor_Preis + (mundprop_nw_e * Faktor_mundprop_e) + brennstoff_nw_e * Faktor_brennstoff + wartungskosten_nw_e * Faktor_Wartungskosten + one-of (list 0 1) * ceiling Random-Float Random_E)  [

     set fz3 "p"
     set color green
     set shape "car"
     set size size - 0.2
  ]



 if (fz3 = "p" and (Preis_nw_e * Faktor_Preis + (mundprop_nw_e * Faktor_mundprop_e) + brennstoff_nw_e * Faktor_brennstoff + wartungskosten_nw_e * Faktor_Wartungskosten + one-of (list 0 1) * ceiling Random-Float Random_E) * Faktor_EP  >=
    Faktor_Plugin * (Preis_nw_p * Faktor_Preis + (mundprop_nw_e * Faktor_mundprop_e) + brennstoff_nw_p * Faktor_brennstoff + wartungskosten_nw_p * Faktor_Wartungskosten + one-of (list 0 1) * ceiling Random-Float Random_E))[

     set fz3 "e"
     set color blue
     set shape "car"
     set size size - 0.2
 ]


end

to entscheidung_4

;; --------------------------------------------------------------------------------------------------------------------------------------------------------------
;  Betrachet werden HH mit zwei herkömmlichen Fahrzeugen fz1 = "h" und fz2 = "h". Hierbei wird das Reichweitenkriterium bei der Berechnung nicht berücksichtigt.
;; ---------------------------------------------------------------------------------------------------------------------------------------------------------------

 if (Preis_nw_e * Faktor_Preis + (mundprop_nw_e * Faktor_mundprop_e) + brennstoff_nw_e * Faktor_brennstoff + wartungskosten_nw_e * Faktor_Wartungskosten + one-of (list 0 1) * ceiling Random-Float Random_E)  >=
    (Preis_nw_h * Faktor_Preis + (mundprop_nw_h * Faktor_mundprop_e) + wartungskosten_nw_h * Faktor_Wartungskosten + brennstoff_nw_h * Faktor_brennstoff) * (Random-Float range_Schwelle + schwelle) + one-of (list 0 1) * ceiling Random-Float Random_H and
    (Preis_nw_e * Faktor_Preis + (mundprop_nw_e * Faktor_mundprop_e) + brennstoff_nw_e * Faktor_brennstoff + wartungskosten_nw_e * Faktor_Wartungskosten + one-of (list 0 1) * ceiling Random-Float Random_E) >=
    Faktor_Plugin * (Preis_nw_p * Faktor_Preis + (mundprop_nw_e * Faktor_mundprop_e) + brennstoff_nw_p * Faktor_brennstoff + wartungskosten_nw_p * Faktor_Wartungskosten + one-of (list 0 1) * ceiling Random-Float Random_E)  [

     set fz4 "e"
     set color blue
     set shape "car"
     set size size - 0.2
  ]

 if Faktor_Plugin * (Preis_nw_p * Faktor_Preis + (mundprop_nw_e * Faktor_mundprop_e) + brennstoff_nw_p * Faktor_brennstoff + wartungskosten_nw_p * Faktor_Wartungskosten + one-of (list 0 1) * ceiling Random-Float Random_E)  >=
    (Preis_nw_h * Faktor_Preis + (mundprop_nw_h * Faktor_mundprop_e) + wartungskosten_nw_h * Faktor_Wartungskosten + brennstoff_nw_h * Faktor_brennstoff) * (Random-Float range_Schwelle + schwelle) + one-of (list 0 1) * ceiling Random-Float Random_H and
    Faktor_Plugin * (Preis_nw_p * Faktor_Preis + (mundprop_nw_e * Faktor_mundprop_e) + brennstoff_nw_p * Faktor_brennstoff + wartungskosten_nw_p * Faktor_Wartungskosten + one-of (list 0 1) * ceiling Random-Float Random_E) >=
    (Preis_nw_e * Faktor_Preis + (mundprop_nw_e * Faktor_mundprop_e) + brennstoff_nw_e * Faktor_brennstoff + wartungskosten_nw_e * Faktor_Wartungskosten + one-of (list 0 1) * ceiling Random-Float Random_E)  [

     set fz4 "p"
     set color green
     set shape "car"
     set size size - 0.2
  ]



  if (fz4 = "p" and (Preis_nw_e * Faktor_Preis + (mundprop_nw_e * Faktor_mundprop_e) + brennstoff_nw_e * Faktor_brennstoff + wartungskosten_nw_e * Faktor_Wartungskosten + one-of (list 0 1) * ceiling Random-Float Random_E) * Faktor_EP  >=
    Faktor_Plugin * (Preis_nw_p * Faktor_Preis + (mundprop_nw_e * Faktor_mundprop_e) + brennstoff_nw_p * Faktor_brennstoff + wartungskosten_nw_p * Faktor_Wartungskosten + one-of (list 0 1) * ceiling Random-Float Random_E))[

     set fz4 "e"
     set color blue
     set shape "car"
     set size size - 0.2
 ]



end
@#$#@#$#@
GRAPHICS-WINDOW
236
12
730
668
-1
-1
3.22
1
10
1
1
1
0
1
1
1
-75
75
-100
100
0
0
1
ticks
30.0

BUTTON
13
717
168
750
GO
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

BUTTON
92
754
168
787
GO forever
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
692
1844
851
1889
Anzahl an Elektrofahrzeugen
count hh with [fz1 = \"e\"] + count hh with [fz2 = \"e\"] + count hh with [fz3 = \"e\"] + count hh with [fz4 = \"e\"]
17
1
11

MONITOR
690
1349
848
1394
Anzahl der Haushalte
count hh
17
1
11

BUTTON
14
754
89
787
5 steps
repeat 5[go]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
232
707
396
752
Year
year
17
1
11

SLIDER
22
1757
177
1790
schwelle_inno
schwelle_inno
0.1
1.1
0.97
0.01
1
NIL
HORIZONTAL

SLIDER
22
1793
178
1826
schwelle_earlya
schwelle_earlya
0.5
1.2
1.0
0.01
1
NIL
HORIZONTAL

SLIDER
23
1829
178
1862
schwelle_earlyma
schwelle_earlyma
0.7
1.2
1.02
0.01
1
NIL
HORIZONTAL

SLIDER
19
516
159
549
links-per-node
links-per-node
1
5
4.0
1
1
NIL
HORIZONTAL

CHOOSER
203
1234
361
1279
Grenzen-Anzeige
Grenzen-Anzeige
"Laender" "Kreise" "Gemeinden"
1

CHOOSER
204
1288
363
1333
Grenzen-Berechnung
Grenzen-Berechnung
"Kreise" "Gemeinden"
0

BUTTON
8
11
97
44
Setup: Grenzen
setup-de
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
407
172
440
Anzahl-Fahrzeughalter
Anzahl-Fahrzeughalter
0
100000
10000.0
100
1
NIL
HORIZONTAL

BUTTON
15
369
174
402
Erstelle Fahrzeughalter
setup-hh\n
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
19
1558
176
1618
export_data_name
0
1
0
String

BUTTON
19
1234
177
1267
Export
export-world export_data_name
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
19
1269
177
1302
Import
import-world \"de_kreise\"
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
1529
1493
1723
1526
Forschungsfoerderung
Forschungsfoerderung
0
1000
0.0
50
1
Mio. €
HORIZONTAL

SLIDER
24
1867
180
1900
schwelle_latema
schwelle_latema
0.8
1.5
1.05
0.01
1
NIL
HORIZONTAL

SLIDER
24
1903
181
1936
schwelle_laggards
schwelle_laggards
1
1.7
1.08
0.01
1
NIL
HORIZONTAL

MONITOR
693
1733
844
1778
Reichweite E-Kfz
[reichweite] of one-of kfz with [antrieb = \"e\"]
1
1
11

MONITOR
693
1783
844
1828
Reichweite Kfz (herkömmlich)
[reichweite] of one-of kfz with [antrieb = \"h\"]
1
1
11

TEXTBOX
117
445
173
517
Bei geändertem Wert\nneues \"Setup: HH\" nötig.
9
0.0
1

TEXTBOX
763
694
934
722
Politikmaßnahmen
20
15.0
1

TEXTBOX
1531
1473
1653
1492
Technology Push
11
0.0
1

TEXTBOX
762
732
851
760
Demand Pull in €
11
0.0
1

SWITCH
106
10
196
43
Karte?
Karte?
0
1
-1000

BUTTON
142
10
197
43
Karte
ifelse Karte? \n[import-drawing \"data/germany.png\"]\n[clear-drawing] ;Mapit]
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
19
333
158
366
Lade Daten
Kartendaten
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
19
604
159
637
Netzwerk speichern?
nw:save-gexf \"Diff_neu.gexf\"\n\n
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
19
555
159
588
Setup: Netzwerk
setup-netzwerk-2\n;Schnelle Netzwerkerstellung bei bis zu 10.000 Agenten
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
859
1349
1018
1394
Anzahl Netzwerkverbindungen
count links
17
1
11

BUTTON
29
81
133
114
~30.000 Agenten
setup-de\nnw:load-gexf \"Diff_30000.gexf\" hh links\n\n\n;Quelle: https://www.destatis.de/DE/ZahlenFakten/GesellschaftStaat/EinkommenKonsumLebensbedingungen/AusstattungGebrauchsguetern/Tabellen/Fahrzeuge_D.html\n;Anzahl HH 2017: 37 381 Mio\n;davon mit PKW: 78,4% = 29.306.704 HH  >>> ~30.000 Agenten (0,1%)
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
29
203
133
236
~10.000 Agenten
setup-de\nnw:load-gexf \"Diff_10000.gexf\" hh links
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
29
183
133
216
~20.000 Agenten
setup-de\nnw:load-gexf \"Diff_20000.gexf\" hh links
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
30
63
180
81
Quick-Start
13
105.0
1

TEXTBOX
173
62
188
300
|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|
11
0.0
1

TEXTBOX
10
56
25
294
|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n
11
0.0
1

TEXTBOX
10
284
176
312
====================
11
0.0
1

TEXTBOX
30
237
148
261
jeweils average-node-degree = 3
9
0.0
1

TEXTBOX
173
269
188
801
|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|
11
0.0
1

TEXTBOX
10
266
25
798
|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n
11
0.0
1

TEXTBOX
28
298
178
330
Manuelle Netzwerk-\neinstellungen
13
105.0
1

TEXTBOX
15
47
176
75
====================
11
0.0
1

TEXTBOX
15
663
174
681
===================
11
0.0
1

TEXTBOX
14
584
178
612
__________________________
11
0.0
1

TEXTBOX
22
638
164
662
Dateinamen über \"Edit\" überprüfen!
9
0.0
1

INPUTBOX
20
444
114
504
Anzahl-Fahrzeughalter
10000.0
1
0
Number

BUTTON
29
160
133
193
~50.000 Agenten
setup-de\nnw:load-gexf \"Diff_50000.gexf\" hh links\n
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
31
114
165
156
Standardwert, da nach statistischem Bundesamt 29.306.704 HH mit Pkw
9
0.0
1

CHOOSER
19
1628
177
1673
Faktor_mundprop_e
Faktor_mundprop_e
0 0.1 0.2 0.25 0.275 0.3 0.4 0.5 0.6 0.7 0.75 0.8 0.9 1
7

BUTTON
13
679
167
712
Setup
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
19
1510
177
1543
Haltedauer
Haltedauer
1
15
7.0
1
1
NIL
HORIZONTAL

BUTTON
18
1309
176
1342
NIL
export-all-plots \"plot.csv\"
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
693
1897
847
1942
Gesamtzahl Fahrzeuge
count hh with [fz1 = \"h\"] + count hh with [fz1 =\"e\"] + count hh with [fz1 =\"p\"] + count hh with [fz2 = \"h\"] + count hh with [fz2 = \"e\"] + count hh with [fz2 =\"p\"] + count hh with [fz3 = \"h\"] + count hh with [fz3 = \"e\"] + count hh with [fz3 =\"p\"] + count hh with [fz4 = \"h\"] + count hh with [fz4 = \"e\"] + count hh with [fz4 =\"p\"]
17
1
11

INPUTBOX
19
1443
178
1503
Jahr
30.0
1
0
Number

CHOOSER
1236
1259
1341
1304
Kampagnen
Kampagnen
1 1.1 1.2 1.3 1.4 1.5
0

TEXTBOX
1239
1230
1427
1253
Info-Kampagne (positiv)
16
105.0
1

CHOOSER
1239
1318
1331
1363
Anz_inno
Anz_inno
0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1
0

CHOOSER
1240
1415
1332
1460
Anz_earlyma
Anz_earlyma
0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1
0

CHOOSER
1240
1366
1332
1411
Anz_earlya
Anz_earlya
0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1
0

CHOOSER
1240
1468
1332
1513
Anz_latema
Anz_latema
0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1
0

BUTTON
18
1344
176
1377
NIL
export-world \"fire.csv\"
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
1524
1293
1749
1326
Preis_konventionell_Liter
Preis_konventionell_Liter
1.4
1.4
1.4
0.1
1
€/l
HORIZONTAL

SLIDER
1524
1334
1749
1367
Preis_strom_kWh
Preis_strom_kWh
0.233
0.233
0.233
0.001
1
€/kWh
HORIZONTAL

SLIDER
1526
1374
1751
1407
Verbrauch_konventionell
Verbrauch_konventionell
7.4
7.4
7.4
0.1
1
l/100km
HORIZONTAL

TEXTBOX
384
1207
534
1225
[Anzahl Nachbarn]
13
0.0
1

TEXTBOX
1527
1219
1677
1297
Verbrauchsdaten und Brennstoffkosten:\n
16
0.0
1

SLIDER
384
1235
556
1268
Nachbarn_laendlich
Nachbarn_laendlich
1
10
3.0
1
1
NIL
HORIZONTAL

SLIDER
384
1278
556
1311
tw_staedtisch
tw_staedtisch
1
10
4.0
1
1
NIL
HORIZONTAL

SLIDER
382
1320
560
1353
staedtisch
staedtisch
1
10
5.0
1
1
NIL
HORIZONTAL

INPUTBOX
202
1473
286
1533
Materialkosten
20000.0
1
0
Number

MONITOR
693
1453
750
1498
NIL
SPn
0
1
11

MONITOR
868
1509
932
1554
NIL
Anzahl_E
17
1
11

MONITOR
940
1512
1005
1557
NIL
Anzahl_H
17
1
11

MONITOR
692
1403
796
1448
NIL
market_doubling
2
1
11

MONITOR
695
1627
895
1672
NIL
count hh with [fz1 = \"e\"]
17
1
11

MONITOR
694
1572
844
1617
NIL
count hh with [fz2 = \"e\"]
17
1
11

SLIDER
19
1717
179
1750
Random_E
Random_E
0
50
25.0
1
1
NIL
HORIZONTAL

SLIDER
19
1680
178
1713
Random_H
Random_H
0
50
25.0
1
1
NIL
HORIZONTAL

MONITOR
693
1503
743
1548
NIL
count hh with [typ = \"innovators\"]
17
1
11

MONITOR
752
1504
841
1549
NIL
count hh with [typ = \"early-majority\"]
17
1
11

SLIDER
204
1580
362
1613
Preis_konventionell
Preis_konventionell
15000
50000
35000.0
1000
1
€
HORIZONTAL

SLIDER
203
1538
334
1571
Preis_Eauto
Preis_Eauto
10000
50000
25000.0
1000
1
€
HORIZONTAL

SLIDER
1527
1416
1751
1449
Verbrauch_E-Auto
Verbrauch_E-Auto
20
20
20.0
1
1
kWh/100km
HORIZONTAL

MONITOR
859
1399
972
1444
NIL
Reichweite_nw_e
0
1
11

MONITOR
858
1450
972
1495
NIL
Reichweite_nw_h
0
1
11

MONITOR
1010
1400
1091
1445
NIL
Preis_nw_h
0
1
11

MONITOR
1012
1454
1092
1499
NIL
Preis_nw_e
0
1
11

MONITOR
888
1845
1011
1890
CO2-Emission_E in t
CO2-Emission_E
0
1
11

MONITOR
884
1728
972
1773
Emissionen in t
Gesamtemissionen
0
1
11

MONITOR
884
1897
1008
1942
CO2-Emission_H in t
CO2-Emission_H
0
1
11

INPUTBOX
203
1873
358
1933
Faktor_brennstoff
1.0
1
0
Number

TEXTBOX
-121
1092
1782
1130
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
15
0.0
1

TEXTBOX
19
790
169
822
---------------------------------
13
0.0
1

MONITOR
692
1682
857
1727
Preis_EFahrzeug in €
Preis_EFahrzeug
0
1
11

CHOOSER
759
757
897
802
Umweltbonus
Umweltbonus
0 1000 2000 3000 3500 3750 4000 5000 6000 7000 8000 9000 10000
6

PLOT
764
12
1636
668
 Diffusionsoprozess der Elektromobilität in Deutschland
Zeit
%  E-Mob. am Gesamtbestand
0.0
30.0
0.0
50.0
true
false
"" ""
PENS
"default" 1.0 0 -11033397 true "" "plot (((count hh with [fz1 = \"e\"] + count hh with [fz2 = \"e\"] + count hh with [fz3 = \"e\"] + count hh with [fz4 = \"e\"])* 100)/(count hh with [fz1 = \"h\"] + count hh with [fz1 =\"e\"] + count hh with [fz1 =\"p\"]  + count hh with [fz2 = \"h\"] + count hh with [fz2 = \"e\"] + count hh with [fz2 = \"p\"] + count hh with [fz3 = \"h\"] + count hh with [fz3 = \"e\"] + count hh with [fz3 = \"p\"] + count hh with [fz4 = \"h\"] + count hh with [fz4 = \"e\"] + count hh with [fz4 = \"p\"]))"
"pen-1" 1.0 0 -13840069 true "" "plot (((count hh with [fz1 = \"p\"] + count hh with [fz2 = \"p\"] + count hh with [fz3 = \"p\"] + count hh with [fz4 = \"p\"]) * 100)/(count hh with [fz1 = \"h\"] + count hh with [fz1 =\"e\"] + count hh with [fz1 =\"p\"]  + count hh with [fz2 = \"h\"] + count hh with [fz2 = \"e\"] + count hh with [fz2 = \"p\"] + count hh with [fz3 = \"h\"] + count hh with [fz3 = \"e\"] + count hh with [fz3 = \"p\"] + count hh with [fz4 = \"h\"] + count hh with [fz4 = \"e\"] + count hh with [fz4 = \"p\"]))"
"pen-2" 1.0 0 -7500403 true "" "plot (((count hh with [fz1 = \"e\"] + count hh with [fz2 = \"e\"] + count hh with [fz3 = \"e\"] + count hh with [fz4 = \"e\"] + count hh with [fz1 = \"p\"] + count hh with [fz2 = \"p\"] + count hh with [fz3 = \"p\"] + count hh with [fz4 = \"p\"]) * 100)/(count hh with [fz1 = \"h\"] + count hh with [fz1 =\"e\"] + count hh with [fz1 =\"p\"]  + count hh with [fz2 = \"h\"] + count hh with [fz2 = \"e\"] + count hh with [fz2 = \"p\"] + count hh with [fz3 = \"h\"] + count hh with [fz3 = \"e\"] + count hh with [fz3 = \"p\"] + count hh with [fz4 = \"h\"] + count hh with [fz4 = \"e\"] + count hh with [fz4 = \"p\"]))"

MONITOR
885
1780
1090
1825
Emissionen in t (Gesamtbetrachtung)
Gesamtemissionen_hochgerechnet
0
1
11

MONITOR
418
758
548
803
Anzahl_tatsächlich
((count hh with [fz1 = \"e\"] + count hh with [fz2 = \"e\"]) * 30000000)/(Anzahl-Fahrzeughalter)
17
1
11

INPUTBOX
369
1873
491
1933
Faktor_Reichweite
1.5
1
0
Number

INPUTBOX
318
1742
424
1802
wartungskosten_e
650.0
1
0
Number

INPUTBOX
205
1740
310
1800
wartungskosten_h
1000.0
1
0
Number

INPUTBOX
339
1805
464
1865
Faktor_Wartungskosten
0.2
1
0
Number

MONITOR
860
1294
1021
1339
E-Fahrzeuge_Innovators
;count hh with [fz1 = \"e\" and typ = \"innovators\"] + count hh with [fz2 = \"e\" and typ = \"innovators\"] + count hh with [fz1 = \"e\" and fz2 = \"e\" and typ = \"innovators\"]\ncount hh with [fz1 = \"e\" and typ = \"innovators\"] + count hh with [fz2 = \"e\" and typ = \"innovators\"]
17
1
11

MONITOR
690
1294
848
1339
NIL
Faktor_Preis
1
1
11

MONITOR
233
756
395
801
%fzg Elektrofahrzeuge
((count hh with [fz1 = \"e\"] + count hh with [fz2 = \"e\"] + count hh with [fz3 = \"e\"] + count hh with [fz4 = \"e\"]) * 100) / (count hh with [fz1 = \"h\"] + count hh with [fz1 =\"e\"] + count hh with [fz1 =\"p\"]  + count hh with [fz2 = \"h\"] + count hh with [fz2 = \"e\"]  + count hh with [fz2 = \"p\"] + \ncount hh with [fz3 = \"h\"] + count hh with [fz3 =\"e\"] + count hh with [fz3 = \"p\"] + count hh with [fz4 = \"h\"] + count hh with [fz4 = \"e\"] + count hh with [fz4 = \"p\"])
2
1
11

MONITOR
688
1237
874
1282
% Fahrzeuge am Gesamtbestand
(count hh with [fz1 = \"h\"] + count hh with [fz1 =\"e\"] + count hh with [fz2 = \"h\"] + count hh with [fz2 = \"e\"]) * 100 / Anzahl-Fahrzeughalter
2
1
11

INPUTBOX
1244
1597
1366
1657
Abnahme_Fahrzeuge
0.0
1
0
Number

MONITOR
889
1237
964
1282
NIL
nr_patches
17
1
11

SLIDER
204
1692
320
1725
Preis_plugin
Preis_plugin
20000
100000
30000.0
1000
1
€
HORIZONTAL

INPUTBOX
204
1804
331
1864
wartungskosten_p
1000.0
1
0
Number

MONITOR
983
1234
1076
1279
Anzahl Plug-In
count hh with [fz1 = \"p\"] + count hh with [fz2 = \"p\"] + count hh with [fz3 = \"p\"] + count hh with [fz4 = \"p\"]
17
1
11

INPUTBOX
204
1623
325
1683
Materialkosten_plugin
5000.0
1
0
Number

MONITOR
1109
1394
1182
1439
NIL
Spn_plugin
0
1
11

MONITOR
233
809
395
854
%fzg Plugin
((count hh with [fz1 = \"p\"] + count hh with [fz2 = \"p\"] + count hh with [fz3 = \"p\"] + count hh with [fz4 = \"p\"]) * 100) / (count hh with [fz1 = \"h\"] + count hh with [fz1 =\"e\"] + count hh with [fz1 =\"p\"]  + count hh with [fz2 = \"h\"] + count hh with [fz2 = \"e\"]  + count hh with [fz2 = \"p\"] + \ncount hh with [fz3 = \"h\"] + count hh with [fz3 =\"e\"] + count hh with [fz3 = \"p\"] + count hh with [fz4 = \"h\"] + count hh with [fz4 = \"e\"] + count hh with [fz4 = \"p\"])
2
1
11

MONITOR
1017
1514
1142
1559
NIL
Durchschnittseink
2
1
11

CHOOSER
1241
1519
1333
1564
Anz_laggards
Anz_laggards
0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1
0

TEXTBOX
1226
1214
1487
1242
============================
11
0.0
1

SLIDER
385
1402
557
1435
schwelle_inno_p
schwelle_inno_p
0
2
0.95
0.05
1
NIL
HORIZONTAL

SLIDER
385
1444
557
1477
schwelle_earlya_p
schwelle_earlya_p
0
1.5
0.98
0.01
1
NIL
HORIZONTAL

SLIDER
384
1487
556
1520
schwelle_earlyma_p
schwelle_earlyma_p
0
2
1.02
0.01
1
NIL
HORIZONTAL

INPUTBOX
344
1624
499
1684
Faktor_EP
1.0
1
0
Number

MONITOR
418
705
548
750
CO2-Emissionen in %
Gesamtemission_Jahr
0
1
11

MONITOR
695
1952
864
1997
NIL
count hh
17
1
11

MONITOR
885
1953
1036
1998
NIL
Durchschnittsfahrstrecke
0
1
11

MONITOR
1036
1297
1132
1342
NIL
strompreis_var
4
1
11

INPUTBOX
472
1806
627
1866
Faktor_Plugin
1.0
1
0
Number

MONITOR
234
865
394
910
%fzg E-mobility
((count hh with [fz1 = \"p\"] + count hh with [fz2 = \"p\"] + count hh with [fz3 = \"p\"] + count hh with [fz4 = \"p\"]) * 100) / (count hh with [fz1 = \"h\"] + count hh with [fz1 =\"e\"] + count hh with [fz1 =\"p\"]  + count hh with [fz2 = \"h\"] + count hh with [fz2 = \"e\"]  + count hh with [fz2 = \"p\"] + \ncount hh with [fz3 = \"h\"] + count hh with [fz3 =\"e\"] + count hh with [fz3 = \"p\"] + count hh with [fz4 = \"h\"] + count hh with [fz4 = \"e\"] + count hh with [fz4 = \"p\"])\n+\n((count hh with [fz1 = \"e\"] + count hh with [fz2 = \"e\"] + count hh with [fz3 = \"e\"] + count hh with [fz4 = \"e\"]) * 100) / (count hh with [fz1 = \"h\"] + count hh with [fz1 =\"e\"] + count hh with [fz1 =\"p\"]  + count hh with [fz2 = \"h\"] + count hh with [fz2 = \"e\"]  + count hh with [fz2 = \"p\"] + \ncount hh with [fz3 = \"h\"] + count hh with [fz3 =\"e\"] + count hh with [fz3 = \"p\"] + count hh with [fz4 = \"h\"] + count hh with [fz4 = \"e\"] + count hh with [fz4 = \"p\"])
2
1
11

CHOOSER
952
758
1092
803
Ökosteuer
Ökosteuer
1 1.1 1.2 1.3
0

MONITOR
1022
1575
1165
1620
NIL
kraftstoffpreis_konv_var
2
1
11

TEXTBOX
955
733
1105
751
Price Rise (Fuel)
11
0.0
1

CHOOSER
1137
755
1275
800
Emissionssteuer
Emissionssteuer
10 20 30 40 50
0

TEXTBOX
1140
733
1290
751
Emission tax
11
0.0
1

SLIDER
205
1960
377
1993
Difference
Difference
0
100
50.0
1
1
NIL
HORIZONTAL

MONITOR
1039
1678
1303
1723
NIL
[reichweite] of one-of kfz with [antrieb = \"p\"]
17
1
11

@#$#@#$#@
## WHAT IS IT?

The Model trys to simulate the diffusion of elektromobility in Germany. Questions about how the diffusion process of a technology develops and which factors have an impact are difficult to predict. Here economic, sociological, techno-economic and political decision factors are considered.

Only households owning one or more vehicles are
included in the model. This information will then be used to simulate the diffusion process from the conventional vehicle to the electric vehicle. The code of the model lists
various algorithms that imply whether the decision for or against an electric vehicle is
made.

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

The rules of the agents are based on a mathematical calculation. The mathematical calculations include the following parameters:

- Prize
- Consumption
- Technical specifications
- Social aspects
- Political
- Emissions

When Agents want to buy a new car there compare the utility value of the different parameters. If the value for BEV or PHEV is higher than conventional Cars then they will buy it. Every year the parameters change their value in sense of the changing surroundings.

(what rules the agents used to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

It is possible to change the value of population. It's better to go not higher than 50.000 in case of simulation time. Between 10.000 and 50.000 it's a good number of agents. 

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
  <experiment name="Wartungskosten 0.1" repetitions="2" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count hh with [fz1 = "e"] + count hh with [fz2 = "e"]</metric>
    <enumeratedValueSet variable="Verbrauch_konventionell">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Preis_Eauto">
      <value value="27000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Anz_laggards">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Preis_konventionell_Liter">
      <value value="1.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="schwelle_earlyma">
      <value value="1.03"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Anz_inno">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="schwelle_laggards">
      <value value="1.07"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Anz_earlyma">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="schwelle_inno">
      <value value="0.95"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Jahr">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="wartungskosten_h">
      <value value="4000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="schwelle_earlya">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Karte?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Anz_latema">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tw_staedtisch">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Faktor_Reichweite">
      <value value="0.75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Grenzen-Anzeige">
      <value value="&quot;Laender&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="links-per-node">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Umweltbonus">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Anzahl-Haushalte">
      <value value="5000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Nachbarn_laendlich">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Materialkosten">
      <value value="15000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="schwelle_latema">
      <value value="1.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Grenzen-Berechnung">
      <value value="&quot;Gemeinden&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Random_H">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Faktor_mundprop_e">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="staedtisch">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Preis_strom_kWh">
      <value value="0.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Kampagnen">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Faktor_Wartungskosten">
      <value value="0.1"/>
      <value value="0.2"/>
      <value value="0.3"/>
      <value value="0.4"/>
      <value value="0.5"/>
      <value value="0.6"/>
      <value value="0.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Haltedauer">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Anz_earlya">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Anzahl-Haushalte">
      <value value="5000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Faktor_brennstoff">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="wartungskosten_e">
      <value value="2500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Preis">
      <value value="27000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Verbrauch_E-Auto">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Forschungsfoerderung">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="export_data_name">
      <value value="&quot;de_kreise&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Random_E">
      <value value="5"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Mundprop_[01]_0.1" repetitions="2" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count hh with [fz1 = "e"] + count hh with [fz2 = "e"]</metric>
    <enumeratedValueSet variable="Verbrauch_konventionell">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Preis_Eauto">
      <value value="27000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Anz_laggards">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Preis_konventionell_Liter">
      <value value="1.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="schwelle_earlyma">
      <value value="1.03"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Anz_inno">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="schwelle_laggards">
      <value value="1.07"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Anz_earlyma">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="schwelle_inno">
      <value value="0.95"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Jahr">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="wartungskosten_h">
      <value value="4000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="schwelle_earlya">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Karte?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Anz_latema">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tw_staedtisch">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Faktor_Reichweite">
      <value value="0.75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Grenzen-Anzeige">
      <value value="&quot;Laender&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="links-per-node">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Umweltbonus">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Anzahl-Haushalte">
      <value value="5000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Nachbarn_laendlich">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Materialkosten">
      <value value="15000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="schwelle_latema">
      <value value="1.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Grenzen-Berechnung">
      <value value="&quot;Gemeinden&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Random_H">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Faktor_mundprop_e">
      <value value="0"/>
      <value value="0.1"/>
      <value value="0.2"/>
      <value value="0.3"/>
      <value value="0.4"/>
      <value value="0.5"/>
      <value value="0.6"/>
      <value value="0.7"/>
      <value value="0.8"/>
      <value value="0.9"/>
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="staedtisch">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Preis_strom_kWh">
      <value value="0.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Kampagnen">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Faktor_Wartungskosten">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Haltedauer">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Anz_earlya">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Anzahl-Haushalte">
      <value value="5000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Faktor_brennstoff">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="wartungskosten_e">
      <value value="2500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Preis">
      <value value="27000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Verbrauch_E-Auto">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Forschungsfoerderung">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="export_data_name">
      <value value="&quot;de_kreise&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Random_E">
      <value value="5"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Test_01_21.06.2019" repetitions="2" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="30"/>
    <metric>count hh with [fz1 = "e"] + count hh with [fz2 = "e"] + count hh with [fz3 = "e"] + count hh with [fz4 = "e"]</metric>
    <enumeratedValueSet variable="Forschungsfoerderung">
      <value value="0"/>
      <value value="10"/>
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Materialkosten">
      <value value="20000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="schwelle_earlyma">
      <value value="0.94"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Anz_inno">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="wartungskosten_e">
      <value value="2500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Verbrauch_konventionell">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Nachbarn_laendlich">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Umweltbonus">
      <value value="10000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Faktor_EP">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Faktor_brennstoff">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="links-per-node">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="wartungskosten_h">
      <value value="4000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Anz_laggards">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Grenzen-Berechnung">
      <value value="&quot;Kreise&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Preis_Eauto">
      <value value="27000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Verbrauch_E-Auto">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Grenzen-Anzeige">
      <value value="&quot;Kreise&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Anzahl-Haushalte">
      <value value="3000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Abnahme_Fahrzeuge">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="staedtisch">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="schwelle_earlya_p">
      <value value="0.98"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Materialkosten_plugin">
      <value value="5000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="schwelle_laggards_p">
      <value value="1.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Jahr">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Kampagnen">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Anz_earlya">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Anz_earlyma">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Preis_strom_kWh">
      <value value="0.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="schwelle_laggards">
      <value value="1.06"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="schwelle_inno">
      <value value="0.85"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="export_data_name">
      <value value="&quot;0&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Random_H">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="schwelle_inno_p">
      <value value="0.95"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tw_staedtisch">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Preis_plugin">
      <value value="30000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Haltedauer">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="schwelle_earlya">
      <value value="0.88"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Anz_latema">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Preis_konventionell">
      <value value="3000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Faktor_mundprop_e">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Faktor_Reichweite">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="wartungskosten_p">
      <value value="4000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Karte?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Random_E">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="schwelle_earlyma_p">
      <value value="1.02"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="schwelle_latema_p">
      <value value="1.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Preis_konventionell_Liter">
      <value value="1.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Faktor_Wartungskosten">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="schwelle_latema">
      <value value="1"/>
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
