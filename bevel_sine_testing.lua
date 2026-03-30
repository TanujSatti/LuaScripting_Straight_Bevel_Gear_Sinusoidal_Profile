-- ============================================================
--  Bevel Gear Pair  –  IceSl 2.5.x
--  Sine-tooth version
-- ============================================================

-- UI PARAMETERS
module_val  = ui_scalar('Module (mm)',         2.0,  0.5, 5.0)
num_teeth   = ui_scalar('Teeth per gear',     12.0,  8.0, 40.0)
face_width  = ui_scalar('Face width (mm)',    10.0,  3.0, 20.0)
shaft_r     = ui_scalar('Shaft radius (mm)',   3.0,  1.0,  8.0)
hub_h       = ui_scalar('Hub height (mm)',     8.0,  3.0, 20.0)

sine_power = ui_scalar('Sine smoothness', 1.0, 0.3, 3.0)
wave_freq = ui_scalar('Wave frequency tweak', 1.0, 0.5, 2.0)
sine_amp_ui = ui_scalar('Sine amplitude', 0.9, 0.1, 2.0)
show_g2     = ui_bool  ('Show Gear 2',        true)
-- ----------------------------------------------------------------
-- CONSTANTS
-- ----------------------------------------------------------------
local pi    = math.pi
local N     = math.max(8, math.floor(num_teeth + 0.5))
local m     = module_val
local fw    = face_width
local sr    = shaft_r
local hh    = hub_h
local sp = sine_power
local sa = sine_amp_ui

-- 90-deg miter bevel: both cone half-angles = 45 deg
local delta  = pi / 4
local Rp     = (m * N) / 2
local Ao     = Rp / math.sin(delta)

local ha     = m
local hf     = 1.25 * m

-- Radii at large end
local Ra     = Rp + ha * math.cos(delta)
local Rr     = math.max(sr*2.2, Rp - hf*math.cos(delta))

-- Scale to small end
local si     = math.max(0.1, (Ao - fw) / Ao)
local Ra_i   = Ra  * si
local Rr_i   = Rr  * si

-- Gear blank axial height (along Z)
local bh     = fw * math.cos(delta)

-- ----------------------------------------------------------------
-- MAKE ONE GEAR
-- ----------------------------------------------------------------
local function make_gear()

  -- Large-end and small-end wave contours
  local pts0 = {}
  local pts1 = {}

  local steps = 220
  local amp0  = m * sa
  local amp1  = amp0 * si

  for k = 0, steps - 1 do
    local t = (2 * pi * k) / steps

    -- large end
    local s = math.sin(N * wave_freq * t)
local shaped = math.sign and math.sign(s) * (math.abs(s)^sp) or (s >= 0 and (math.abs(s)^sp) or -(math.abs(s)^sp))
local r0 = Rp + amp0 * shaped
    local x0 = r0 * math.cos(t)
    local y0 = r0 * math.sin(t)
    pts0[#pts0 + 1] = v(x0, y0, 0)

    -- small end (scaled inward for conical taper)
    local r1 = (Rp * si) + amp1 * shaped
    local x1 = r1 * math.cos(t)
    local y1 = r1 * math.sin(t)
    pts1[#pts1 + 1] = v(x1, y1, bh)
  end

  -- build tapered/conical body from 2 sections
  local gear3d = sections_extrude({pts0, pts1})

  -- hub
  gear3d = union(gear3d, translate(0, 0, -hh) * cylinder(sr * 1.8, hh))

  -- shaft bore
  gear3d = difference(
    gear3d,
    translate(0, 0, -(hh+1)) * cylinder(sr, bh + hh + 2)
  )

  return gear3d
end

-- ----------------------------------------------------------------
-- EMIT
-- ----------------------------------------------------------------
emit(make_gear())

if show_g2 then
  local g2 = make_gear()

  -- Phase shift so teeth interlock
  g2 = rotate(0, 0, 16 / N) * g2

  -- Rotate second gear axis
  g2 = rotate(90, 0, 0) * g2

  -- ORIGINAL apex alignment (important!)
  local apex = Ao * math.cos(delta)

  -- small offset to prevent collision due to sine profile
  local offset = m * 0   -- tune this (0.8 → 2.0)

  g2 = translate(0, apex + offset, apex + offset) * g2

  emit(g2)
end