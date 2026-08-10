---
name: chat-cleanup-check
description: Diagnose the current chat's cleanup level without changing files or threads.
---

# ChatCleanup Check

Use Portuguese and inspect only the active project and current chat. Confirm
the active root in one short sentence.

When the user sends `/chat-cleanup check`:

- classify the current chat as `light`, `medium`, or `heavy` using visible
  automatic compactions, context pressure, response quality, and reported
  slowdown;
- explain the evidence briefly;
- recommend `/chat-cleanup refresh` or `/chat-cleanup now` only when useful;
- do not write files, open a thread, archive a chat, or use a local service.

The command is global and must not depend on a project-local installation.
