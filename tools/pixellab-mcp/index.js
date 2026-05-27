/**
 * pixellab-godot MCP server
 * Exposes tools for generating pixel art via PixelLab and saving assets locally.
 * Configure via environment variables — never hardcode keys or paths.
 */

import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";
import fs from "fs/promises";
import path from "path";

const PIXELLAB_API_KEY = process.env.PIXELLAB_API_KEY;
const PIXELLAB_API_URL = "https://api.pixellab.ai/v1";

if (!PIXELLAB_API_KEY) {
  console.error("PIXELLAB_API_KEY environment variable is required.");
  process.exit(1);
}

const server = new McpServer({
  name: "pixellab-godot",
  version: "0.1.0",
});

server.tool(
  "generate_sprite",
  "Generate a pixel art sprite via PixelLab and save it to a local path.",
  {
    prompt: z.string().describe("Text description of the sprite to generate"),
    output_path: z.string().describe("Absolute path where the PNG will be saved"),
    width: z.number().int().default(32).describe("Sprite width in pixels"),
    height: z.number().int().default(32).describe("Sprite height in pixels"),
    style_reference: z.string().optional().describe("Base64-encoded style reference image"),
  },
  async ({ prompt, output_path, width, height, style_reference }) => {
    const body = {
      description: prompt,
      image_size: { width, height },
    };
    if (style_reference) {
      body.style_image = style_reference;
    }

    const response = await fetch(`${PIXELLAB_API_URL}/generate`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${PIXELLAB_API_KEY}`,
      },
      body: JSON.stringify(body),
    });

    if (!response.ok) {
      const err = await response.text();
      return { content: [{ type: "text", text: `PixelLab error: ${err}` }], isError: true };
    }

    const data = await response.json();
    const imageBase64 = data.image;
    const imageBuffer = Buffer.from(imageBase64, "base64");

    await fs.mkdir(path.dirname(output_path), { recursive: true });
    await fs.writeFile(output_path, imageBuffer);

    return {
      content: [{ type: "text", text: `Saved sprite to ${output_path}` }],
    };
  }
);

server.tool(
  "generate_tileset",
  "Generate a pixel art tileset via PixelLab and save it to a local path.",
  {
    prompt: z.string().describe("Text description of the tileset to generate"),
    output_path: z.string().describe("Absolute path where the PNG will be saved"),
    tile_size: z.number().int().default(16).describe("Size of each tile in pixels"),
    columns: z.number().int().default(4).describe("Number of tile columns in the sheet"),
    rows: z.number().int().default(4).describe("Number of tile rows in the sheet"),
    style_reference: z.string().optional().describe("Base64-encoded style reference image"),
  },
  async ({ prompt, output_path, tile_size, columns, rows, style_reference }) => {
    const body = {
      description: prompt,
      image_size: { width: tile_size * columns, height: tile_size * rows },
      tileset: true,
    };
    if (style_reference) {
      body.style_image = style_reference;
    }

    const response = await fetch(`${PIXELLAB_API_URL}/generate`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${PIXELLAB_API_KEY}`,
      },
      body: JSON.stringify(body),
    });

    if (!response.ok) {
      const err = await response.text();
      return { content: [{ type: "text", text: `PixelLab error: ${err}` }], isError: true };
    }

    const data = await response.json();
    const imageBuffer = Buffer.from(data.image, "base64");

    await fs.mkdir(path.dirname(output_path), { recursive: true });
    await fs.writeFile(output_path, imageBuffer);

    return {
      content: [{ type: "text", text: `Saved tileset to ${output_path}` }],
    };
  }
);

const transport = new StdioServerTransport();
await server.connect(transport);
