---
name: jira-writing
description: Draft, create, or refine Jira tasks, user stories, bugs, spikes, and epics using Atlassian MCP when Jira access is needed. Use for issue writing, not implementing issues or answering general status queries.
---

# Jira writing

Write the smallest independent useful outcome, not a full implementation spec.
Use precise plain English by default; match the user's language. Use active voice,
without corporate jargon, fluff, or forced “As a …” boilerplate.
An independent future reader must understand the ticket without this chat.

## Decide what to write

- Identify the intended outcome, why it matters, and observable success conditions.
  Ask one concise question if the outcome or success conditions are missing.
- Keep unknowns visible as questions, not facts, commitments, or promises.
  Implementation unknowns can wait for planning unless they change the outcome.
- Separate independently useful outcomes rather than bundling unrelated work.
- Distinguish verified constraints from possible implementation ideas. Omit ideas
  that add no necessary context; label any retained ideas as nonbinding.
- Do not dictate files, APIs, libraries, or technical design unless the user asks
  for them or a verified contract constrains them.
- Planning, design, grilling, and implementation are separate later phases.
  Do not invoke them automatically while writing an issue.

## Choose an issue type

Use the project's actual types, not an assumed universal type list.

| Type | Use and required detail |
| --- | --- |
| Story | A user-visible capability, stated as a feature or outcome. |
| Task | A technical or operational deliverable with observable completion. |
| Bug | Observed behavior, expected behavior, and reproduction steps or conditions. Mark missing details explicitly unknown; include a regression check in DoD. |
| Spike | A bounded question and research scope, with a user-provided or agreed timebox. Ask if the timebox is missing. Require findings with evidence, a recommendation even if inconclusive, and proposed follow-ups. No implicit implementation. |
| Epic | A broad outcome with links to child work and clear overall completion. Not a vague giant task; do not fabricate child keys or create children without authorization. |

If a requested type is unsupported (including Spike), resolve the choice with the
user. Never silently substitute Task or another type.

## Core template

Use Markdown headings and checklists by default. Respect an existing team template,
but always include an explicit Definition of Done. Keep success checks in one place;
do not duplicate acceptance criteria and DoD. Incorporate existing criteria into DoD
or reference them precisely if the team requires a separate section.

```markdown
Title: <clear action or outcome, specific enough to distinguish this issue>

## Outcome
<What changes and why it matters. Usually one or two sentences.>

## Scope
<Only when needed to establish boundaries. Exclude only likely points of confusion.>

## Definition of Done
- [ ] <Observable binary condition and the evidence needed to establish it.>
- [ ] <Another condition that defines success for this particular outcome.>
- [ ] <Relevant boundary or failure case, if applicable.>
```

Typically use 3–6 DoD checks; use fewer when they fully define a small outcome.
Each check must be testable with a clear yes/no result. Choose evidence relevant
to the work: observed behavior, a verified deliverable, or a recorded finding.
Do not pad the checklist with generic review, testing, security, or documentation
rituals. Add those obligations only when supplied, required, or part of the outcome.
Never fabricate performance targets, deadlines, or other numerical commitments.

Add Context/links, Constraints/dependencies, or Open questions only when material.
Include Bug reproduction details and Spike question/scope/timebox where applicable.
Link to specific evidence and explain its relevance; “as discussed” is not context.
Known constraints and unresolved questions must be distinguishable.

## Authorization and context

- A request for a draft authorizes no Jira writes. Return a paste-ready draft.
- Explicit create/update authorization is sufficient; do not ask for redundant
  confirmation. Resolve ambiguity about site, project, type, or intended meaning
  before writing. Draft what is known while awaiting a necessary decision.
- Read existing linked context only as needed. For an update, read the existing
  issue fully enough to preserve its text and unrelated sections and fields.
- Do not invent assignee, priority, sprint, labels, estimates, dependencies, or
  deadlines. Set only supplied/confirmed values or verified project requirements.
  A requirement to populate a field does not authorize guessing its value.

## Atlassian MCP workflow

The connected tools' current schemas are authoritative. Names below may have a
client prefix; use the exposed tool and argument names rather than assuming them.

1. When resolving a site, call `getAccessibleAtlassianResources` once per session
   and cache the selected `cloudId`. Clarify multiple candidate sites; never pick
   the first arbitrarily. Pass `cloudId` explicitly at the top level of execute
   calls and primary calls that require it.
2. Use `getJiraIssue` for a known key. Use `atlassian_search` (Rovo search) for
   semantic Jira/Confluence searches unless the user supplies JQL/CQL; in that case
   use a tool supporting that query language, discovering it if necessary.
   Before creating a new issue, search likely duplicates with a narrow,
   project-aware query. Raise a likely match instead of silently duplicating it.
   A search outage is not evidence that no duplicates exist; report the limitation
   and do not block drafting.
3. Use primary tools such as `createJiraIssue`, `editJiraIssue`, and
   `addOrEditJiraIssueComment` directly when available and authorized. For unavailable
   operations, use discovery with verb + object + product, for example
   “list project issue types Jira” or “lookup account id Jira”. Use only returned
   operation names with the matching `executeRead`, `executeWrite`, or
   `executeDestructive` route. Never guess operation names or IDs.
4. Avoid exhaustive schema or metadata fetches. Where supported, `additional_fields`
   resolves human-readable field names. A rejected create lists allowed/required
   values: repair input once from that error, not speculation. Ask about mandatory
   fields that need a user decision. Resolve an assignee through an account lookup
   and use the returned `accountId`, not a guessed ID or display name.
5. Prepare the description in the correct format (see below), then perform only
   the authorized write. Never blindly retry an ambiguous write timeout. Check
   whether the issue or change exists first; ask the user if this cannot be
   established. A timeout is not proof that a write failed.
6. Verify the authoritative returned issue, or make one targeted read if the
   payload is insufficient. Check title, type, description including DoD, and
   requested fields. Report discrepancies rather than claiming success.
7. Return the verified key/link and any material unresolved questions. If MCP is
   unavailable, never fall back to shell or curl. Provide a paste-ready draft and
   state clearly that it was not created or updated. If a write may have completed,
   report its outcome as unknown rather than claiming it did not happen.

Changing workflow status requires a transition, not editing a status field.
Only with separate authorization, discover available transitions and select the
requested named transition using its returned ID. Do not automatically transition
issues, create follow-ups, or add comments. A Spike can propose follow-ups in its
findings without authorizing their creation.

## Preserve content formats

- Use Markdown for ordinary new descriptions and headings/checklists.
- Edit bodies containing inline media or rich HTML losslessly using `html`.
  Before authoring HTML, call `getContentFormatGuide` via `executeRead` with
  `toolName: editJiraIssue` or `toolName: createJiraIssue`, as applicable, and the
  top-level `cloudId`. Follow the current schema and returned guide.
- Preserve unrelated description sections, media, and fields. Never overwrite
  fetched HTML with Markdown. If a lossless edit is not possible with the available
  content/tools, explain the limitation and provide a proposed edit without writing.

## Worked tickets

These details are illustrative, not defaults or inferred project requirements.
The Spike timebox below represents an explicitly agreed timebox.

### Story: Show the delivery address before order confirmation

**Outcome:** Shoppers can check their selected delivery address before placing
an order, reducing orders sent to an unintended address.

**Scope:** The order review step for orders requiring delivery. Changing saved
addresses and changing the checkout flow are outside this ticket.

**Definition of Done**
- [ ] An order requiring delivery shows its selected delivery address on the
      review step before the shopper confirms the order.
- [ ] When a shopper changes the selected address through the existing flow,
      returning to review shows the newly selected address, not the previous one.
- [ ] An order that does not require delivery shows no delivery-address section.

### Spike: Determine whether carrier tracking data can explain delivery delays

**Outcome:** Decide whether the carrier's available tracking data can explain
delays to customers without implying a cause the data cannot establish.

**Question and scope:** Review the carrier's published event definitions and the
sample delayed shipments provided by the support team. Can the data distinguish
a failed delivery attempt from a parcel still in transit? No customer feature or
production integration is included.

**Agreed timebox:** One working day. Stop at the limit and record remaining unknowns.

**Definition of Done**
- [ ] Findings link the reviewed event definitions and samples, distinguishing
      supported interpretations from gaps or conflicting evidence.
- [ ] A recommendation states whether to proceed, not proceed, or gather more
      evidence, with reasons; inconclusive findings are an acceptable result.
- [ ] Proposed follow-ups identify the remaining questions and evidence needed,
      or explicitly state that no follow-up is needed. No implementation is assumed.

## Before publishing

- [ ] A future human or agent can identify the outcome, boundaries, completion
      evidence, and material unknowns without this chat.
- [ ] The title and DoD contain no vague “improve”, “support”, or “handle properly”
      without an observable condition; “works as expected” alone is not a check.
- [ ] The issue delivers one independently useful outcome, or is an Epic whose
      child work and overall outcome are clear.
- [ ] DoD is explicit, testable, and specific; no duplicated criteria, invented
      commitments, or unnecessary implementation instructions remain.
- [ ] Context is self-contained, links are meaningful, and unresolved decisions
      are questions rather than hidden assumptions.
- [ ] The write matches authorization and preserves unrelated existing content.
