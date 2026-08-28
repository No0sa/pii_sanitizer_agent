# 🛡️ Agentic PII Sanitizer

An enterprise-grade, Multi-Agent Privacy & PII (Personally Identifiable Information) Sanitization platform powered by **Gemini 3.6 Flash** and **Flutter Web**. Built for the micro1 challenge.

## 🚀 Key Features

- **Multi-Agent Architecture**:
  - **Inspector Agent**: Scans unstructured text and identifies sensitive PII (Names, Phones, Credit Cards, Passports, IPs) with contextual classification.
  - **Generator Agent**: Supports two dynamic operational modes:
    - **Synthetic Mode**: Replaces sensitive data with realistic fake values while maintaining contextual grammar.
    - **Redaction Mode**: Masks sensitive data directly with `[REDACTED_*]` security tags.
  - **Verification Agent**: Acts as a reflection layer to evaluate outputs and ensure zero data leakage.
- **Audit & Transparency**: Live Trajectory Logging drawer tracking all agent actions and reasoning chains.
- **Interactive UI**: Custom text testing, real-time mode switching, and one-click clipboard formatting.

## 🛠️ Tech Stack

- **Frontend**: Flutter Web (Dart)
- **AI Models**: Gemini 3.6 Flash
- **State & Architecture**: Agentic Flow with Custom Trajectory Logger

## 💻 How to Run Locally

1. **Clone the repository**:
   ```bash
   git clone [https://github.com/No0sa/pii_sanitizer_agent.git](https://github.com/No0sa/pii_sanitizer_agent.git)
   cd pii_sanitizer_agent
