import React from 'react';

const sampleRate = 16000;
const frameMs = 20;
const maxCaptureMs = 60_000;
const waitForSpeechMs = 10_000;
const endSilenceMs = 1400;
const preRollFrames = 300 / frameMs;
const tailFrames = 240 / frameMs;

export type VoiceIssue = 'unsupported' | 'permission' | 'captureFailed' | 'noSpeech' | 'transcriptionFailed';
export type AgentTranscribe = (wav: Blob, signal: AbortSignal) => Promise<string>;

function encodeWav(frames: Float32Array[]) {
  const byteCount = frames.reduce((count, frame) => count + frame.length * 2, 0);
  const data = new DataView(new ArrayBuffer(44 + byteCount));
  const tag = (offset: number, value: string) => {
    for (let i = 0; i < value.length; i++) data.setUint8(offset + i, value.charCodeAt(i));
  };
  tag(0, 'RIFF');
  data.setUint32(4, 36 + byteCount, true);
  tag(8, 'WAVE');
  tag(12, 'fmt ');
  data.setUint32(16, 16, true);
  data.setUint16(20, 1, true);
  data.setUint16(22, 1, true);
  data.setUint32(24, sampleRate, true);
  data.setUint32(28, sampleRate * 2, true);
  data.setUint16(32, 2, true);
  data.setUint16(34, 16, true);
  tag(36, 'data');
  data.setUint32(40, byteCount, true);
  let offset = 44;
  for (const frame of frames) {
    for (const sample of frame) {
      const clamped = Math.max(-1, Math.min(1, sample));
      data.setInt16(offset, clamped * (clamped < 0 ? 32768 : 32767), true);
      offset += 2;
    }
  }
  return new Blob([data.buffer], {type: 'audio/wav'});
}

type VoiceSession = {
  abort: AbortController;
  release: () => void;
  finish?: () => void;
};

export function useAgentVoice(
  transcribe: AgentTranscribe | undefined,
  scope: string | undefined,
  onText: (text: string) => void,
  onIssue: (issue: VoiceIssue) => void,
) {
  const [phase, setPhase] = React.useState<'idle' | 'opening' | 'waiting' | 'recording' | 'transcribing'>('idle');
  const [level, setLevel] = React.useState(0);
  const session = React.useRef<VoiceSession | undefined>(undefined);
  const latest = React.useRef({onText, onIssue});
  latest.current = {onText, onIssue};

  const releaseSession = React.useCallback(() => {
    const current = session.current;
    session.current = undefined;
    current?.abort.abort();
    current?.release();
  }, []);

  const cancel = React.useCallback(() => {
    releaseSession();
    setPhase('idle');
    setLevel(0);
  }, [releaseSession]);

  React.useEffect(() => {
    cancel();
    window.addEventListener('pagehide', cancel);
    return () => {
      window.removeEventListener('pagehide', cancel);
      releaseSession();
    };
  }, [scope, transcribe, cancel, releaseSession]);

  async function start() {
    if (session.current || !transcribe) return;
    const requestTranscription = transcribe;
    if (!navigator.mediaDevices?.getUserMedia || typeof AudioWorkletNode === 'undefined') {
      latest.current.onIssue('unsupported');
      return;
    }

    const abort = new AbortController();
    let context: AudioContext | undefined;
    let stream: MediaStream | undefined;
    let node: AudioWorkletNode | undefined;
    let timer: ReturnType<typeof setTimeout> | undefined;
    const current: VoiceSession = {abort, release: () => {
      clearTimeout(timer);
      if (node) {
        node.port.onmessage = null;
        node.port.close();
        node.disconnect();
        node = undefined;
      }
      stream?.getTracks().forEach(track => track.stop());
      stream = undefined;
      if (context && context.state !== 'closed') void context.close().catch(() => {});
      context = undefined;
    }};
    session.current = current;
    const isCurrent = () => session.current === current && !abort.signal.aborted;
    const fail = (error: VoiceIssue) => {
      if (!isCurrent()) return;
      cancel();
      latest.current.onIssue(error);
    };
    setPhase('opening');

    try {
      const audioContext = new AudioContext({sampleRate});
      context = audioContext;
      // Start resuming during the user gesture, before awaiting permission.
      const resumed = audioContext.resume();
      void resumed.catch(() => {});
      const input = await navigator.mediaDevices.getUserMedia({
        audio: {channelCount: 1, echoCancellation: true, noiseSuppression: true},
      });
      if (!isCurrent()) {
        input.getTracks().forEach(track => track.stop());
        return;
      }
      stream = input;
      timer = setTimeout(() => fail('captureFailed'), 15_000);
      input.getAudioTracks().forEach(track => {
        track.addEventListener('ended', () => fail('captureFailed'), {once: true});
      });
      if (audioContext.sampleRate !== sampleRate) {
        fail('unsupported');
        return;
      }
      await resumed;
      await audioContext.audioWorklet.addModule(new URL('./voice-capture.worklet.js?no-inline', import.meta.url).href);
      if (!isCurrent()) return;
      const source = audioContext.createMediaStreamSource(input);
      const highPass = audioContext.createBiquadFilter();
      highPass.type = 'highpass';
      highPass.frequency.value = 85;
      node = new AudioWorkletNode(audioContext, 'dora-voice-capture', {
        channelCount: 1, channelCountMode: 'explicit', outputChannelCount: [1],
      });
      node.onprocessorerror = () => fail('captureFailed');

      const frames: Float32Array[] = [];
      let noise = 0.002;
      let voicedRun = 0;
      let startFrame = -1;
      let lastVoice = 0;
      async function finish() {
        if (!isCurrent() || !current.finish) return;
        delete current.finish;
        if (startFrame < 0) {
          fail('noSpeech');
          return;
        }
        current.release();
        setPhase('transcribing');
        timer = setTimeout(() => fail('transcriptionFailed'), 60_000);
        try {
          const text = (await requestTranscription(encodeWav(frames.slice(startFrame, lastVoice + 1 + tailFrames)), abort.signal)).trim();
          if (!isCurrent()) return;
          if (!text) {
            fail('noSpeech');
            return;
          }
          cancel();
          latest.current.onText(text);
        } catch {
          fail('transcriptionFailed');
        }
      }
      current.finish = () => void finish();
      node.port.onmessage = ({data}: MessageEvent<Float32Array>) => {
        const index = frames.push(data) - 1;
        let energy = 0;
        for (const value of data) energy += value * value;
        const rms = Math.sqrt(energy / data.length);
        if (index % 3 === 0) setLevel(Math.min(1, rms * 12));
        // Adaptive energy VAD with a lower threshold after speech starts.
        const voiced = rms > Math.max(startFrame < 0 ? 0.008 : 0.005, noise * (startFrame < 0 ? 3 : 1.8));
        if (!voiced) noise = noise * 0.97 + rms * 0.03;
        voicedRun = voiced ? voicedRun + 1 : 0;
        if (startFrame < 0 && voicedRun >= 6) {
          startFrame = Math.max(0, index - voicedRun + 1 - preRollFrames);
          lastVoice = index;
          setPhase('recording');
          clearTimeout(timer);
          timer = setTimeout(() => void finish(), Math.max(0, maxCaptureMs - index * frameMs));
        }
        if (startFrame >= 0 && voicedRun >= 2) lastVoice = index;
        if (startFrame >= 0 && (index - lastVoice) * frameMs >= endSilenceMs) void finish();
      };
      clearTimeout(timer);
      timer = setTimeout(() => fail('noSpeech'), waitForSpeechMs);
      setPhase('waiting');
      // The worklet emits silence while posting microphone frames to the composer.
      source.connect(highPass).connect(node).connect(audioContext.destination);
    } catch (error) {
      fail(error instanceof DOMException && error.name === 'NotAllowedError' ? 'permission' : 'captureFailed');
    }
  }

  return {phase, level, start, cancel, finish: () => session.current?.finish?.()};
}
