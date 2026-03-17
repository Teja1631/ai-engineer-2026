"""Anthropic SDK patterns: sync, async, streaming, error handling."""

import asyncio
import time
from anthropic import (
    Anthropic,
    AsyncAnthropic,
    APIError,
    RateLimitError,
    APIConnectionError,
    AuthenticationError,
)

client = Anthropic()
aclient = AsyncAnthropic()

MODEL = "claude-haiku-4-5-20251001"
MAX_TOKENS = 1024


def sync_call(prompt: str) -> str:
    msg = client.messages.create(
        model=MODEL, max_tokens=MAX_TOKENS,
        messages=[{"role": "user", "content": prompt}]
    )
    print(f"Tokens: {msg.usage.input_tokens} in / {msg.usage.output_tokens} out")
    return msg.content[0].text


async def async_calls(prompts: list[str]) -> list[str]:
    async def _call(p: str) -> str:
        msg = await aclient.messages.create(
            model=MODEL, max_tokens=MAX_TOKENS,
            messages=[{"role": "user", "content": p}]
        )
        print(f"Tokens: {msg.usage.input_tokens} in / {msg.usage.output_tokens} out")
        return msg.content[0].text
    return await asyncio.gather(*[_call(p) for p in prompts])


def stream_call(prompt: str) -> str:
    with client.messages.stream(
        model=MODEL, max_tokens=MAX_TOKENS,
        messages=[{"role": "user", "content": prompt}]
    ) as stream:
        for text in stream.text_stream:
            print(text, end="", flush=True)
        response = stream.get_final_message()
    print(f"\nTokens: {response.usage.input_tokens} in / {response.usage.output_tokens} out")
    return response.content[0].text


def call_with_retry(prompt: str, max_retries: int = 3) -> str:
    for attempt in range(max_retries):
        try:
            return sync_call(prompt)
        except RateLimitError:
            wait = 2 ** attempt
            print(f"Rate limited. Retrying in {wait}s...")
            time.sleep(wait)
        except APIConnectionError:
            print("Connection failed. Retrying...")
            time.sleep(1)
        except AuthenticationError:
            raise
        except APIError as e:
            print(f"API error {e.status_code}: {e.message}")
            raise
    raise RuntimeError("Max retries exceeded")


if __name__ == "__main__":
    print("=== Sync ===")
    print(sync_call("Summarize tissue fixation artifacts in 2 sentences."))

    print("\n=== Async ===")
    results = asyncio.run(async_calls([
        "What causes tissue folding artifacts?",
        "What causes air bubbles in mounted slides?",
        "What causes uneven staining?",
    ]))
    for r in results:
        print(r[:100], "\n---")

    print("\n=== Streaming ===")
    stream_call("Explain H&E staining steps.")

    print("\n=== Retry ===")
    call_with_retry("Explain H&E staining steps.")