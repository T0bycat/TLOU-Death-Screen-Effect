# TLOU-Death-Screen-Effect

![Cool Preview (BSMOD kick animation by Pixelbozz)](https://github.com/CT-Studios-UT/TLOU-Death-Screen-Effect/blob/main/workshopassets/widescreenpreview.gif)

This repository aims to re-upload and enhance the original TLOU death screen addon for Garry's Mod, since it was deleted off of the workshop.

This wouldn't have been possible without **GIGA** originally making the mod, and then **u/GateCages** archiving the original mod's code!

## Installing

[Steam Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=2575284168)

## Usage

There's not much to using the mod except for just loading it up and well... Dying!  But there are some ConVars you can mess with in the console.

| ConVar                   | Default Value | Description                                                                                                             |
| ------------------------ | ------------- | ----------------------------------------------------------------------------------------------------------------------- |
| `tloudeath_blockouttime` | 0.9           | Time before screen blacks out after death                                                                               |
| `tloudeath_deathsound`   | ""            | What sound to play on death.  This can be used by extracting the addon with GMAD and dropping .wav files into `/sound/` |
| `tloudeath_postprocess`  | 1             | Enable post processing effects?                                                                                         |
| `tloudeath_dsp`          | 1             | Enable sound DSP ("underwater" effect on all sounds) on blackout?                                                       |

## Addon Compatability

| Addon                                                                     | Problem                                                    |
| ------------------------------------------------------------------------- | ---------------------------------------------------------- |
| Any addon that modifies ragdoll physics (Fedhoria, Realism Ragdoll, etc.) | Camera can't track the ragdoll, so it just stays in place. |

## Planned Features

| Feature | Status |
| --- | --- |
| Death Screen Hints - [Mockup Video](https://www.youtube.com/watch?v=f64z6Uhe-7o) | 🟨 Nearing completion |
| Less horrific method of switching between death sounds | ✅ Complete (Thank you **GIGA**!) |
