-- ============================================================
--  Bevel Gear Pair  -  IceSl 2.5.x
--  Sine-tooth version  |  Variable gear ratio
-- ============================================================

-- UI PARAMETERS
module_val  = ui_scalar('Module (mm)',          3.0,  0.5,  5.0)
num_teeth1  = ui_scalar('Teeth - Gear 1',      16.0,  8.0, 40.0)
ratio_ui    = ui_scalar('Gear ratio (G2/G1)',   1.0,  0.5,  4.0)
face_width  = ui_scalar('Face width (mm)',     12.0,  3.0, 20.0)
shaft_r     = ui_scalar('Shaft radius (mm)',    4.0,  1.0,  8.0)
hub_h       = ui_scalar('Hub height (mm)',      8.0,  3.0, 20.0)
sine_amp_ui = ui_scalar('Sine amplitude',       0.85, 0.1,  2.0)
sine_power  = ui_scalar('Sine smoothness',      1.0,  0.3,  3.0)
wave_freq   = ui_scalar('Wave freq tweak',      1.0,  0.5,  2.0)
mesh_offset = ui_scalar('Mesh offset (mm)',     0.9,  0.0,  3.0)
show_g2     = ui_bool  ('Show Gear 2',          true)

-- ----------------------------------------------------------------
-- CONSTANTS
-- ----------------------------------------------------------------
local pi = math.pi

-- Round tooth counts to integers
local N1 = math.max(8,  math.floor(num_teeth1 + 0.5))
local N2 = math.max(8,  math.floor(num_teeth1 * ratio_ui + 0.5))

local m  = module_val
local fw = face_width
local sr = shaft_r
local hh = hub_h
local sa = sine_amp_ui
local sp = sine_power
local wf = wave_freq

-- ----------------------------------------------------------------
-- CONE ANGLES  (derived from tooth counts so ratio is exact)
-- For 90-deg shaft angle:
--   tan(delta1) = N1/N2  =>  delta1 = atan(N1/N2)
--   delta2 = 90 - delta1
-- When N1==N2 this gives delta1=delta2=45 deg (miter)
-- ----------------------------------------------------------------
local delta1 = math.atan(N1 / N2)
local delta2  = pi / 2 - delta1

-- ----------------------------------------------------------------
-- GEOMETRY HELPERS
-- ----------------------------------------------------------------
local function gear_geom(N, delta)
  local Rp  = (m * N) / 2
  local Ao  = Rp / math.sin(delta)
  local ha  = m
  local hf  = 1.25 * m
  local Ra  = Rp + ha * math.cos(delta)
  local Rr  = math.max(sr * 2.2, Rp - hf * math.cos(delta))
  local si  = math.max(0.1, (Ao - fw) / Ao)
  local bh  = fw * math.cos(delta)
  return { N=N, delta=delta, Rp=Rp, Ao=Ao, ha=ha, hf=hf,
           Ra=Ra, Rr=Rr, si=si, bh=bh }
end

local g1 = gear_geom(N1, delta1)
local g2 = gear_geom(N2, delta2)

-- ----------------------------------------------------------------
-- SINE SHAPE HELPER
-- ----------------------------------------------------------------
local function sine_shape(s, sp_val)
  -- shaped sine: preserves sign, raises abs to power sp_val
  -- sp_val=1 -> pure sine; <1 -> flatter (wider land); >1 -> sharper
  local abs_s = math.abs(s)
  local powered = abs_s ^ sp_val
  if s >= 0 then return powered else return -powered end
end

-- ----------------------------------------------------------------
-- BUILD ONE GEAR BODY
-- ----------------------------------------------------------------
local function make_gear(g)
  local steps = 240
  local amp0  = m * sa
  local amp1  = amp0 * g.si

  local pts0 = {}
  local pts1 = {}

  for k = 0, steps - 1 do
    local t = (2 * pi * k) / steps
    local s = math.sin(g.N * wf * t)
    local shaped = sine_shape(s, sp)

    -- large end (z = 0)
    local r0 = g.Rp + amp0 * shaped
    pts0[#pts0 + 1] = v(r0 * math.cos(t), r0 * math.sin(t), 0)

    -- small end (z = bh), scaled toward apex
    local r1 = g.Rp * g.si + amp1 * shaped
    pts1[#pts1 + 1] = v(r1 * math.cos(t), r1 * math.sin(t), g.bh)
  end

  -- Tapered gear body
  local body = sections_extrude({pts0, pts1})

  -- Hub cylinder below large face
  local hub = translate(0, 0, -hh) * cylinder(sr * 1.8, hh)
  body = union(body, hub)

  -- Shaft bore through entire part
  body = difference(
    body,
    translate(0, 0, -(hh + 1)) * cylinder(sr, g.bh + hh + 2)
  )

  return body
end

-- ----------------------------------------------------------------
-- EMIT GEAR 1
-- ----------------------------------------------------------------
emit(make_gear(g1))

-- ----------------------------------------------------------------
-- EMIT GEAR 2  (repositioned to mesh with Gear 1)
-- ----------------------------------------------------------------
if show_g2 then
  local body2 = make_gear(g2)

  -- Phase-shift Gear 2 teeth so they fall in Gear 1 tooth gaps
  -- half-tooth angular spacing = pi / N2
  local phase = pi / g2.N
  body2 = rotate(0, 0, phase) * body2

  -- The shared apex lies at distance Ao1 from G1 origin along its axis
  -- In G1 frame: apex is at (0, 0, Ao1*cos(delta1)) ... but since
  -- G1 large face is at z=0 and cone points inward (+z), apex is at:
  --   z_apex = g1.bh + (Ao - fw)*cos(delta1)  = Ao1*cos(delta1)
  -- Simpler: apex_z = g1.Ao * math.cos(g1.delta)
  local apex_z = g1.Ao * math.cos(g1.delta)

  -- For G2 its apex must coincide with G1 apex.
  -- G2 sits with its axis along Y (after 90-deg rotate around X).
  -- After rotate(90,0,0): G2's old Z becomes -Y, old X stays X.
  -- So G2 large face (was z=0) is now at y=0, apex at y = -apex_z2
  -- We need G2 apex at same point as G1 apex: y = 0, z = apex_z
  -- Translation: y += apex_z + mesh_offset, z += apex_z
  body2 = rotate(90, 0, 0) * body2
  body2 = translate(0, apex_z + mesh_offset, apex_z) * body2

  emit(body2)
end