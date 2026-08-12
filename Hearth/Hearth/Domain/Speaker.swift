/// Who is speaking in a conversation turn, named for the people rather than screen positions.
/// The resident faces the top (rotated) pane; the worker faces the bottom pane.
enum Speaker: Sendable, Equatable, Hashable {
    case resident
    case worker
}
