# algodrum

This is a algorithmic drum machine based on Barlow's theory of meter as explained in his book "On Musiquantics" (Section 22, "A Quantitative Approach to Metre"). It generates rhythmic patterns for any given meter in an automatic fashion, assigning a unique pulse strength for each pulse. Different notes can be played for different ranges of pulse strengths, and the pulses can be filtered according to their strengths.

![algodrum](algodrum.png)

algodrum is rather quirky as drum sequencers go, but it handles completely arbitrary meters with ease, can be used to produce interesting and dynamically evolving rhythmic or melodic patterns with a bit of experimentation, and, best of all, can also be used if you, like me, are devoid of any trace of legit finger drumming skills. :)

## Prerequisites

algodrum is implemented as a Pd patch, and includes some externals written in Lua, so you'll need Pd (any recent version of vanilla Pd or Purr Data will do) and Pd-Lua (0.11 or later, available from https://agraef.github.io/pd-lua/).

I've only tested algodrum on Linux so far, but it's not in any way OS-specific, so it should work fine on Mac and Windows, too.

## Operation

Normally, playback goes to MIDI channel 10 which usually has a drumkit on a GM-compatible synthesizer. But you can also play melodies by changing the `ch` numbox in the gmkit abstration. In this case you may also want to engage the secondary sample-driven drumkit in the sampler abstraction, which can be used to play along the main sequencer in the gmkit abstraction which outputs MIDI.

There's no preset management at present, but you can save the patch under a new name to store the relevant settings (meter, bpm, MIDI channel) along with it.

### Transport

Playback can be started either through an external clock or using the internal timer. The latter can be invoked by engaging the green toggle in the timebase abstration, or with play/stop controls for the supported MIDI devices (only AKAI mini/miniplus and the Donner StarryPad at this time, see the MIDI Controls section below for further details). It's also possible to control the patch externally using Jack transport (including BBT information if the server provides it, in which case the meter will be chosen automatically), or using MIDI clocks (in this case you have to choose the meter manually).

To enable Jack transport control, just engage the red `jack` toggle in the timebase abstraction and make sure that your DAW (usually Ardour) is configured as a Jack transport server. For MIDI clocks, engage the `mclk` toggle instead and make sure that the MIDI clocks are delivered to one of Pd's MIDI inputs from the clock-generating device or program that you're using.

### Meter and Tempo

Meter and tempo (bpm) can be changed with the appropriate controls at the top of the patch. These can be changed on the fly at any time. However, note that when using an external timer, the tempo -- and, in the case of Jack transport with Ardour, also the meter -- are dictated by the timer. But it will still be possible to change subdivisions.

Subdivision (the `div` parameter) in the timebase abstraction can be changed to play different kinds of n-tuplets (up to septuplets) based on the current meter. Specifically, duplets and triplets can be activated temporarily with the pitch wheel: up enables duplets, down changes to triplets, and returning the wheel to neutral position changes back to the base meter. For other kinds of n-tuplets, you can change the `div` numbox or include the division as a third number in the meter specification, see the patch for examples.

### Note Input

Notes can also be played manually on a connected keyboard or drumpad controller, using a built-in arpeggiator which distributes the played notes in a round-robin fashion to 16 quantized levels of pulse strengths. The played notes can also be recorded into the pattern with the `rec` button. In `rec` mode you can erase existing notes by engaging the `erase` toggle. Otherwise, `rec` will only replace existing notes with the notes that you are playing, and simply play the already recorded notes otherwise. But once `erase` is turned on in `rec` mode, existing notes will be deleted if there is no note input.

Also note that the 16 pulse strength levels in the note storage only affects the number of different notes the sequencer can play at any one time, but has no bearing on the number of pulses itself. The rhythm can still consist of an arbitrary number of pulses (and different pulse strengths), which is determined by the meter (including the number of subdivisions) only.

Finally, you can create a random pattern with the `rnd` button, or clear the entire pattern with the `clr` button to start from a clean slate. This will overwrite all existing note data on all pulse strength levels. Also, the `def` button resets the pattern, so you can quickly get back to the default state if you messed up. It also resets the MIDI channel and the volume controller in the gmkit abstraction to their default values.

### Pulse Filter

Two continuous controllers can be used to filter by pulse strengths, giving you additional possibilities for variations in performances, and control over which pulse strength levels to both play and record while you're still building your pattern.

To these ends, the green and red sliders in the patch can be adjusted to determine the range of pulse strengths to play. The green slider specifies the lower bound, the red slider the upper bound of the range. By these means, you can silence either low-strength pulses with the green slider (which has the effect of gradually "thinning out" the pulse train as you move the slider), or high-strength pulses (giving the rhythm an "off-beat" feel), or both.

The two sliders can also be controlled by MIDI controllers (at least on some devices, see "MIDI Controls" below). In this case the slider values can be quantized to the actual pulse strength levels in the current meter for added precision. This is done by engaging the `quantize` toggle above the sliders (which is on by default, but you may want to disable this if you prefer smoother controller response).

## MIDI Controls

First, you want to make sure that you have your MIDI controller hooked up to Pd's MIDI input so that you can input notes and employ the MIDI controls of your device. And of course you want to connect Pd's MIDI output to whatever synthesizer you want to play algodrum's output.

NB: You can do without MIDI controller and synthesizer, but then you'll only be able to play the (rather limited) sampled drumkit of the included sampler abtraction. To fully utilize algodrum, you'll need to have both MIDI input and output working.

As already mentioned, all available control schemes accept pitch bends as duplet/triplet controls (see above). In addition, if your MIDI controller has a sustain pedal, you can use it to momentarily engage `rec` mode, which is handy for hands-free operation if you're busy operating the drum pads. Also, if your MIDI controller has a volume control (CC7), it can be used to change the MIDI volume in the gmkit abtraction (this can also be operated manually by changing the volume slider with the mouse).

Note that algodrum takes input from any MIDI channel, so if you need to filter out some MIDI channels, you'll have to use an external tool for that purpose.

The available control schemes are provided as abstractions named `control-xyz` in the lib subfolder. At present, we have ready-made control schemes for the AKAI mini/miniplus keyboards, as well as the Donner StarryPad drumpad (a budget drum controller, but very usable). There's also a generic control scheme which should work with most MIDI controllers and offers some computer keyboard bindings for functions which might not be readily available as MIDI buttons.

- control-generic.pd: This assigns CC3 and CC4 to the pulse filter controls. The F1 and F2 keys on the computer keyboard are assigned to the `play` and `rec` functions, respectively.

- control-miniplus.pd: This will work with any of the AKAI mini keyboards. It assigns CC70 and CC71 to the pulse filter controls. On the miniplus, the STOP, PLAY, and REC transport buttons also work as you'd expect.

- control-starrypad.pd: This assigns CC20 and CC21 to the pulse filter controls, and the play/stop and rec transport controls to the appropriate functions. Moreover, since the StarryPad has no pitch bend wheel, the A and B buttons work as momentary switches for duplet/triplet divisions.

- control-combo.pd: This is a combination of the assignments in the generic, miniplus, and starrypad schemes, useful if you have multiple controllers available and want to use them all at the same time.

As I'm lazy and don't want to change the control scheme all the time, control-combo is currently the default. But YMMV, so you may want to change it. To enable any of these bindings, just replace the control-combo abstraction in the algodrum patch with whatever best suits your purpose. If your controller doesn't match, you might still be able to make it work by just changing some CC numbers in the control subpatch.
