#!/usr/bin/env python3
import json
import subprocess
import sys
from pathlib import Path

import gi

gi.require_version("Gdk", "4.0")
gi.require_version("Gtk", "4.0")
gi.require_version("Gtk4LayerShell", "1.0")
gi.require_version("WebKit", "6.0")
from gi.repository import Gdk, GLib, Gtk, Gtk4LayerShell, WebKit


class ControlCentre(Gtk.Application):
    def __init__(self, assets: Path):
        super().__init__(application_id="dev.lawliet.ControlCentre")
        self.assets = assets
        self.connect("activate", self.activate)

    @staticmethod
    def run_command(*args: str) -> str:
        return subprocess.run(args, text=True, capture_output=True, check=False).stdout.strip()

    @staticmethod
    def call(*args: str) -> None:
        subprocess.Popen(args, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

    def node_label(self, target: str, fallback: str) -> str:
        values = {}
        for line in self.run_command("wpctl", "inspect", target).splitlines():
            if " = " in line:
                key, value = line.strip().split(" = ", 1)
                values[key.lstrip("* ")] = value.strip('"')
        return values.get("node.description") or values.get("node.nick") or fallback

    def audio_state(self) -> dict[str, object]:
        volume = self.run_command("wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@")
        try:
            value = float(volume.split()[1])
        except (IndexError, ValueError):
            value = 0
        return {
            "volume": value,
            "muted": "MUTED" in volume,
            "output": self.node_label("@DEFAULT_AUDIO_SINK@", "Default output"),
            "input": self.node_label("@DEFAULT_AUDIO_SOURCE@", "Default input"),
        }

    def send_audio_state(self) -> bool:
        payload = json.dumps(self.audio_state())
        self.webview.evaluate_javascript(
            f"window.controlCentre?.updateAudio({payload})", -1, None, None, None, None, None
        )
        return True

    def on_message(self, _manager, result):
        try:
            value = result.get_js_value().to_string()
            message = json.loads(value)
        except Exception:
            return

        match message.get("type"):
            case "ready":
                self.send_audio_state()
            case "window:close":
                self.quit()
            case "audio:mute":
                self.call("wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle")
            case "audio:volume":
                value = max(0, min(float(message.get("value", 0)), 1.5))
                self.call("wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", str(value))
            case "audio:choose-output" | "audio:choose-input":
                self.call("pavucontrol")

    def activate(self, *_args):
        self.window = Gtk.ApplicationWindow(application=self)
        self.window.set_decorated(False)
        self.window.set_resizable(False)
        self.window.set_default_size(440, 540)
        Gtk4LayerShell.init_for_window(self.window)
        Gtk4LayerShell.set_layer(self.window, Gtk4LayerShell.Layer.OVERLAY)
        Gtk4LayerShell.set_anchor(self.window, Gtk4LayerShell.Edge.TOP, True)
        Gtk4LayerShell.set_anchor(self.window, Gtk4LayerShell.Edge.RIGHT, True)
        Gtk4LayerShell.set_margin(self.window, Gtk4LayerShell.Edge.TOP, 54)
        Gtk4LayerShell.set_margin(self.window, Gtk4LayerShell.Edge.RIGHT, 12)
        Gtk4LayerShell.set_keyboard_mode(self.window, Gtk4LayerShell.KeyboardMode.ON_DEMAND)

        self.webview = WebKit.WebView.new()
        manager = self.webview.get_user_content_manager()
        manager.register_script_message_handler("control", None)
        manager.connect("script-message-received::control", self.on_message)
        transparent = Gdk.RGBA()
        transparent.parse("transparent")
        self.webview.set_background_color(transparent)
        settings = self.webview.get_settings()
        settings.set_enable_javascript(True)
        # Frontend is static `file://` assets in Nix store, not a web origin.
        settings.set_allow_file_access_from_file_urls(True)
        settings.set_enable_developer_extras(True)
        self.window.set_child(self.webview)
        # Inject current state before Lit loads. This avoids a blank/loading
        # panel when WebKit's async JS bridge starts after first paint.
        page = (self.assets / "index.html").read_text()
        initial_state = json.dumps({"audio": self.audio_state()})
        page = page.replace(
            "</head>",
            f"<script>window.controlCentreInitialState = {initial_state};</script></head>",
        )
        self.webview.load_html(page, GLib.filename_to_uri(f"{self.assets}/", None))
        self.window.present()
        GLib.timeout_add(1000, self.send_audio_state)


if __name__ == "__main__":
    ControlCentre(Path(sys.argv[1])).run(None)
