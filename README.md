# Experiments with the Motorola MEK6800D2 6800 Evaluation Kit

For background (and photos) see this Retro Computing Forum thread:
* [Unusual 6800 Microprocessor Trainer](https://retrocomputingforum.com/t/unusual-6800-microprocessor-trainer/4220/1)

Work done so far:
* Repaired some PCB damage from a leaking power supply capacitor
* Jumpered U10 to take a 2716 EPROM (at $C000)
* Wired up a TTL level serial port to PIA Port A bits 0 and 1
* Wrote a serial driver that bit-bangs the PIA at 9600, 19200 and 38400 baud
