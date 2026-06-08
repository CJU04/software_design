# TODO

## Inventory Log bottom overflow fix
- [ ] Replace `InventoryLogsScreen` body layout with `SafeArea` + `CustomScrollView` using `SliverToBoxAdapter` (search) and `SliverList` (items) to prevent bottom `RenderFlex overflow`.
- [ ] Verify no bottom overflow by running the app and navigating to Inventory Logs.
- [ ] Run `flutter analyze` (or at least ensure no analyzer errors are introduced).

