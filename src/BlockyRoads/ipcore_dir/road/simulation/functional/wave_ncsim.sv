

 
 
 

 



window new WaveWindow  -name  "Waves for BMG Example Design"
waveform  using  "Waves for BMG Example Design"

      waveform add -signals /road_tb/status
      waveform add -signals /road_tb/road_synth_inst/bmg_port/CLKA
      waveform add -signals /road_tb/road_synth_inst/bmg_port/ADDRA
      waveform add -signals /road_tb/road_synth_inst/bmg_port/DOUTA

console submit -using simulator -wait no "run"
