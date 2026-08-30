# Flutter UI Rules

## General

- Follow the existing project architecture.
- Modify only the requested files.
- Do not create unnecessary files or folders.
- Reuse existing widgets before creating new ones.
- Do not change the project structure unless explicitly requested.
- Do not add new packages unless explicitly requested.
- Do not add business logic when only UI implementation is requested.

## Build Context

At the beginning of every `build` method, declare:

```dart
final color = context.colorScheme;
final locale = context.localization;
```

Use these variables throughout the widget.

Do not declare either variable when it is genuinely unused in that specific `build` method. Never keep unused variables only to satisfy a convention.

## Colors

- Always obtain UI colors from `color`.
- Never use `Colors.*`.
- Never use `Color(...)` or hexadecimal color literals inside UI files.
- Never hardcode colors.
- Never use `AppColors` directly inside widgets.
- If a required semantic color is missing, report that a new theme color is required instead of inventing or hardcoding one.

## Localization

- Always obtain user-facing text from `locale`.
- Never hardcode user-facing text.
- If a localization key is missing, report that a new localization key is required instead of hardcoding a fallback.
- The implementation must support every locale configured in the application, not only Arabic and English.
- Never write locale checks such as `languageCode == 'ar'` to control layout direction.
- Never maintain manual lists of RTL or LTR languages.
- Layout direction must come from Flutter's inherited `Directionality` and the application's localization configuration.

## Text Styles

Always use the existing styles from:

```text
lib/config/theme/styles_manager.dart
```

- Never create a new `TextStyle` directly inside a widget.
- Use `copyWith()` only when the design requires a supported variation.
- Do not use `copyWith()` to recreate a style that should already exist in the style manager.
- If a required style is missing, add it to `styles_manager.dart` only when that file is within the requested scope. Otherwise, stop and report the missing style.

## Spacing

Always use spacing values from:

```text
lib/config/theme/spacing.dart
```

- Never hardcode spacing values.
- Use existing spacing constants for `Padding`, `SizedBox`, `Gap`, margins, and `EdgeInsets`.
- Do not introduce a new spacing constant unless the exact value is confirmed from Figma and no existing constant matches it.

## EdgeInsets

- Use `EdgeInsets.symmetric()` when opposite sides have equal values.
- Use `EdgeInsetsDirectional.only()` when spacing is related to `start` or `end`.
- Use `EdgeInsets.only()` only when spacing is physically fixed to `top`, `bottom`, `left`, or `right` in both LTR and RTL.
- Use `EdgeInsets.all()` when all sides have the same value.
- Avoid `EdgeInsets.fromLTRB()` unless it is the only correct representation of the Figma design.
- Keep every padding value consistent with `lib/config/theme/spacing.dart`.

Preferred:

```dart
EdgeInsets.symmetric(
  horizontal: Spacing.md,
  vertical: Spacing.sm,
)

EdgeInsetsDirectional.only(
  start: Spacing.md,
  end: Spacing.sm,
)

EdgeInsets.only(
  top: Spacing.md,
  bottom: Spacing.lg,
)

EdgeInsets.all(Spacing.md)
```

Avoid:

```dart
EdgeInsets.fromLTRB(
  Spacing.md,
  Spacing.sm,
  Spacing.md,
  Spacing.sm,
)
```

## Widget Files

- Every custom widget must be placed in its own separate file.
- Keep exactly one widget class per file.
- This rule applies to public and private widgets.
- Never create private widget classes such as `_Header`, `_Card`, `_Item`, `_Tile`, `_Button`, `_Logo`, or `_MetaChip` inside another widget file.
- Even if a widget is used only once, place it in its own file.
- Place feature-specific widgets inside the appropriate `widgets/` folder.
- The parent screen or parent widget should only compose and organize child widgets.
- Reuse existing widgets before creating new widgets.
- Do not duplicate an existing widget.
- Do not extract simple layout fragments into separate widgets unless they are actual custom UI components. Normal Flutter widgets such as `Row`, `Column`, `Padding`, `Expanded`, `Flexible`, `Spacer`, and `Wrap` may be composed directly in the parent.

## Row and Column

- Use `Row` and `Column` normally when they are the simplest correct implementation.
- Do not replace a straightforward `Row` or `Column` with `Stack`, `Wrap`, `LayoutBuilder`, `CustomMultiChildLayout`, or another complex layout without a real design requirement.
- Use `Expanded`, `Flexible`, and `Spacer` only when they express the required layout behavior.
- Do not add `Expanded` or `Flexible` automatically when the child does not need to share or constrain available space.
- Do not reverse `Row.children` manually for any language.
- Do not change `mainAxisAlignment` or child order based on a locale code.
- Allow Flutter's inherited text direction and directional properties to handle locale direction.

## Constraints and Sizing

- Do not use `ConstrainedBox`, `BoxConstraints`, `SizedBox` with fixed dimensions, or `LayoutBuilder` without a demonstrated layout requirement.
- Do not add constraints defensively or only to silence an overflow without understanding its cause.
- Prefer natural child sizing and standard `Row`/`Column` layout.
- Use `Expanded`, `Flexible`, or `Wrap` when content should adapt to available space.
- Fixed width or height is allowed only when Figma explicitly defines it or the component requires it, such as an icon, avatar, or fixed control.
- Never guess `minWidth`, `maxWidth`, `minHeight`, or `maxHeight` values.
- Avoid deeply nested sizing widgets that do not change the final layout.

## Responsive UI

- Build responsive layouts that preserve the Figma design across supported screen sizes.
- Avoid fixed screen-level widths and heights unless Figma explicitly requires them.
- Prefer `Row`, `Column`, `Expanded`, `Flexible`, `Spacer`, and `Wrap` for normal responsive composition.
- Use `LayoutBuilder` only when the layout must react to the parent's actual constraints.
- Use `MediaQuery.sizeOf(context)` only when the layout genuinely depends on the screen size.
- Do not read the complete `MediaQuery.of(context)` object when only size or padding is needed.
- Do not introduce arbitrary breakpoints. Use only existing project breakpoints or exact breakpoints defined by the design.

## RTL and LTR

The application supports multiple languages. Direction must never be inferred from a specific language.

- Use the direction supplied by `Directionality.of(context)` when direction must be inspected.
- Prefer directional Flutter APIs such as:
  - `EdgeInsetsDirectional`
  - `AlignmentDirectional`
  - `BorderRadiusDirectional`
  - `PositionedDirectional`
  - `TextAlign.start`
  - `TextAlign.end`
- Use `start` and `end` for logical placement.
- Use physical `left` and `right` only when the Figma design requires the element to remain on the same physical side in every text direction.
- Never check the language code to decide RTL or LTR.
- Never force `TextDirection` unless explicitly requested by the design or required for isolated content with a known direction.
- Never reverse a `Row`, list, or collection manually based on locale.
- Never mirror assets manually unless Figma explicitly specifies that the asset itself must mirror.
- The same implementation must work with all configured RTL and LTR locales.
- Judge the final rendered result in both directions. Directional APIs are preferred, but the final rendering must remain faithful to Figma.

## Rebuild Performance

- Use `const` constructors and `const` widget instances whenever all arguments are compile-time constants.
- Keep state as close as possible to the smallest widget that needs it.
- Do not call `setState()` for values that have not changed.
- Do not rebuild an entire screen when only a small section depends on changing state.
- With Bloc/Cubit, use existing `BlocSelector`, `buildWhen`, or equivalent project patterns to rebuild only the affected UI.
- With other state-management solutions, use the project's existing selective-listening mechanism rather than watching the entire state unnecessarily.
- Do not introduce a new state-management approach.
- Do not perform calculations, sorting, filtering, parsing, object creation, or data transformation repeatedly inside `build` when the result can be prepared outside it safely.
- Do not create controllers, focus nodes, animations, streams, futures, keys, or notifiers inside `build`.
- Dispose of owned controllers, focus nodes, animations, and listeners correctly.
- Avoid unnecessary wrapper widgets that do not affect layout, semantics, styling, or behavior.
- Do not use performance optimizations blindly. Apply them only when they preserve correctness and follow the existing architecture.

## UI Implementation Rules

- Figma is the single source of truth.
- Never redesign, improve, simplify, or reinterpret the UI unless explicitly requested.
- Never add behavior or business logic that is not shown or requested.
- Never swap physical sides manually.
- Never guess any design value.
- If a required detail cannot be verified, stop and ask for the missing information before implementing that part.

## Code Quality

- Use `const` whenever possible.
- Keep widgets small and readable.
- Remove unused imports.
- Remove unused variables.
- Remove unused methods.
- Remove unused classes.
- Do not add unnecessary comments.
- Do not add placeholder or dummy code.
- Do not create helper methods without a functional purpose.
- Do not add new packages unless explicitly requested.
- Preserve the project's naming conventions, folder structure, architecture, and state-management patterns.
- Run the existing formatter and relevant analyzer or tests after implementation when available.

## Before Creating Anything

Always inspect the project for an existing:

- Reusable widget
- Text style
- Spacing constant
- Localization key
- Theme color
- Asset
- Helper or extension
- Responsive utility or breakpoint
- Existing state-management selector or optimization pattern

Reuse existing code whenever possible.

## Fake Data Models

- Any image that will later come from the backend must be a field in the corresponding model or entity.
- Store the image asset path in the fake data source as part of the model.
- Store fake asset paths using `AssetsFake`.
- Widgets must read the image path from the model.
- Never hardcode asset paths directly inside widgets.
- If the model does not contain an image field, add one only when the model file is within the requested scope. Otherwise, stop and report the required model change.

Example:

```dart
HomeMealEntity(
  title: locale.homeMealTitle,
  imageAsset: AssetsFake.homeOatmeal,
)

HomeCategoryEntity(
  title: locale.homeCategoryTitle,
  imageAsset: AssetsFake.homeBurger,
)
```

In the UI:

```dart
Image.asset(meal.imageAsset)
```

Never do this directly inside a widget:

```dart
Image.asset(AssetsFake.homeOatmeal)
```

## Figma Rules

- Figma is the single source of truth.
- Implement the design exactly as it appears in Figma.
- Always inspect the exact Figma node before implementing.
- Never implement from a screenshot when the Figma node is available.
- Never guess measurements, colors, typography, spacing, dimensions, border radii, shadows, or icon sizes.
- Use the exact verified values from Figma and map them to the project's existing theme, styles, spacing, and assets.
- Never adjust spacing or alignment manually to make it look better.
- Never change the intended widget hierarchy or interaction behavior unless explicitly requested.
- If any detail is unclear, inspect the Figma properties instead of assuming.
- The final Flutter UI must match Figma as closely as possible, pixel by pixel.
- If the implementation differs from Figma, Figma is correct.
- If an exact Figma value conflicts with the existing design tokens, stop and report the conflict instead of hardcoding a value.
- Do not override verified Figma typography with an arbitrary minimum font size. If readability is a concern, report it and ask before changing the design.

## Validation Before Completion

Before reporting completion:

- Confirm that the requested Figma node was inspected.
- Confirm that only requested files were modified.
- Confirm that existing widgets, styles, spacing, colors, localization keys, and assets were checked first.
- Confirm that no user-facing text, colors, spacing, asset paths, or unverified dimensions were hardcoded.
- Confirm that the UI works with inherited RTL and LTR direction without language-specific checks.
- Confirm that no child collection is manually reversed for localization.
- Confirm that unnecessary constraints and layout wrappers were not added.
- Confirm that rebuild scope is limited appropriately.
- Confirm that there are no unused imports, variables, methods, or classes.
- Run formatting, analysis, and relevant tests when available.

## Critical Stop Rule

If any required step cannot be completed, stop and ask before continuing.

Do not:

- Assume values.
- Invent implementations.
- Redesign the UI.
- Skip a requirement.
- Continue with a workaround without approval.
- Claim that Figma was inspected when it was not accessible.
- Claim pixel-perfect completion without validating the rendered result.

Explain the exact blocker and ask for the specific information or access required.
