# Account Status Feature Design

## Goal

Build the account status UI from the provided Figma nodes for accepted, rejected, more-information-required, and under-review states.

## Figma Sources

- `2023:5401` - `03.04 - Account Accepted`
- `2023:5414` - `03.03 - Application Rejected`
- `2023:5440` - `03.02 - More Information Required`
- `1522:13201` - `03.01 - Application Under Review`

## Scope

The feature is UI-only. It uses fake/static state data and callbacks supplied by the screen. It does not add backend calls, persistence, authentication logic, or new packages.

## Architecture

Create `lib/features/account_status/` with a small domain model and focused presentation widgets. The state model selects localized copy, the exported illustration asset, optional reason panel data, and available actions. One screen composes these pieces and can be instantiated for any account status state.

Routing adds a single account status route. The route defaults to the under-review state unless route arguments provide another state.

## UI Requirements

- Use `context.colorScheme` and `context.localization` at the start of build methods when needed.
- Use existing spacing constants where values match, and add account-status-specific spacing constants only for Figma-verified values.
- Use existing text style helpers from `styles_manager.dart`; do not create inline `TextStyle`.
- Use user-facing strings only from localization.
- Use directional layout APIs and inherited text direction.
- Do not add new packages.
- Export the Figma illustrations as local PNG assets under `assets/images/auth/` and reference them through `AppAssets`.
- Use `AuthHeaderLogo.compact` for the top logo because it matches the Figma compact logo asset and size.

## States

Accepted:
- Title: account accepted.
- Body: account activated successfully, user can start work.
- Illustration: accepted node image.
- Actions: start work, back to login.
- No reason panel.

Rejected:
- Title: application rejected.
- Body: rejected request with direction to review reasons and resubmit.
- Illustration: rejected node image.
- Reason panel with three rejection reasons.
- Actions: resubmit, back to login.

More information required:
- Title: data changes required.
- Body: update listed data and resend request.
- Illustration: more-information node image.
- Reason panel with two edit reasons.
- Actions: edit and resend, back to login.

Under review:
- Header title/subtitle with shield icon.
- Large review card containing the review illustration, status chip, title, body, and notification note.
- Help card with support action.
- Bottom trust note.
- No primary bottom actions.

## Theme Requirements

Existing `ColorScheme` values cover white surface, primary purple, primary container, warning, error, and text colors. Figma-specific account status surfaces and borders should be mapped through theme colors, not hardcoded in widgets. If the exact values are not already represented, add them to `AppColors` and expose them through existing `ColorScheme` slots only where semantically appropriate.

## Testing

Add widget tests that render:
- accepted state with both action buttons,
- rejected state with three reason items,
- more-information-required state with two reason items,
- under-review state with its header, status title, help card, and trust note,
- route generation defaulting to under-review.

Tests should use `MaterialApp` with existing localization delegates and theme.
