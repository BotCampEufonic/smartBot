use_bpm 140
use_random_seed 11

# Variables iniciales globales
set :pm_1, 30
set :pm_2, 4
set :pm_4, 80
set :pm_10, 10
set :noise, 0  # normalizado 0..1

# Live loops para recibir OSC y actualizar variables globales
live_loop :osc_pm_1 do
  use_real_time
  val = sync "/osc*/pm_1_0"
  set :pm_1, val[0] if val.length > 0
end

live_loop :osc_pm_2 do
  use_real_time
  val = sync "/osc*/pm_2_5"
  set :pm_2, val[0] if val.length > 0
end

live_loop :osc_pm_4 do
  use_real_time
  val = sync "/osc*/pm_4_0"
  set :pm_4, val[0] if val.length > 0
end

live_loop :osc_pm_10 do
  use_real_time
  val = sync "/osc*/pm_10_0"
  set :pm_10, val[0] if val.length > 0
end

live_loop :osc_noise_receiver do
  use_real_time
  val = sync "/osc*/noise"
  if val.length > 0
    noise_raw = val[0].to_f
    # Normalizar a 0..1
    noise_norm = [[noise_raw / 70.0, 0].max, 1].min
    set :noise, noise_norm
  end
end


samples = [
  :ambi_swoosh,
  :ambi_drone,
  :ambi_glass_hum,
  :ambi_glass_rub,
  :ambi_haunted_hum,
  :ambi_piano,
  :ambi_lunar_land,
  :ambi_dark_woosh,
  :ambi_choir,
  :ambi_sauna
]
uncomment do
  live_loop :bird_sample do
    noise = get(:noise) || 0.0
    
    if noise > 0.2
      amp = (noise - 0.2) / 0.8 * 1
      amp = [[amp, 0].max, 1].min
      
      chosen_sample = "ru_ecm_90_modular_sfx_loop_dilemma.wav"
      
      
      sample chosen_sample, amp: amp, rate: 16
      sleep 16
    else
      sleep 16
    end
  end
end
live_loop :bird_sample2 do
  noise = get(:noise) || 0.0  # noise normalizado 0..1
  threshold = 0.44
  
  amp = 0
  if noise > threshold
    amp = ((noise - threshold) / (1 - threshold)) ** 1.5
    amp = [[amp, 0].max, 1].min
  end
  
  samples = [
    "SPLC-4408_FX_Oneshot_Rainforest_Amb_Morning_Birds_Bugs_Insects_Frogs_Swamp_Marshland.wav",
    "Tropical_Rainforest/SPLC-4417_FX_Oneshot_Rainforest_Designed_Forest_Bird.wav",
    "Tropical_Rainforest/SPLC-4416_FX_Oneshot_Rainforest_Designed_Forest_Bird.wav"
  ]
  
  chosen_sample = samples.choose
  
  sample chosen_sample, amp: amp, rate: 1
  
  sleep 16
end







use_bpm 140
comment do
  live_loop :pm_effect_continuous do
    pm_1 = get(:pm_1) || 0
    pm_2 = get(:pm_2) || 0
    pm_4 = get(:pm_4) || 0
    pm_10 = get(:pm_10) || 0
    
    max_pm = 100.0
    val_pm_1 = [[pm_1.to_f / max_pm, 0].max, 1].min
    val_pm_2 = [[pm_2.to_f / max_pm, 0].max, 1].min
    val_pm_4 = [[pm_4.to_f / max_pm, 0].max, 1].min
    val_pm_10 = [[pm_10.to_f / max_pm, 0].max, 1].min
    
    amp_val = 0.1 + val_pm_4 * 0.2
    cutoff_val = 60 + val_pm_1 * 60
    pan_val = -1 + val_pm_2 * 2
    echo_phase = 0.1 + val_pm_10 * 0.4
    
    # Mapea pm_1 a nota entre :e2 (midi 40) y :e4 (midi 64)
    base_midi = 40
    top_midi = 64
    note_midi = (base_midi + val_pm_1 * (top_midi - base_midi)).to_i
    note = note_midi
    
    use_synth :sine
    
    with_fx :echo, phase: echo_phase, decay: 2, mix: 0.4 do
      play note, sustain: 0.5, release: 0, amp: amp_val, pan: pan_val, cutoff: cutoff_val
      sleep 0.1
    end
  end
end
live_loop :pm_sampler_melodic do
  pm_1 = get(:pm_1) || 0
  pm_2 = get(:pm_2) || 0
  pm_4 = get(:pm_4) || 0
  pm_10 = get(:pm_10) || 0
  
  max_pm = 500.0
  val_pm_1 = [[pm_1.to_f / max_pm, 0].max, 1].min
  val_pm_2 = [[pm_2.to_f / max_pm, 0].max, 1].min
  val_pm_4 = [[pm_4.to_f / max_pm, 0].max, 1].min
  val_pm_10 = [[pm_10.to_f / max_pm, 0].max, 1].min
  
  total_cont = val_pm_1 + val_pm_2 + val_pm_4 + val_pm_10
  total_cont = [[total_cont / 4.0, 0].max, 1].min
  
  base_midi = 72
  top_midi = 84
  note_midi = (base_midi + val_pm_2 * (top_midi - base_midi)).to_i
  
  amp_val = 0.2 + val_pm_4 * 0.6
  rate_val = 0.9 + val_pm_4 * 0.1
  
  with_fx :reverb, room: 0.6, mix: 0.3 do
    with_fx :bitcrusher do
      with_fx :wobble, phase: 4 + total_cont * 8 do
        sample :loop_tabla, note: note_midi, amp: amp_val, rate: rate_val
      end
    end
  end
  
  sleep 1
end
