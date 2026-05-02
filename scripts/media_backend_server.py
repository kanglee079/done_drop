#!/usr/bin/env python3
from __future__ import annotations

import json
import mimetypes
import os
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import unquote, urlparse


HOST = os.environ.get("DD_MEDIA_BACKEND_HOST", "0.0.0.0")
PORT = int(os.environ.get("PORT", os.environ.get("DD_MEDIA_BACKEND_PORT", "8081")))
ROOT = Path(
    os.environ.get(
        "DD_MEDIA_BACKEND_ROOT",
        str(Path.cwd() / ".media_backend_storage"),
    )
).resolve()
PUBLIC_BASE_URL = os.environ.get(
    "DD_MEDIA_BACKEND_PUBLIC_BASE_URL",
    "",
).rstrip("/")
MAX_UPLOAD_BYTES = int(
    os.environ.get("DD_MEDIA_BACKEND_MAX_UPLOAD_BYTES", str(15 * 1024 * 1024))
)


def sanitize_relative_path(raw_path: str) -> Path:
    candidate = Path(unquote(raw_path.lstrip("/")))
    if candidate.is_absolute() or ".." in candidate.parts:
        raise ValueError("Invalid storage path")
    return candidate


class MediaBackendHandler(BaseHTTPRequestHandler):
    server_version = "DoneDropMediaBackend/1.0"

    def log_message(self, format: str, *args) -> None:
        print(
            json.dumps(
                {
                    "remote": self.address_string(),
                    "method": self.command,
                    "path": self.path,
                    "message": format % args,
                }
            ),
            flush=True,
        )

    def _request_base_url(self) -> str:
        if PUBLIC_BASE_URL:
            return PUBLIC_BASE_URL

        forwarded_proto = self.headers.get("X-Forwarded-Proto")
        proto = forwarded_proto or "http"
        host = self.headers.get("Host", f"{HOST}:{PORT}")
        return f"{proto}://{host}"

    def _send_json(self, status: int, payload: dict) -> None:
        body = json.dumps(payload).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Access-Control-Allow-Origin", "*")
        self.end_headers()
        self.wfile.write(body)

    def _send_bytes(self, status: int, data: bytes, content_type: str) -> None:
        self.send_response(status)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(data)))
        self.send_header("Cache-Control", "public, max-age=31536000")
        self.send_header("Access-Control-Allow-Origin", "*")
        self.end_headers()
        self.wfile.write(data)

    def do_OPTIONS(self) -> None:
        self.send_response(204)
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, PUT, DELETE, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        self.end_headers()

    def do_GET(self) -> None:
        parsed = urlparse(self.path)
        if parsed.path == "/health":
            self._send_json(
                200,
                {
                    "ok": True,
                    "root": str(ROOT),
                    "publicBaseUrl": self._request_base_url(),
                },
            )
            return

        if not parsed.path.startswith("/file/"):
            self._send_json(404, {"error": "Not found"})
            return

        try:
            relative_path = sanitize_relative_path(parsed.path[len("/file/"):])
        except ValueError as error:
            self._send_json(400, {"error": str(error)})
            return

        target = (ROOT / relative_path).resolve()
        if not str(target).startswith(str(ROOT)) or not target.exists() or not target.is_file():
            self._send_json(404, {"error": "File not found"})
            return

        content_type, _ = mimetypes.guess_type(target.name)
        self._send_bytes(200, target.read_bytes(), content_type or "application/octet-stream")

    def do_PUT(self) -> None:
        parsed = urlparse(self.path)
        if not parsed.path.startswith("/upload/"):
            self._send_json(404, {"error": "Not found"})
            return

        try:
            relative_path = sanitize_relative_path(parsed.path[len("/upload/"):])
        except ValueError as error:
            self._send_json(400, {"error": str(error)})
            return

        content_length = int(self.headers.get("Content-Length", "0"))
        if content_length <= 0:
            self._send_json(400, {"error": "Empty body"})
            return
        if content_length > MAX_UPLOAD_BYTES:
            self._send_json(413, {"error": "Upload too large"})
            return

        body = self.rfile.read(content_length)
        target = (ROOT / relative_path).resolve()
        if not str(target).startswith(str(ROOT)):
            self._send_json(400, {"error": "Invalid target path"})
            return

        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(body)

        self._send_json(
            200,
            {
                "storagePath": relative_path.as_posix(),
                "downloadUrl": f"{self._request_base_url()}/file/{relative_path.as_posix()}",
                "size": len(body),
            },
        )

    def do_DELETE(self) -> None:
        parsed = urlparse(self.path)
        if not parsed.path.startswith("/file/"):
            self._send_json(404, {"error": "Not found"})
            return

        try:
            relative_path = sanitize_relative_path(parsed.path[len("/file/"):])
        except ValueError as error:
            self._send_json(400, {"error": str(error)})
            return

        target = (ROOT / relative_path).resolve()
        if not str(target).startswith(str(ROOT)):
            self._send_json(400, {"error": "Invalid target path"})
            return

        if target.exists():
            target.unlink()
        self._send_json(200, {"deleted": True, "storagePath": relative_path.as_posix()})


def main() -> None:
    ROOT.mkdir(parents=True, exist_ok=True)
    server = ThreadingHTTPServer((HOST, PORT), MediaBackendHandler)
    print(
        json.dumps(
            {
                "status": "ready",
                "host": HOST,
                "port": PORT,
                "root": str(ROOT),
                "publicBaseUrl": PUBLIC_BASE_URL or f"http://{HOST}:{PORT}",
            }
        ),
        flush=True,
    )
    server.serve_forever()


if __name__ == "__main__":
    main()
