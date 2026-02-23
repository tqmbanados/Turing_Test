# Automata
Provisional name, that I will probably end up loving!
They are a group of programs that have the ability to improvize together
with me; and possibly someone else. They are not AI, or auto-improvizing
algorithms, they should be understood as an extension of the improvizer
and their instrument. They may also be used in pieces, as an extension
of the player.

From a conceptual/artistic point of view, they are created to explore
ideas of transhumanism, cyborgs and technology. They are related
to the concept of understanding ourselves as Cyborgs already, 
with technology we don't understand extending our capabilities,
and putting into question what we consider to be "human".

These Automata have a few defining characteristics:
1) They shouldn't need a large CPU usage, or a technical rider. They should be able to be largely independant.
2) They react in predictable ways to those who understand how they work. Unlike Black Box AI, Automata work as a quite simple IO machine. In this way, the improviser has **relative control** over what happens musically.
3) **Relative control**, because they all develop infinitely, upon reaching a breaking point in which they are no longer able to create music. They **must** be manually turned off.

These characteristics serve the following purposes: 
* Reinforce them as extensions of the improvizer, not as external electronics. They shouldn't be understood as playing "in duo", rather, the "capabilities" of the Human are extended through the automata.
* Reflect a view (that is itself ideological) that Technology needs Human Input to make sense. It cannot be created and left running, even if it is more efficient than a human. This is because the Composer believes that the Universe is grounded on Aesthetics rather than Practicality, and Machines are only able to imitate Aesthetics, but are inherently Practical.
* As said, this is an ideaological belief, and an invitation to discuss this is a part of the process. The improvizer has to manually turn off the Automata once they start "malfunctioning", or when they are tired of playing the piece.

Automata can have a variety of functionalities, and will usually be created to fit the needs of the Composer/creator.
Their main funcionalities are:
* Audio In: The Automata has to react in some way to what the live player is doing.
* Development: A value that constantly increases, at varying speeds or events. This value develops the sounds of the Automata, but also makes it more unstable as it gets higher.
* OSC Sockets: Ability to interact with other automata using networking with OSC.
* Specific Musical Personality: All automata should be different, but each one with a relatively specific sound and musical world to explore.
* Name(!): We like giving things names! This is done for Animism purposes mainly.
* Pause: Very important! Automata have to be able to stay silent when receiving certain cues or even on their own!
* Other Signals: Each Automaton has a certain set of signals it can send or receive, which prompt different behaviours. The "Pause" signal is an important one, but many others may be included. 

#### Meta Automata
Meta Automata are Automata who don't actively generate music, but send
signals to other Automata, acitvating them or pausing them.
## Overview of Automata

### Seed
Seed is a basic Automaton, and also a Blueprint for more developed ones.
The basic idea of Seed is using the amplitude variations of the input for itself,
but with a few extras: these amplitude variations are rounded with RMS, and also
powered, to exaggerate higher amplitudes and impulses. 

The processed sound works as "PingPong Granular FFTs", following certain
rhythmical envelopes. Its development value makes the PingPong faster, reaching
points where the original buffers aren't recognizable anymore, and start becoming tones.

#### Attributes:
* Audio In (a)
* Audio Out (stereo, aa)
* Attack Trigger (k)
* End Trigger (k)
* Pause Trigger
* Growth (k)
* Pingponged (a)
* ReflectedAmp (a)

#### Functions
* Event Handler: Upon receiving an Attack Trigger, begins an event, upon receiving an End Trigger, if the Event has culminated, begins the Event Decay. Is also affected by the Pause Event.
* PingPong FFT Granulator: receives two audio signals and performs the Synthesis. The size of each "grain" is reduced as Growth.k increases, as well as the variation in size.
* Reactive Envelope: Creates amplitude variation based on rms of AudioIn.a, exaggerating it through exponential functions.
* Rhythmic Envelope: Creates rhythms for each event, based on algorithms. As Growth.k gets larger, the rhythms are more varied and random.
* Play Event: Brings all together!


### Croak
Croak is a secondary automaton that works with low tones and sharp, percussive sounds. 
It forms overbearing atmospheres, the low tones (waves) are formed directly from buffers,
both the live input and loaded files, combined with pitch shifting and filtering.
The percussion (clicks) generated through synthesis, but the rhythms responding to
the input (similarly to Seed). 

##### Waves
The waves are come from live input (to allow flexibility in terms of material), 
but also by directly reading a sound file. This allows for more flexibility on
speed control. FFT pitch shifting can be used, but must be tested, as in low frequencies
FFT is unreliable. Reverberation is also used to add texture.

##### Clicks
Clicks are that: clicking sounds. An algorithm must be designed for producing the sounds,
and a way to create melodies with them, that possibly react to pitch analysis of played material.
The rhythm of clicks is fluid (like all Automata), and follows amplitude envelopes of 
input. 


#### Attributes:
* Audio In (a)
* Audio Out (a)
* Filter Freq (k)
* Wave Speed (k) 
* Croak Speed (k)




