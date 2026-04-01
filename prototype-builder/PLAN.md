# Prototype Builder Plan

## Goal

Build a specialized prototyping agent and a shared hosting platform for many small apps on the same VPS that runs OpenClaw.

## Requirements

- User gives an app/tool idea in chat.
- Agent asks at most 1-2 short clarification rounds when truly necessary.
- Agent then builds the app without requiring more back-and-forth.
- Apps live in `~/antons-playground/apps/<app-name>`.
- Each app gets a subdomain at `<app-name>.carbon.jonathansalzer.com`.
- Apps are private-by-default for Tailscale use.
- Selected apps can be exposed publicly on the internet.
- Apps should be Dockerized when sensible.
- The system should support many little apps at once.
- The workflow should encourage frequent commits.

## Deliverables

1. Platform architecture document
2. Builder-agent spec
3. Repository README documentation
4. Initial scaffold recommendations for implementation

## Recommended Build Order

### Phase 1 - Platform foundation
- Create shared hosting conventions.
- Define reverse proxy approach.
- Define app metadata format.
- Define private/public exposure model.
- Define deployment scripts and network layout.

### Phase 2 - Builder-agent contract
- Define prompt and scope.
- Define clarification policy.
- Define stack selection defaults.
- Define deployment behavior.
- Define reporting format.

### Phase 3 - Implementation scaffold
- Create `platform/` layout.
- Create app template.
- Create app registration/deployment scripts.
- Create example app.

## Key Design Principles

- MVP-first over polish
- private-by-default
- boring tech over novelty
- one app per folder
- one clear deployment convention
- minimal clarification, then action
- reasonable assumptions when blocked
