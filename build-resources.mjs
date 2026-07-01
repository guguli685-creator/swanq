import fs from "node:fs";
import crypto from "node:crypto";
import readline from "node:readline/promises";
import { stdin as input, stdout as output } from "node:process";

const SOURCE_FILE = "resources.private.json";
const LOCKED_FILE = "resources.locked.js";
const PUBLIC_INDEX_FILE = "resources.txt";
const BASE_URL = (process.env.SWANQ_BASE_URL || "https://guguli685-creator.github.io/swanq").replace(/\/$/, "");

const ITERATIONS = 250000;
const KEY_LENGTH = 32;
const DIGEST = "sha256";

function toBase64(buffer) {
  return Buffer.from(buffer).toString("base64");
}

function normalizeResources(resources) {
  if (!Array.isArray(resources)) {
    throw new Error(`${SOURCE_FILE} 必须是 JSON 数组`);
  }

  return resources.map((item, index) => {
    if (!item || typeof item !== "object") {
      throw new Error(`第 ${index + 1} 条资源格式错误`);
    }

    const id = String(item.id || index + 1);
    const group = String(item.group || item.cat || "资源");
    const title = String(item.title || "").trim();
    const url = String(item.url || "#").trim();

    if (!title) {
      throw new Error(`第 ${index + 1} 条资源缺少 title`);
    }

    return { id, group, title, url };
  });
}

async function askPassword() {
  if (process.env.SWANQ_PASSWORD) {
    return process.env.SWANQ_PASSWORD;
  }

  const rl = readline.createInterface({ input, output });
  const password = await rl.question("输入加密密码：");
  const confirm = await rl.question("再次输入密码：");
  rl.close();

  if (!password || password.length < 10) {
    throw new Error("密码至少 10 位，建议使用更长密码");
  }

  if (password !== confirm) {
    throw new Error("两次密码不一致");
  }

  return password;
}

function buildPublicIndex(resources) {
  const lines = [
    "# SwanQ Creative Hub resources",
    "# 真实资源链接已加密到 resources.locked.js。",
    "# 不要在这个文件里直接写真实链接。",
    "# 修改资源时：编辑 resources.private.json，然后运行 node build-resources.mjs。",
    ""
  ];

  const groups = new Map();

  for (const item of resources) {
    if (!groups.has(item.group)) groups.set(item.group, []);
    groups.get(item.group).push(item);
  }

  for (const [group, items] of groups) {
    lines.push(`[${group}]`);

    for (const item of items) {
      const unlockUrl = `${BASE_URL}/unlock.html?id=${encodeURIComponent(item.id)}`;
      lines.push(item.title, unlockUrl, "");
    }
  }

  return `${lines.join("\n").trim()}\n`;
}

async function main() {
  if (!fs.existsSync(SOURCE_FILE)) {
    throw new Error(`找不到 ${SOURCE_FILE}。可以先复制 resources.private.example.json 为 ${SOURCE_FILE}`);
  }

  const resources = normalizeResources(JSON.parse(fs.readFileSync(SOURCE_FILE, "utf8")));
  const password = await askPassword();
  const plainText = JSON.stringify(resources, null, 2);

  const salt = crypto.randomBytes(16);
  const iv = crypto.randomBytes(12);
  const key = crypto.pbkdf2Sync(password, salt, ITERATIONS, KEY_LENGTH, DIGEST);
  const cipher = crypto.createCipheriv("aes-256-gcm", key, iv);
  const encrypted = Buffer.concat([
    cipher.update(plainText, "utf8"),
    cipher.final()
  ]);
  const tag = cipher.getAuthTag();

  const payload = {
    v: 1,
    alg: "AES-GCM",
    kdf: "PBKDF2",
    hash: "SHA-256",
    iterations: ITERATIONS,
    salt: toBase64(salt),
    iv: toBase64(iv),
    data: toBase64(encrypted),
    tag: toBase64(tag)
  };

  fs.writeFileSync(
    LOCKED_FILE,
    `window.SWANQ_LOCKED_DATA = ${JSON.stringify(payload, null, 2)};\n`,
    "utf8"
  );

  fs.writeFileSync(PUBLIC_INDEX_FILE, buildPublicIndex(resources), "utf8");

  console.log(`已生成 ${LOCKED_FILE}`);
  console.log(`已生成 ${PUBLIC_INDEX_FILE}`);
}

main().catch((error) => {
  console.error(error.message);
  process.exit(1);
});
