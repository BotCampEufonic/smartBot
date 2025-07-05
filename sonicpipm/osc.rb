use_bpm 180

live_loop :foo do
  #puts "----entramos"
  use_real_time
  sleep 0.45
  a = sync "/osc*/p5/brillo"
  
  # Mapea el valor de brillo (0 a 255) al rango de cutoff (30 a 130)
  cutoff = (a[0] / 255.0) * (130 - 30) + 30
  
  # Usar un sintetizador diferente y modificar el cutoff del filtro
  with_fx :reverb, room: 0.8 do
    with_fx :echo, phase: 0.25, decay: 2 do
      synth :saw, note: :c4, cutoff: cutoff, amp: a, release: 0.5
    end
  end
end
