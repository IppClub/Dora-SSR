class VoiceCapture extends AudioWorkletProcessor {
  frame = new Float32Array(320);
  offset = 0;

  process(inputs) {
    const channel = inputs[0]?.[0];
    if (!channel) return true;
    for (const sample of channel) {
      this.frame[this.offset++] = sample;
      if (this.offset === this.frame.length) {
        this.port.postMessage(this.frame, [this.frame.buffer]);
        this.frame = new Float32Array(320);
        this.offset = 0;
      }
    }
    return true;
  }
}

registerProcessor('dora-voice-capture', VoiceCapture);
