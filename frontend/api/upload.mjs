import formidable from "formidable";
import FormData from "form-data";
import axios from "axios";
import fs from "node:fs";

export const config = { api: { bodyParser: false } };

export default async function handler(req, res) {
  if (req.method !== "POST") return res.status(405).json({ error: "POST only" });
  if (!process.env.PINATA_JWT) return res.status(503).json({ error: "PINATA_JWT is not configured on the server" });
  const form = formidable({ maxFiles: 1, maxFileSize: 4 * 1024 * 1024, multiples: false });
  let parsed;
  try { parsed = await form.parse(req); }
  catch (error) { return res.status(400).json({ error: error?.message || "Invalid upload" }); }
  const files = parsed[1];
  const incoming = Array.isArray(files.file) ? files.file[0] : files.file;
  if (!incoming) return res.status(400).json({ error: "No file received" });
  const body = new FormData();
  body.append("file", fs.createReadStream(incoming.filepath), { filename: incoming.originalFilename || "upload.bin", contentType: incoming.mimetype || "application/octet-stream" });
  body.append("pinataMetadata", JSON.stringify({ name: incoming.originalFilename || "DATUMARK upload" }));
  body.append("pinataOptions", JSON.stringify({ cidVersion: 1 }));
  try {
    const response = await axios.post("https://api.pinata.cloud/pinning/pinFileToIPFS", body, { headers: { ...body.getHeaders(), Authorization: `Bearer ${process.env.PINATA_JWT}` }, maxBodyLength: Infinity });
    return res.status(200).json({ cid: response.data.IpfsHash });
  } catch (error) {
    const message = error?.response?.data?.error?.details || error?.response?.data?.error || error?.message || "Pinning failed";
    return res.status(502).json({ error: typeof message === "string" ? message : "Pinning failed" });
  }
}