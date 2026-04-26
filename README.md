# 🛠️ Bevel Gear Apex-Aligned Housing (Lua)

A parametric Lua-based model for generating a pair of bevel gears with intersecting shafts and an enclosing housing.
All geometry is constructed **with respect to a shared apex**, ensuring correct alignment and realistic mechanical behavior.

---

## ✨ Features

* ⚙️ Parametric bevel gear generation (based on module and tooth count)
* 📐 Apex-aligned geometry for accurate shaft intersection
* 🧱 Automatically generated housing (gearbox enclosure)
* 🔩 Shaft and hub integration
* 🔄 Adjustable shaft angle (default: 90°)

---

## 📂 File Structure

```
.
├── Updated_Shaft_angle(allignment_problem).lua
└── README.md
```

---

## ⚙️ Parameters

You can tweak the system using the following variables:

| Parameter         | Description                | Example |
| ----------------- | -------------------------- | ------- |
| `z1`, `z2`        | Number of teeth            | 16, 32  |
| `module_val`      | Gear module (size scaling) | 2       |
| `face_width`      | Width of gear              | 10      |
| `shaft_angle_deg` | Angle between shafts       | 90      |
| `shaft_r`         | Shaft radius               | 2       |
| `hub_r`, `hub_h`  | Hub radius and height      | 4, 6    |

---

## 🧠 Concept: Apex Alignment

Both gears are constructed from a shared geometric origin:

* The **apex (0,0,0)** is where the pitch cones meet
* Each gear extends outward along its shaft axis
* The housing is built **around this same reference point**

This avoids misalignment and ensures:

✔ Proper meshing
✔ Accurate shaft intersection
✔ Clean enclosure design

---

## 🧱 Housing Logic

The housing is automatically generated based on:

* Maximum gear radius
* Face width and hub size
* Clearance for motion

It includes:

* Hollow interior
* Shaft pass-through holes
* Centered positioning around apex

---

## ▶️ How to Use

1. Open the `.lua` file in your modeling environment
2. Adjust parameters as needed
3. Run the script
4. Export or render the result

---

## 📸 Output

The script generates:

* Two intersecting bevel gears
* Shafts and hubs
* A surrounding gearbox housing

---

## 🚧 Limitations

* Gear teeth are approximated (cone-based, not true involute)
* No bearings or fasteners included
* Housing is a simple enclosure (not split or manufacturable yet)

---

## 🚀 Future Improvements

* 🔧 True bevel gear tooth geometry
* 🧲 Bearing seats and mounts
* 🔩 Split housing with bolts
* 📦 Export-ready mechanical assembly

---

## 🤝 Contributing

Feel free to fork this repo and improve:

* Geometry accuracy
* Visualization
* Mechanical realism

---

## 📜 License

MIT License (or specify your preferred license)

---

## 💡 Inspiration

This project focuses on translating mechanical design principles into procedural geometry using Lua — turning math into motion-ready structures.

---
