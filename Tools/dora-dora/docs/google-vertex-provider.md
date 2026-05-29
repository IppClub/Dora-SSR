# Google Vertex Provider

The Pixel Sprite generator uses a provider boundary instead of calling Google
Vertex AI directly from the browser. This keeps Google credentials out of the
Web IDE and lets development and production use the same API shape.

## Provider endpoint

Development can point to a proxy running on the same machine:

```text
http://127.0.0.1:8877/api/google-vertex/generate-frame
```

Production can point to the same API hosted by Cloud Run or another trusted
service:

```text
https://your-domain.example.com/api/google-vertex/generate-frame
```

The Pixel Editor should treat both as the same `Google Vertex` provider.

## Start the development proxy

```bash
cd /Users/wangyue/dora/Dora-SSR/Tools/dora-dora

GOOGLE_VERTEX_PROJECT=gen-lang-client-0594452709 \
pnpm google:vertex-proxy
```

Optional environment variables:

```bash
GOOGLE_VERTEX_LOCATION=global
GOOGLE_VERTEX_MODEL=gemini-2.5-flash-image
GOOGLE_VERTEX_PROXY_PORT=8877
GOOGLE_VERTEX_HTTP_PROXY=http://127.0.0.1:7897
GCLOUD_BIN=/opt/homebrew/share/google-cloud-sdk/bin/gcloud
```

## API

### Health check

```http
GET /health
```

### Generate one sprite sheet image

```http
POST /api/google-vertex/generate-frame
Content-Type: application/json
```

Request:

```json
{
	"prompt": "Generate one complete 256x256 pixel art sprite sheet. Image 1 is character identity. Image 2 is the strict pose-slot layout reference...",
	"referenceImages": [
		"data:image/png;base64,...character portrait 256x256...",
		"data:image/png;base64,...motion reference sheet 256x256..."
	]
}
```

Response:

```json
{
	"success": true,
	"mimeType": "image/png",
	"imageBase64": "...",
	"text": "...",
	"usage": {
		"promptTokenCount": 1320,
		"candidatesTokenCount": 1290,
		"totalTokenCount": 2610
	}
}
```

## Pixel Editor flow

```text
Character Portrait 256x256
  + Motion Reference Sheet 256x256
  -> analyze reference sheet foreground components
  -> detect pose slot boxes and row/column order
  -> Google Vertex provider endpoint
  -> generated 256x256 PNG sprite sheet
  -> cut generated sheet using reference pose slots
  -> green-screen foreground extraction
  -> frame canvas placement / palette quantize
  -> PixelDocument.frames[]
```
