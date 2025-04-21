import fetch from 'node-fetch';
import dotenv from 'dotenv';

dotenv.config();
const SERVER_URL = process.env.SERVER_URL || 'http://localhost:8000';

async function* chatStream(message) {
  const res = await fetch(\`\${SERVER_URL}/chat?message=\${encodeURIComponent(message)}\`);
  if (!res.ok) throw new Error(await res.text());

  const reader = res.body.getReader();
  const decoder = new TextDecoder();
  let buffer = '';

  while (true) {
    const { done, value } = await reader.read();
    if (done) break;
    buffer += decoder.decode(value, { stream: true });

    const parts = buffer.split("\n\n");
    buffer = parts.pop();
    for (const chunk of parts) {
      const text = chunk.replace(/^data: /, '');
      yield text;
    }
  }
}

(async () => {
  for await (const msg of chatStream('Hello, world!')) {
    console.log('>', msg);
  }
})();
