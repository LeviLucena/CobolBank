# AI Render Pipeline

![Python](https://img.shields.io/badge/Python_3.13+-3776AB?style=for-the-badge&logo=python&logoColor=white)
![FastAPI](https://img.shields.io/badge/FastAPI-009688?style=for-the-badge&logo=fastapi&logoColor=white)
![Flux](https://img.shields.io/badge/Flux_1.1_Pro-000000?style=for-the-badge&logo=blackforestlabs&logoColor=white)
![Replicate](https://img.shields.io/badge/Replicate-6B21A8?style=for-the-badge&logo=replicate&logoColor=white)
![Stability AI](https://img.shields.io/badge/Stability_AI-FF6B35?style=for-the-badge&logo=stability-ai&logoColor=white)
![Stable Diffusion](https://img.shields.io/badge/Stable_Diffusion-8A2BE2?style=for-the-badge&logo=adobe&logoColor=white)
![LoRA](https://img.shields.io/badge/LoRA_Fine--Tuning-FF4500?style=for-the-badge&logo=pytorch&logoColor=white)
![PyTorch](https://img.shields.io/badge/PyTorch-EE4C2C?style=for-the-badge&logo=pytorch&logoColor=white)
![Uvicorn](https://img.shields.io/badge/Uvicorn-499848?style=for-the-badge&logo=gunicorn&logoColor=white)
![JavaScript](https://img.shields.io/badge/JavaScript-F7DF1E?style=for-the-badge&logo=javascript&logoColor=black)
![HTML5](https://img.shields.io/badge/HTML5-E34F26?style=for-the-badge&logo=html5&logoColor=white)
![CodeMirror](https://img.shields.io/badge/CodeMirror-D30707?style=for-the-badge&logo=codemirror&logoColor=white)
![dotenv](https://img.shields.io/badge/.ENV-ECD53F?style=for-the-badge&logo=dotenv&logoColor=black)

A Python-based generative AI pipeline for architectural visualization. Transforms 3D renders into photo-realistic images, generates complete PBR material maps, and creates full architectural scenes from text — all powered by Flux, Stable Diffusion, and LoRA models.

Built as a portfolio project aligned with the **Generative Image AI Engineer** role at Structure Studios.

<img width="1893" height="901" alt="image" src="https://github.com/user-attachments/assets/d1cc76a3-9089-4120-9b1f-e1b977eb27ee" />

---

## Features

### Mode A — Render Enhancer
Upload a basic 3D render (from Blender, SketchUp, or any 3D software) and transform it into a photo-realistic image using Flux Dev img2img. Simultaneously generates a PBR diffuse texture map via Stability AI. The web interface shows a side-by-side before/after comparison with the PBR map displayed below.

### Mode B — Scene Generator
Describe an architectural scene in plain text and generate a full photorealistic image using Flux 1.1 Pro. Supports optional LoRA fine-tuned models for consistent architectural styles. The generated image is displayed with the prompt overlaid, matching the style of the Replicate playground.

### Mode C — PBR Material Generator
Enter any material name and generate a complete PBR texture set (Diffuse, Roughness, and Normal maps) using Stability AI's core image generation model. All three maps are displayed in a grid, ready for use in any 3D software.

---

## Tech Stack

| Layer | Technology |
|---|---|
| AI — Image Generation | Flux 1.1 Pro, Flux Dev (img2img) via Replicate |
| AI — PBR Textures | Stability AI Stable Image Core |
| AI — Style / LoRA | Flux Dev LoRA via Replicate |
| Backend | Python 3.13+, FastAPI, Uvicorn |
| Frontend | Vanilla HTML/JS, CodeMirror (syntax highlighting) |
| HTTP Client | `requests` (no SDK dependency) |
| Config | `python-dotenv` |

---

## Project Structure

```
ai-render-pipeline/
├── app.py                  # FastAPI server — web interface + API endpoints
├── main.py                 # CLI entry point
├── config.py               # Centralized config — models, API keys, paths
├── replicate_api.py        # Replicate HTTP client (no SDK, Python 3.14 compatible)
├── modes/
│   ├── render.py           # Mode A: Flux img2img + Stability AI PBR
│   ├── scene.py            # Mode B: Flux text-to-image + LoRA
│   └── material.py         # Mode C: Stability AI PBR map generator
├── static/
│   └── index.html          # Web UI — split editor + image viewer
├── outputs/                # Generated images saved here
├── .env                    # API keys (not committed)
├── requirements.txt
└── README.md
```

---

## Requirements

- Python 3.13 or higher
- [Replicate](https://replicate.com) account and API key
- [Stability AI](https://stability.ai) account and API key

---

## Installation

**1. Clone the repository**

```bash
git clone https://github.com/your-username/ai-render-pipeline.git
cd ai-render-pipeline
```

**2. Install dependencies**

```bash
pip install -r requirements.txt
pip install fastapi uvicorn python-multipart
```

**3. Configure API keys**

Create a `.env` file in the project root:

```env
REPLICATE_API_KEY=your_replicate_api_key_here
STABILITY_API_KEY=your_stability_api_key_here
```

- Get your Replicate key at: https://replicate.com/account/api-tokens
- Get your Stability AI key at: https://platform.stability.ai/account/keys

---

## Usage

### Web Interface

Start the server:

```bash
python -m uvicorn app:app --host 0.0.0.0 --port 8000 --reload
```

Open your browser at **http://localhost:8000**

The interface has three tabs:

- **B · Scene Generator** — Edit the `"prompt"` line in the code editor and click **Generate** (or press `Ctrl+Enter`)
- **A · Render Enhancer** — Upload a 3D render image, adjust the prompt, and click **Generate**. Before/after comparison appears on the right with the PBR diffuse map below
- **C · PBR Material** — Edit the `material = "..."` line and click **Generate**. Three PBR maps appear in a grid on the right

---

### CLI

The pipeline is also fully usable from the terminal.

**Mode B — Generate a scene from text:**

```bash
python main.py --mode scene --prompt "modern swimming pool with garden"
```

**Mode A — Enhance a 3D render:**

```bash
python main.py --mode render --input my_render.jpg
python main.py --mode render --input my_render.jpg --prompt "photorealistic interior, 8K, dramatic lighting"
```

**Mode C — Generate PBR material maps:**

```bash
python main.py --mode material --material "white carrara marble"
```

Add `--lora` to Mode B to use the architectural LoRA model:

```bash
python main.py --mode scene --prompt "luxury penthouse rooftop" --lora
```

All outputs are saved to the `outputs/` folder.

---

## API Endpoints

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/` | Serves the web interface |
| `POST` | `/generate-scene` | Mode B — text to scene |
| `POST` | `/generate-render` | Mode A — render enhancement (multipart/form-data) |
| `POST` | `/generate-material` | Mode C — PBR material generation |

### POST `/generate-scene`

```json
{
  "prompt": "modern swimming pool with garden at sunset"
}
```

Response:
```json
{
  "image": "data:image/png;base64,...",
  "prompt": "modern swimming pool with garden at sunset"
}
```

### POST `/generate-render`

`multipart/form-data` with:
- `file` — image file (JPEG or PNG)
- `prompt` — enhancement description (optional)

Response:
```json
{
  "original": "data:image/png;base64,...",
  "enhanced": "data:image/png;base64,...",
  "pbr": "data:image/png;base64,...",
  "prompt": "photorealistic architectural render, 8K"
}
```

### POST `/generate-material`

```json
{
  "material": "white carrara marble"
}
```

Response:
```json
{
  "diffuse":   "data:image/png;base64,...",
  "roughness": "data:image/png;base64,...",
  "normal":    "data:image/png;base64,...",
  "material":  "white carrara marble"
}
```

---

## Models Used

| Model | Provider | Used For |
|---|---|---|
| `black-forest-labs/flux-1.1-pro` | Replicate | Scene generation (Mode B) |
| `black-forest-labs/flux-dev` | Replicate | Render enhancement img2img (Mode A) |
| `lucataco/flux-dev-lora` | Replicate | Architectural style LoRA (Mode B --lora) |
| `stable-image/generate/core` | Stability AI | PBR texture generation (Modes A and C) |

---

## Roadmap

- [ ] Mode A: slider comparison (drag to reveal before/after)
- [ ] Mode C: export all 3 PBR maps as a zip
- [ ] LoRA fine-tuning pipeline for custom architectural styles
- [ ] AI video upscaling integration (Phase 3)
- [ ] Batch processing via CLI
- [ ] Docker deployment

---

## Notes

- The Replicate SDK is intentionally not used. `replicate_api.py` communicates directly with the Replicate REST API, making the project fully compatible with Python 3.13 and 3.14.
- All generated images are saved locally to `outputs/` in addition to being returned as base64 by the API.
- The `.env` file is never committed. Rotate your API keys if they are ever exposed in version control or chat history.

---

## License

MIT
