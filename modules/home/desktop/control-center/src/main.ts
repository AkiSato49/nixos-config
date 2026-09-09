import { LitElement, css, html, svg } from 'lit';
import { customElement, property, state } from 'lit/decorators.js';
import './style.css';

type AudioState = {
  volume: number;
  muted: boolean;
  output: string;
  input: string;
};

declare global {
  interface Window {
    controlCentre?: {
      updateAudio(state: AudioState): void;
    };
    webkit?: {
      messageHandlers?: {
        control?: { postMessage(message: string): void };
      };
    };
    controlCentreInitialState?: { audio: AudioState };
  }
}

function send(type: string, payload: Record<string, unknown> = {}) {
  window.webkit?.messageHandlers?.control?.postMessage(JSON.stringify({ type, ...payload }));
}

const speaker = svg`<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M4 10v4h4l5 4V6L8 10H4Zm12.5 2a4.5 4.5 0 0 0-2.5-4.03v8.05A4.5 4.5 0 0 0 16.5 12Zm-2.5-9.42v2.06a7.5 7.5 0 0 1 0 14.72v2.06a9.5 9.5 0 0 0 0-18.84Z"/></svg>`;
const muted = svg`<svg viewBox="0 0 24 24" aria-hidden="true"><path d="m4.27 3 16.97 16.97-1.41 1.41-3.33-3.33L13 18v-3.64l-3.37-3.37L8 12H4v-4h1.63L2.86 5.23 4.27 3ZM13 6v3.64L9.36 6H13Zm6.5 6c0 .82-.17 1.6-.48 2.31l-1.51-1.51c.16-.49.24-1.02.24-1.55a4.5 4.5 0 0 0-2.25-3.89V5.3A6.5 6.5 0 0 1 19.5 12Z"/></svg>`;

@customElement('audio-widget')
class AudioWidget extends LitElement {
  @property({ type: Object }) audio: AudioState = {
    volume: 0,
    muted: false,
    output: 'No output',
    input: 'No input',
  };

  static styles = css`
    :host { display: block; }
    button { font: inherit; }
  `;

  render() {
    const volume = Math.round(this.audio.volume * 100);
    return html`
      <section class="card audio-card" aria-label="Sound">
        <header>
          <span class="icon sound">${this.audio.muted ? muted : speaker}</span>
          <div><h2>Sound</h2><p>${this.audio.output}</p></div>
          <button class="icon-button" @click=${() => send('audio:mute')} aria-label="${this.audio.muted ? 'Unmute' : 'Mute'}">
            ${this.audio.muted ? muted : speaker}
          </button>
        </header>
        <div class="slider-row">
          <span class="slider-icon" aria-hidden="true">${speaker}</span>
          <input
            aria-label="Output volume"
            type="range"
            min="0"
            max="150"
            .value=${String(volume)}
            @input=${(event: InputEvent) => send('audio:volume', { value: Number((event.target as HTMLInputElement).value) / 100 })}
          />
          <output>${volume}%</output>
        </div>
        <div class="device-row"><span>Output</span><button @click=${() => send('audio:choose-output')}>${this.audio.output} <b>›</b></button></div>
        <div class="device-row"><span>Input</span><button @click=${() => send('audio:choose-input')}>${this.audio.input} <b>›</b></button></div>
      </section>
    `;
  }
}

@customElement('control-centre')
class ControlCentre extends LitElement {
  @state() private audio: AudioState = window.controlCentreInitialState?.audio ?? {
    volume: 0,
    muted: false,
    output: 'Loading output…',
    input: 'Loading input…',
  };

  connectedCallback() {
    super.connectedCallback();
    window.controlCentre = { updateAudio: (audio) => (this.audio = audio) };
    send('ready');
  }

  render() {
    return html`
      <main>
        <header class="panel-header">
          <div><p class="eyebrow">CONTROL CENTRE</p><h1>Good ${new Date().getHours() < 12 ? 'morning' : new Date().getHours() < 18 ? 'afternoon' : 'evening'}</h1></div>
          <button class="close" @click=${() => send('window:close')} aria-label="Close control centre">×</button>
        </header>
        <audio-widget .audio=${this.audio}></audio-widget>
        <section class="coming-soon" aria-label="Upcoming controls">
          <span>Wi‑Fi, Bluetooth, Battery, Focus and Display controls arrive next.</span>
        </section>
      </main>
    `;
  }
}
