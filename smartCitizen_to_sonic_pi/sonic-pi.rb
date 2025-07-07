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

live_loop :osc_noise do
  use_real_time
  val = sync "/osc*/noise"
  if val.length > 0
    raw_noise = val[0].to_f
    noise = [[(raw_noise - 34) / (80.0 - 34), 0].max, 1].min
    set :noise, noise
  end
end

# Loop con sonido que reacciona al ruido ambiente normalizado
live_loop :sensor_noise_feedback do
  use_synth :mod_beep
  
  noise = get(:noise)
  
  base_midi = note(:e2)
  pitch = base_midi + (noise * 24).to_i        # Pitch varía 2 octavas según noise
  amp = 0.1 + noise * 0.9                       # Amplificación de 0.1 a 1
  cutoff = 40 + noise * 80                      # Filtro pasa bajos de 40 a 120
  mod_range = 0.05 + noise * 0.5                # Modulación de 0.05 a 0.55
  release_time = 0.1 + noise * 0.7              # Release de 0.1 a 0.8 seg
  
  play pitch, amp: amp, cutoff: cutoff, mod_range: mod_range, release: release_time
  
  sleep 0.2
end

live_loop :pm_effect do
  pm_1 = get(:pm_1) || 0
  pm_2 = get(:pm_2) || 0
  pm_4 = get(:pm_4) || 0
  pm_10 = get(:pm_10) || 0
  
  pm_1 = [[pm_1.to_f, 0].max, 500].min
  pm_2 = [[pm_2.to_f, 0].max, 500].min
  pm_4 = [[pm_4.to_f, 0].max, 500].min
  pm_10 = [[pm_10.to_f, 0].max, 500].min
  
  max_pm = 500.0
  
  val_pm_1 = [[pm_1 / max_pm, 0].max, 1].min
  cutoff_val = 60 + val_pm_1 * 60
  
  val_pm_2 = [[pm_2 / max_pm, 0].max, 1].min
  res_val = 0.1 + val_pm_2 * 0.8
  
  val_pm_4 = [[pm_4 / max_pm, 0].max, 1].min
  amp_val = 0.1 + val_pm_4 * 0.7
  
  val_pm_10 = [[pm_10 / max_pm, 0].max, 1].min
  echo_time = 0.1 + val_pm_10 * 0.4
  
  with_fx :echo, phase: echo_time, decay: 2, mix: 0.4 do
    with_fx :lpf, cutoff: cutoff_val, res: res_val do
      use_synth :prophet
      play :e2, release: 0.3, amp: amp_val
      sleep 0.3
    end
  end
end

