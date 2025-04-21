//
//  Sampler.swift
//  gameTest
//
//  Created by Luke S on 04/11/2022.
//

import AudioKit
import AVFAudio

// Global audiokit variable declarations.
var engine: AudioEngine!
var samplerMIDI: MIDISampler!
var filter: LowPassFilter!
var reverb: Reverb!
var delay: Delay!

open class Sampler {
    
    // Properties for storing the current state of audio effects.
    var reverbTemp: AUValue = 0
    var delayTemp: AUValue = 0
    var filterCutoffTemp: AUValue = 6900
    var filterResTemp:AUValue = 0
    
    // Access to GameViewController.
    weak var viewController: GameViewController?
    
    init() {
        // Instances of audio engine, MIDISampler and filter, reverb & delay effects.
        engine = AudioEngine()
        samplerMIDI = MIDISampler()
        filter = LowPassFilter(samplerMIDI)
        delay = Delay(filter)
        reverb = Reverb(delay)
        engine.output = reverb
        
        // Set the initial values for reverb and delay.
        delay.dryWetMix = 0.0
        reverb.dryWetMix = 0.0
        
        // Load "marimba.wav" sample and start audio engine.
        try! samplerMIDI.loadWav("marimba")
        try!engine.start()
    }
    
    func resetEngine() {
        try!engine.start()
    }
    
    // Adjusts filter cutoff frequency and resonance.
    func adjustFilter(x: CGFloat, y: CGFloat) {
        if filter != nil {
            filter.cutoffFrequency = AUValue(x * 2.6855 + 250)      // Converts values into 250 to 3000 Hz range for cutoff frequency.
            filter.resonance = AUValue(y * 0.05347593582 - 20)      // Converts values into -20 to 40 dB range for filter resonance.
        } else {
            print("Filter is nil")
        }
    }
    
    // Turns filter on/off.
    func toggleFilter() {
        if filter.cutoffFrequency < 6900 {
            filterCutoffTemp = filter.cutoffFrequency
            filter.cutoffFrequency = 6900
        } else {
            filter.cutoffFrequency = filterCutoffTemp
        }
        
        if filter.resonance > 0 {
            filterResTemp = filter.resonance
            filter.resonance = 0
        } else {
            filter.resonance = filterResTemp
        }
    }
    
    // Adjusts delay dry/wet mix.
    func adjustDelayWet(wet: Float) {
        if delay != nil {
            delay.dryWetMix = AUValue(wet)
        }
    }
    
    // Adjusts delay time.
    func adjustDelayTime(time: Float) {
        if delay != nil {
            delay.time = AUValue(time)
        } else {
            print("Delay is nil")
        }
    }
    
    // Turns delay on/off.
    func toggleDelay() {
        if delay.dryWetMix > 0 {
            delayTemp = delay.dryWetMix
            delay.dryWetMix = 0
        } else {
            delay.dryWetMix = delayTemp
        }
    }
    
    // Adjusts reverb dry/wet mix.
    func adjustReverb(x: CGFloat, y: CGFloat) {
        let z: Int = Int(x + y)
        if reverb != nil {
            reverb.dryWetMix = AUValue(Double(z) * (0.5/1792))
        } else {
            print("Reverb is nil")
        }
    }
    
    // Turns reverb on/off.
    func toggleReverb() {
        if reverb.dryWetMix > 0 {
            reverbTemp = reverb.dryWetMix
            reverb.dryWetMix = 0
        } else {
            reverb.dryWetMix = reverbTemp
        }
    }
    
    // Functions to play MIDI notes in sampler.
    func playBassC(velocity: Int) {
        samplerMIDI.play(noteNumber: 48, velocity: MIDIVelocity(velocity), channel: 0)
    }
    
    func playBassD(velocity: Int) {
        samplerMIDI.play(noteNumber: 50, velocity: MIDIVelocity(velocity), channel: 0)
    }
    
    func playBassE(velocity: Int) {
        samplerMIDI.play(noteNumber: 52, velocity: MIDIVelocity(velocity), channel: 0)
    }
    
    func playBassF(velocity: Int) {
        samplerMIDI.play(noteNumber: 53, velocity: MIDIVelocity(velocity), channel: 0)
    }
    
    func playBassG(velocity: Int) {
        samplerMIDI.play(noteNumber: 55, velocity: MIDIVelocity(velocity), channel: 0)
    }
    
    func playBassA(velocity: Int) {
        samplerMIDI.play(noteNumber: 57, velocity: MIDIVelocity(velocity), channel: 0)
    }
    
    func playBassB(velocity: Int) {
        samplerMIDI.play(noteNumber: 59, velocity: MIDIVelocity(velocity), channel: 0)
    }
    
    func playC(velocity: Int) {
        samplerMIDI.play(noteNumber: 60, velocity: MIDIVelocity(velocity), channel: 0)
    }
    
    func playD(velocity: Int) {
        samplerMIDI.play(noteNumber: 62, velocity: MIDIVelocity(velocity), channel: 0)
    }
    
    func playE(velocity: Int) {
        samplerMIDI.play(noteNumber: 64, velocity: MIDIVelocity(velocity), channel: 0)
    }
    
    func playF(velocity: Int) {
        samplerMIDI.play(noteNumber: 65, velocity: MIDIVelocity(velocity), channel: 0)
    }
    
    func playG(velocity: Int) {
        samplerMIDI.play(noteNumber: 67, velocity: MIDIVelocity(velocity), channel: 0)
    }
    
    func playA(velocity: Int) {
        samplerMIDI.play(noteNumber: 69, velocity: MIDIVelocity(velocity), channel: 0)
    }
    
    func playB(velocity: Int) {
        samplerMIDI.play(noteNumber: 71, velocity: MIDIVelocity(velocity), channel: 0)
    }
    
    func playHighC(velocity: Int) {
        samplerMIDI.play(noteNumber: 72, velocity: MIDIVelocity(velocity), channel: 0)
    }
    
    func playHighD(velocity: Int) {
        samplerMIDI.play(noteNumber: 74, velocity: MIDIVelocity(velocity), channel: 0)
    }
    
    func playHighE(velocity: Int) {
        samplerMIDI.play(noteNumber: 76, velocity: MIDIVelocity(velocity), channel: 0)
    }
    
    func playHighF(velocity: Int) {
        samplerMIDI.play(noteNumber: 77, velocity: MIDIVelocity(velocity), channel: 0)
    }
    
    func playHighG(velocity: Int) {
        samplerMIDI.play(noteNumber: 79, velocity: MIDIVelocity(velocity), channel: 0)
    }
    
    func playHighA(velocity: Int) {
        samplerMIDI.play(noteNumber: 81, velocity: MIDIVelocity(velocity), channel: 0)
    }
}
