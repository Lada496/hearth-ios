/// Who is speaking in a conversation turn. Replaces the prototype's `"top"`/`"bottom"`
/// string union (`reference/frontend/types.ts`) with names tied to the physical layout:
/// the resident faces the top (rotated) pane, the worker faces the bottom pane.
enum Speaker: Sendable, Equatable, Hashable {
    case resident
    case worker
}
