Constructors HTML Gating — Pre-Cutover Snapshot
===============================================

Captured during the 2026-08-22 semantic site-construction migration.

Purpose
-------
HTML Cutover 0A removed semantic environment gating from HTML serialization.

This directory preserves the old Constructors-side call chain so later
`webs*` migration can directly inspect what existed before the semantic
projection/rendering redesign.

Preserved areas
---------------
- RenderBundle.ExportAPI.DocumentAPI.HTMLAPI
- DocumentEvaluationOptions
- DocumentDeclaration
- SiteDocumentDefinition
- SiteObject bundle export adapters
- HTMLScopeSelector
- legacy RenderEngine page builder
- legacy RenderEngine snippet builder
- SnippetTargets / renderInlineHTML
- GateTally
- GateTallySink

Old model
---------
BuildEnvironment
    ↓
Constructors rendering API
    ↓
HTMLDocument.render(environment:onGate:)
    ↓
HTMLGate
    ↓
GateEvent
    ↓
GateTally

Replacement direction
---------------------
Declaration
    ↓
Resolution
    ↓
SiteProjection(BuildEnvironment)
    ↓
Rendering
    ↓
HTMLDocument
    ↓
serialization-only HTML rendering
    ↓
Materialization

This directory is migration-reference material only.
